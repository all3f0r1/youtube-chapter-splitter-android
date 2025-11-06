import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../models/video_info.dart';
import 'youtube_service.dart';
import 'audio_service.dart';

enum ProcessState {
  idle,
  fetchingInfo,
  downloadingAudio,
  convertingAudio,
  splittingTracks,
  completed,
  error,
}

class AppState extends ChangeNotifier {
  final YouTubeService _youtubeService = YouTubeService();
  final AudioService _audioService = AudioService();

  ProcessState _state = ProcessState.idle;
  VideoInfo? _videoInfo;
  String? _errorMessage;
  double _progress = 0.0;
  String _statusMessage = '';
  int _currentTrack = 0;
  int _totalTracks = 0;

  ProcessState get state => _state;
  VideoInfo? get videoInfo => _videoInfo;
  String? get errorMessage => _errorMessage;
  double get progress => _progress;
  String get statusMessage => _statusMessage;
  int get currentTrack => _currentTrack;
  int get totalTracks => _totalTracks;

  Future<void> processUrl(String url) async {
    try {
      // Reset state
      _state = ProcessState.idle;
      _videoInfo = null;
      _errorMessage = null;
      _progress = 0.0;
      notifyListeners();

      // Extract video ID
      final videoId = _youtubeService.extractVideoId(url);
      if (videoId == null) {
        throw Exception('Invalid YouTube URL');
      }

      // Fetch video info
      _state = ProcessState.fetchingInfo;
      _statusMessage = 'Fetching video information...';
      notifyListeners();

      _videoInfo = await _youtubeService.getVideoInfo(videoId);
      
      if (_videoInfo!.chapters.isEmpty) {
        throw Exception('No chapters found in this video');
      }

      notifyListeners();
    } catch (e) {
      _state = ProcessState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> downloadAndSplit() async {
    if (_videoInfo == null) return;

    try {
      // Request permissions
      final status = await _requestPermissions();
      if (!status) {
        throw Exception('Storage permission denied');
      }

      // Get Downloads directory
      final downloadsDir = await _getDownloadsDirectory();
      final outputDir = Directory('${downloadsDir.path}/${_videoInfo!.cleanTitle}');
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }

      // Download thumbnail
      _statusMessage = 'Downloading album artwork...';
      notifyListeners();
      
      final thumbnailPath = '${outputDir.path}/cover.jpg';
      await _youtubeService.downloadThumbnail(_videoInfo!.thumbnailUrl, thumbnailPath);

      // Download audio
      _state = ProcessState.downloadingAudio;
      _statusMessage = 'Downloading audio...';
      _progress = 0.0;
      notifyListeners();

      final tempAudioPath = '${outputDir.path}/temp_audio';
      await _youtubeService.downloadAudio(
        _videoInfo!.id,
        tempAudioPath,
        onProgress: (progress) {
          _progress = progress;
          notifyListeners();
        },
      );

      // Convert to MP3
      _state = ProcessState.convertingAudio;
      _statusMessage = 'Converting to MP3...';
      _progress = 0.0;
      notifyListeners();

      final mp3Path = '${outputDir.path}/temp_audio.mp3';
      await _audioService.convertToMp3(tempAudioPath, mp3Path);

      // Delete original temp file
      await File(tempAudioPath).delete();

      // Split by chapters
      _state = ProcessState.splittingTracks;
      _statusMessage = 'Splitting into tracks...';
      _progress = 0.0;
      _totalTracks = _videoInfo!.chapters.length;
      notifyListeners();

      await _audioService.splitByChapters(
        mp3Path,
        _videoInfo!.chapters,
        outputDir.path,
        _videoInfo!.cleanTitle,
        onProgress: (current, total) {
          _currentTrack = current;
          _progress = current / total;
          _statusMessage = 'Track $current/$total: ${_videoInfo!.chapters[current - 1].title}';
          notifyListeners();
        },
      );

      // Delete temp MP3
      await File(mp3Path).delete();

      // Completed
      _state = ProcessState.completed;
      _statusMessage = 'Completed! Files saved to Downloads/${_videoInfo!.cleanTitle}';
      _progress = 1.0;
      notifyListeners();
    } catch (e) {
      _state = ProcessState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) {
        return true;
      }
      
      final status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }

      // For Android 13+, try media permissions
      if (await Permission.audio.isGranted) {
        return true;
      }
      
      final mediaStatus = await Permission.audio.request();
      return mediaStatus.isGranted;
    }
    return true;
  }

  Future<Directory> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Download');
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  void reset() {
    _state = ProcessState.idle;
    _videoInfo = null;
    _errorMessage = null;
    _progress = 0.0;
    _statusMessage = '';
    _currentTrack = 0;
    _totalTracks = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _youtubeService.dispose();
    super.dispose();
  }
}
