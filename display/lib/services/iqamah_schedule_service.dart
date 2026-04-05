import 'package:supabase_flutter/supabase_flutter.dart';

class IqamahScheduleService {
  static final _supabase = Supabase.instance.client;

  static const _labels = {
    'fajr': 'Fajr',
    'zuhr': 'Dhuhr',
    'asr': 'Asr',
    'maghrib': 'Maghrib',
    'isha': 'Isha',
  };

  static Future<void> applyScheduledChanges() async {
    try {
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final response = await _supabase
          .from('iqamah_schedule')
          .select('*')
          .lte('effective_date', todayStr);

      final rows = response as List;
      if (rows.isEmpty) return;

      final changes = <String>[];

      for (final row in rows) {
        final prayer = row['prayer'] as String;
        final iqamah = row['iqamah'] as String;
        final id = row['id'];

        await _supabase
            .from('prayer_times')
            .update({'iqamah': iqamah})
            .eq('prayer', prayer);

        changes.add('${_labels[prayer] ?? prayer}: $iqamah');

        await _supabase.from('iqamah_schedule').delete().eq('id', id);
      }

      if (changes.isNotEmpty) {
        final alertText = 'Iqamah time updated — ${changes.join(', ')}';
        final now = DateTime.now().toUtc();
        await _supabase.from('alerts').insert({
          'text': alertText,
          'start_time': now.toIso8601String(),
          'end_time': now.add(const Duration(hours: 24)).toIso8601String(),
        });
      }
    } catch (_) {}
  }

  /// Look ahead to tomorrow's scheduled changes and apply them now.
  /// Called after a prayer's silence ends so the display immediately
  /// shows the next occurrence's iqamah time.
  static Future<void> applyLookaheadChanges() async {
    try {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowStr = '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';

      final response = await _supabase
          .from('iqamah_schedule')
          .select('*')
          .eq('effective_date', tomorrowStr);

      final rows = response as List;
      if (rows.isEmpty) return;

      for (final row in rows) {
        final prayer = row['prayer'] as String;
        final iqamah = row['iqamah'] as String;
        final id = row['id'];

        await _supabase
            .from('prayer_times')
            .update({'iqamah': iqamah})
            .eq('prayer', prayer);

        await _supabase.from('iqamah_schedule').delete().eq('id', id);
      }
    } catch (_) {}
  }
}
