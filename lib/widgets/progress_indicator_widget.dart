import 'package:flutter/material.dart';
import '../services/app_state.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final AppState appState;

  const ProgressIndicatorWidget({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    value: appState.state == ProcessState.fetchingInfo
                        ? null
                        : appState.progress,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStateTitle(appState.state),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (appState.statusMessage.isNotEmpty)
                        Text(
                          appState.statusMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (appState.state != ProcessState.fetchingInfo) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: appState.progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                '${(appState.progress * 100).toStringAsFixed(0)}%',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getStateTitle(ProcessState state) {
    switch (state) {
      case ProcessState.fetchingInfo:
        return 'Fetching video information...';
      case ProcessState.downloadingAudio:
        return 'Downloading audio...';
      case ProcessState.convertingAudio:
        return 'Converting to MP3...';
      case ProcessState.splittingTracks:
        return 'Splitting into tracks...';
      case ProcessState.completed:
        return 'Completed!';
      default:
        return '';
    }
  }
}
