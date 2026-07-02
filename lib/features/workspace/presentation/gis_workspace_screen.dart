import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:amateur_gis/widgets/status_bar.dart';
import 'package:amateur_gis/widgets/top_menu_bar.dart';
import 'package:amateur_gis/features/layers/domain/layer_model.dart';
import 'package:amateur_gis/features/map_canvas/presentation/map_render_zone.dart';
import 'package:amateur_gis/features/layers/presentation/layers_sidebar_panel.dart';
import 'package:flutter_map_geojson2/flutter_map_geojson2.dart';
import 'package:amateur_gis/features/map_canvas/presentation/components/navigation_cluster.dart';

class GisMainWorkspace extends StatefulWidget {
  const GisMainWorkspace({super.key});

  @override
  State<GisMainWorkspace> createState() => _GisMainWorkspaceState();
}

class _GisMainWorkspaceState extends State<GisMainWorkspace> {
  // Mock layer state
  final List<LayerItem> _layers = [
    LayerItem(id: '1', name: 'Roads Network (Vector)'),
    LayerItem(id: '2', name: 'Hydrography / Lakes'),
    LayerItem(id: '3', name: 'Satellite Base Imagery'),
    LayerItem(id: '4', name: 'Digital Elevation Model (DEM)'),
  ];

  String _cursorCoordinates = 'Lat: 0.00000, Lon: 0.00000';

  Future<void> _pickAndLoadGeoJsonFile() async {
    try {
      final FilePickerResult? pickerResult = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'json',
          'geojson',
        ], // Enforce rigid geographic text formats
      );

      // Handle fallback scenario when users close the window without picking a target path
      if (pickerResult == null || pickerResult.files.single.path == null) {
        return;
      }

      // Select file from local storage
      final String diskFilePath = pickerResult.files.single.path!;
      final File localFileNode = File(diskFilePath);
      final GeoJsonLayer spatialFeatures = GeoJsonLayer.file(localFileNode);
      // Extract file name structure to apply as presentation text
      final String shortFileName = pickerResult.files.single.name;

      setState(() {
        _layers.add(
          GeojsonLayerItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: shortFileName,
            geojsonLayer: spatialFeatures,
          ),
        );
      });
    } catch (error) {
      debugPrint('Error accessing local coordinate text format: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 1. Top Menu Bar
          const TopMenuBar(),

          // 2. Main Workspace Split View
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Sidebar: Layer Panel (Fixed Width for Desktop)
                LayersSidebarPanel(
                  layers: _layers,
                  onLayersChanged: () => setState(() {}),
                  onImportDataset: _pickAndLoadGeoJsonFile,
                  onInformationChanged: () => {},
                ),

                // Right Viewport: Isolated Map Canvas & Overlay Controls
                Expanded(
                  child: MouseRegion(
                    onHover: (event) {
                      // Simulating localized event updates
                      setState(() {
                        _cursorCoordinates =
                            'Lat: ${(23.5 - event.localPosition.dy * 0.01).toStringAsFixed(5)}, '
                            'Lon: ${(120.4 + event.localPosition.dx * 0.01).toStringAsFixed(5)}';
                      });
                    },
                    child: Stack(
                      children: [
                        // Critical Optimization: RepaintBoundary isolates heavy map painting
                        Positioned.fill(
                          child: RepaintBoundary(
                            child: MapCanvasRenderZone(activeLayers: _layers),
                          ),
                        ),

                        // Floating Navigation Cluster
                        Positioned(
                          top: 20,
                          right: 20,
                          child: NavigationCluster(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Bottom Status Bar
          StatusBar(cursorCoordinates: _cursorCoordinates),
        ],
      ),
    );
  }
}
