import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/compound_provider.dart';
import '../../services/search_history_service.dart';
import '../../widgets/custom_search_screen.dart';
import 'compound_details_screen.dart';

class CompoundSearchScreen extends StatefulWidget {
  const CompoundSearchScreen({Key? key}) : super(key: key);

  @override
  State<CompoundSearchScreen> createState() => _CompoundSearchScreenState();
}

class _CompoundSearchScreenState extends State<CompoundSearchScreen> {
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  final List<String> _quickSearchItems = [
    'Aspirin',
    'Caffeine',
    'Glucose',
    'Ethanol',
    'Benzene',
    'Methane',
    'Water',
    'Carbon dioxide',
    'Sodium chloride',
    'Acetic acid'
  ];
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final history =
        await _searchHistoryService.getSearchHistory(SearchType.compound);
    setState(() {
      _searchHistory = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CompoundProvider>(
      builder: (context, provider, child) {
        return CustomSearchScreen(
          title: 'Compound Explorer',
          hintText: 'Search compounds or molecules...',
          searchIcon: Icons.science_outlined,
          quickSearchItems: _quickSearchItems,
          historyItems: _searchHistory,
          isLoading: provider.isLoading,
          error: provider.error,
          items: provider.compounds,
          imageUrl:
              'https://w0.peakpx.com/wallpaper/362/21/HD-wallpaper-adn-genetics.jpg',
          onSearch: (query) async {
            if (query.isNotEmpty) {
              await _searchHistoryService.addToSearchHistory(
                  query, SearchType.compound);
              await _loadSearchHistory();
              provider.searchCompounds(query);
            }
          },
          onClear: () {
            provider.clearCompounds();
          },
          onItemTap: (compound) async {
            await provider.fetchCompoundDetails(compound.cid);
            if (provider.error == null && provider.selectedCompound != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CompoundDetailsScreen(),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(provider.error ?? 'Failed to load compound details'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          itemBuilder: (compound) => Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: InkWell(
              onTap: () {
                provider.fetchCompoundDetails(compound.cid);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompoundDetailsScreen(),
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
                          compound.molecularFormula
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
                            compound.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            compound.molecularFormula,
                            style: GoogleFonts.poppins(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                          ),
                          Text(
                            'CID: ${compound.cid}',
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
              'Search for any chemical compound to discover its properties',
          emptyIcon: Icons.science,
        );
      },
    );
  }
}
