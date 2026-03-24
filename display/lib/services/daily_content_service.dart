import 'package:supabase_flutter/supabase_flutter.dart';
import 'shared_data.dart';

class DailyContentService {
  final String tableName;
  final Map<String, String> _fallback;

  DailyContentService({
    required this.tableName,
    required Map<String, String> fallback,
  }) : _fallback = fallback;

  Future<Map<String, String>> getTodaysContent() async {
    try {
      return await _fetchFromSupabase();
    } catch (_) {
      return _fallback;
    }
  }

  Future<Map<String, String>> _fetchFromSupabase() async {
    final hijriMonth = SharedData.instance.hijriMonth;
    final hijriDay = SharedData.instance.hijriDay;
    final id = (hijriMonth - 1) * 30 + hijriDay;

    final response = await Supabase.instance.client
        .from(tableName)
        .select('text, source')
        .eq('id', id)
        .single();

    return {
      'text': response['text'] as String,
      'source': response['source'] as String,
    };
  }
}
