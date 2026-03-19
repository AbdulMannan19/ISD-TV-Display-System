import 'package:supabase_flutter/supabase_flutter.dart';

class SlidesService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getActiveSlides() async {
    try {
      final response = await _supabase
          .from('slides')
          .select('id, image_url, display_order, duration_seconds')
          .order('display_order', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching slides: $e');
      return [];
    }
  }

  String getPublicUrl(String imagePath) {
    return _supabase.storage.from('slides').getPublicUrl(imagePath);
  }
}
