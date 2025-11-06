import 'chapter.dart';

class VideoInfo {
  final String id;
  final String title;
  final String author;
  final Duration duration;
  final String thumbnailUrl;
  final List<Chapter> chapters;

  VideoInfo({
    required this.id,
    required this.title,
    required this.author,
    required this.duration,
    required this.thumbnailUrl,
    required this.chapters,
  });

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  String get cleanTitle {
    // Remove content in brackets and parentheses
    String cleaned = title;
    cleaned = cleaned.replaceAll(RegExp(r'\[.*?\]'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\(.*?\)'), '');
    
    // Replace underscores with hyphens between artist and album
    cleaned = cleaned.replaceAll('_', ' - ');
    
    // Capitalize words
    cleaned = cleaned.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
    
    // Clean up extra spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return cleaned;
  }
}
