import 'package:flutter/material.dart';

class NavigationCluster extends StatelessWidget {
  const NavigationCluster({super.key});

  @override
  Widget build(BuildContext themeContext) {
    return Card(
      elevation: 4,
      color: const Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            IconButton(icon: const Icon(Icons.add), onPressed: () {}),
            const Divider(height: 1, color: Colors.black26),
            IconButton(icon: const Icon(Icons.remove), onPressed: () {}),
            const Divider(height: 1, color: Colors.black26),
            IconButton(icon: const Icon(Icons.explore), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}