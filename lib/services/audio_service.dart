import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import '../models/chapter.dart';

class AudioService {
  Future<String> convertToMp3(String inputPath, String outputPath) async {
    try {
      final command = '-i "$inputPath" -vn -ar 44100 -ac 2 -b:a 192k "$outputPath"';
      
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      
      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      } else {
        final output = await session.getOutput();
        throw Exception('FFmpeg conversion failed: $output');
      }
    } catch (e) {
      throw Exception('Failed to convert to MP3: $e');
    }
  }

  Future<List<String>> splitByChapters(
    String inputPath,
    List<Chapter> chapters,
    String outputDir,
    String albumName, {
    Function(int, int)? onProgress,
  }) async {
    try {
      final outputFiles = <String>[];
      
      for (int i = 0; i < chapters.length; i++) {
        final chapter = chapters[i];
        final trackNumber = (i + 1).toString().padLeft(2, '0');
        final fileName = '$trackNumber - ${_sanitizeFileName(chapter.title)}.mp3';
        final outputPath = '$outputDir/$fileName';
        
        // Extract track using FFmpeg
        final startTime = _formatDuration(chapter.startTime);
        final duration = _formatDuration(chapter.duration);
        
        final command = '-i "$inputPath" -ss $startTime -t $duration '
            '-acodec copy '
            '-metadata title="${chapter.title}" '
            '-metadata track="$trackNumber/${chapters.length}" '
            '-metadata album="$albumName" '
            '"$outputPath"';
        
        final session = await FFmpegKit.execute(command);
        final returnCode = await session.getReturnCode();
        
        if (ReturnCode.isSuccess(returnCode)) {
          outputFiles.add(outputPath);
          if (onProgress != null) {
            onProgress(i + 1, chapters.length);
          }
        } else {
          final output = await session.getOutput();
          throw Exception('Failed to split track ${i + 1}: $output');
        }
      }
      
      return outputFiles;
    } catch (e) {
      throw Exception('Failed to split audio: $e');
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _sanitizeFileName(String fileName) {
    // Remove invalid characters for file names
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
