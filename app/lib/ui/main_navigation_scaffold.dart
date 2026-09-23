import 'package:flutter/material.dart';
import '../core/state/smart_soil_scope.dart';
import 'core/app_theme.dart';
import 'home/views/home_screen.dart';
import 'scan/views/crop_disease_scan_screen.dart';
import 'yield/views/yield_prediction_screen.dart';
import 'ai_chat/views/agronomic_chat_screen.dart';
import 'farm_soil/views/farm_soil_telemetry_screen.dart';

/// Central 5-Tab Navigation Scaffold with Language Selector & Greeting Header.
class MainNavigationScaffold extends StatefulWidget {
  const MainNavigationScaffold({super.key});

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = SmartSoilScope.of(context).language;

    final screens = [
      HomeScreen(
        onNavigateToScan: () => _onTabSelected(1),
        onNavigateToFarm: () => _onTabSelected(4),
      ),
      const CropDiseaseScanScreen(),
      const YieldPredictionScreen(),
      const AgronomicChatScreen(),
      const FarmSoilTelemetryScreen(),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${lang.tr('greeting_prefix')} Chaitanya Sharma',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: SmartSoilTheme.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                lang.tr('welcome_subtitle'),
                style: const TextStyle(
                  fontSize: 11,
                  color: SmartSoilTheme.textMuted,
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: SmartSoilTheme.creamBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black.withOpacity(0.08)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: lang.currentLocale,
                  icon: const Icon(Icons.arrow_drop_down_rounded, size: 20, color: SmartSoilTheme.forestGreen),
                  items: const [
                    DropdownMenuItem(
                      value: 'en',
                      child: Text('🌐 English', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    DropdownMenuItem(
                      value: 'hi',
                      child: Text('🌐 हिन्दी', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) lang.setLocale(val);
                  },
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 14, left: 4),
              child: const CircleAvatar(
                backgroundColor: SmartSoilTheme.forestGreen,
                radius: 17,
                child: Text(
                  'C',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded, color: SmartSoilTheme.forestGreen),
            label: lang.tr('tab_home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.camera_alt_outlined),
            selectedIcon: const Icon(Icons.camera_alt_rounded, color: SmartSoilTheme.forestGreen),
            label: lang.tr('tab_scan'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.trending_up_rounded),
            selectedIcon: const Icon(Icons.trending_up_rounded, color: SmartSoilTheme.forestGreen),
            label: lang.tr('tab_yield'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.smart_toy_outlined),
            selectedIcon: const Icon(Icons.smart_toy_rounded, color: SmartSoilTheme.forestGreen),
            label: lang.tr('tab_ai'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.eco_outlined),
            selectedIcon: const Icon(Icons.eco_rounded, color: SmartSoilTheme.forestGreen),
            label: lang.tr('tab_farm'),
          ),
        ],
      ),
    );
  }
}
