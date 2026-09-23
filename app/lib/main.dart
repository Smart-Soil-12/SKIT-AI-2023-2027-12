import 'package:flutter/material.dart';
import 'core/state/smart_soil_scope.dart';
import 'ui/core/app_theme.dart';
import 'ui/main_navigation_scaffold.dart';

void main() {
  runApp(const SmartSoilApp());
}

/// Root Smart Soil Application Widget
class SmartSoilApp extends StatelessWidget {
  const SmartSoilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SmartSoilAppState(
      child: MaterialApp(
        title: 'Smart Soil',
        debugShowCheckedModeBanner: false,
        theme: SmartSoilTheme.lightTheme,
        home: const MainNavigationScaffold(),
      ),
    );
  }
}
