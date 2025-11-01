# Assets Folder

## Application Icon Required

Your application icon needs to be placed in **TWO locations**:

### 1. System Tray Icon (this folder):
- **File name:** `app_icon.ico`
- **Format:** .ico (Windows Icon)
- **Recommended size:** 16x16 or 32x32 pixels
- **Location:** Place it in this `assets/` folder

### 2. Windows Taskbar Icon (Windows resources):
- **File name:** `app_icon.ico`
- **Format:** .ico (Windows Icon)
- **Recommended size:** 16x16, 32x32, 48x48 (multi-size .ico is best)
- **Location:** `windows/runner/resources/app_icon.ico`

**Quick Tip:** Create one icon file and copy it to both locations!

### How to create an icon:

1. **Option 1 - Use an online converter:**
   - Create or find a simple PNG image (32x32 pixels recommended)
   - Go to https://www.icoconverter.com or https://convertio.co/png-ico/
   - Upload your PNG and convert to .ico
   - Download and save as `app_icon.ico` in this folder

2. **Option 2 - Use GIMP (free software):**
   - Open/create your image in GIMP
   - Resize to 32x32: Image → Scale Image
   - Export as: File → Export As → Choose .ico format
   - Save as `app_icon.ico`

3. **Option 3 - Use Discord's logo:**
   - Download Discord's logo from their brand resources
   - Convert to .ico format using online tool
   - Save as `app_icon.ico`

### Temporary workaround:
If you don't have an icon yet, the app will still work but the tray icon initialization might fail gracefully. The app will continue to function, just without the tray icon visible.

### Future icons (optional):
- `app_icon.png` - For Linux/macOS support (if you plan to port the app)
- Different sizes for better quality on high-DPI displays
