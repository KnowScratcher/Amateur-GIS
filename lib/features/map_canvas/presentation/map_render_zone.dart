import 'package:flutter/material.dart';
import 'package:amateur_gis/features/layers/domain/layer_model.dart';
import 'package:amateur_gis/features/map_canvas/background/painters/grid_canvas_painter.dart';


class MapCanvasRenderZone extends StatelessWidget {
  final List<LayerItem> activeLayers;

  const MapCanvasRenderZone({super.key, required this.activeLayers});

  @override
  Widget build(BuildContext themeContext) {
    // CustomPainter or an optimized third-party GIS canvas renders inside this block
    return CustomPaint(
      painter: GridCanvasPainter(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 48, color: Colors.white30),
            const SizedBox(height: 8),
            const Text(
              'Interactive Spatial Vector / Raster Canvas',
              style: TextStyle(color: Colors.white30, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}