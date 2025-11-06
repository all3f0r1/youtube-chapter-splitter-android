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
      
      // Get chapters
      List<Chapter> chapters = [];
      if (video.engagement.chapters.isNotEmpty) {
        for (int i = 0; i < video.engagement.chapters.length; i++) {
          final chapter = video.engagement.chapters[i];
          final nextChapter = i < video.engagement.chapters.length - 1
              ? video.engagement.chapters[i + 1]
              : null;
          
          final duration = nextChapter != null
              ? nextChapter.offset - chapter.offset
              : video.duration! - chapter.offset;
          
          chapters.add(Chapter(
            title: chapter.title,
            startTime: chapter.offset,
            duration: duration,
          ));
        }
      }

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

  void dispose() {
    _yt.close();
  }
}
