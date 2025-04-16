import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/element_provider.dart';
import '../../models/element.dart' as element_model;
import 'element_detail_screen.dart';

class PeriodicTableScreen extends StatelessWidget {
  const PeriodicTableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Periodic Table'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ElementProvider>().fetchElements(),
          ),
        ],
      ),
      body: Consumer<ElementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchElements(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          MediaQuery.of(context).size.width < 600 ? 6 : 10,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                    itemCount: provider.elements.length,
                    itemBuilder: (context, index) {
                      final element = provider.elements[index];
                      return ElementCard(element: element);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ElementCard extends StatelessWidget {
  final element_model.Element element;

  const ElementCard({Key? key, required this.element}) : super(key: key);

  Color _getElementColor() {
    switch (element.category.toLowerCase()) {
      case 'diatomic nonmetal':
      case 'polyatomic nonmetal':
        return Colors.green;
      case 'alkali metal':
        return Colors.red;
      case 'alkaline earth metal':
        return Colors.orange;
      case 'transition metal':
        return Colors.yellow.shade700;
      case 'metalloid':
        return Colors.purple;
      case 'halogen':
        return Colors.lightBlue;
      case 'noble gas':
        return Colors.blue;
      case 'lanthanide':
        return Colors.pink;
      case 'actinide':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }

  String _formatAtomicMass(double mass) {
    String formatted = mass.toStringAsFixed(2);
    while (formatted.endsWith('0')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    if (formatted.endsWith('.')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getElementColor().withOpacity(0.3),
      elevation: 3,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          context.read<ElementProvider>().fetchElementDetails(element.symbol);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ElementDetailScreen(),
            ),
          );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              padding: const EdgeInsets.all(1),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Container(
                  width: 50,
                  height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${element.number}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        element.symbol,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        element.name,
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatAtomicMass(element.atomicMass),
                        style: const TextStyle(fontSize: 8),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
