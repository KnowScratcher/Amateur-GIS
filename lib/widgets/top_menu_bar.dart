import 'package:flutter/material.dart';

class TopMenuBar extends StatelessWidget {
  const TopMenuBar({super.key});

  @override
  Widget build(BuildContext themeContext) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF3C3C3C),
        border: Border(
          bottom: BorderSide(color: Theme.of(themeContext).dividerColor),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          const Icon(Icons.public, size: 18, color: Colors.green),
          const SizedBox(width: 12),
          _buildMenuButton('File'),
          _buildMenuButton('Edit'),
          _buildMenuButton('Layer'),
          _buildMenuButton('Vector'),
          _buildMenuButton('Raster'),
          _buildMenuButton('Help'),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
        ),
      ),
    );
  }
}