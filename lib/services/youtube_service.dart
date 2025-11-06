import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../models/video_info.dart' as models;
import '../models/chapter.dart';

class YouTubeService {
  final YoutubeExplode _yt = YoutubeExplode();

  String? extractVideoId(String url) {
    try {
      // Clean URL - remove everything after &
      final uri = Uri.parse(url);
      if (uri.queryParameters.containsKey('v')) {
        return uri.queryParameters['v'];
      }
      
      // Try to extract from short URL (youtu.be)
      if (url.contains('youtu.be/')) {
        final id = url.split('youtu.be/')[1].split('?')[0].split('&')[0];
        return id;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<models.VideoInfo> getVideoInfo(String videoId) async {
    try {
      final video = await _yt.videos.get(videoId);
      final streamManifest = await _yt.videos.streamsClient.getManifest(videoId);
      
      // Get chapters from description
      List<Chapter> chapters = _extractChaptersFromDescription(
        video.description,
        video.duration ?? Duration.zero,
      );

      // Get best thumbnail URL
      String thumbnailUrl = video.thumbnails.highResUrl;

      return models.VideoInfo(
        id: video.id.value,
        title: video.title,
        author: video.author,
        duration: video.duration ?? Duration.zero,
        thumbnailUrl: thumbnailUrl,
        chapters: chapters,
      );
    } catch (e) {
      throw Exception('Failed to get video info: $e');
    }
  }

  Future<String> downloadAudio(String videoId, String outputPath, 
      {Function(double)? onProgress}) async {
    try {
      final streamManifest = await _yt.videos.streamsClient.getManifest(videoId);
      
      // Get best audio stream
      final audioStream = streamManifest.audioOnly.withHighestBitrate();
      
      // Download
      final file = File(outputPath);
      final output = file.openWrite();
      final stream = _yt.videos.streamsClient.get(audioStream);
      
      int downloaded = 0;
      final totalSize = audioStream.size.totalBytes;
      
      await for (final data in stream) {
        output.add(data);
        downloaded += data.length;
        
        if (onProgress != null && totalSize > 0) {
          onProgress(downloaded / totalSize);
        }
      }
      
      await output.flush();
      await output.close();
      
      return outputPath;
    } catch (e) {
      throw Exception('Failed to download audio: $e');
    }
  }

  Future<File> downloadThumbnail(String thumbnailUrl, String outputPath) async {
    try {
      final response = await http.get(Uri.parse(thumbnailUrl));
      if (response.statusCode == 200) {
        final file = File(outputPath);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        throw Exception('Failed to download thumbnail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to download thumbnail: $e');
    }
  }

  /// Extract chapters from video description using timestamps
  List<Chapter> _extractChaptersFromDescription(String description, Duration videoDuration) {
    final List<Map<String, dynamic>> tempChapters = [];
    final lines = description.split('\n');
    
    // Regex to match timestamps like "0:00", "1:23", "12:34:56"
    final timestampRegex = RegExp(r'(\d{1,2}):(\d{2})(?::(\d{2}))?');
    
    for (final line in lines) {
      final match = timestampRegex.firstMatch(line);
      if (match != null) {
        // Extract timestamp
        final hours = match.group(3) != null ? int.parse(match.group(1)!) : 0;
        final minutes = match.group(3) != null ? int.parse(match.group(2)!) : int.parse(match.group(1)!);
        final seconds = match.group(3) != null ? int.parse(match.group(3)!) : int.parse(match.group(2)!);
        
        final startTime = Duration(
          hours: hours,
          minutes: minutes,
          seconds: seconds,
        );

        // Extract title (everything after the timestamp)
        var title = line.substring(match.end).trim();
        
        // Remove common prefixes and clean up
        title = title.replaceAll(RegExp(r'^[-–—\s]+'), '');
        title = title.trim();
        
        if (title.isNotEmpty) {
          tempChapters.add({
            'title': title,
            'startTime': startTime,
          });
        }
      }
    }

    // If no chapters found, return empty list
    if (tempChapters.isEmpty) {
      return [];
    }

    // Sort chapters by start time
    tempChapters.sort((a, b) => (a['startTime'] as Duration).compareTo(b['startTime'] as Duration));

    // Calculate duration for each chapter and create Chapter objects
    final List<Chapter> chapters = [];
    for (int i = 0; i < tempChapters.length; i++) {
      final tempChapter = tempChapters[i];
      final nextTempChapter = i < tempChapters.length - 1 ? tempChapters[i + 1] : null;
      
      final startTime = tempChapter['startTime'] as Duration;
      final nextStartTime = nextTempChapter != null ? nextTempChapter['startTime'] as Duration : null;
      
      final duration = nextStartTime != null
          ? nextStartTime - startTime
          : videoDuration - startTime;

      chapters.add(Chapter(
        title: tempChapter['title'] as String,
        startTime: startTime,
        duration: duration,
      ));
    }

    return chapters;
  }

  void dispose() {
    _yt.close();
  }
}
