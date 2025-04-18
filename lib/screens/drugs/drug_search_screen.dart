import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'provider/drug_provider.dart';
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.8),
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.6),
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
          "What are Pharmaceutical Drugs?",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        leading: Icon(
          Icons.medication,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
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
              size: 20,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.close,
                color: Theme.of(context)
                    .colorScheme
                    .onSecondaryContainer
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
                  "Pharmaceutical drugs are substances used to diagnose, cure, treat, or prevent diseases. They typically work by altering chemical processes in the body.",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSecondaryContainer
                        .withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Drugs can be classified based on their chemical structure, mechanism of action, therapeutic use, or biological target.",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSecondaryContainer
                        .withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildInfoPill("Analgesics", Icons.healing),
                      const SizedBox(width: 8),
                      _buildInfoPill("Antibiotics", Icons.coronavirus),
                      const SizedBox(width: 8),
                      _buildInfoPill("Antivirals", Icons.biotech),
                      const SizedBox(width: 8),
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
            size: 16,
            color: Theme.of(context)
                .colorScheme
                .onSecondaryContainer
                .withOpacity(0.8),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        title: Text(
          "Drug Terminology",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: const Icon(Icons.menu_book),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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

  // Update the disclaimer in the customHeader section
  Widget _buildDisclaimer() {
    if (!_showInfoCard) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
          size: 20,
        ),
        title: Text(
          "For educational purposes only. Consult healthcare professionals for medical advice.",
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
        dense: true,
      ),
    );
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
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${drug.cid}/PNG',
                            fit: BoxFit.cover,
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
                            errorWidget: (context, error, stackTrace) =>
                                Container(
                              width: 120,
                              height: 120,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              child: Icon(
                                Icons.image_not_supported,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
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
                                        .secondaryContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    drug.molecularFormula,
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
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
                            if (_drugInfo.containsKey(drug.title)) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.category,
                                    size: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _drugInfo[drug.title]!['class'] ?? '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
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
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
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
                ),
                onPressed: () {
                  setState(() {
                    _showInfoCard = !_showInfoCard;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
