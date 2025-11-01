# RPC Games - Features & Implementation Details

## Core Features

### 1. Process Detection System
- **Real-time monitoring** of Windows processes using `tasklist` command
- **Configurable polling interval** (default: 5 seconds)
- **Efficient change detection** - only updates when processes change
- **Case-insensitive matching** for process names
- **CSV parsing** for accurate process name extraction

### 2. Discord Rich Presence Integration
- **Direct IPC communication** with Discord via Named Pipes
- **Custom status messages** with support for:
  - Details (first line)
  - State (second line)
  - Large image with text
  - Small image with text (optional)
  - Automatic elapsed time tracking
- **Reconnection handling** when Discord restarts
- **Clean shutdown** to clear presence on exit

### 3. Game Profile Management
- **CRUD operations** for game profiles:
  - Create new profiles
  - Edit existing profiles
  - Delete profiles
  - Enable/Disable profiles
- **Profile properties**:
  - Display name
  - Process name (.exe)
  - Icon URL or asset name
  - Custom details text
  - Custom state text
  - Enabled/disabled flag
- **Persistent storage** using SharedPreferences
- **UUID-based identification** for each profile

### 4. User Interface

#### Main Screen
- **Status bar** showing:
  - Discord connection status
  - Current monitoring state
  - Currently detected game
  - Start/Stop button
- **Game list** with:
  - Visual indicators for enabled/disabled
  - Running process badges
  - Edit/Delete/Toggle actions
  - Empty state guidance

#### Add/Edit Game Dialog
- **Form validation** for required fields
- **Process browser** showing currently running processes
- **Quick-add** from process list
- **Image URL or asset name** support
- **Optional fields** for custom text

#### Settings Dialog
- **Discord Client ID** configuration
- **Auto-start** toggle for monitoring
- **Inline instructions** for Discord setup
- **Tips and tricks** panel

### 5. Data Persistence
- **Local storage** using SharedPreferences
- **JSON serialization** for game profiles
- **Settings preservation**:
  - Discord Client ID
  - Auto-start preference
  - All game profiles
- **Data migration** safe (uses structured JSON)

### 6. State Management
- **Provider pattern** for reactive updates
- **Centralized AppState** managing:
  - Game profiles list
  - Discord connection status
  - Monitoring state
  - Running processes
  - Current game detection
- **Automatic UI updates** when state changes

## Technical Implementation

### Architecture

```
lib/
├── main.dart                      # App entry point
├── models/
│   └── game_profile.dart          # Data model for games
├── providers/
│   └── app_state.dart             # Central state management
├── screens/
│   ├── home_screen.dart           # Main UI
│   ├── add_game_dialog.dart       # Game form
│   └── settings_dialog.dart       # Settings UI
└── services/
    ├── discord_rpc_service.dart   # Discord communication
    ├── process_monitor.dart       # Process detection
    └── storage_service.dart       # Data persistence
```

### Key Technologies

- **Flutter 3.9.2+**: UI framework
- **Provider**: State management
- **SharedPreferences**: Local storage
- **Windows tasklist**: Process enumeration
- **Discord IPC**: Named pipes communication

### Discord RPC Protocol

The app implements Discord's RPC protocol:

1. **Handshake**: Send client ID to establish connection
2. **SET_ACTIVITY**: Update Rich Presence status
3. **CLEAR_ACTIVITY**: Remove Rich Presence
4. **Opcode system**: Binary protocol for message types

Message format:
```
[opcode (1 byte)][length (4 bytes)][json payload]
```

### Process Monitoring

Uses Windows `tasklist` command:
```bash
tasklist /FO CSV /NH
```

Advantages:
- No elevated privileges required
- Works on all Windows versions
- Reliable and fast
- Easy to parse (CSV format)

### Data Models

#### GameProfile
```dart
{
  id: string (UUID)
  processName: string
  displayName: string
  iconUrl: string?
  largeImageKey: string?
  largeImageText: string?
  smallImageKey: string?
  smallImageText: string?
  details: string?
  state: string?
  enabled: boolean
}
```

## User Experience Features

### Visual Feedback
- ✅ Connection status indicators
- ✅ Running process badges
- ✅ Enabled/disabled visual states
- ✅ Current game highlighting
- ✅ Empty state messages
- ✅ Loading states
- ✅ Error messages via SnackBars

### Usability
- 🎯 One-click process selection
- 🎯 In-app process browser
- 🎯 Quick enable/disable toggle
- 🎯 Confirmation dialogs for destructive actions
- 🎯 Keyboard-friendly forms
- 🎯 Clear labeling and hints

### Accessibility
- 📱 Material Design 3 compliance
- 📱 Light and dark theme support
- 📱 Responsive layouts
- 📱 Clear visual hierarchy
- 📱 Descriptive tooltips

## Performance Optimizations

### Efficient Updates
- Only update Discord when game changes
- Debounced process checking (configurable interval)
- Set comparison to detect changes
- Lazy loading of settings

### Resource Management
- Proper disposal of timers
- Connection cleanup on exit
- Memory-efficient process lists
- No unnecessary rebuilds (Provider selectors)

### Background Operations
- Non-blocking process enumeration
- Async/await for I/O operations
- Timer-based polling (not continuous)

## Security & Privacy

### Data Safety
- ✅ All data stored locally
- ✅ No telemetry or analytics
- ✅ No network requests (except Discord IPC)
- ✅ No sensitive data collection
- ✅ Process names never leave machine

### Permissions
- Requires: Read process list
- Does NOT require: Admin rights (unless Discord does)
- No registry modifications
- No system file access

## Future Enhancement Ideas

### Potential Features
- [ ] Hot reload detection (faster than 5s)
- [ ] Multiple Discord accounts
- [ ] Import/export profiles
- [ ] Profile templates
- [ ] Cloud sync (optional)
- [ ] Tray icon with quick actions
- [ ] Process priority detection
- [ ] Window title detection
- [ ] Activity history log
- [ ] Statistics tracking
- [ ] Scheduled profiles
- [ ] Webhook notifications

### UI Improvements
- [ ] Drag-and-drop profile reordering
- [ ] Search/filter in process list
- [ ] Bulk enable/disable
- [ ] Profile groups/categories
- [ ] Custom themes
- [ ] Keyboard shortcuts
- [ ] Profile duplicating

### Technical Enhancements
- [ ] Native process monitoring (FFI)
- [ ] Better error recovery
- [ ] Automatic Discord detection
- [ ] Multiple client IDs
- [ ] Plugin system
- [ ] API for external control

## Known Limitations

### Current Constraints
1. **Windows only** - Uses Windows-specific APIs
2. **Polling-based** - 5-second default interval (configurable)
3. **Single Discord account** - One client ID at a time
4. **Process name only** - Cannot detect by window title
5. **No multi-instance** - First match wins for same process
6. **Manual setup required** - Need to create Discord app

### Technical Limitations
1. Discord IPC pipe connection can be unstable
2. Large process lists may impact performance
3. Image URLs must be publicly accessible
4. Discord has rate limits for presence updates
5. Requires Discord desktop client (not web)

## Testing Recommendations

### Manual Testing Checklist
- [ ] Add game profile
- [ ] Edit game profile
- [ ] Delete game profile
- [ ] Enable/disable profile
- [ ] Start monitoring
- [ ] Stop monitoring
- [ ] Discord connection
- [ ] Process detection
- [ ] Rich Presence update
- [ ] Icon display
- [ ] Auto-start on launch
- [ ] Settings persistence
- [ ] Multiple profiles
- [ ] Empty states
- [ ] Error handling

### Edge Cases
- Discord not running
- Invalid client ID
- Process name typos
- Network issues
- Rapid process start/stop
- Multiple instances of same process
- Very long profile lists
- Invalid image URLs

## Debugging Tips

### Common Issues

**Discord not connecting:**
- Check Discord is running
- Verify client ID is correct
- Try restarting Discord
- Check Windows Firewall

**Process not detected:**
- Verify exact process name
- Check process is running (Task Manager)
- Try stopping/starting monitoring
- Check spelling and .exe extension

**Icon not showing:**
- Verify URL is publicly accessible
- Check asset name spelling
- Wait for Discord cache update
- Try different image format

### Logging

The app includes debug logging for:
- Discord connection attempts
- RPC message sending
- Process monitoring cycles
- State changes
- Error conditions

View logs in VS Code Debug Console when running in debug mode.

## Contributing Guidelines

### Code Style
- Follow Dart style guide
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused
- Use const constructors where possible

### Pull Request Process
1. Create feature branch
2. Implement feature/fix
3. Test thoroughly
4. Update documentation
5. Submit PR with description

### Reporting Issues
Include:
- Windows version
- Flutter version
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots if applicable

---

**Built with Flutter for the Windows desktop gaming community! 🎮**
