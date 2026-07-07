import 'package:amateur_gis/features/layers/domain/layer_model.dart';
import 'package:flutter/material.dart';

class TileLayerEditor extends StatefulWidget {
  final VoidCallback? onBackPressed;
  const TileLayerEditor({super.key, this.onBackPressed});

  @override
  State<TileLayerEditor> createState() => _TileLayerEditorModalState();
}

class _TileLayerEditorModalState extends State<TileLayerEditor> {
  // Form variables
  String _layerName = 'New Raster Layer';
  String _selectedSource = 'osm'; // Default option
  final TextEditingController _urlController = TextEditingController(
    text: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _updatePresetUrl(String? sourceCode) {
    if (sourceCode == null) return;
    setState(() {
      _selectedSource = sourceCode;
      if (sourceCode == 'osm') {
        _urlController.text = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      } else if (sourceCode == 'google') {
        _urlController.text =
            'http://mt0.google.com/vt/lyrs=m&hl=en&x={x}&y={y}&z={z}';
      } else if (sourceCode == 'custom') {
        _urlController.text = ''; // Clear for user input
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildTileEditorPage();
  }

  // --- TILE FORM CONFIGURATOR ---
  Widget _buildTileEditorPage() {
    return AlertDialog(
      backgroundColor: const Color(0xFF252526),
      title: const Row(
        children: [
          Icon(Icons.edit, color: Colors.blue, size: 18),
          SizedBox(width: 10),
          Text(
            'Configure Tile Layer',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Layer Name input
            const Text(
              'Layer Display Name',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 6),
            TextField(
              style: const TextStyle(fontSize: 13, color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                hintText: _layerName,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
              onChanged: (text) => _layerName = text,
            ),
            const SizedBox(height: 16),

            // Tile Provider Source Dropdown selection
            const Text(
              'Tile Source Provider',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                border: Border.all(color: const Color(0xFF3F3F46)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSource,
                  dropdownColor: const Color(0xFF252526),
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: 'osm',
                      child: Text('OpenStreetMap Standard'),
                    ),
                    DropdownMenuItem(
                      value: 'google',
                      child: Text('Google Maps Road'),
                    ),
                    DropdownMenuItem(
                      value: 'custom',
                      child: Text('Custom XYZ Server URL...'),
                    ),
                  ],
                  onChanged: _updatePresetUrl,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Conditional rendering layout for Custom template configurations
            if (_selectedSource == 'custom') ...[
              const Text(
                'XYZ URL Template (use {x}, {y}, {z})',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontFamily: 'monospace',
                      ),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        hintText: 'https://example.com/{z}/{x}/{y}.png',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3C3C3C),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    onPressed: () {
                      final testUrl = _urlController.text;
                      debugPrint(
                        'Testing connection endpoint link template: $testUrl',
                      );
                      // Add networking check queries or connections validation routines here
                    },
                    child: const Text(
                      'Test Source',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (widget.onBackPressed != null) ...[
          TextButton(
            onPressed: widget.onBackPressed,
            child: const Text('Back', style: TextStyle(color: Colors.white30)),
          ),
        ],
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: () {
            // Build the finished layer payload back up out of parameters
            final generatedLayer = TileLayerItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name:
                  _layerName.trim().isEmpty ? 'Raster Tile Layer' : _layerName,
              provider: _urlController.text,
            );
            Navigator.pop(context, generatedLayer);
          },
          child: const Text(
            'Create Layer',
            style: TextStyle(fontSize: 13, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
