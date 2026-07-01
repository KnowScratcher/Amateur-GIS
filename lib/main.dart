import 'package:flutter/material.dart';
import 'package:amateur_gis/features/workspace/presentation/gis_workspace_screen.dart';

void main() {
  runApp(const GisDesktopApp());
}

class GisDesktopApp extends StatelessWidget {
  const GisDesktopApp({super.key});

  @override
  Widget build(BuildContext themeContext) {
    return MaterialApp(
      title: 'Desktop GIS Workspace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        cardColor: const Color(0xFF252526),
        dividerColor: const Color(0xFF3F3F46),
      ),
      home: const GisMainWorkspace(),
    );
  }
}