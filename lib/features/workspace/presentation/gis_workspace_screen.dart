import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:amateur_gis/widgets/status_bar.dart';
import 'package:amateur_gis/widgets/top_menu_bar.dart';
import 'package:amateur_gis/features/layers/domain/layer_model.dart';
import 'package:amateur_gis/features/map_canvas/presentation/map_render_zone.dart';
import 'package:amateur_gis/features/layers/presentation/layers_sidebar_panel.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_geojson2/flutter_map_geojson2.dart';
import 'package:amateur_gis/features/map_canvas/presentation/components/navigation_cluster.dart';
import 'package:latlong2/latlong.dart';

class GisMainWorkspace extends StatefulWidget {
  const GisMainWorkspace({super.key});

  @override
  State<GisMainWorkspace> createState() => _GisMainWorkspaceState();
}

class _GisMainWorkspaceState extends State<GisMainWorkspace> with TickerProviderStateMixin{
  late final AnimatedMapController _mapController = AnimatedMapController(vsync: this);
  // Mock layer state
  final List<LayerItem> _layers = [
    LayerItem(id: '1', name: 'Roads Network (Vector)'),
    LayerItem(id: '2', name: 'Hydrography / Lakes'),
    LayerItem(id: '3', name: 'Satellite Base Imagery'),
    LayerItem(id: '4', name: 'Digital Elevation Model (DEM)'),
  ];

  String _cursorCoordinates = 'Lat: 0.00000, Lon: 0.00000';

  void _showCreateLayerModal() {
    showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF252526),
          title: const Row(
            children: [
              Icon(Icons.layers_outlined, color: Colors.blue, size: 22),
              SizedBox(width: 10),
              Text(
                'Create New Layer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            // Explicit layout ceiling constraints optimized for desktop views
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select the spatial layer source format type you want to instantiate in your current workspace:',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 16),

                // 1. Tile Layer Selection Option
                _buildLayerTypeOption(
                  context: dialogContext,
                  title: 'Raster Tile Layer',
                  subtitle:
                      'Load map imagery slices from remote web servers (XYZ / WMS)',
                  icon: Icons.map,
                  value: 'tile',
                ),
                const SizedBox(height: 10),

                // 2. Feature Layer Selection Option
                _buildLayerTypeOption(
                  context: dialogContext,
                  title: 'Feature Vector Layer',
                  subtitle:
                      'Instantiate custom data nodes, line strings, and bounding shapes',
                  icon: Icons.polyline_outlined,
                  value: 'feature',
                ),
                const SizedBox(height: 10),

                // 3. GeoJSON Selection Option
                _buildLayerTypeOption(
                  context: dialogContext,
                  title: 'GeoJSON Data Source',
                  subtitle:
                      'Import complex vector coordinates directly from a local static file',
                  icon: Icons.code,
                  value: 'geojson',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.purple[30], fontSize: 13),
              ),
            ),
          ],
        );
      },
    ).then((String? selectedType) {
      if (selectedType == null) return;

      // Verification check confirming hook interception
      debugPrint('User initiated step 2 pipeline for type: $selectedType');

      // The configuration flow pauses here as requested.
      // Next, we will direct specific workflows based on the selected string type value.
    });
  }

  Widget _buildLayerTypeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    return InkWell(
      onTap: () => Navigator.pop(context, value),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF3F3F46)),
          borderRadius: BorderRadius.circular(6),
          color: const Color(0xFF1E1E1E),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.white70),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.white30),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: Colors.white30),
          ],
        ),
      ),
    );
  }

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
                  onCreatePressed: _showCreateLayerModal,
                  onInformationChanged: () => {},
                ),

                // Right Viewport: Isolated Map Canvas & Overlay Controls
                Expanded(
                  child: Stack(
                    children: [
                      // Critical Optimization: RepaintBoundary isolates heavy map painting
                      Positioned.fill(
                        child: RepaintBoundary(
                          child: MapCanvasRenderZone(
                            activeLayers: _layers,
                            mapController: _mapController,
                            onPointerHover: (LatLng position) {
                              setState(() {
                                _cursorCoordinates =
                                    'Lat: ${position.latitude.toStringAsFixed(5)}, '
                                    'Lon: ${position.longitude.toStringAsFixed(5)}';
                              });
                            },
                          ),
                        ),
                      ),

                      // Floating Navigation Cluster
                      Positioned(
                        top: 20,
                        right: 20,
                        child: NavigationCluster(animatedMapController: _mapController),
                      ),
                    ],
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
