import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:amateur_gis/features/layers/domain/layer_model.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';

class MapCanvasRenderZone extends StatefulWidget {
  final List<LayerItem> activeLayers;
  final AnimatedMapController mapController;
  final ValueChanged<LatLng> onPointerHover;

  const MapCanvasRenderZone({
    super.key,
    required this.activeLayers,
    required this.mapController,
    required this.onPointerHover,
  });

  @override
  State<MapCanvasRenderZone> createState() => _MapCanvasRenderZoneState();
}

class _MapCanvasRenderZoneState extends State<MapCanvasRenderZone> {
  LatLng _currentGeoPosition = const LatLng(0.0, 0.0);

  void _showContextMenu(BuildContext context, Offset globalPosition) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    // Format the string for copy operation
    final String latLonString =
        '${_currentGeoPosition.latitude.toStringAsFixed(5)}, ${_currentGeoPosition.longitude.toStringAsFixed(5)}';

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        globalPosition & const Size(50, 50), // Anchor rectangle at cursor point
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'copy',
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              const Icon(Icons.copy, size: 16, color: Colors.white70),
              const SizedBox(width: 10),
              Expanded(child: Text('Copy $latLonString')),
            ],
          ),
        ),
      ],
    ).then((value) {
      // FIX: Guard the async gap check before referencing the build context tree
      if (!mounted) return;

      if (value == 'copy') {
        Clipboard.setData(ClipboardData(text: latLonString));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coordinates copied to clipboard'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> layers = [];
    //   // OpenStreetMap raster tile layer
    //   TileLayer(
    //     urlTemplate: 'http://mt0.google.com/vt/lyrs=p&hl=en&x={x}&y={y}&z={z}',
    //     userAgentPackageName:
    //         'AmateurGIS/1.0.0+1 (contact: ${dotenv.env["contact"]})',
    //     tileProvider: NetworkTileProvider(
    //       cachingProvider: BuiltInMapCachingProvider.getOrCreateInstance(
    //         maxCacheSize: 1_000_000_000, // 1 GB is the default
    //       ),
    //     ),
    //   ),
    // ];

    // Convert parsed background coordinates into flutter_map Polyline instances
    for (final layer in widget.activeLayers) {
      if (!layer.isVisible) continue;

      if (layer is GeojsonLayerItem) {
        layers.add(layer.geojsonLayer);
      } else if (layer is FeatureLayerItem) {
        layers.add(MarkerLayer(markers: layer.markers));
        layers.add(PolylineLayer(polylines: layer.polylines));
        layers.add(PolygonLayer(polygons: layer.polygons));
      }
    }
    return FlutterMap(
      mapController: widget.mapController.mapController,
      options: const MapOptions(
        initialCenter: LatLng(0.0, 0.0),
        initialZoom: 2,
        interactionOptions: InteractionOptions(
          flingAnimationDampingRatio: 2,
          flags:
              InteractiveFlag.all &
              ~InteractiveFlag
                  .rotate, // Disable rotation for standard desktop workflows
        ),
      ),
      children: [
        ...layers,
        Positioned.fill(
          child: Builder(
            builder: (mapContext) {
              return GestureDetector(
                // Detect right-click release actions on desktop system nodes
                onSecondaryTapUp: (details) {
                  _showContextMenu(context, details.globalPosition);
                },
                child: MouseRegion(
                  onHover: (PointerHoverEvent event) {
                    // Access the active map camera context configuration
                    final camera = MapCamera.of(mapContext);

                    // FIX: Use offsetToLatLng instead of pointToLatLng
                    _currentGeoPosition = camera.screenOffsetToLatLng(
                      Offset(event.localPosition.dx, event.localPosition.dy),
                    );

                    // Bubble the accurate coordinates back up to the workspace screen state
                    widget.onPointerHover(_currentGeoPosition);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
