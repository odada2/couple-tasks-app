# App Icon & Launch Assets Documentation

## Overview

This document describes the app icons and launch assets created for the Couple Tasks app, meeting all Apple and Google Play Store requirements.

## Icon Design

### Concept
The app icon features **two overlapping hearts with an integrated checkmark**, symbolizing:
- **Love & Partnership**: Two hearts representing the couple
- **Task Completion**: Checkmark indicating getting things done together
- **Collaboration**: Overlapping design showing teamwork

### Color Palette
- **Primary**: #FF6B9D (vibrant pink)
- **Secondary**: #FFB4C8 (light pink/peach)
- **Background**: #FFF0F3 (very light pink/peach)
- **Gradient**: Pink to peach for warmth and friendliness

### Design Principles
- Simple and recognizable at all sizes
- Friendly and approachable aesthetic
- Consistent with app's therapy-inspired philosophy
- Works across all platform mask shapes

## iOS Icons

### Requirements Met
✅ **Master Icon**: 1024×1024 px PNG (no transparency)
✅ **All Sizes Generated**: 15 icon sizes from 20px to 1024px
✅ **Square Shape**: Unmasked, system applies rounded corners
✅ **Contents.json**: Properly configured for Xcode

### iOS Icon Sizes
| Size | Scale | Purpose | Filename |
|------|-------|---------|----------|
| 1024×1024 | 1x | App Store | Icon-App-1024x1024@1x.png |
| 180×180 | 3x | iPhone | Icon-App-60x60@3x.png |
| 167×167 | 2x | iPad Pro | Icon-App-83.5x83.5@2x.png |
| 152×152 | 2x | iPad | Icon-App-76x76@2x.png |
| 120×120 | 3x/2x | iPhone/Spotlight | Icon-App-40x40@3x.png |
| 87×87 | 3x | Settings | Icon-App-29x29@3x.png |
| 80×80 | 2x | Spotlight | Icon-App-40x40@2x.png |
| 76×76 | 1x | iPad | Icon-App-76x76@1x.png |
| 60×60 | 3x | Notification | Icon-App-20x20@3x.png |
| 58×58 | 2x | Settings | Icon-App-29x29@2x.png |
| 40×40 | 2x/1x | Notification | Icon-App-20x20@2x.png |
| 29×29 | 1x | Settings | Icon-App-29x29@1x.png |
| 20×20 | 1x | Notification | Icon-App-20x20@1x.png |

### iOS Location
```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
├── Contents.json
├── Icon-App-1024x1024@1x.png
├── Icon-App-20x20@1x.png
├── Icon-App-20x20@2x.png
├── Icon-App-20x20@3x.png
├── Icon-App-29x29@1x.png
├── Icon-App-29x29@2x.png
├── Icon-App-29x29@3x.png
├── Icon-App-40x40@1x.png
├── Icon-App-40x40@2x.png
├── Icon-App-40x40@3x.png
├── Icon-App-60x60@2x.png
├── Icon-App-60x60@3x.png
├── Icon-App-76x76@1x.png
├── Icon-App-76x76@2x.png
└── Icon-App-83.5x83.5@2x.png
```

## Android Icons

### Requirements Met
✅ **Play Store Icon**: 512×512 px PNG with alpha
✅ **Adaptive Icons**: Foreground + Background + Monochrome layers
✅ **All Densities**: mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi
✅ **No Pre-applied Effects**: System applies rounded corners and shadows
✅ **Themed Icons**: Monochrome layer for Android 13+ theming

### Android Icon Sizes
| Density | Size | DPI | Purpose |
|---------|------|-----|---------|
| mdpi | 48×48 | 160 | Baseline |
| hdpi | 72×72 | 240 | High density |
| xhdpi | 96×96 | 320 | Extra high density |
| xxhdpi | 144×144 | 480 | Extra extra high |
| xxxhdpi | 192×192 | 640 | Extra extra extra high |

### Adaptive Icon Layers

#### 1. Background Layer
- Solid pink color (#FF6B9D)
- Defined in `drawable/ic_launcher_background.xml`
- Full bleed, no transparency

#### 2. Foreground Layer
- Two overlapping hearts with checkmark
- PNG images in all densities
- Sized for 108dp canvas with 66dp safe zone
- Files: `ic_launcher_foreground.png`

#### 3. Monochrome Layer
- Black outline version of icon
- For Android 13+ themed icons
- System applies user's wallpaper tint
- Files: `ic_launcher_monochrome.png`

### Android Location
```
android/app/src/main/res/
├── drawable/
│   ├── ic_launcher_background.xml
│   └── launch_background.xml
├── mipmap-anydpi-v26/
│   └── ic_launcher.xml
├── mipmap-mdpi/
│   ├── ic_launcher.png
│   ├── ic_launcher_foreground.png
│   └── ic_launcher_monochrome.png
├── mipmap-hdpi/
│   ├── ic_launcher.png
│   ├── ic_launcher_foreground.png
│   └── ic_launcher_monochrome.png
├── mipmap-xhdpi/
│   ├── ic_launcher.png
│   ├── ic_launcher_foreground.png
│   └── ic_launcher_monochrome.png
├── mipmap-xxhdpi/
│   ├── ic_launcher.png
│   ├── ic_launcher_foreground.png
│   └── ic_launcher_monochrome.png
└── mipmap-xxxhdpi/
    ├── ic_launcher.png
    ├── ic_launcher_foreground.png
    └── ic_launcher_monochrome.png
```

## Google Play Store Icon

### Requirements Met
✅ **Size**: 512×512 px
✅ **Format**: 32-bit PNG with alpha
✅ **File Size**: Under 1 MB
✅ **No Effects**: No shadows or rounded corners (system applies)
✅ **Full Square**: System applies 30% corner radius

### Location
```
couple_tasks_icons/generated/play_store/ic_launcher_512.png
```

## Launch Screens / Splash Screens

### Design
- Soft gradient background (light pink to peach)
- App icon centered
- App name "Couple Tasks" below icon
- Tagline "Together, we get things done"
- Clean, minimalist design

### iOS Launch Screen
- Storyboard-based (default Flutter configuration)
- Background color: #FFF0F3
- Icon displayed via launch_background.xml

### Android Splash Screen
- Multiple density versions created
- Sizes: 320×480 to 1440×2560
- Configured in `drawable/launch_background.xml`
- Shows app icon on white background

### Splash Screen Sizes
| Density | Resolution |
|---------|------------|
| mdpi | 320×480 |
| hdpi | 480×800 |
| xhdpi | 720×1280 |
| xxhdpi | 1080×1920 |
| xxxhdpi | 1440×2560 |

## Asset Files

### Master Assets
Located in `assets/icon/`:
- `app_icon.png` - 1024×1024 master icon
- `app_icon_foreground.png` - Adaptive foreground layer
- `app_icon_monochrome.png` - Monochrome layer for theming

### Generated Assets
Located in `couple_tasks_icons/generated/`:
- `ios/` - All iOS icon sizes
- `android/` - All Android densities
- `play_store/` - Google Play Store icon

## Configuration Files

### iOS
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json`
  - Maps icon files to sizes and devices
  - Auto-generated by icon generator script

### Android
- `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`
  - Defines adaptive icon layers
  - References background, foreground, monochrome

- `android/app/src/main/res/drawable/ic_launcher_background.xml`
  - Vector drawable for background layer
  - Solid pink color

- `android/app/src/main/res/drawable/launch_background.xml`
  - Splash screen configuration
  - Shows app icon on white background

### Flutter
- `pubspec.yaml` - Assets section includes:
  ```yaml
  assets:
    - assets/images/
    - assets/icon/
  ```

## Generation Script

A Python script was created to automate icon generation:
- **Location**: `/home/ubuntu/generate_icons.py`
- **Features**:
  - Generates all iOS sizes from master icon
  - Generates all Android densities
  - Creates adaptive icon layers
  - Generates Play Store icon
  - Copies files to Flutter project
  - Creates Contents.json for iOS

### Running the Script
```bash
python3 /home/ubuntu/generate_icons.py
```

## Verification Checklist

### iOS
- [x] 1024×1024 master icon created
- [x] All 15 icon sizes generated
- [x] Contents.json properly formatted
- [x] Icons copied to AppIcon.appiconset
- [x] No transparency in master icon
- [x] Square shape (unmasked)

### Android
- [x] 512×512 Play Store icon created
- [x] All 5 density levels generated
- [x] Adaptive icon foreground layers created
- [x] Adaptive icon background defined
- [x] Monochrome layer for themed icons
- [x] ic_launcher.xml configuration
- [x] No pre-applied rounded corners
- [x] No pre-applied shadows

### Launch Screens
- [x] iOS launch screen configured
- [x] Android splash screens (5 densities)
- [x] launch_background.xml updated
- [x] Splash images in drawable folders

## Platform-Specific Features

### iOS Features
- **Adaptive Appearance**: Supports light/dark mode
- **System Rounding**: iOS applies rounded corners automatically
- **Liquid Glass**: System adds specular highlights and effects
- **App Store Ready**: 1024×1024 master icon meets requirements

### Android Features
- **Adaptive Icons**: Different shapes on different devices
- **Themed Icons**: Monochrome layer for Android 13+ theming
- **Visual Effects**: Parallax, pulsing, elevation
- **Play Store Ready**: 512×512 icon meets all requirements

## Testing

### iOS Testing
1. Open project in Xcode
2. Check Assets.xcassets/AppIcon.appiconset
3. Build and run on simulator/device
4. Verify icon appears on home screen
5. Check all sizes in different contexts (Settings, Spotlight, etc.)

### Android Testing
1. Open project in Android Studio
2. Check res/mipmap-* folders
3. Build and run on emulator/device
4. Verify adaptive icon with different masks
5. Test themed icons on Android 13+ device
6. Check icon in launcher, settings, recent apps

## Compliance

### Apple Guidelines
✅ Simple, recognizable design
✅ No text in icon
✅ Consistent across platforms
✅ Proper sizing and format
✅ No pre-applied effects
✅ Square shape for system masking

### Google Guidelines
✅ Full square 512×512 for Play Store
✅ No pre-applied rounded corners
✅ No pre-applied shadows
✅ Adaptive icon layers (108dp)
✅ Safe zone respected (66dp)
✅ Monochrome layer for theming
✅ Under 1 MB file size

## Future Enhancements

### Potential Improvements
- [ ] Create alternate app icons (different color schemes)
- [ ] Add seasonal icon variants
- [ ] Create widget icons
- [ ] Design notification icons
- [ ] Create Apple Watch icon
- [ ] Design Android TV icon

## Resources

### Design Files
- Master icons: `/home/ubuntu/couple_tasks_icons/`
- Generated icons: `/home/ubuntu/couple_tasks_icons/generated/`
- Flutter assets: `/home/ubuntu/couple_tasks/assets/icon/`

### Documentation
- iOS Guidelines: https://developer.apple.com/design/human-interface-guidelines/app-icons
- Android Guidelines: https://developer.android.com/distribute/google-play/resources/icon-design-specifications
- Adaptive Icons: https://developer.android.com/develop/ui/views/launch/icon_design_adaptive

### Tools Used
- AI Image Generation: For creating icon design
- Python + Pillow: For resizing and generating all sizes
- Flutter: For app integration

## Summary

All app icons and launch assets have been successfully created and integrated into the Couple Tasks Flutter app, meeting all requirements for:

✅ **iOS App Store** - 1024×1024 master icon + 15 sizes
✅ **Google Play Store** - 512×512 store icon
✅ **Android Adaptive Icons** - Foreground + Background + Monochrome layers
✅ **Launch Screens** - iOS and Android splash screens
✅ **Platform Compliance** - Meets all Apple and Google standards

The app is ready for submission to both app stores with professional, platform-compliant icons and launch assets.
