import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'provider/drug_provider.dart';
import '../../services/search_history_service.dart';
import '../../widgets/custom_search_screen.dart';
import '../../utils/error_handler.dart';
import 'drug_detail_screen.dart';
import '../../widgets/chemistry_widgets.dart';

class DrugSearchScreen extends StatefulWidget {
  const DrugSearchScreen({Key? key}) : super(key: key);

  @override
  State<DrugSearchScreen> createState() => _DrugSearchScreenState();
}

class _DrugSearchScreenState extends State<DrugSearchScreen> {
  final SearchHistoryService _searchHistoryService = SearchHistoryService();

  // Add CID mapping for quick search items for direct navigation
  final List<Map<String, dynamic>> _quickSearchItemsWithCids = [
    {'name': 'Aspirin', 'cid': 2244},
    {'name': 'Ibuprofen', 'cid': 3672},
    {'name': 'Paracetamol', 'cid': 1983},
    {'name': 'Amoxicillin', 'cid': 33613},
    {'name': 'Metformin', 'cid': 4091},
    {'name': 'Atorvastatin', 'cid': 60823},
    {'name': 'Omeprazole', 'cid': 4594},
    {'name': 'Lisinopril', 'cid': 5362119},
    {'name': 'Levothyroxine', 'cid': 5819},
    {'name': 'Metoprolol', 'cid': 4171}
  ];

  // Converted list for backward compatibility
  List<String> get _quickSearchItems =>
      _quickSearchItemsWithCids.map((item) => item['name'] as String).toList();

  List<String> _searchHistory = [];
  bool _showInfoCard = true;

  // Information about drugs for educational purposes
  final Map<String, Map<String, String>> _drugInfo = {
    'Aspirin': {
      'generic': 'Acetylsalicylic acid',
      'class': 'NSAID (Non-steroidal anti-inflammatory drug)',
      'uses': 'Pain relief, fever reduction, anti-inflammatory, blood thinner',
    },
    'Ibuprofen': {
      'generic': 'Ibuprofen',
      'class': 'NSAID (Non-steroidal anti-inflammatory drug)',
      'uses': 'Pain relief, fever reduction, anti-inflammatory',
    },
    'Paracetamol': {
      'generic': 'Acetaminophen',
      'class': 'Analgesic and antipyretic',
      'uses': 'Pain relief and fever reduction',
    },
  };

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

  Widget _buildInfoCard() {
    if (!_showInfoCard) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.8),
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.6),
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
          "What are Pharmaceutical Drugs?",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        leading: Icon(
          Icons.medication,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          size: 20,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.expand_more,
              color: Theme.of(context)
                  .colorScheme
                  .onSecondaryContainer
                  .withOpacity(0.7),
              size: 18,
            ),
            const SizedBox(width: 6),
            IconButton(
              icon: Icon(
                Icons.close,
                color: Theme.of(context)
                    .colorScheme
                    .onSecondaryContainer
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
                  "Pharmaceutical drugs are substances used to diagnose, cure, treat, or prevent diseases. They typically work by altering chemical processes in the body.",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onSecondaryContainer
                        .withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Drugs can be classified based on their chemical structure, mechanism of action, therapeutic use, or biological target.",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onSecondaryContainer
                        .withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildInfoPill("Analgesics", Icons.healing),
                      const SizedBox(width: 6),
                      _buildInfoPill("Antibiotics", Icons.coronavirus),
                      const SizedBox(width: 6),
                      _buildInfoPill("Antivirals", Icons.biotech),
                      const SizedBox(width: 6),
                      _buildInfoPill("Vaccines", Icons.shield),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .onSecondaryContainer
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
                .onSecondaryContainer
                .withOpacity(0.8),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context)
                  .colorScheme
                  .onSecondaryContainer
                  .withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrugGlossary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        title: Text(
          "Drug Terminology",
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
              "Generic Name",
              "The standard non-proprietary name given to a drug's active ingredient.",
              "Example: Acetylsalicylic acid (for Aspirin)"),
          _buildGlossaryItem(
              "Brand Name",
              "The proprietary name given by the manufacturer to a drug or combination of drugs.",
              "Example: Tylenol (for Acetaminophen/Paracetamol)"),
          _buildGlossaryItem(
              "Drug Class",
              "A group of medications that work in a similar way or are used to treat the same condition.",
              "Example: NSAIDs, Antibiotics, Antidepressants"),
          _buildGlossaryItem(
              "Mechanism of Action",
              "The specific biochemical interaction through which a drug produces its effect.",
              "Example: Aspirin inhibits the enzyme cyclooxygenase"),
          _buildGlossaryItem(
              "Half-life",
              "The time required for the concentration of a drug in the body to be reduced by one-half.",
              "Example: Caffeine has a half-life of about 5-6 hours"),
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

  // Update the disclaimer in the customHeader section
  Widget _buildDisclaimer() {
    if (!_showInfoCard) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.error,
          size: 18,
        ),
        title: Text(
          "For educational purposes only. Consult healthcare professionals for medical advice.",
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
        dense: true,
      ),
    );
  }

  // Method to handle quick search item taps for direct navigation
  void _handleQuickSearchTap(String drugName) async {
    // Find the corresponding CID for this drug name
    final item = _quickSearchItemsWithCids.firstWhere(
      (item) => item['name'] == drugName,
      orElse: () => {'name': drugName, 'cid': 0},
    );

    final int cid = item['cid'] as int;
    if (cid == 0) {
      // If no CID found, fall back to regular search
      await context.read<DrugProvider>().searchDrugs(drugName);
      return;
    }

    try {
      // Clear any previous drug data
      final provider = context.read<DrugProvider>();
      provider.clearSelectedDrug();

      // Show loading dialog with a more visible loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: ChemistryLoadingWidget(
            message: 'Loading drug details...',
          ),
        ),
      );

      // Use the new method to fetch by CID directly
      final result = await provider.getDrug(cid);

      // Close the loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (result != null) {
        // Navigate to drug details screen
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DrugDetailScreen(),
            ),
          );
        }
      } else if (context.mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to load drug details'),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<DrugProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: CustomSearchScreen(
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
            customHeader: Column(
              children: [
                // Educational info card
                _buildInfoCard(),

                // Glossary
                if (_showInfoCard) _buildDrugGlossary(),

                // Disclaimer
                if (_showInfoCard) _buildDisclaimer(),
              ],
            ),
            onSearch: (query) async {
              if (query.isNotEmpty) {
                try {
                  await _searchHistoryService.addToSearchHistory(
                      query, SearchType.drug);
                  await _loadSearchHistory();
                  await provider.searchDrugs(query);
                } catch (e) {
                  print('Error during drug search: $e');
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
              provider.clearDrugs();
            },
            onItemTap: (drug) async {
              try {
                // Show loading dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: ChemistryLoadingWidget(
                      message: 'Loading drug details...',
                    ),
                  ),
                );

                // First clear any previously loaded drug data
                final provider = context.read<DrugProvider>();
                provider.clearSelectedDrug();

                // Fetch details and then navigate
                provider.fetchDrugDetails(drug.cid).then((result) {
                  // Close loading dialog
                  if (context.mounted) {
                    Navigator.pop(context);
                  }

                  if (context.mounted && provider.error == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DrugDetailScreen(),
                      ),
                    );
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            provider.error ?? 'Failed to load drug details'),
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
                ErrorHandler.showErrorSnackBar(
                  context,
                  ErrorHandler.getErrorMessage(e),
                );
              }
            },
            onAutoComplete: (query) async {
              try {
                return await provider.fetchAutoCompleteSuggestions(query);
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
            onQuickSearchTap: (dynamic item) =>
                _handleQuickSearchTap(item.toString()),
            itemBuilder: (drug) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                onTap: () {
                  try {
                    // Show loading dialog
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: ChemistryLoadingWidget(
                          message: 'Loading drug details...',
                        ),
                      ),
                    );

                    // First clear any previously loaded drug data
                    final provider = context.read<DrugProvider>();
                    provider.clearSelectedDrug();

                    // Fetch details and then navigate
                    provider.fetchDrugDetails(drug.cid).then((result) {
                      // Close loading dialog
                      if (context.mounted) {
                        Navigator.pop(context);
                      }

                      if (context.mounted && provider.error == null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DrugDetailScreen(),
                          ),
                        );
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(provider.error ??
                                'Failed to load drug details'),
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
                    ErrorHandler.showErrorSnackBar(
                      context,
                      ErrorHandler.getErrorMessage(e),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${drug.cid}/PNG',
                            fit: BoxFit.cover,
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
                              print('Error loading drug image: $error');
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
                              drug.title,
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
                                        .secondaryContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    drug.molecularFormula,
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'CID: ${drug.cid}',
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
                            if (_drugInfo.containsKey(drug.title)) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.category,
                                    size: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      _drugInfo[drug.title]!['class'] ?? '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            emptyMessage: 'Ready to Explore Medications',
            emptySubMessage: 'Search for any drug to discover its properties',
            emptyIcon: Icons.medication,
            actions: [
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
                constraints: const BoxConstraints(maxHeight: 36, maxWidth: 36),
              ),
            ],
          ),
        );
      },
    );
  }
}
