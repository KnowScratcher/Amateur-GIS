import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  final String cursorCoordinates;

  const StatusBar({super.key, required this.cursorCoordinates});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF007ACC), // Standard status bar tint
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            cursorCoordinates,
            style: const TextStyle(fontSize: 11, color: Colors.white),
          ),
          const Text(
            'EPSG:4326 (WGS 84)  |  Scale 1:25,000',
            style: TextStyle(fontSize: 11, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
