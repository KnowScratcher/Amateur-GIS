import 'package:flutter/material.dart';

class SidebarHeader extends StatelessWidget {
  final VoidCallback onCreatePressed;

  const SidebarHeader({super.key, required this.onCreatePressed});

  @override
  Widget build(BuildContext themeContext) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Layers Control Panel',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add_box, size: 18),
            onPressed: onCreatePressed, // Trigger local file picker
            tooltip: 'Create New Layer',
          ),
        ],
      ),
    );
  }
}