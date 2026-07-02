import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';

class NavigationCluster extends StatelessWidget {
  final AnimatedMapController animatedMapController;

  const NavigationCluster({super.key, required this.animatedMapController});

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
            // Zoom In Action
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white70),
              onPressed: () {
                final currentZoom =
                    animatedMapController.mapController.camera.zoom;
                animatedMapController.animatedZoomIn(
                  curve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 100),
                );
              },
              tooltip: 'Zoom In',
            ),
            const Divider(height: 1, color: Colors.black26),

            // Zoom Out Action
            IconButton(
              icon: const Icon(Icons.remove, color: Colors.white70),
              onPressed: () {
                final currentZoom =
                    animatedMapController.mapController.camera.zoom;
                animatedMapController.animatedZoomOut(
                  curve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 100),
                );
              },
              tooltip: 'Zoom Out',
            ),
            const Divider(height: 1, color: Colors.black26),

            // Recenter / Explore Action
            IconButton(
              icon: const Icon(Icons.explore, color: Colors.white70),
              onPressed: () {
                animatedMapController.animateTo(
                  zoom: 2,
                  dest: LatLng(0.0, 0.0),
                  curve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 300),
                );
              },
              tooltip: 'Recenter Map',
            ),
          ],
        ),
      ),
    );
  }
}
