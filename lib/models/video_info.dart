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
    // Remove everything after (FULL ALBUM) or [FULL ALBUM] (case insensitive)
    String cleaned = title.replaceAll(RegExp(r'(?i)\s*[\[(]full\s+album[\])].*$'), '');
    
    // Remove remaining content in brackets and parentheses
    cleaned = cleaned.replaceAll(RegExp(r'\[.*?\]'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\(.*?\)'), '');
    
    // Replace underscores, pipes and slashes with hyphens
    cleaned = cleaned.replaceAll('_', '-');
    cleaned = cleaned.replaceAll('|', '-');
    cleaned = cleaned.replaceAll('/', '-');
    
    // Clean up multiple spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    
    // Capitalize each word
    cleaned = cleaned.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
    
    // Clean up hyphens and spaces at start/end
    cleaned = cleaned.trim();
    while (cleaned.startsWith('-') || cleaned.endsWith('-')) {
      cleaned = cleaned.replaceAll(RegExp(r'^-+|-+$'), '').trim();
    }
    
    return cleaned;
  }
}
