import 'dart:io';

import 'package:amateur_gis/features/layers/presentation/create_layer_panel.dart';
import 'package:amateur_gis/features/layers/presentation/tile_layer_editor.dart';
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

/// The main workspace screen for the Amateur GIS application.
///
/// This screen coordinates the top menu, the layer management sidebar,
/// the central map canvas, and the bottom status bar.
class GisMainWorkspace extends StatefulWidget {
  const GisMainWorkspace({super.key});

  @override
  State<GisMainWorkspace> createState() => _GisMainWorkspaceState();
}

class _GisMainWorkspaceState extends State<GisMainWorkspace> with TickerProviderStateMixin {
  /// Controller used to animate map movements and interactions.
  late final AnimatedMapController _mapController = AnimatedMapController(vsync: this);

  /// The list of layers currently managed in this workspace.
  final List<LayerItem> _layers = [
    FeatureLayerItem(id: '1', name: 'Roads Network (Vector)'),
    FeatureLayerItem(id: '2', name: 'Hydrography / Lakes'),
    TileLayerItem(
      id: '3',
      name: 'Satellite Base Imagery',
      provider: "http://mt0.google.com/vt/lyrs=s&hl=en&x={x}&y={y}&z={z}",
    ),
    TileLayerItem(id: '4', name: 'Digital Elevation Model (DEM)', provider: ""),
  ];

  /// The placeholder for current geographic coordinates under the mouse cursor.
  String _cursorCoordinates = 'Lat: 0.00000, Lon: 0.00000';

  /// Displays a modal dialog allowing the user to select a new layer type to add.
  void _showCreateLayerModal() async {
    bool workflowActive = true;
    String currentScreen = 'panel'; // States: 'panel', 'tile'

    while (workflowActive) {
      if (currentScreen == 'panel') {
        final String? selectedType = await showDialog<String>(
          context: context,
          builder: (BuildContext dialogContext) {
            return CreateLayerPanel(dialogContext: dialogContext);
          },
        );

        if (selectedType == null) {
          workflowActive = false; // User closed modal via cancel button
        } else if (selectedType == 'tile') {
          currentScreen = 'tile'; // Progress forward
        }
      }

      else if (currentScreen == 'tile') {
        final dynamic result = await showDialog<dynamic>(
          context: context,
          builder: (BuildContext dialogContext) {
            return TileLayerEditor(
              onBackPressed: () {
                Navigator.pop(dialogContext, 'go_back'); // Signal backward routing
              },
            );
          },
        );

        if (result == null) {
          workflowActive = false; // User dismissed window frame
        } else if (result == 'go_back') {
          currentScreen = 'panel'; // Return to selection screen stage
        } else if (result is LayerItem) {
          setState(() {
            _layers.add(result);
          });
          workflowActive = false; // Core creation sequence finished successfully

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Successfully instantiated: ${result.name}')),
          );
        }
      }
      // TODO: The configuration flow pauses here as requested.
      // TODO: Next, we will direct specific workflows based on the selected string type value.
    }
  }

  /// Opens a file picker to select a GeoJSON file and adds it as a new layer.
  Future<void> _pickAndLoadGeoJsonFile() async { //TODO: Wait for geojson import functionality
    try {
      final FilePickerResult? pickerResult = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'geojson'],
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
          const TopMenuBar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Viewport: Layers
                LayersSidebarPanel(
                  layers: _layers,
                  onLayersChanged: () => setState(() {}),
                  onCreatePressed: _showCreateLayerModal,
                  onInformationChanged: () => {},
                ),

                // Right Viewport: Map Canvas & Overlay Controls
                Expanded(
                  child: Stack(
                    children: [
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

          // Bottom Status Bar
          StatusBar(cursorCoordinates: _cursorCoordinates),
        ],
      ),
    );
  }
}
