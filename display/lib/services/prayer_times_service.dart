import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class PrayerTimesService {
  static const String _masjidalRangeUrl = 'https://masjidal.com/api/v1/time/range';
  static const String _defaultMasjidId = 'O8L7ppA5';

  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> fetchPrayerTimes() async {
    try {
      final masjidId = dotenv.env['MASJIDAL_MASJID_ID']?.trim().isNotEmpty == true
          ? dotenv.env['MASJIDAL_MASJID_ID']!.trim()
          : _defaultMasjidId;
      final url = Uri.parse('$_masjidalRangeUrl?masjid_id=$masjidId');
      final response = await http.get(url);
      if (response.statusCode != 200) return null;

      final decoded = json.decode(response.body) as Map<String, dynamic>;
      if (decoded['status'] != 'success' || decoded['data'] == null) return null;

      final data = decoded['data'] as Map<String, dynamic>;
      final salah = data['salah'];
      if (salah is! List || salah.isEmpty) return null;

      final day = salah.first as Map<String, dynamic>;

      final fajrAdhan = _masjidalTimeTo24(day['fajr'] as String? ?? '');
      final dhuhrAdhan = _masjidalTimeTo24(day['zuhr'] as String? ?? '');
      final asrAdhan = _masjidalTimeTo24(day['asr'] as String? ?? '');
      final maghribAdhan = _masjidalTimeTo24(day['maghrib'] as String? ?? '');
      final ishaAdhan = _masjidalTimeTo24(day['isha'] as String? ?? '');
      final sunrise = _masjidalTimeTo24(day['sunrise'] as String? ?? '');

      if (fajrAdhan.isEmpty ||
          dhuhrAdhan.isEmpty ||
          asrAdhan.isEmpty ||
          maghribAdhan.isEmpty ||
          ishaAdhan.isEmpty ||
          sunrise.isEmpty) {
        return null;
      }

      final hijriMonthName = day['hijri_month'] as String? ?? '';
      final hijriDateRaw = day['hijri_date'] as String? ?? '';
      final hijriParts = _parseHijriDateParts(hijriDateRaw, hijriMonthName);
      final hijriDate = hijriParts.formatted;
      final hijriMonthNum = hijriParts.month;
      final hijriDayNum = hijriParts.day;

      final iqamahTimes = await _fetchIqamahFromDb();
      final fajrIqamah = iqamahTimes['fajr'] ?? _addMinutes(fajrAdhan, 25);
      final dhuhrIqamah = iqamahTimes['zuhr'] ?? _addMinutes(dhuhrAdhan, 19);
      final asrIqamah = iqamahTimes['asr'] ?? _addMinutes(asrAdhan, 19);
      final ishaIqamah = iqamahTimes['isha'] ?? _addMinutes(ishaAdhan, 28);
      final maghribIqamah = iqamahTimes['maghrib'] ?? _addMinutes(maghribAdhan, 10);
      final jummah1 = iqamahTimes['jummah'] ?? '1:45 PM';

      await _updateDbTimes(
        fajrAdhan,
        dhuhrAdhan,
        asrAdhan,
        maghribAdhan,
        ishaAdhan,
        fajrIqamah,
        dhuhrIqamah,
        asrIqamah,
        maghribIqamah,
        ishaIqamah,
      );

      return {
        'date': day['date'] as String? ?? '',
        'prayers': [
          {'name': 'FAJR', 'adhan': _to12(fajrAdhan), 'iqamah': fajrIqamah},
          {'name': 'DHUHR', 'adhan': _to12(dhuhrAdhan), 'iqamah': dhuhrIqamah},
          {'name': 'ASR', 'adhan': _to12(asrAdhan), 'iqamah': asrIqamah},
          {'name': 'MAGHRIB', 'adhan': _to12(maghribAdhan), 'iqamah': maghribIqamah},
          {'name': 'ISHA', 'adhan': _to12(ishaAdhan), 'iqamah': ishaIqamah},
        ],
        'sunrise': _to12(sunrise),
        'sunset': _to12(maghribAdhan),
        'jummah': jummah1,
        'hijriDate': hijriDate,
        'hijriMonth': hijriMonthNum,
        'hijriDay': hijriDayNum,
      };
    } catch (_) {
      return null;
    }
  }

  String _masjidalTimeTo24(String raw) {
    final normalized = _normalizeMasjidalTime(raw);
    if (normalized.isEmpty) return '';
    return _to24(normalized);
  }

  String _normalizeMasjidalTime(String raw) {
    var s = raw.trim();
    if (s.isEmpty) return '';
    s = s.replaceAllMapped(
      RegExp(r'(\d{1,2}:\d{2})\s*(AM|PM)', caseSensitive: false),
      (m) => '${m[1]} ${m[2]!.toUpperCase()}',
    );
    return s;
  }

  ({String formatted, int month, int day}) _parseHijriDateParts(
    String hijriDateRaw,
    String hijriMonthEn,
  ) {
    var day = 1;
    var year = '';
    final comma = hijriDateRaw.split(',');
    if (comma.isNotEmpty) {
      final d = int.tryParse(comma.first.trim());
      if (d != null) day = d;
    }
    if (comma.length > 1) {
      year = comma[1].trim();
    }
    final monthNum = _hijriMonthNumberFromEnglish(hijriMonthEn);
    final formatted = year.isNotEmpty
        ? '$hijriMonthEn $day, $year'
        : '$hijriMonthEn $day';
    return (formatted: formatted, month: monthNum, day: day);
  }

  int _hijriMonthNumberFromEnglish(String en) {
    if (en.isEmpty) return 1;
    final k = en.toLowerCase().replaceAll(RegExp(r"['\u2019]"), '').replaceAll('-', ' ');
    const map = {
      'muharram': 1,
      'safar': 2,
      'rabi al awwal': 3,
      'rabi al thani': 4,
      'rabialawwal': 3,
      'rabialthani': 4,
      'jumada al awwal': 5,
      'jumada al thani': 6,
      'jumada al awula': 5,
      'jumada al akhira': 6,
      'rajab': 7,
      'shaban': 8,
      'sha ban': 8,
      'ramadan': 9,
      'ramadhan': 9,
      'shawwal': 10,
      'dhul qadah': 11,
      'dhu al qidah': 11,
      'dhul hijjah': 12,
      'dhu al hijjah': 12,
      'dhulhijjah': 12,
    };
    for (final e in map.entries) {
      if (k == e.key || k.replaceAll(' ', '') == e.key.replaceAll(' ', '')) {
        return e.value;
      }
    }
    if (k.contains('shawwal')) return 10;
    if (k.contains('ramadan')) return 9;
    return 1;
  }

  Future<Map<String, String>> _fetchIqamahFromDb() async {
    try {
      final response = await _supabase
          .from('prayer_times')
          .select('prayer, iqamah');

      final Map<String, String> times = {};
      for (final row in response as List) {
        times[row['prayer'] as String] = _to12(row['iqamah'] as String);
      }
      return times;
    } catch (_) {
      return {};
    }
  }

  Future<void> _updateDbTimes(
    String fajrA,
    String zuhrA,
    String asrA,
    String maghribA,
    String ishaA,
    String fajrI,
    String zuhrI,
    String asrI,
    String maghribI,
    String ishaI,
  ) async {
    try {
      final rows = [
        {'prayer': 'fajr', 'adhan': fajrA, 'iqamah': _to24(fajrI)},
        {'prayer': 'zuhr', 'adhan': zuhrA, 'iqamah': _to24(zuhrI)},
        {'prayer': 'asr', 'adhan': asrA, 'iqamah': _to24(asrI)},
        {'prayer': 'maghrib', 'adhan': maghribA, 'iqamah': _to24(maghribI)},
        {'prayer': 'isha', 'adhan': ishaA, 'iqamah': _to24(ishaI)},
      ];
      await _supabase.from('prayer_times').upsert(rows);
    } catch (_) {}
  }

  String _addMinutes(String time24, int minutes) {
    final parts = time24.split(':');
    final dt = DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
    final newDt = dt.add(Duration(minutes: minutes));
    final h = newDt.hour > 12 ? newDt.hour - 12 : (newDt.hour == 0 ? 12 : newDt.hour);
    final m = newDt.minute.toString().padLeft(2, '0');
    final p = newDt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $p';
  }

  String _to12(String time) {
    if (time.contains('AM') || time.contains('PM')) return time;
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final p = hour >= 12 ? 'PM' : 'AM';
    return '$h:${minute.toString().padLeft(2, '0')} $p';
  }

  String _to24(String time) {
    if (!time.contains('AM') && !time.contains('PM')) return time;
    final parts = time.replaceAll(RegExp(r'[APM ]'), '').split(':');
    var hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    if (time.contains('PM') && hour != 12) hour += 12;
    if (time.contains('AM') && hour == 12) hour = 0;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
