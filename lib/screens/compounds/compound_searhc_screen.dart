import 'package:cached_network_image/cached_network_image.dart';
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
  List<String> _availableHeadings = [];
  String? _selectedHeading;
  String? _selectedValue;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _loadHeadings();
  }

  Future<void> _loadSearchHistory() async {
    final history =
        await _searchHistoryService.getSearchHistory(SearchType.compound);
    setState(() {
      _searchHistory = history;
    });
  }

  Future<void> _loadHeadings() async {
    final headings =
        await context.read<CompoundProvider>().getAvailableHeadings();
    setState(() {
      _availableHeadings = headings;
    });
  }

  Widget _buildFilterSection() {
    if (!_showFilters) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Filter Compounds',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedHeading,
            decoration: InputDecoration(
              labelText: 'Property',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: _availableHeadings.map((heading) {
              return DropdownMenuItem(
                value: heading,
                child: Text(heading),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedHeading = value;
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Value',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _selectedValue = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_selectedHeading != null) {
                      final provider = context.read<CompoundProvider>();
                      await provider.fetchCompoundsByCriteria(
                        heading: _selectedHeading,
                        value: _selectedValue,
                      );
                    }
                  },
                  child: Text(
                    'Apply Filter',
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedHeading = null;
                    _selectedValue = null;
                    _showFilters = false;
                  });
                  context.read<CompoundProvider>().clearCompounds();
                },
                child: Text(
                  'Clear',
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CompoundProvider>(
      builder: (context, compoundProvider, child) {
        return Stack(
          children: [
            CustomSearchScreen(
              title: 'Compound Search',
              hintText: 'Search compounds...',
              searchIcon: Icons.science_outlined,
              quickSearchItems: _quickSearchItems,
              historyItems: _searchHistory,
              isLoading: compoundProvider.isLoading,
              error: compoundProvider.error,
              items: compoundProvider.compounds,
              imageUrl:
                  'https://w0.peakpx.com/wallpaper/362/21/HD-wallpaper-adn-genetics.jpg',
              onSearch: (query) async {
                if (query.isNotEmpty) {
                  await _searchHistoryService.addToSearchHistory(
                      query, SearchType.compound);
                  await _loadSearchHistory();
                  compoundProvider.searchCompounds(query);
                }
              },
              onClear: () {
                compoundProvider.clearCompounds();
              },
              onItemTap: (item) async {
                final compound = item;
                await compoundProvider.fetchCompoundDetails(compound.cid);
                if (compoundProvider.error == null &&
                    compoundProvider.selectedCompound != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CompoundDetailsScreen(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(compoundProvider.error ??
                          'Failed to load compound details'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              },
              onAutoComplete: (query) =>
                  compoundProvider.fetchAutoCompleteSuggestions(query),
              itemBuilder: (item) => Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: InkWell(
                  onTap: () {
                    final compound = item;
                    compoundProvider.fetchCompoundDetails(compound.cid);
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl:
                                  'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${item.cid}/PNG',
                              fit: BoxFit.contain,
                              errorWidget: (context, error, stackTrace) =>
                                  Center(
                                child: Icon(
                                  Icons.science_outlined,
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
                                item.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                item.molecularFormula,
                                style: GoogleFonts.poppins(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                              Text(
                                'CID: ${item.cid}',
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
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                ),
              ],
            ),
            if (_showFilters)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildFilterSection(),
              ),
          ],
        );
      },
    );
  }
}
