import 'package:flutter/material.dart';

class CreateLayerPanel extends StatefulWidget {
  final BuildContext dialogContext;
  const CreateLayerPanel({super.key, required this.dialogContext});

  @override
  State<CreateLayerPanel> createState() => _CreateLayerPanelState();
}

class _CreateLayerPanelState extends State<CreateLayerPanel> {
  /// Builds a clickable option for the layer creation modal.
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

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select the spatial layer source format type you want to instantiate in your current workspace:',
                style: TextStyle(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 16),

              // Tile Layer Selection Option
              _buildLayerTypeOption(
                context: widget.dialogContext,
                title: 'Raster Tile Layer',
                subtitle: 'Load map imagery slices from remote web servers (XYZ / WMS)',
                icon: Icons.map,
                value: 'tile',
              ),
              const SizedBox(height: 10),

              // Feature Layer Selection Option
              _buildLayerTypeOption(
                context: widget.dialogContext,
                title: 'Feature Vector Layer',
                subtitle: 'Instantiate custom data nodes, line strings, and bounding shapes',
                icon: Icons.polyline_outlined,
                value: 'feature',
              ),
              const SizedBox(height: 10),

              // GeoJSON Selection Option
              _buildLayerTypeOption(
                context: widget.dialogContext,
                title: 'GeoJSON Data Source',
                subtitle: 'Import complex vector coordinates directly from a local static file',
                icon: Icons.code,
                value: 'geojson',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(widget.dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.purple[30], fontSize: 13),
            ),
          ),
        ],
    );
  }
}