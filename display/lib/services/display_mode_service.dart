import 'dart:async';
import 'dart:ui';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'shared_data.dart';
import 'prayer_times_service.dart';

enum DisplayMode { normal, silence, prohibited }

class DisplayModeService {
  DisplayMode mode = DisplayMode.normal;
  DateTime? silenceEndTime;
  DateTime? prohibitedEndTime;

  Timer? _silenceTimer;
  Timer? _prohibitedTimer;
  VoidCallback? _onModeChanged;

  List<String> _iqamahTimes = [];
  String _sunriseTime = '';
  String _sunsetTime = '';
  List<Map<String, String>> _prayersList = [];

  String get sunriseTime => _sunriseTime;
  String get sunsetTime => _sunsetTime;
  List<Map<String, String>> get prayersList => _prayersList;

  void setOnModeChanged(VoidCallback callback) {
    _onModeChanged = callback;
  }

  Future<void> fetchPrayerData() async {
    try {
      final data = await PrayerTimesService().fetchPrayerTimes();
      if (data == null) return;
      _prayersList = (data['prayers'] as List).map((p) => {
        'name': p['name'] as String,
        'start': p['adhan'] as String,
        'iqamah': p['iqamah'] as String,
      }).toList();
      _sunriseTime = data['sunrise'] as String;
      _sunsetTime = data['sunset'] as String;
    } catch (e) {
      print('Error fetching prayer data: $e');
    }
  }

  Future<void> fetchIqamahTimes() async {
    try {
      final response = await Supabase.instance.client
          .from('prayer_times')
          .select('prayer, iqamah');
      final now = DateTime.now();
      final isFriday = now.weekday == DateTime.friday;
      final times = <String>[];
      for (final row in response as List) {
        final prayer = row['prayer'] as String;
        if (isFriday && prayer == 'zuhr') continue;
        if (prayer.startsWith('jummah')) continue;
        times.add(row['iqamah'] as String);
      }
      _iqamahTimes = times;
      await SharedData.instance.refreshIqamah();
    } catch (e) {
      print('Error fetching iqamah times: $e');
    }
  }

  /// Schedule the next silence screen. Calculates exact time until next iqamah,
  /// fires once, shows silence for 15 min (or 45 for jumu'ah), then reschedules.
  void scheduleSilence() {
    _silenceTimer?.cancel();
    final now = DateTime.now();

    // If currently in silence mode, schedule exit
    if (mode == DisplayMode.silence && silenceEndTime != null) {
      final remaining = silenceEndTime!.difference(now);
      if (remaining.isNegative) {
        mode = DisplayMode.normal;
        silenceEndTime = null;
        _onModeChanged?.call();
        scheduleSilence();
      } else {
        _silenceTimer = Timer(remaining, () {
          mode = DisplayMode.normal;
          silenceEndTime = null;
          _onModeChanged?.call();
          scheduleSilence();
        });
      }
      return;
    }

    // Find next iqamah time
    final upcoming = <DateTime>[];

    for (final iqamah in _iqamahTimes) {
      final dt = _parseTimeToday(iqamah);
      if (dt != null && dt.isAfter(now)) upcoming.add(dt);
    }

    // Friday jumu'ah
    if (now.weekday == DateTime.friday) {
      final jummahTime = SharedData.instance.jummah;
      if (jummahTime.isNotEmpty) {
        final jDt = _parseTimeToday(jummahTime);
        if (jDt != null && jDt.isAfter(now)) upcoming.add(jDt);
      }
    }

    if (upcoming.isEmpty) return;
    upcoming.sort();
    final next = upcoming.first;
    final delay = next.difference(now);

    _silenceTimer = Timer(delay, () {
      // Determine duration: 45 min for jumu'ah on Friday, 15 min otherwise
      final isFridayJummah = now.weekday == DateTime.friday &&
          SharedData.instance.jummah.isNotEmpty &&
          _parseTimeToday(SharedData.instance.jummah) == next;
      final duration = isFridayJummah ? 45 : 15;

      mode = DisplayMode.silence;
      silenceEndTime = DateTime.now().add(Duration(minutes: duration));
      _onModeChanged?.call();
      scheduleSilence(); // This will now schedule the exit
    });
  }

  /// Schedule the next prohibited time screen. Calculates exact time until
  /// next prohibited window, fires once, shows for duration, then reschedules.
  void scheduleProhibited() {
    _prohibitedTimer?.cancel();
    final now = DateTime.now();

    // If currently in prohibited mode, schedule exit
    if (mode == DisplayMode.prohibited && prohibitedEndTime != null) {
      final remaining = prohibitedEndTime!.difference(now);
      if (remaining.isNegative) {
        mode = DisplayMode.normal;
        prohibitedEndTime = null;
        _onModeChanged?.call();
        scheduleProhibited();
      } else {
        _prohibitedTimer = Timer(remaining, () {
          mode = DisplayMode.normal;
          prohibitedEndTime = null;
          _onModeChanged?.call();
          scheduleProhibited();
        });
      }
      return;
    }

    // Build list of prohibited windows: (start, end)
    final windows = <List<DateTime>>[];
    final sunriseDt = _parseTimeToday(_sunriseTime);
    final sunsetDt = _parseTimeToday(_sunsetTime);

    if (sunriseDt != null) {
      windows.add([sunriseDt, sunriseDt.add(const Duration(minutes: 15))]);
    }
    if (sunsetDt != null) {
      windows.add([sunsetDt.subtract(const Duration(minutes: 15)), sunsetDt]);
    }

    final dhuhrStart = _prayersList
        .where((p) => p['name'] == 'DHUHR')
        .map((p) => _parseTimeToday(p['start']!))
        .firstOrNull;
    if (dhuhrStart != null) {
      windows.add([dhuhrStart.subtract(const Duration(minutes: 15)), dhuhrStart]);
    }

    // Check if we're currently inside a window
    for (final w in windows) {
      if (now.isAfter(w[0]) && now.isBefore(w[1])) {
        mode = DisplayMode.prohibited;
        prohibitedEndTime = w[1];
        _onModeChanged?.call();
        scheduleProhibited(); // Schedule exit
        return;
      }
    }

    // Find next upcoming window start
    final futureStarts = windows.where((w) => w[0].isAfter(now)).toList();
    if (futureStarts.isEmpty) return;
    futureStarts.sort((a, b) => a[0].compareTo(b[0]));

    final nextWindow = futureStarts.first;
    final delay = nextWindow[0].difference(now);

    _prohibitedTimer = Timer(delay, () {
      mode = DisplayMode.prohibited;
      prohibitedEndTime = nextWindow[1];
      _onModeChanged?.call();
      scheduleProhibited(); // Schedule exit
    });
  }

  void setTestSilence() {
    _silenceTimer?.cancel();
    if (mode == DisplayMode.silence) {
      mode = DisplayMode.normal;
      silenceEndTime = null;
      scheduleSilence();
    } else {
      mode = DisplayMode.silence;
      silenceEndTime = DateTime.now().add(const Duration(hours: 1));
      scheduleSilence();
    }
  }

  void setTestProhibited() {
    _prohibitedTimer?.cancel();
    if (mode == DisplayMode.prohibited) {
      mode = DisplayMode.normal;
      prohibitedEndTime = null;
      scheduleProhibited();
    } else {
      mode = DisplayMode.prohibited;
      prohibitedEndTime = DateTime.now().add(const Duration(minutes: 15));
      scheduleProhibited();
    }
  }

  void exitSpecialMode() {
    mode = DisplayMode.normal;
    silenceEndTime = null;
    prohibitedEndTime = null;
    scheduleSilence();
    scheduleProhibited();
  }

  void dispose() {
    _silenceTimer?.cancel();
    _prohibitedTimer?.cancel();
  }

  DateTime? _parseTimeToday(String time) {
    try {
      final parts = time.split(' ');
      if (parts.length != 2) return null;
      final timeParts = parts[0].split(':');
      var hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      if (parts[1] == 'PM' && hour != 12) hour += 12;
      if (parts[1] == 'AM' && hour == 12) hour = 0;
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (_) {
      return null;
    }
  }
}
