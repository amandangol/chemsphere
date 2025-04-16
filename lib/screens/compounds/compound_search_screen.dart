import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/compound_provider.dart';
import 'compound_detail_screen.dart';

class CompoundSearchScreen extends StatelessWidget {
  const CompoundSearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compound Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Enter compound name (e.g., "aspirin", "caffeine")',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                prefixIcon: Icon(Icons.science),
                suffixIcon: Icon(Icons.clear),
              ),
              onSubmitted: (query) {
                context.read<CompoundProvider>().searchCompounds(query);
              },
            ),
            const SizedBox(height: 16),
            Consumer<CompoundProvider>(
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
                          onPressed: () => provider.searchCompounds(''),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.compounds.isEmpty) {
                  return const Center(
                    child: Text('No compounds found. Try searching for one.'),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: provider.compounds.length,
                    itemBuilder: (context, index) {
                      final compound = provider.compounds[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(compound.title),
                          subtitle: Text(compound.molecularFormula),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () {
                            provider.fetchCompoundDetails(compound.cid);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CompoundDetailScreen(),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
