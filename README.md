# YouTube Chapter Splitter - Android App

Download YouTube videos and automatically split them into MP3 tracks based on chapters.

## Features

- 🎵 **Automatic Chapter Detection**: Extracts chapters from YouTube videos
- 📱 **Share Integration**: Share YouTube URLs directly from the YouTube app
- 🎨 **Album Artwork**: Downloads and saves video thumbnails as cover.jpg
- 📂 **Smart Folder Names**: Automatically cleans and capitalizes folder names
- ⏱️ **Progress Tracking**: Real-time progress bars for downloads and processing
- 🎧 **ID3 Tags**: Adds proper metadata (title, track number, album) to MP3 files
- 📥 **Downloads Folder**: Saves files directly to your Downloads directory

## How It Works

1. Share a YouTube video URL from the YouTube app or paste it directly
2. The app fetches video information and displays all chapters/tracks
3. Tap "Download & Split" to start the process
4. Files are saved to `Downloads/Artist - Album Name/`
   - `cover.jpg` - Album artwork
   - `01 - Track Name.mp3` - Individual tracks with metadata

## Installation

### Option 1: Download APK from Releases

1. Go to the [Releases page](https://github.com/all3f0r1/youtube-chapter-splitter-android/releases)
2. Download the latest `app-release.apk`
3. Install on your Android device (you may need to enable "Install from Unknown Sources")

### Option 2: Build from Source

#### Prerequisites

- Flutter SDK (3.35.5 or later)
- Android SDK (API 21+)
- Android Studio or VS Code with Flutter extension

#### Steps

```bash
# Clone the repository
git clone https://github.com/all3f0r1/youtube-chapter-splitter-android.git
cd youtube-chapter-splitter-android

# Install dependencies
flutter pub get

# Build APK
flutter build apk --release

# The APK will be at: build/app/outputs/flutter-apk/app-release.apk
```

## Permissions

The app requires the following permissions:

- **Internet**: To download videos from YouTube
- **Storage**: To save MP3 files to your Downloads folder

## Technology Stack

- **Framework**: Flutter 3.24.5
- **YouTube**: youtube_explode_dart (Dart-native, no Python dependencies)
- **Audio Processing**: ffmpeg_kit_flutter_audio
- **State Management**: Provider
- **File Management**: path_provider, permission_handler

## How to Use

### From YouTube App

1. Open a YouTube video with chapters
2. Tap the Share button
3. Select "YouTube Chapter Splitter"
4. The app will open with the URL pre-filled
5. Review the tracks and tap "Download & Split"

### Direct Input

1. Open the app
2. Paste a YouTube URL in the text field
3. Tap "Get Video Info"
4. Review the tracks and tap "Download & Split"

## Example Output

For a video titled "MARIGOLD - Oblivion Gate [Full Album]", the app creates:

```
Downloads/
└── Marigold - Oblivion Gate/
    ├── cover.jpg
    ├── 01 - Oblivion Gate.mp3
    ├── 02 - Obsidian Throne.mp3
    ├── 03 - Crimson Citadel.mp3
    ├── 04 - Silver Spire.mp3
    └── 05 - Eternal Pyre.mp3
```

## Folder Name Cleaning

The app automatically cleans folder names by:

- Removing content in brackets `[]` and parentheses `()`
- Replacing underscores `_` with hyphens `-`
- Capitalizing words
- Removing extra spaces

Example:
- Input: `MARIGOLD - Oblivion Gate [Full Album]`
- Output: `Marigold - Oblivion Gate`

## Limitations

- Only works with YouTube videos that have chapters
- Requires active internet connection
- Video must be publicly accessible (not age-restricted or private)
- youtube_explode_dart may break if YouTube changes their API

## Troubleshooting

### "No chapters found in this video"

The video doesn't have chapters. You can check by looking for timestamps in the video description on YouTube.

### "Storage permission denied"

Go to Settings > Apps > YouTube Chapter Splitter > Permissions and enable Storage.

### "Failed to download audio"

- Check your internet connection
- Make sure the video is publicly accessible
- Try a different video

## Development

### Running in Debug Mode

```bash
flutter run
```

### Building APK Variants

```bash
# Build release APK
flutter build apk --release

# Build debug APK
flutter build apk --debug

# Build APK for specific architecture
flutter build apk --target-platform android-arm64 --release
```

## License

This project is licensed under the MIT License.

## Related Projects

- [YouTube Chapter Splitter (Rust CLI)](https://github.com/all3f0r1/youtube-chapter-splitter) - Desktop version
