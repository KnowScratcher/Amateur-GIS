import 'package:flutter/material.dart';
import 'package:amateur_gis/features/layers/domain/layer_model.dart';
import 'package:amateur_gis/features/layers/presentation/components/sidebar_header.dart';

class LayersSidebarPanel extends StatelessWidget {
  final List<LayerItem> layers;
  final VoidCallback onLayersChanged;
  final VoidCallback onImportDataset;
  final VoidCallback onInformationChanged;

  const LayersSidebarPanel({
    super.key,
    required this.layers,
    required this.onLayersChanged,
    required this.onImportDataset,
    required this.onInformationChanged,
  });

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
          SidebarHeader(onImportPressed: onImportDataset),
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
                  leading: Checkbox(
                    value: layer.isVisible,
                    onChanged: (value) {
                      layer.isVisible = value ?? false;
                      onLayersChanged();
                    },
                  ),
                  title: Text(layer.name, style: const TextStyle(fontSize: 13)),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onInformationChanged,
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
