# Quick Start Guide - RPC Games

## What You Need Before Starting

1. **Discord Desktop App** - Must be installed and running
2. **A Discord Application** - Create one at https://discord.com/developers/applications

## Step-by-Step Setup

### Step 1: Create Your Discord Application

1. Visit: https://discord.com/developers/applications
2. Click "New Application"
3. Name it (e.g., "My Custom Games")
4. Click "Create"
5. **IMPORTANT**: Copy the "Application ID" - you'll need this!

### Step 2: Upload Game Icons (Optional)

1. In your Discord Application, go to "Rich Presence" → "Art Assets"
2. Click "Add Image(s)"
3. Upload your game icons (PNG, JPG - minimum 512x512px recommended)
4. Give each a name (e.g., "minecraft", "game_logo")
5. Save

### Step 3: Configure This App

1. Launch the RPC Games application
2. Click the ⚙️ Settings icon (top right)
3. Paste your **Application ID** into "Discord Client ID"
4. (Optional) Enable "Auto-start monitoring" if you want it to start automatically
5. Click "Save"

### Step 4: Add Your First Game

1. Click the **"+ Add Game"** button (bottom right)
2. Fill in the form:

   **Display Name**: `Minecraft` (or whatever you want to show in Discord)
   
   **Process Name**: `javaw.exe` (the actual .exe file - see tips below)
   
   **Icon URL**: Either:
   - Asset name from Step 2: `minecraft`
   - Or full URL: `https://example.com/minecraft.png`
   
   **Details** (optional): `Exploring the world`
   
   **State** (optional): `Survival Mode`

3. Click "Add"

### Step 5: Start Monitoring

1. Make sure Discord is running!
2. Click the **"Start"** button in the status bar
3. Launch your game
4. Check Discord - you should see your Rich Presence! 🎉

## How to Find Process Names

### Method 1: Use This App
1. Click "Start" to begin monitoring
2. Click "+ Add Game"
3. Scroll down and expand "Running Processes"
4. Find your game and click the + icon

### Method 2: Task Manager
1. Open Task Manager (Ctrl+Shift+Esc)
2. Go to "Details" tab
3. Find your application
4. Look at the "Name" column (e.g., `chrome.exe`)

### Method 3: Process Explorer
1. Download from Microsoft Sysinternals
2. Launch your game
3. Find it in Process Explorer
4. The image name is what you need

## Common Process Names

| Application | Process Name |
|------------|--------------|
| Minecraft (Java) | `javaw.exe` |
| Google Chrome | `chrome.exe` |
| VS Code | `Code.exe` |
| Steam | `steam.exe` |
| Discord | `Discord.exe` |
| Spotify | `Spotify.exe` |
| OBS Studio | `obs64.exe` |

## Tips & Tricks

### 🎨 Image Requirements
- Minimum size: 512x512 pixels (recommended: 1024x1024)
- Formats: PNG, JPG, GIF
- Must be publicly accessible if using URLs

### 🔄 Using Discord Assets vs URLs
- **Discord Assets** (uploaded in your app):
  - ✅ Fast and reliable
  - ✅ No external dependencies
  - ✅ Just use the asset name
  
- **Public URLs**:
  - ✅ Easy to change without re-uploading
  - ❌ Must be publicly accessible
  - ❌ Can break if image is removed

### 📝 Status Text Ideas
- **Details**: "Level 45 Mage" / "Building a Castle" / "Ranked Match"
- **State**: "Playing Solo" / "In Party" / "Creative Mode"

### 🎯 Multiple Profiles
- You can add multiple games
- They're monitored simultaneously
- First matching process wins
- Disable profiles you don't want monitored

## Troubleshooting

### ❌ "Failed to connect to Discord"
**Solution:**
- Ensure Discord is running
- Try restarting Discord
- If Discord runs as admin, run this app as admin too
- Check Discord isn't blocked by firewall

### ❌ "Process not detected"
**Solution:**
- Verify exact process name (including .exe)
- Check process is actually running (use Task Manager)
- Process names are case-insensitive but must be exact

### ❌ "Icon not showing"
**Solution:**
- If using asset name: Check spelling (case-sensitive!)
- If using URL: Test the URL in a browser
- Wait a few seconds - Discord can be slow to update
- Try stopping and restarting monitoring

### ❌ "Rich Presence not updating"
**Solution:**
- Stop and start monitoring
- Restart Discord
- Check your game profile is enabled
- Verify the process is actually running

## Advanced Usage

### Custom Application Icons
You can upload multiple assets to your Discord Application:
- **large_image**: Main game icon
- **small_image**: Status indicator (online, afk, etc.)

### Timestamps
The app automatically tracks how long you've been playing. This shows as "Elapsed time" in Discord.

### Multiple Games
If you have multiple games with the same process name (rare), the first matching profile in your list will be used.

## Privacy & Security

- ✅ All data stored locally on your computer
- ✅ No data sent to external servers (except Discord)
- ✅ Process names never leave your machine
- ✅ Open source - you can review the code

## Need Help?

### The app won't start
- Check Windows Event Viewer for errors
- Try running as Administrator
- Reinstall Visual C++ Redistributables

### Discord shows wrong info
- Edit the game profile
- Stop and restart monitoring
- Restart Discord

### Want to reset everything?
- Delete the app data (stored in Windows Registry/SharedPreferences)
- Or just delete and re-add your games

## Example Configurations

### Configuration 1: Minecraft
```
Display Name: Minecraft
Process Name: javaw.exe
Icon URL: minecraft_icon (uploaded asset)
Details: Building in Creative
State: Single Player
```

### Configuration 2: Visual Studio Code
```
Display Name: Coding
Process Name: Code.exe
Icon URL: vscode (uploaded asset)
Details: Working on a Flutter Project
State: Deep Focus Mode
```

### Configuration 3: Custom App
```
Display Name: My Game
Process Name: mygame.exe
Icon URL: https://mywebsite.com/game-icon.png
Details: Playing My Game
State: Level 10
```

## Pro Tips 💡

1. **Keep it simple**: Don't overcomplicate the status text
2. **Test first**: Add one game, test it works, then add more
3. **Asset names**: Use lowercase and underscores (e.g., `my_game_icon`)
4. **Process monitoring**: Start monitoring before launching games
5. **Auto-start**: Enable if you always want this running
6. **Disable unused**: Disable profiles you're not currently using

## Support

If you encounter issues:
1. Check this guide first
2. Review the main README.md
3. Check the application logs
4. Verify Discord's Developer Portal shows your application correctly

---

**Enjoy your custom Discord Rich Presence! 🎮**
