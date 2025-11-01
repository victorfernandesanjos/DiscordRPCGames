# RPC Games - Custom Discord Rich Presence

A Windows Flutter application that detects running processes and displays custom Rich Presence status on Discord, allowing you to show any game or application with custom icons and text, even if it's not registered in Discord's game library.

## Features

- 🎮 **Process Detection**: Automatically detects running processes on your Windows system
- 🎨 **Custom Icons**: Set custom image URLs for each game/application
- 📝 **Custom Status**: Configure custom details and state text for Rich Presence
- 💾 **Persistent Storage**: Your game profiles are saved locally
- 🔄 **Auto-monitoring**: Optional automatic monitoring on app startup
- 🎯 **Discord Integration**: Direct integration with Discord via IPC (Named Pipes)

## Why Use This App?

When you manually set a custom status on Discord using their official Rich Presence feature, you cannot include custom images unless your application is registered with Discord. This app solves that problem by creating your own Discord application where you can upload custom icons and show them for any running process.

## Setup Instructions

### 1. Create a Discord Application

1. Go to the [Discord Developer Portal](https://discord.com/developers/applications)
2. Click **"New Application"**
3. Give it a name (this will appear in your Rich Presence)
4. Click **"Create"**
5. Copy the **Application ID** (also called Client ID) - you'll need this

### 2. Upload Custom Images (Optional but Recommended)

1. In your Discord Application, go to **"Rich Presence"** → **"Art Assets"**
2. Upload your game/app icons
3. Give each image a name (e.g., "minecraft_icon", "game_logo")
4. You can reference these by name in the app, or use direct URLs

### 3. Install & Configure the App

1. Run the application
2. Click the **Settings** button (gear icon)
3. Paste your Discord **Client ID** (Application ID)
4. Optionally enable **"Auto-start monitoring"**
5. Click **Save**

### 4. Add Games/Applications

1. Click the **"+ Add Game"** button
2. Fill in:
   - **Display Name**: The name to show in Discord (e.g., "Minecraft")
   - **Process Name**: The exact .exe name (e.g., "javaw.exe")
     - Tip: Start monitoring to see a list of running processes
   - **Icon URL**: Either:
     - The name of an asset you uploaded (e.g., "minecraft_icon")
     - A direct URL to an image (e.g., "https://example.com/icon.png")
   - **Details**: First line of status text (optional)
   - **State**: Second line of status text (optional)
3. Click **Add**

### 5. Start Monitoring

1. Ensure Discord is running
2. Click the **"Start"** button
3. Launch your game/application
4. Your custom Rich Presence should appear in Discord!

## Building from Source

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Windows 10/11
- Visual Studio 2022 (for Windows development)

### Build Steps

```bash
# Get dependencies
flutter pub get

# Run in debug mode
flutter run -d windows

# Build release version
flutter build windows --release
```

The executable will be in `build\windows\x64\runner\Release\`

## Troubleshooting

### "Failed to connect to Discord"
- Make sure Discord is running
- Try restarting Discord  
- Check if Discord is running in administrator mode (if so, run this app as admin too)

### "Process not detected"
- Verify the exact process name (including .exe)
- Process names are case-insensitive
- Make sure the process is actually running

### "Icon not showing"
- If using URLs, ensure the image is publicly accessible
- If using Discord assets, verify the asset name is correct (case-sensitive)
- Try uploading the image again in the Discord Developer Portal

## License

This project is open source. Feel free to modify and distribute.

## Disclaimer

This application is not affiliated with Discord Inc. Use at your own risk.
