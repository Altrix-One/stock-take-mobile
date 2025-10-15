import 'package:flutter/material.dart';
import '../constants/liquid_theme.dart';
import '../constants/wallpaper_manager.dart';
import '../components/liquid_components.dart';

/// Demo screen showcasing all liquid components and effects
/// This screen demonstrates how to use the liquid theme system
class LiquidDemoScreen extends StatefulWidget {
  const LiquidDemoScreen({Key? key}) : super(key: key);

  @override
  State<LiquidDemoScreen> createState() => _LiquidDemoScreenState();
}

class _LiquidDemoScreenState extends State<LiquidDemoScreen> {
  String _currentWallpaper = 'ios_blue';
  String _currentPalette = 'ocean';
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated liquid wallpaper background
        Positioned.fill(
          child: WallpaperManager.fromKey(_currentWallpaper, effectsEnabled: true),
        ),
        
        Scaffold(
          backgroundColor: Colors.transparent,
          
          // Liquid App Bar
          appBar: LiquidAppBar(
            title: const Text('Liquid Demo'),
            liquidPalette: _currentPalette,
            actions: [
              IconButton(
                icon: const Icon(Icons.palette),
                onPressed: _showPaletteSelector,
              ),
              IconButton(
                icon: const Icon(Icons.wallpaper),
                onPressed: _showWallpaperSelector,
              ),
            ],
          ),
          
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Animated liquid background container
                  LiquidContainer(
                    height: 120,
                    liquidPalette: _currentPalette,
                    animated: true,
                    child: const Center(
                      child: Text(
                        'Animated Liquid Container',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Glass morphism cards
                  Row(
                    children: [
                      Expanded(
                        child: LiquidCard(
                          height: 100,
                          opacity: 0.2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.star, color: Colors.white, size: 30),
                              SizedBox(height: 8),
                              Text(
                                'Glass Card',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: LiquidCard(
                          height: 100,
                          animated: true,
                          liquidPalette: _currentPalette,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.auto_awesome, color: Colors.white, size: 30),
                              SizedBox(height: 8),
                              Text(
                                'Animated Card',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Liquid buttons
                  const Text(
                    'Liquid Buttons',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  LiquidButton(
                    liquidPalette: _currentPalette,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Liquid button pressed!')),
                      );
                    },
                    child: const Text('Primary Liquid Button'),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: LiquidButton(
                          liquidPalette: 'sunset',
                          elevation: 2,
                          onPressed: () {},
                          child: const Text('Sunset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LiquidButton(
                          liquidPalette: 'forest',
                          elevation: 2,
                          onPressed: () {},
                          child: const Text('Forest'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LiquidButton(
                          liquidPalette: 'purple',
                          elevation: 2,
                          onPressed: () {},
                          child: const Text('Purple'),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Static gradient containers
                  const Text(
                    'Static Gradient Examples',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LiquidTheme.staticLiquidGradient(palette: 'roseGold'),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Rose Gold Gradient',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LiquidTheme.radialLiquidGradient(
                              palette: 'corporate',
                              radius: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Radial',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 60,
                          decoration: LiquidTheme.glassDecoration(
                            borderRadius: BorderRadius.circular(12),
                            opacity: 0.3,
                          ),
                          child: const Center(
                            child: Text(
                              'Glass Effect',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Color information
                  LiquidCard(
                    opacity: 0.25,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Palette: ${_currentPalette.toUpperCase()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Primary: ${LiquidTheme.getPrimaryColor(_currentPalette).toString()}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Accent: ${LiquidTheme.getAccentColor(_currentPalette).toString()}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Background: ${WallpaperManager.wallpapers[_currentWallpaper]?.name}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 100), // Space for floating action button
                ],
              ),
            ),
          ),
          
          // Liquid Floating Action Button
          floatingActionButton: LiquidFloatingActionButton(
            liquidPalette: _currentPalette,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Liquid FAB pressed!')),
              );
            },
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ],
    );
  }
  
  void _showPaletteSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Choose Color Palette',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...LiquidTheme.liquidPalettes.entries.map((entry) {
                return ListTile(
                  leading: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: entry.value),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  title: Text(entry.key.toUpperCase()),
                  onTap: () {
                    setState(() {
                      _currentPalette = entry.key;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
  
  void _showWallpaperSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Choose Wallpaper',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: WallpaperManager.wallpapers.length,
                  itemBuilder: (context, index) {
                    final entry = WallpaperManager.wallpapers.entries.elementAt(index);
                    final key = entry.key;
                    final wallpaper = entry.value;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentWallpaper = key;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: key == _currentWallpaper ? Colors.blue : Colors.grey[300]!,
                            width: key == _currentWallpaper ? 3 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: wallpaper.colors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                wallpaper.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}