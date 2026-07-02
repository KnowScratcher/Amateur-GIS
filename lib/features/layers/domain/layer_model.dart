import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson2/flutter_map_geojson2.dart';

class LayerItem {
  final String id;
  final String name;
  final String type;
  bool isVisible;

  LayerItem({required this.id, required this.name, this.isVisible = true, required this.type});
}

class GeojsonLayerItem extends LayerItem {
  final GeoJsonLayer geojsonLayer;

  GeojsonLayerItem({
    required super.id,
    required super.name,
    required this.geojsonLayer,
    super.type = 'geojson',
  });
}

class FeatureLayerItem extends LayerItem {
  final List<Marker> markers;
  final List<Polyline> polylines;
  final List<Polygon> polygons;

  FeatureLayerItem({
    required super.id,
    required super.name,
    this.markers = const [],
    this.polylines = const [],
    this.polygons = const [],
    super.type = 'feature',
  });
}

class TileLayerItem extends LayerItem {
  final String provider;

  TileLayerItem({
    required super.id,
    required super.name,
    required this.provider,
    super.type = 'tile',
  });

  late final TileLayer tileLayer = TileLayer(
    urlTemplate: provider,
    userAgentPackageName:
    'AmateurGIS/1.0.0+1 (contact: ${dotenv.env["contact"]})',
    tileProvider: NetworkTileProvider(
      cachingProvider: BuiltInMapCachingProvider.getOrCreateInstance(
        maxCacheSize: 1_000_000_000, // 1 GB is the default
      ),
    ),
  );

}
