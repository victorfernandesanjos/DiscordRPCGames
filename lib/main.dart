import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/home_screen.dart';
import 'services/tray_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _trayService = TrayService();
  late AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
    _initializeTray();
  }

  Future<void> _initializeTray() async {
    try {
      await _trayService.initialize(
        onShowWindow: () {
          // Optional: You can add logic when window is shown from tray
        },
        onQuitApp: () {
          // Cleanup before quit
          _appState.dispose();
        },
      );
      await _appState.initialize();
    } catch (e) {
      debugPrint('Failed to initialize tray: $e');
      // Continue without tray if it fails
      await _appState.initialize();
    }
  }

  @override
  void dispose() {
    _trayService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _appState,
      child: MaterialApp(
        title: 'RPC Games - Discord Rich Presence',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueAccent,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueAccent,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
