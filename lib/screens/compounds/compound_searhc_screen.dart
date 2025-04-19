import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io'; // Import for SocketException
import 'provider/compound_provider.dart';
import '../../services/search_history_service.dart';
import '../../widgets/custom_search_screen.dart';
import '../../utils/error_handler.dart'; // Import ErrorHandler
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
  bool _showInfoCard = true;

  // Information about chemical compounds for educational purposes
  final Map<String, Map<String, String>> _compoundInfo = {
    'Glucose': {
      'formula': 'C₆H₁₂O₆',
      'description':
          'A simple sugar that is an important energy source in living organisms.',
      'uses': 'Energy source in cells, food sweetener, medical IV solutions.'
    },
    'Benzene': {
      'formula': 'C₆H₆',
      'description': 'An aromatic hydrocarbon with a ring structure.',
      'uses': 'Precursor for many chemicals, solvent in industrial processes.'
    },
    'Ethanol': {
      'formula': 'C₂H₅OH',
      'description': 'A simple alcohol produced by fermentation.',
      'uses': 'Alcoholic beverages, biofuel, disinfectant, solvent.'
    },
  };

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

  Widget _buildInfoCard() {
    if (!_showInfoCard) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        title: Text(
          "What are Chemical Compounds?",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        leading: Icon(
          Icons.science,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.expand_more,
              color: Theme.of(context)
                  .colorScheme
                  .onPrimaryContainer
                  .withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.close,
                color: Theme.of(context)
                    .colorScheme
                    .onPrimaryContainer
                    .withOpacity(0.7),
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _showInfoCard = false;
                });
              },
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "A chemical compound is a substance composed of two or more different elements (atoms) that are chemically bonded together in fixed proportions.",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer
                        .withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "For example, water (H₂O) is a compound of hydrogen and oxygen in a 2:1 ratio.",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer
                        .withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoPill("Inorganic Compounds", Icons.category),
                    const SizedBox(width: 8),
                    _buildInfoPill("Organic Compounds", Icons.emoji_nature),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill(String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color:
              Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .onPrimaryContainer
                .withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context)
                  .colorScheme
                  .onPrimaryContainer
                  .withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer
                      .withOpacity(0.9),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    if (!_showFilters) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              helperText:
                  'Example: For "Molecular Weight", enter a number like 18 for water',
              helperStyle: GoogleFonts.poppins(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withOpacity(0.7),
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
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_selectedHeading != null) {
                      final provider = context.read<CompoundProvider>();
                      await provider.fetchCompoundsByCriteria(
                        heading: _selectedHeading,
                        value: _selectedValue,
                      );
                    }
                  },
                  icon: const Icon(Icons.filter_alt),
                  label: Text(
                    'Apply Filter',
                    style: GoogleFonts.poppins(),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedHeading = null;
                    _selectedValue = null;
                    _showFilters = false;
                  });
                  context.read<CompoundProvider>().clearCompounds();
                },
                icon: const Icon(Icons.clear),
                label: Text(
                  'Clear',
                  style: GoogleFonts.poppins(),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompoundGlossary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        title: Text(
          "Common Compound Terms",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: const Icon(Icons.menu_book),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          _buildGlossaryItem(
              "Molecular Formula",
              "A representation of a molecule using chemical symbols to indicate the types of atoms with subscripts to show the number of atoms of each element.",
              "Example: H₂O (water)"),
          _buildGlossaryItem(
              "Molecular Weight",
              "The sum of the atomic weights of all atoms in a molecule, measured in atomic mass units (AMU) or Daltons.",
              "Example: Water (H₂O) has a molecular weight of ~18 g/mol"),
          _buildGlossaryItem(
              "CID",
              "PubChem Compound ID - a unique identifier assigned to chemical compounds in the PubChem database.",
              "Example: Water has CID 962"),
          _buildGlossaryItem(
              "Functional Group",
              "A specific group of atoms within molecules that are responsible for the characteristic chemical reactions of those molecules.",
              "Examples: Hydroxyl (-OH), Carbonyl (C=O), Amino (-NH₂)"),
        ],
      ),
    );
  }

  Widget _buildGlossaryItem(String term, String definition, String example) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            term,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            definition,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            example,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withOpacity(0.8),
            ),
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
              customHeader: Column(
                children: [
                  // Educational info card
                  _buildInfoCard(),

                  // Glossary
                  if (_showInfoCard) _buildCompoundGlossary(),
                ],
              ),
              onSearch: (query) async {
                if (query.isNotEmpty) {
                  try {
                    await _searchHistoryService.addToSearchHistory(
                        query, SearchType.compound);
                    await _loadSearchHistory();
                    await compoundProvider.searchCompounds(query);
                  } catch (e) {
                    print('Error during search: $e');
                    if (e is SocketException) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ErrorHandler.getErrorMessage(e)),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  }
                }
              },
              onClear: () {
                compoundProvider.clearCompounds();
              },
              onItemTap: (item) async {
                final compound = item;
                try {
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
                } catch (e) {
                  print('Error tapping item: $e');
                  ErrorHandler.showErrorSnackBar(
                    context,
                    ErrorHandler.getErrorMessage(e),
                  );
                }
              },
              onAutoComplete: (query) async {
                try {
                  return await compoundProvider
                      .fetchAutoCompleteSuggestions(query);
                } catch (e) {
                  print('Error during autocomplete: $e');
                  if (e is SocketException) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ErrorHandler.getErrorMessage(e)),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                  return [];
                }
              },
              itemBuilder: (item) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: InkWell(
                  onTap: () {
                    final compound = item;
                    try {
                      compoundProvider.fetchCompoundDetails(compound.cid);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CompoundDetailsScreen(),
                        ),
                      );
                    } catch (e) {
                      print('Error navigating to details: $e');
                      ErrorHandler.showErrorSnackBar(
                        context,
                        ErrorHandler.getErrorMessage(e),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
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
                              placeholder: (context, url) => Container(
                                width: 120,
                                height: 120,
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, error, stackTrace) {
                                // Improved error handling for image loading
                                print('Error loading image: $error');
                                String errorMessage = 'Image not available';

                                if (error is SocketException ||
                                    ErrorHandler.isNetworkError(error)) {
                                  errorMessage = 'Network error';
                                }

                                return Container(
                                  width: 120,
                                  height: 120,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                      if (errorMessage.isNotEmpty)
                                        Text(
                                          errorMessage,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                    ],
                                  ),
                                );
                              },
                              // Add retries for network issues
                              maxHeightDiskCache: 250,
                              maxWidthDiskCache: 250,
                              memCacheWidth: 250,
                              memCacheHeight: 250,
                              useOldImageOnUrlChange: true,
                              fadeInDuration: const Duration(milliseconds: 300),
                              errorListener: (e) {
                                print('CachedNetworkImage error: $e');
                              },
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
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.molecularFormula,
                                      style: GoogleFonts.robotoMono(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
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
                              const SizedBox(height: 4),
                              if (_compoundInfo.containsKey(item.title)) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _compoundInfo[item.title]!['description'] ??
                                      '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
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
              emptyMessage: 'Ready to Explore Compounds',
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
                IconButton(
                  icon: Icon(
                    _showInfoCard ? Icons.info : Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _showInfoCard = !_showInfoCard;
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
