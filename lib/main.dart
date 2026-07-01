import 'package:flutter/material.dart';

void main() {
  runApp(const GisDesktopApp());
}

class GisDesktopApp extends StatelessWidget {
  const GisDesktopApp({super.key});

  @override
  Widget build(BuildContext themeContext) {
    return MaterialApp(
      title: 'Desktop GIS Workspace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        cardColor: const Color(0xFF252526),
        dividerColor: const Color(0xFF3F3F46),
      ),
      home: const GisMainWorkspace(),
    );
  }
}

class LayerItem {
  final String id;
  final String name;
  bool isVisible;

  LayerItem({required this.id, required this.name, this.isVisible = true});
}

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
                Container(
                  width: 320,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      right: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SidebarHeader(),
                      Expanded(
                        child: ReorderableListView.builder(
                          itemCount: _layers.length,
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              final item = _layers.removeAt(oldIndex);
                              _layers.insert(newIndex, item);
                            });
                          },
                          itemBuilder: (context, index) {
                            final layer = _layers[index];
                            return ListTile(
                              key: ValueKey(layer.id),
                              leading: const Icon(
                                Icons.drag_indicator,
                                color: Colors.grey,
                              ),
                              title: Text(
                                layer.name,
                                style: const TextStyle(fontSize: 13),
                              ),
                              trailing: Checkbox(
                                value: layer.isVisible,
                                onChanged: (value) {
                                  setState(() {
                                    layer.isVisible = value ?? false;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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
          Container(
            height: 28,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF007ACC), // Standard status bar tint
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _cursorCoordinates,
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
                const Text(
                  'EPSG:4326 (WGS 84)  |  Scale 1:25,000',
                  style: TextStyle(fontSize: 11, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TopMenuBar extends StatelessWidget {
  const TopMenuBar({super.key});

  @override
  Widget build(BuildContext themeContext) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF3C3C3C),
        border: Border(
          bottom: BorderSide(color: Theme.of(themeContext).dividerColor),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          const Icon(Icons.public, size: 18, color: Colors.green),
          const SizedBox(width: 12),
          _buildMenuButton('File'),
          _buildMenuButton('Edit'),
          _buildMenuButton('Layer'),
          _buildMenuButton('Vector'),
          _buildMenuButton('Raster'),
          _buildMenuButton('Help'),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
        ),
      ),
    );
  }
}

class SidebarHeader extends StatelessWidget {
  const SidebarHeader({super.key});

  @override
  Widget build(BuildContext themeContext) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Layers Control Panel',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add_box, size: 18),
            onPressed: () {}, // Trigger local file picker
            tooltip: 'Import Spatial Dataset',
          ),
        ],
      ),
    );
  }
}

class MapCanvasRenderZone extends StatelessWidget {
  final List<LayerItem> activeLayers;

  const MapCanvasRenderZone({super.key, required this.activeLayers});

  @override
  Widget build(BuildContext themeContext) {
    // CustomPainter or an optimized third-party GIS canvas renders inside this block
    return CustomPaint(
      painter: GridCanvasPainter(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 48, color: Colors.white30),
            const SizedBox(height: 8),
            const Text(
              'Interactive Spatial Vector / Raster Canvas',
              style: TextStyle(color: Colors.white30, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class GridCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF2A2A2A)
          ..strokeWidth = 1.0;

    const double step = 40.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NavigationCluster extends StatelessWidget {
  const NavigationCluster({super.key});

  @override
  Widget build(BuildContext themeContext) {
    return Card(
      elevation: 4,
      color: const Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            IconButton(icon: const Icon(Icons.add), onPressed: () {}),
            const Divider(height: 1, color: Colors.black26),
            IconButton(icon: const Icon(Icons.remove), onPressed: () {}),
            const Divider(height: 1, color: Colors.black26),
            IconButton(icon: const Icon(Icons.explore), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
