class Chapter {
  final String title;
  final Duration startTime;
  final Duration duration;

  Chapter({
    required this.title,
    required this.startTime,
    required this.duration,
  });

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  String get formattedStartTime {
    final minutes = startTime.inMinutes;
    final seconds = startTime.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
