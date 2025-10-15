# Unified Theme System Guide

This guide explains the new unified theme system that replaces all the conflicting theme files and ensures consistent royal blue gradient wallpaper background across all screens.

## Overview

The unified theme system consists of:
- **AppThemeUnified**: Single comprehensive theme with royal blue gradient wallpaper support
- **UniversalScaffold**: Standard scaffold that automatically shows wallpaper on every screen
- **Universal Components**: Pre-styled widgets that work perfectly with the wallpaper

## Key Benefits

✅ **Consistent royal blue gradient background on ALL screens**  
✅ **No more hardcoded colors or individual screen styling**  
✅ **Glass morphism UI components for wallpaper visibility**  
✅ **Single source of truth for theming**  
✅ **Automatic white text for wallpaper readability**  

## Files Created/Updated

### New Files
- `lib/constants/app_theme_unified.dart` - Single comprehensive theme system
- `lib/widgets/universal_scaffold.dart` - Universal components for consistent UI
- `lib/screens/modern_leaves_page_refactored.dart` - Example of refactored screen

### Updated Files  
- `lib/main.dart` - Now uses unified theme instead of conflicting themes
- `lib/screens/modern_hr_dashboard.dart` - Partially refactored to demonstrate approach
- `lib/screens/login.dart` - Refactored to use universal components

## Usage Guide

### 1. Using UniversalScaffold (REQUIRED)

**Every screen must use UniversalScaffold instead of regular Scaffold:**

```dart
import 'package:stock_count/widgets/universal_scaffold.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return UniversalScaffold(  // ← Use this, not Scaffold
      appBar: UniversalAppBar(
        title: 'My Screen',
      ),
      body: UniversalPageContent(
        children: [
          // Your content here
        ],
      ),
    );
  }
}
```

### 2. Using Universal Components

**Replace hardcoded widgets with universal components:**

```dart
// ❌ OLD WAY - Individual styling
Container(
  color: Colors.white.withOpacity(0.1),
  child: Text('Hello', style: TextStyle(color: Colors.white)),
)

// ✅ NEW WAY - Universal components
UniversalCard(
  child: Text('Hello', style: AppThemeUnified.bodyLarge),
)
```

### 3. Typography System

**Use AppThemeUnified text styles instead of custom ones:**

```dart
// ❌ OLD WAY
Text('Title', style: TextStyle(fontSize: 18, color: Colors.white))

// ✅ NEW WAY  
Text('Title', style: AppThemeUnified.headlineSmall)
```

**Available text styles:**
- `AppThemeUnified.displayLarge/Medium/Small` - For hero text
- `AppThemeUnified.headlineLarge/Medium/Small` - For section headers  
- `AppThemeUnified.titleLarge/Medium/Small` - For card/component titles
- `AppThemeUnified.bodyLarge/Medium/Small` - For regular text
- `AppThemeUnified.labelLarge/Medium/Small` - For buttons/UI elements

### 4. Colors System

**Use unified colors instead of hardcoded values:**

```dart
// ❌ OLD WAY
color: Color(0xFF1436AC)
color: Colors.white.withOpacity(0.1)

// ✅ NEW WAY
color: AppThemeUnified.primaryRoyalBlue
color: AppThemeUnified.glassLight
```

**Available colors:**
- `AppThemeUnified.primaryRoyalBlue` - Main brand color
- `AppThemeUnified.secondaryOceanBlue` - Secondary brand color
- `AppThemeUnified.lightSkyBlue` - Tertiary brand color
- `AppThemeUnified.success/warning/error/info` - Status colors
- `AppThemeUnified.textPrimary/Secondary/Tertiary` - Text colors (all white variants)
- `AppThemeUnified.glassLight/Medium/Border` - Glass morphism colors
- `AppThemeUnified.glassDark/DarkMedium` - Dark glass for contrast

### 5. Spacing System

**Use consistent spacing instead of hardcoded values:**

```dart
// ❌ OLD WAY
EdgeInsets.all(16.0)
SizedBox(height: 24.0)

// ✅ NEW WAY
EdgeInsets.all(AppThemeUnified.spaceMD)
SizedBox(height: AppThemeUnified.spaceLG)
```

**Available spacing:**
- `AppThemeUnified.spaceXS` - 4px
- `AppThemeUnified.spaceSM` - 8px  
- `AppThemeUnified.spaceMD` - 16px
- `AppThemeUnified.spaceLG` - 24px
- `AppThemeUnified.spaceXL` - 32px
- `AppThemeUnified.space2XL` - 40px

### 6. Universal Components Reference

#### UniversalScaffold
```dart
UniversalScaffold(
  appBar: UniversalAppBar(title: 'Title'),
  body: widget,
  bottomNavigationBar: widget,
  floatingActionButton: widget,
  // Automatically shows royal blue gradient wallpaper
)
```

#### UniversalAppBar
```dart
UniversalAppBar(
  title: 'Screen Title',
  actions: [IconButton(...)],
  // Transparent with white text
)
```

#### UniversalPageContent
```dart
UniversalPageContent(
  children: [
    widget1,
    widget2,
  ],
  // Handles scrolling and padding
)
```

#### UniversalCard
```dart
UniversalCard(
  onTap: () => {},
  child: widget,
  // Glass morphism styling
)
```

#### UniversalSectionHeader
```dart
UniversalSectionHeader(
  title: 'Section Name',
  subtitle: 'Optional subtitle',
  icon: Icons.icon_name,
  trailing: widget,
)
```

#### Loading & Empty States
```dart
// Loading
UniversalLoading(message: 'Loading...')

// Empty state
UniversalEmptyState(
  icon: Icons.inbox,
  title: 'No Data',
  message: 'Description',
  action: ElevatedButton(...),
)

// Error state
UniversalErrorState(
  title: 'Error',
  message: 'Something went wrong',
  onRetry: () => {},
)
```

## Migration Steps

### Step 1: Update Screen Structure
```dart
// Replace Scaffold with UniversalScaffold
// Replace AppBar with UniversalAppBar  
// Wrap content in UniversalPageContent
```

### Step 2: Replace Hardcoded Colors
```dart
// Find all Color(0x...) and Colors.xyz
// Replace with AppThemeUnified.xyz colors
```

### Step 3: Update Text Styles
```dart
// Replace TextStyle(...) with AppThemeUnified text styles
// Remove color properties (text is automatically white)
```

### Step 4: Use Universal Components
```dart
// Replace custom cards with UniversalCard
// Replace custom headers with UniversalSectionHeader
// Replace loading indicators with UniversalLoading
```

### Step 5: Fix Spacing
```dart
// Replace hardcoded EdgeInsets/SizedBox with unified spacing
// Use AppThemeUnified.spaceMD instead of 16.0
```

## Example: Before & After

### Before (Hardcoded)
```dart
class OldScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1436AC),
      appBar: AppBar(
        title: Text('Title', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                'Content',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### After (Unified)
```dart
class NewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return UniversalScaffold(
      appBar: UniversalAppBar(title: 'Title'),
      body: UniversalPageContent(
        children: [
          UniversalCard(
            child: Text(
              'Content',
              style: AppThemeUnified.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
```

## Testing

After refactoring each screen:
1. Verify royal blue gradient wallpaper shows
2. Check all text is white and readable
3. Confirm glass morphism effects work
4. Test loading states and dialogs
5. Run `flutter analyze` and fix any issues

## Important Notes

⚠️ **ALWAYS use UniversalScaffold instead of Scaffold**  
⚠️ **Never hardcode colors - use AppThemeUnified colors**  
⚠️ **All text should be white (handled automatically by theme)**  
⚠️ **Use glass morphism colors for overlays on wallpaper**  
⚠️ **Test on both light and dark mode (though theme is same for both)**  

## Need Help?

Check the example files:
- `modern_leaves_page_refactored.dart` - Complete refactored screen
- `modern_hr_dashboard.dart` - Partially refactored (see changes)
- `login.dart` - Refactored login screen

The unified theme system ensures every screen looks consistent with the beautiful royal blue gradient wallpaper while maintaining excellent readability and modern glass morphism effects.