import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:amateur_gis/features/layers/domain/layer_model.dart';
import 'package:latlong2/latlong.dart';

class MapCanvasRenderZone extends StatelessWidget {
  final List<LayerItem> activeLayers;

  const MapCanvasRenderZone({super.key, required this.activeLayers});

  @override
  Widget build(BuildContext themeContext) {
    final List<Polyline> allPolylines = [];
    final List<Widget> layers = [
      // OpenStreetMap raster tile layer
      TileLayer(
        urlTemplate: 'http://mt0.google.com/vt/lyrs=p&hl=en&x={x}&y={y}&z={z}',
        userAgentPackageName: 'AmateurGIS/1.0.0+1 (contact: ${dotenv.env["contact"]})',
        tileProvider: NetworkTileProvider(
          cachingProvider: BuiltInMapCachingProvider.getOrCreateInstance(
            maxCacheSize: 1_000_000_000, // 1 GB is the default
          ),
        ),
      ),
    ];

    // Convert parsed background coordinates into flutter_map Polyline instances
    for (final layer in activeLayers) {
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
      options: const MapOptions(
        initialCenter: LatLng(0.0, 0.0),
        initialZoom: 2,
        interactionOptions: InteractionOptions(
          flags:
              InteractiveFlag.all &
              ~InteractiveFlag
                  .rotate, // Disable rotation for standard desktop workflows
        ),
      ),
      children: layers,
    );
  }
}
