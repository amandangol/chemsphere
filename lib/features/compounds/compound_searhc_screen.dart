import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'provider/compound_provider.dart';
import '../../services/search_history_service.dart';
import '../../widgets/custom_search_screen.dart';
import '../../utils/error_handler.dart';
import '../../widgets/chemistry_widgets.dart';
import 'compound_details_screen.dart';

class CompoundSearchScreen extends StatefulWidget {
  const CompoundSearchScreen({Key? key}) : super(key: key);

  @override
  State<CompoundSearchScreen> createState() => _CompoundSearchScreenState();
}

class _CompoundSearchScreenState extends State<CompoundSearchScreen> {
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  final TextEditingController _searchController = TextEditingController();

  // Add CID mapping for quick search items for direct navigation
  final List<Map<String, dynamic>> _quickSearchItemsWithCids = [
    {'name': 'Glucose', 'cid': 5793},
    {'name': 'Benzene', 'cid': 241},
    {'name': 'Ethanol', 'cid': 702},
    {'name': 'Methane', 'cid': 297},
    {'name': 'Water', 'cid': 962},
    {'name': 'Carbon dioxide', 'cid': 280},
    {'name': 'Sodium chloride', 'cid': 5234},
    {'name': 'Acetic acid', 'cid': 176},
    {'name': 'Ammonia', 'cid': 222},
    {'name': 'Sulfuric acid', 'cid': 1118},
  ];

  // Converted list for backward compatibility
  List<String> get _quickSearchItems =>
      _quickSearchItemsWithCids.map((item) => item['name'] as String).toList();

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

  // Method to handle quick search item taps for direct navigation
  void _handleQuickSearchTap(String compound) async {
    // Find the corresponding CID for this compound name
    final item = _quickSearchItemsWithCids.firstWhere(
      (item) => item['name'] == compound,
      orElse: () => {'name': compound, 'cid': 0},
    );

    final int cid = item['cid'] as int;
    if (cid == 0) {
      // If no CID found, fall back to regular search
      _searchController.text = compound;
      await context.read<CompoundProvider>().searchCompounds(compound);
      return;
    }

    try {
      // Clear any previous compound data
      final provider = context.read<CompoundProvider>();
      provider.clearSelectedCompound();

      // Show loading dialog with a more visible loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: ChemistryLoadingWidget(
            message: 'Loading compound details...',
          ),
        ),
      );

      // Use the new method to fetch by CID directly
      final result = await provider.getCompound(cid);

      // Close the loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (result != null) {
        // Navigate to compound details screen
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CompoundDetailsScreen(),
            ),
          );
        }
      } else if (context.mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to load compound details'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      // Handle errors
      print('Error handling quick search tap: $e');
      if (context.mounted) {
        // Close loading dialog if it's still showing
        Navigator.pop(context);

        ErrorHandler.showErrorSnackBar(
          context,
          ErrorHandler.getErrorMessage(e),
        );
      }
    }
  }

  Widget _buildInfoCard() {
    if (!_showInfoCard) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        title: Text(
          "What are Chemical Compounds?",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        leading: Icon(
          Icons.science,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          size: 20,
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
              size: 18,
            ),
            const SizedBox(width: 6),
            IconButton(
              icon: Icon(
                Icons.close,
                color: Theme.of(context)
                    .colorScheme
                    .onPrimaryContainer
                    .withOpacity(0.7),
                size: 18,
              ),
              onPressed: () {
                setState(() {
                  _showInfoCard = false;
                });
              },
              constraints: const BoxConstraints(maxHeight: 32, maxWidth: 32),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "A chemical compound is a substance composed of two or more different elements (atoms) that are chemically bonded together in fixed proportions.",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer
                        .withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "For example, water (H₂O) is a compound of hydrogen and oxygen in a 2:1 ratio.",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer
                        .withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoPill("Inorganic Compounds", Icons.category),
                    const SizedBox(width: 6),
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
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
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
              size: 14,
              color: Theme.of(context)
                  .colorScheme
                  .onPrimaryContainer
                  .withOpacity(0.8),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _selectedHeading,
            decoration: InputDecoration(
              labelText: 'Property',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            items: _availableHeadings.map((heading) {
              return DropdownMenuItem(
                value: heading,
                child: Text(heading, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedHeading = value;
              });
            },
          ),
          const SizedBox(height: 14),
          TextField(
            decoration: InputDecoration(
              labelText: 'Value',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              helperText:
                  'Example: For "Molecular Weight", enter a number like 18 for water',
              helperStyle: GoogleFonts.poppins(
                fontSize: 11,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withOpacity(0.7),
              ),
            ),
            style: const TextStyle(fontSize: 13),
            onChanged: (value) {
              setState(() {
                _selectedValue = value;
              });
            },
          ),
          const SizedBox(height: 14),
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
                  icon: const Icon(Icons.filter_alt, size: 18),
                  label: Text(
                    'Apply Filter',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
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
                icon: const Icon(Icons.clear, size: 18),
                label: Text(
                  'Clear',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        title: Text(
          "Common Compound Terms",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        leading: const Icon(Icons.menu_book, size: 20),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            term,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            definition,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            example,
            style: GoogleFonts.poppins(
              fontSize: 11,
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
                  // Show loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: ChemistryLoadingWidget(
                        message: 'Loading compound details...',
                      ),
                    ),
                  );

                  // First clear any previously loaded compound data
                  final provider = context.read<CompoundProvider>();
                  provider.clearSelectedCompound();

                  // Fetch details and then navigate
                  provider.fetchCompoundDetails(compound.cid).then((result) {
                    // Close loading dialog
                    if (context.mounted) {
                      Navigator.pop(context);
                    }

                    if (context.mounted && provider.error == null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CompoundDetailsScreen(),
                        ),
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(provider.error ??
                              'Failed to load compound details'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  }).catchError((e) {
                    // Close loading dialog on error
                    if (context.mounted) {
                      Navigator.pop(context);
                      ErrorHandler.showErrorSnackBar(
                        context,
                        ErrorHandler.getErrorMessage(e),
                      );
                    }
                  });
                } catch (e) {
                  print('Error navigating to details: $e');
                  ErrorHandler.showErrorSnackBar(
                    context,
                    ErrorHandler.getErrorMessage(e),
                  );
                }
              },
              onQuickSearchTap: (dynamic item) =>
                  _handleQuickSearchTap(item.toString()),
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
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
                child: InkWell(
                  onTap: () {
                    final compound = item;
                    try {
                      // Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: ChemistryLoadingWidget(
                            message: 'Loading compound details...',
                          ),
                        ),
                      );

                      // First clear any previously loaded compound data
                      final provider = context.read<CompoundProvider>();
                      provider.clearSelectedCompound();

                      // Fetch details and then navigate
                      provider
                          .fetchCompoundDetails(compound.cid)
                          .then((result) {
                        // Close loading dialog
                        if (context.mounted) {
                          Navigator.pop(context);
                        }

                        if (context.mounted && provider.error == null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CompoundDetailsScreen(),
                            ),
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(provider.error ??
                                  'Failed to load compound details'),
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                          );
                        }
                      }).catchError((e) {
                        // Close loading dialog on error
                        if (context.mounted) {
                          Navigator.pop(context);
                          ErrorHandler.showErrorSnackBar(
                            context,
                            ErrorHandler.getErrorMessage(e),
                          );
                        }
                      });
                    } catch (e) {
                      print('Error navigating to details: $e');
                      ErrorHandler.showErrorSnackBar(
                        context,
                        ErrorHandler.getErrorMessage(e),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 3,
                                offset: Offset(1, 1),
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl:
                                  'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${item.cid}/PNG',
                              fit: BoxFit.contain,
                              placeholder: (context, url) => Container(
                                width: 60,
                                height: 60,
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
                                  width: 60,
                                  height: 60,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        size: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                      if (errorMessage.isNotEmpty)
                                        Text(
                                          errorMessage,
                                          style: TextStyle(
                                            fontSize: 9,
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1,
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
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'CID: ${item.cid}',
                                    style: GoogleFonts.poppins(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.5),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              if (_compoundInfo.containsKey(item.title)) ...[
                                const SizedBox(height: 3),
                                Text(
                                  _compoundInfo[item.title]!['description'] ??
                                      '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
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
                          size: 14,
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
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                  constraints:
                      const BoxConstraints(maxHeight: 36, maxWidth: 36),
                ),
                IconButton(
                  icon: Icon(
                    _showInfoCard ? Icons.info : Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _showInfoCard = !_showInfoCard;
                    });
                  },
                  constraints:
                      const BoxConstraints(maxHeight: 36, maxWidth: 36),
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
