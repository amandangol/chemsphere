import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io'; // Import for SocketException
import '../compounds/compound_details_screen.dart';
import '../compounds/provider/compound_provider.dart';
import 'provider/formula_search_provider.dart';
import '../../services/search_history_service.dart';
import '../../widgets/custom_search_screen.dart';
import '../../utils/error_handler.dart';

class FormulaSearchScreen extends StatefulWidget {
  const FormulaSearchScreen({Key? key}) : super(key: key);

  @override
  State<FormulaSearchScreen> createState() => _FormulaSearchScreenState();
}

class _FormulaSearchScreenState extends State<FormulaSearchScreen> {
  final TextEditingController _formulaController = TextEditingController();
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  List<String> _searchHistory = [];
  bool _showInfoCard = true;

  final List<String> _quickSearchItems = [
    'H2O',
    'C6H12O6',
    'NaCl',
    'C2H5OH',
    'CH4',
    'CO2',
    'C8H10N4O2',
    'H2SO4',
    'NaOH',
    'NH3'
  ];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    // Reset the provider state when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FormulaSearchProvider>(context, listen: false)
          .clearSearchResults();
    });
  }

  Future<void> _loadSearchHistory() async {
    final history =
        await _searchHistoryService.getSearchHistory(SearchType.formula);
    setState(() {
      _searchHistory = history;
    });
  }

  @override
  void dispose() {
    _formulaController.dispose();
    super.dispose();
  }

  String? _validateFormula(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a molecular formula';
    }

    // Basic validation for molecular formula
    // Should contain at least one letter and optional numbers
    final RegExp formulaRegex = RegExp(r'^[A-Z][a-zA-Z0-9]*$');
    if (!formulaRegex.hasMatch(value)) {
      return 'Enter a valid molecular formula (e.g., H2O, C6H12O6)';
    }

    return null;
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
            Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.8),
            Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.6),
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
          "What is a Molecular Formula?",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onTertiaryContainer,
          ),
        ),
        leading: Icon(
          Icons.science,
          color: Theme.of(context).colorScheme.onTertiaryContainer,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.expand_more,
              color: Theme.of(context)
                  .colorScheme
                  .onTertiaryContainer
                  .withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.close,
                color: Theme.of(context)
                    .colorScheme
                    .onTertiaryContainer
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
                  "A molecular formula is a representation of a molecule using chemical symbols to indicate the types of atoms with subscripts to show the number of atoms of each element.",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiaryContainer
                        .withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "For example, H₂O indicates 2 hydrogen atoms and 1 oxygen atom, which is the molecular formula for water.",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiaryContainer
                        .withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoPill("Elements", Icons.category),
                    const SizedBox(width: 8),
                    _buildInfoPill("Proportions", Icons.balance),
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
          color: Theme.of(context)
              .colorScheme
              .onTertiaryContainer
              .withOpacity(0.1),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .onTertiaryContainer
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
                  .onTertiaryContainer
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
                      .onTertiaryContainer
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

  Widget _buildFormulaTips() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        title: Text(
          "Formula Writing Tips",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: const Icon(Icons.tips_and_updates),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          _buildTipItem(
              "Capitalization",
              "Element symbols always start with a capital letter, with the second letter in lowercase if present.",
              "Examples: H (hydrogen), He (helium), Na (sodium)"),
          _buildTipItem(
              "Numbers",
              "Numbers after element symbols indicate the number of atoms of that element.",
              "Example: H2O has 2 hydrogen atoms and 1 oxygen atom"),
          _buildTipItem(
              "Order",
              "Elements are typically written in a specific order: C, H, then other elements alphabetically.",
              "Example: C2H5OH (ethanol)"),
          _buildTipItem(
              "Parentheses",
              "Parentheses group atoms together with a subscript indicating how many of the group.",
              "Example: Ca(OH)2 has one calcium, two oxygen, and two hydrogen atoms"),
        ],
      ),
    );
  }

  Widget _buildTipItem(String term, String definition, String example) {
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

  Widget _buildCommonFormulas() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        title: Text(
          "Common Molecular Formulas",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: const Icon(Icons.menu_book),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          _buildFormulaItem("H2O", "Water",
              "The most common compound on Earth's surface, essential for life."),
          _buildFormulaItem("C6H12O6", "Glucose",
              "A simple sugar that is an important energy source in organisms."),
          _buildFormulaItem("NaCl", "Sodium Chloride (Salt)",
              "Essential dietary mineral and food preservative."),
          _buildFormulaItem("C2H5OH", "Ethanol",
              "Found in alcoholic beverages, also used as a solvent and fuel."),
          _buildFormulaItem("C8H10N4O2", "Caffeine",
              "Stimulant found in coffee, tea, and many other beverages."),
        ],
      ),
    );
  }

  Widget _buildFormulaItem(String formula, String name, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  formula,
                  style: GoogleFonts.robotoMono(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FormulaSearchProvider>(
      builder: (context, provider, child) {
        return CustomSearchScreen(
          title: 'Molecular Formula Search',
          hintText: 'Enter a formula (e.g., H2O, C6H12O6)',
          searchIcon: Icons.science_outlined,
          quickSearchItems: _quickSearchItems,
          historyItems: _searchHistory,
          isLoading: provider.isLoading,
          error: provider.error != null
              ? ErrorHandler.getErrorMessage(provider.error)
              : null,
          items: provider.searchResults,
          imageUrl:
              'https://img.freepik.com/premium-photo/blue-poster-with-blue-background-with-blue-orange-design_978521-27809.jpg',
          customHeader: Column(
            children: [
              _buildInfoCard(),
              if (_showInfoCard) _buildFormulaTips(),
              if (_showInfoCard) _buildCommonFormulas(),
            ],
          ),
          onSearch: (query) async {
            try {
              if (query.isNotEmpty) {
                await _searchHistoryService.addToSearchHistory(
                    query, SearchType.formula);
                await _loadSearchHistory();
                await provider.searchByFormula(query);
              }
            } catch (e) {
              print('Error during formula search: $e');
              ErrorHandler.showErrorSnackBar(
                  context, ErrorHandler.getErrorMessage(e));
            }
          },
          onClear: () {
            provider.clearSearchResults();
          },
          onItemTap: (compound) async {
            try {
              final compoundProvider =
                  Provider.of<CompoundProvider>(context, listen: false);
              await compoundProvider.fetchCompoundDetails(compound.cid);
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompoundDetailsScreen(
                      selectedCompound: compound,
                    ),
                  ),
                );
              }
            } catch (e) {
              print('Error navigating to compound details: $e');
              if (context.mounted) {
                ErrorHandler.showErrorSnackBar(
                    context, ErrorHandler.getErrorMessage(e));
              }
            }
          },
          onAutoComplete: (query) => Future.value([]),
          itemBuilder: (compound) => Card(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: InkWell(
              onTap: () async {
                try {
                  final compoundProvider =
                      Provider.of<CompoundProvider>(context, listen: false);
                  await compoundProvider.fetchCompoundDetails(compound.cid);
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CompoundDetailsScreen(),
                      ),
                    );
                  }
                } catch (e) {
                  print('Error navigating to compound details: $e');
                  if (context.mounted) {
                    ErrorHandler.showErrorSnackBar(
                        context, ErrorHandler.getErrorMessage(e));
                  }
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
                              'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${compound.cid}/PNG',
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
                            print('Error loading formula image: $error');
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
                            compound.title,
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
                                      .tertiaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  compound.molecularFormula,
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiaryContainer,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
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
                          const SizedBox(height: 4),
                          Text(
                            'MW: ${compound.molecularWeight.toStringAsFixed(2)} g/mol',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
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
          emptyMessage: 'Ready to Search by Formula',
          emptySubMessage:
              'Enter a molecular formula to find matching compounds',
          emptyIcon: Icons.science,
          actions: [
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
        );
      },
    );
  }
}
