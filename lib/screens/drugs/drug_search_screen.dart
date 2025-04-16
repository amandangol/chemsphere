import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/drug_provider.dart';
import 'drug_detail_screen.dart';

class DrugSearchScreen extends StatelessWidget {
  const DrugSearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drug Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Enter drug name (e.g., "aspirin", "ibuprofen")',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                prefixIcon: Icon(Icons.medication),
                suffixIcon: Icon(Icons.clear),
              ),
              onSubmitted: (query) {
                context.read<DrugProvider>().searchDrugs(query);
              },
            ),
            const SizedBox(height: 16),
            Consumer<DrugProvider>(
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
                          onPressed: () => provider.searchDrugs(''),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.drugs.isEmpty) {
                  return const Center(
                    child: Text('No drugs found. Try searching for one.'),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: provider.drugs.length,
                    itemBuilder: (context, index) {
                      final drug = provider.drugs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(drug.title),
                          subtitle: Text(drug.molecularFormula),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () {
                            provider.fetchDrugDetails(drug.cid);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DrugDetailScreen(),
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
