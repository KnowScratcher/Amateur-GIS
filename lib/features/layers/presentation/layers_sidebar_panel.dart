import 'package:flutter/material.dart';
import 'package:amateur_gis/features/layers/domain/layer_model.dart';
import 'package:amateur_gis/features/layers/presentation/components/sidebar_header.dart';

class LayersSidebarPanel extends StatelessWidget {
  final List<LayerItem> layers;
  final VoidCallback onLayersChanged;
  final VoidCallback onCreatePressed;
  final VoidCallback onInformationChanged;

  const LayersSidebarPanel({
    super.key,
    required this.layers,
    required this.onLayersChanged,
    required this.onCreatePressed,
    required this.onInformationChanged,
  });

  Icon getLayerIcon(LayerItem layer) {
    if (layer.type == 'tile') {
      return const Icon(Icons.map, size: 16, color: Colors.white70);
    } else if (layer.type == 'feature') {
      return const Icon(
        Icons.polyline_outlined,
        size: 16,
        color: Colors.white70,
      );
    } else if (layer.type == 'geojson') {
      return const Icon(Icons.code, size: 16, color: Colors.white70);
    } else {
      return const Icon(Icons.question_mark, size: 16, color: Colors.white70);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          SidebarHeader(onCreatePressed: onCreatePressed),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: layers.length,
              onReorderItem: (oldIndex, newIndex) {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final item = layers.removeAt(oldIndex);
                layers.insert(newIndex, item);
                onLayersChanged();
              },
              itemBuilder: (context, index) {
                final layer = layers[index];
                return ListTile(
                  key: ValueKey(layer.id),
                  leading: getLayerIcon(layer),
                  title: Text(layer.name, style: const TextStyle(fontSize: 13)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: layer.isVisible,
                        onChanged: (value) {
                          layer.isVisible = value ?? false;
                          onLayersChanged();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: onInformationChanged,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
