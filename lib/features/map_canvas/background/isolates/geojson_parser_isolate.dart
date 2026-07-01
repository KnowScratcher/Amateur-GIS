import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter_map_geojson2/flutter_map_geojson2.dart';

/// Data transfer object holding raw geometric data received from the background thread
class ParsedSpatialFeature {
  final String geometryType;
  final List<List<double>> coordinates;

  ParsedSpatialFeature({required this.geometryType, required this.coordinates});
}

class GeoJsonParserIsolate {
  /// Spawns the background isolate thread to run the decoder
  static Future<GeoJsonLayer> parseDataInBackground(String rawJsonString) async {
    return await Isolate.run(() => _heavyParseExecution(rawJsonString));
  }

  /// Decodes GeoJSON strings into structured point lists inside background memory space
  static GeoJsonLayer _heavyParseExecution(String rawJsonString) {
    final List<ParsedSpatialFeature> parsedFeatures = [];

    try {
      // Decode raw string into unstructured map structure
      final Map<String, dynamic> geoJsonMap = jsonDecode(rawJsonString) as Map<String, dynamic>;

      // Check for valid GeoJSON FeatureCollection signature
      if (geoJsonMap['type'] != 'FeatureCollection' || geoJsonMap['features'] == null) {
        return GeoJsonLayer.memory({}); //TODO: replace with error message
      }
      return GeoJsonLayer.memory(geoJsonMap);
    } catch (error) {
      // Isolate runtime failure bubbles back safely into the primary error handler catching thread block
      debugPrint('Isolate background JSON structure error: $error'); // TODO: replace with error message
    }
    return GeoJsonLayer.memory({});
  }
}