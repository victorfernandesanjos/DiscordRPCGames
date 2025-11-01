import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

/// Service to manage system tray icon and window behavior
class TrayService with TrayListener, WindowListener {
  static final TrayService _instance = TrayService._internal();
  factory TrayService() => _instance;
  TrayService._internal();

  bool _isInitialized = false;
  VoidCallback? _onShowWindow;
  VoidCallback? _onQuitApp;

  bool get isInitialized => _isInitialized;

  /// Initialize system tray and window management
  Future<void> initialize({
    required VoidCallback onShowWindow,
    required VoidCallback onQuitApp,
  }) async {
    if (_isInitialized) return;

    _onShowWindow = onShowWindow;
    _onQuitApp = onQuitApp;

    // Initialize window manager
    await windowManager.ensureInitialized();

    // Configure window options
    const windowOptions = WindowOptions(
      size: Size(900, 700),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'RPC Games',
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    // CRITICAL: Set window to be closable and prevent default close
    await windowManager.setPreventClose(true);

    // Add window listener
    windowManager.addListener(this);

    // Initialize tray
    await _initTray();

    _isInitialized = true;
  }

  /// Initialize system tray icon and menu
  Future<void> _initTray() async {
    try {
      // Set tray icon
      // Note: You'll need to create an icon file (see assets/README.md)
      await trayManager.setIcon(
        Platform.isWindows ? 'assets/app_icon.ico' : 'assets/app_icon.png',
      );
    } catch (e) {
      debugPrint('Warning: Could not set tray icon: $e');
      debugPrint('Please add app_icon.ico to the assets folder (see assets/README.md)');
      // Continue without icon - tray will still work
    }

    // Create tray menu
    final menu = Menu(
      items: [
        MenuItem(
          key: 'show',
          label: 'Show Window',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'quit',
          label: 'Quit',
        ),
      ],
    );

    await trayManager.setContextMenu(menu);
    await trayManager.setToolTip('RPC Games - Discord Rich Presence');

    // Add tray listener
    trayManager.addListener(this);
  }

  /// Show the main window
  Future<void> showWindow() async {
    await windowManager.show();
    await windowManager.focus();
  }

  /// Hide the main window (minimize to tray)
  Future<void> hideWindow() async {
    await windowManager.hide();
  }

  /// Minimize to tray instead of closing
  @override
  Future<void> onWindowClose() async {
    // Prevent window from closing, hide it instead
    debugPrint('Window close requested - minimizing to tray instead');
    await windowManager.hide();
  }

  /// Handle window minimize - optionally hide to tray
  @override
  void onWindowMinimize() async {
    // You can choose to hide to tray on minimize
    // await windowManager.hide();
  }

  /// Tray icon clicked
  @override
  void onTrayIconMouseDown() async {
    await showWindow();
  }

  /// Tray icon right-clicked (shows context menu automatically)
  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  /// Tray menu item clicked
  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'show':
        _onShowWindow?.call();
        await showWindow();
        break;
      case 'quit':
        _onQuitApp?.call();
        // Disable prevent close so app can actually quit
        await windowManager.setPreventClose(false);
        await dispose();
        exit(0);
    }
  }

  /// Clean up resources
  Future<void> dispose() async {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    await trayManager.destroy();
  }
}
