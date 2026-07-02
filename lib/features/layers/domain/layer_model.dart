import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson2/flutter_map_geojson2.dart';

class LayerItem {
  final String id;
  final String name;
  bool isVisible;

  LayerItem({required this.id, required this.name, this.isVisible = true});
}

class GeojsonLayerItem extends LayerItem {
  final GeoJsonLayer geojsonLayer;

  GeojsonLayerItem({
    required super.id,
    required super.name,
    required this.geojsonLayer,
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
  });
}

class TileLayerItem extends LayerItem {
  final TileLayer tileLayer;

  TileLayerItem({
    required super.id,
    required super.name,
    required this.tileLayer,
  });
}
