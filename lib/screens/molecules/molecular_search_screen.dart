import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/molecular_structure_provider.dart';
import '../../services/search_history_service.dart';
import '../../widgets/custom_search_screen.dart';
import 'molecular_structure_screen.dart';

class MolecularSearchScreen extends StatefulWidget {
  const MolecularSearchScreen({Key? key}) : super(key: key);

  @override
  State<MolecularSearchScreen> createState() => _MolecularSearchScreenState();
}

class _MolecularSearchScreenState extends State<MolecularSearchScreen> {
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  final List<String> _quickSearchItems = [
    'Glucose',
    'Benzene',
    'Ethanol',
    'Methane',
    'Water',
    'Carbon dioxide',
    'Sodium chloride',
    'Acetic acid',
    'Ammonia',
    'Sulfuric acid'
  ];
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final history = await _searchHistoryService
        .getSearchHistory(SearchType.molecularStructure);
    setState(() {
      _searchHistory = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MolecularStructureProvider>(
      builder: (context, provider, child) {
        return CustomSearchScreen(
          title: 'Molecular Search',
          hintText: 'Enter compound name (e.g., "glucose", "benzene")',
          searchIcon: Icons.science_outlined,
          quickSearchItems: _quickSearchItems,
          historyItems: _searchHistory,
          isLoading: provider.isLoading,
          error: provider.error,
          items: provider.structure ?? [],
          onSearch: (query) async {
            if (query.isNotEmpty) {
              await _searchHistoryService.addToSearchHistory(
                  query, SearchType.molecularStructure);
              await _loadSearchHistory();
              provider.searchByCompoundName(query);
            }
          },
          onClear: () {
            provider.clearStructures();
          },
          onItemTap: (structure) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MolecularStructureScreen(structure: structure),
              ),
            );
          },
          onAutoComplete: (query) =>
              provider.fetchAutoCompleteSuggestions(query),
          itemBuilder: (structure) => Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MolecularStructureScreen(structure: structure),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          structure.molecularFormula
                              .replaceAll(RegExp(r'[0-9]'), ''),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            structure.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            structure.molecularFormula,
                            style: GoogleFonts.poppins(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                          ),
                          Text(
                            'CID: ${structure.cid}',
                            style: GoogleFonts.poppins(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          emptyMessage: 'Ready to Explore',
          emptySubMessage:
              'Search for any compound to view its molecular structure',
          emptyIcon: Icons.science,
        );
      },
    );
  }
}
