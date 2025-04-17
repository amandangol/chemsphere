import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/drug_provider.dart';
import '../../services/search_history_service.dart';
import '../../widgets/custom_search_screen.dart';
import 'drug_detail_screen.dart';

class DrugSearchScreen extends StatefulWidget {
  const DrugSearchScreen({Key? key}) : super(key: key);

  @override
  State<DrugSearchScreen> createState() => _DrugSearchScreenState();
}

class _DrugSearchScreenState extends State<DrugSearchScreen> {
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  List<String> _quickSearchItems = [
    'Aspirin',
    'Ibuprofen',
    'Paracetamol',
    'Amoxicillin',
    'Metformin',
    'Atorvastatin',
    'Omeprazole',
    'Lisinopril',
    'Levothyroxine',
    'Metoprolol'
  ];
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final history =
        await _searchHistoryService.getSearchHistory(SearchType.drug);
    setState(() {
      _searchHistory = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DrugProvider>(
      builder: (context, provider, child) {
        return CustomSearchScreen(
          title: 'Drug Search',
          hintText: 'Enter drug name (e.g., "aspirin", "ibuprofen")',
          searchIcon: Icons.medication_outlined,
          quickSearchItems: _quickSearchItems,
          historyItems: _searchHistory,
          isLoading: provider.isLoading,
          error: provider.error,
          items: provider.drugs,
          imageUrl:
              'https://images.rawpixel.com/image_800/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvcm0zNzNiYXRjaDE1LTIxNy0wMS5qcGc.jpg',
          onSearch: (query) async {
            if (query.isNotEmpty) {
              await _searchHistoryService.addToSearchHistory(
                  query, SearchType.drug);
              await _loadSearchHistory();
              provider.searchDrugs(query);
            }
          },
          onClear: () {
            provider.clearDrugs();
          },
          onItemTap: (drug) {
            provider.fetchDrugDetails(drug.cid);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DrugDetailScreen(),
              ),
            );
          },
          onAutoComplete: (query) =>
              provider.fetchAutoCompleteSuggestions(query),
          itemBuilder: (drug) => Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: InkWell(
              onTap: () {
                provider.fetchDrugDetails(drug.cid);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DrugDetailScreen(),
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${drug.cid}/PNG',
                          fit: BoxFit.cover,
                          errorWidget: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.medication_outlined,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
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
                            drug.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            drug.molecularFormula,
                            style: GoogleFonts.poppins(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                          ),
                          Text(
                            'CID: ${drug.cid}',
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
          emptySubMessage: 'Search for any drug to discover its properties',
          emptyIcon: Icons.medication,
        );
      },
    );
  }
}
