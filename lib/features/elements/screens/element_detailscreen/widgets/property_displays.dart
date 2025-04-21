import 'package:flutter/material.dart';
import 'detail_widgets.dart';

/// Widget for displaying a property in the quick facts grid
class PropertyDisplay extends StatelessWidget {
  final String label;
  final String value;

  const PropertyDisplay({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value.isEmpty ? 'N/A' : value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for displaying a property in a row format
class PropertyRow extends StatelessWidget {
  final String property;
  final String value;

  const PropertyRow({
    Key? key,
    required this.property,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$property:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: TextStyle(
                color: value.isEmpty ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for displaying quick facts grid
class QuickFactsGrid extends StatelessWidget {
  final Map<String, String> properties;
  final int crossAxisCount;
  final double childAspectRatio;

  const QuickFactsGrid({
    Key? key,
    required this.properties,
    this.crossAxisCount = 2,
    this.childAspectRatio = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final propertyList = properties.entries.toList();

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: propertyList.length,
      itemBuilder: (context, index) {
        final entry = propertyList[index];
        return PropertyDisplay(
          label: entry.key,
          value: entry.value,
        );
      },
    );
  }
}

/// Widget for displaying a list of properties in row format
class PropertyList extends StatelessWidget {
  final Map<String, String> properties;

  const PropertyList({
    Key? key,
    required this.properties,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final propertyList = properties.entries.toList();

    return Column(
      children: propertyList
          .map((entry) => PropertyRow(
                property: entry.key,
                value: entry.value,
              ))
          .toList(),
    );
  }
}
