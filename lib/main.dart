import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _sharedUrl;

  @override
  void initState() {
    super.initState();
    _handleInitialIntent();
  }

  Future<void> _handleInitialIntent() async {
    try {
      // Get initial intent data (for Share functionality)
      const platform = MethodChannel('app.channel.shared.data');
      final sharedData = await platform.invokeMethod('getSharedText');
      
      if (sharedData != null && sharedData is String) {
        setState(() {
          _sharedUrl = sharedData;
        });
      }
    } catch (e) {
      // No shared data or error
      debugPrint('Error getting shared data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'YouTube Chapter Splitter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF251f5d)),
          useMaterial3: true,
          primaryColor: const Color(0xFF251f5d),
        ),
        home: HomeScreen(initialUrl: _sharedUrl),
      ),
    );
  }
}
