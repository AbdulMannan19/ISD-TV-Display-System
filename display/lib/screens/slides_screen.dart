import 'package:flutter/material.dart';
import 'dart:async';
import '../services/slides_service.dart';

class SlidesScreen extends StatefulWidget {
  const SlidesScreen({super.key});

  @override
  State<SlidesScreen> createState() => _SlidesScreenState();
}

class _SlidesScreenState extends State<SlidesScreen> {
  final SlidesService _slidesService = SlidesService();
  List<Map<String, dynamic>> slides = [];
  int currentSlideIndex = 0;
  bool isLoading = true;
  Timer? _slideTimer;
  final Map<String, ImageProvider> _imageCache = {};

  @override
  void initState() {
    super.initState();
    _loadSlides();
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSlides() async {
    final fetchedSlides = await _slidesService.getActiveSlides();
    if (mounted && fetchedSlides.isNotEmpty) {
      setState(() {
        slides = fetchedSlides;
      });
      
      // Pre-cache all images
      await _precacheAllImages();
      
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        _startSlideRotation();
      }
    } else if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _precacheAllImages() async {
    for (var slide in slides) {
      final imageUrl = slide['image_url'] as String;
      if (!_imageCache.containsKey(imageUrl)) {
        final imageProvider = NetworkImage(imageUrl);
        _imageCache[imageUrl] = imageProvider;
        try {
          await precacheImage(imageProvider, context);
        } catch (e) {
          print('Error precaching image $imageUrl: $e');
        }
      }
    }
  }

  void _startSlideRotation() {
    if (slides.isEmpty) return;

    _slideTimer?.cancel();
    
    final currentDuration = slides[currentSlideIndex]['duration_seconds'] as int? ?? 10;
    
    _slideTimer = Timer(Duration(seconds: currentDuration), () async {
      if (mounted) {
        final nextIndex = (currentSlideIndex + 1) % slides.length;
        final nextImageUrl = slides[nextIndex]['image_url'] as String;
        
        // Ensure next image is cached before switching
        if (!_imageCache.containsKey(nextImageUrl)) {
          final imageProvider = NetworkImage(nextImageUrl);
          _imageCache[nextImageUrl] = imageProvider;
          try {
            await precacheImage(imageProvider, context);
          } catch (e) {
            print('Error precaching next image: $e');
          }
        }
        
        if (mounted) {
          setState(() {
            currentSlideIndex = nextIndex;
          });
          _startSlideRotation();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A2A5E),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (slides.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D3B8C), Color(0xFF051840), Color(0xFF0A2A5E)],
            ),
          ),
          child: const Center(
            child: Text(
              'No active slides',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    final currentSlide = slides[currentSlideIndex];
    final imageUrl = currentSlide['image_url'] as String;
    final cachedImage = _imageCache[imageUrl];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (cachedImage != null)
            Image(
              image: cachedImage,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0D3B8C), Color(0xFF051840), Color(0xFF0A2A5E)],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 64,
                      color: Colors.white54,
                    ),
                  ),
                );
              },
            )
          else
            Container(
              color: const Color(0xFF0A2A5E),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
