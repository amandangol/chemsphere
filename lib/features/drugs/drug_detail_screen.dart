import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/url_launcher_util.dart';
import '../bookmarks/provider/bookmark_provider.dart';
import 'provider/drug_provider.dart';
import 'model/drug.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/detail_widgets.dart';
import '../../widgets/chemistry_widgets.dart';
import '../../utils/error_handler.dart';

class DrugDetailScreen extends StatefulWidget {
  final Drug? selectedDrug;

  const DrugDetailScreen({Key? key, this.selectedDrug}) : super(key: key);

  @override
  State<DrugDetailScreen> createState() => _DrugDetailScreenState();
}

class _DrugDetailScreenState extends State<DrugDetailScreen> {
  bool _isInitialized = false; // Track if we've initialized

  @override
  void initState() {
    super.initState();

    // Initialize state with a delay to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDrug();
    });
  }

  // Method to handle initialization or re-initialization
  void _initializeDrug() {
    if (_isInitialized) return;

    final drugProvider = Provider.of<DrugProvider>(context, listen: false);

    // If we have a selected drug either from the widget or provider, make sure it's loaded
    final drug = widget.selectedDrug ?? drugProvider.selectedDrug;

    if (drug != null) {
      setState(() {
        _isInitialized = true;
      });

      // If we have a drug from the widget but not in the provider, we need to fetch its details
      if (widget.selectedDrug != null && drugProvider.selectedDrug == null) {
        // Show loading state
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: ChemistryLoadingWidget(
              message: 'Loading drug details...',
            ),
          ),
        );

        // First fetch basic data quickly using fetchDrugByCid
        drugProvider.fetchDrugByCid(widget.selectedDrug!.cid).then((basicDrug) {
          // Close the loading dialog once basic data is loaded
          if (context.mounted) {
            Navigator.pop(context);
          }

          if (basicDrug == null) {
            if (mounted) {
              ErrorHandler.showErrorSnackBar(
                  context, 'Failed to load drug details');
            }
          } else {
            // Show a toast that full details are loading in background
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text('Loading additional details...'),
                    ],
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        }).catchError((e) {
          // Close the loading dialog on error
          if (context.mounted) {
            Navigator.pop(context);
          }

          debugPrint('Error fetching drug details: $e');
          if (mounted) {
            ErrorHandler.showErrorSnackBar(
                context, ErrorHandler.getErrorMessage(e));
          }
        });
      }
    }
  }

  Future<void> _exportDrugData(BuildContext context, Drug drug) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file =
          File('${directory.path}/${drug.title.replaceAll(' ', '_')}.json');

      final drugData = {
        'title': drug.title,
        'cid': drug.cid,
        'molecularFormula': drug.molecularFormula,
        'molecularWeight': drug.molecularWeight,
        'smiles': drug.smiles,
        'xLogP': drug.xLogP,
        'hBondDonorCount': drug.hBondDonorCount,
        'hBondAcceptorCount': drug.hBondAcceptorCount,
        'rotatableBondCount': drug.rotatableBondCount,
        'complexity': drug.complexity,
        'indication': drug.indication,
        'mechanismOfAction': drug.mechanismOfAction,
        'toxicity': drug.toxicity,
        'pharmacology': drug.pharmacology,
        'metabolism': drug.metabolism,
        'absorption': drug.absorption,
        'halfLife': drug.halfLife,
        'proteinBinding': drug.proteinBinding,
        'routeOfElimination': drug.routeOfElimination,
        'volumeOfDistribution': drug.volumeOfDistribution,
        'clearance': drug.clearance,
      };

      await file.writeAsString(jsonEncode(drugData));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported to ${file.path}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting data: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Chemistry-themed background
          image: DecorationImage(
            image: const AssetImage('assets/images/chemistry_bg.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.97),
              BlendMode.luminosity,
            ),
          ),
        ),
        child: Consumer<DrugProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              // Make sure this loading indicator is visible at the top of the screen
              return SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Back button
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: theme.colorScheme.primary,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const ChemistryLoadingWidget(
                        message: 'Loading drug details...',
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              );
            }

            // If we have a selectedDrug from constructor and provider is still loading
            // or had an error, we can show the selectedDrug directly
            if (provider.error != null && widget.selectedDrug != null) {
              final drug = widget.selectedDrug!;
              // Return the UI with the selectedDrug directly
              return _buildDrugDetailContent(
                  context, drug, bookmarkProvider, theme);
            }

            if (provider.error != null) {
              return Center(
                child: ChemistryCardBackground(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Back button
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: theme.colorScheme.primary,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${ErrorHandler.getErrorMessage(provider.error)}',
                          style: GoogleFonts.poppins(
                            color: theme.colorScheme.error,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => provider.fetchDrugDetails(
                              provider.selectedDrug?.cid ??
                                  widget.selectedDrug?.cid ??
                                  0),
                          icon: const Icon(Icons.refresh),
                          label: Text(
                            'Retry',
                            style: GoogleFonts.poppins(),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final drug = provider.selectedDrug ?? widget.selectedDrug;
            if (drug == null) {
              return Center(
                child: ChemistryCardBackground(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Back button
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: theme.colorScheme.primary,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        Icon(
                          Icons.medication_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No drug selected',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return _buildDrugDetailContent(
                context, drug, bookmarkProvider, theme);
          },
        ),
      ),
    );
  }

  // Extract the drug detail content into a separate method
  Widget _buildDrugDetailContent(BuildContext context, Drug drug,
      BookmarkProvider bookmarkProvider, ThemeData theme) {
    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        ChemistryDetailHeader(
          title: drug.title,
          cid: drug.cid,
          trailing: Row(children: [
            Consumer<DrugProvider>(
              builder: (context, provider, _) {
                // Show a small loading icon if we're still loading details in background
                if (provider.isLoading) {
                  return Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 8),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            IconButton(
              icon: Icon(
                bookmarkProvider.isBookmarked(drug, BookmarkType.drug)
                    ? Icons.bookmark
                    : Icons.bookmark_border,
              ),
              onPressed: () async {
                if (bookmarkProvider.isBookmarked(drug, BookmarkType.drug)) {
                  final success = await bookmarkProvider.removeBookmark(
                      drug, BookmarkType.drug);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? '${drug.title} removed from bookmarks'
                            : 'Error removing bookmark'),
                        behavior: SnackBarBehavior.floating,
                        action: success
                            ? null
                            : SnackBarAction(
                                label: 'Retry',
                                onPressed: () => bookmarkProvider
                                    .removeBookmark(drug, BookmarkType.drug),
                              ),
                      ),
                    );
                  }
                } else {
                  final success = await bookmarkProvider.addBookmark(
                      drug, BookmarkType.drug);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? '${drug.title} added to bookmarks'
                            : 'Error adding bookmark'),
                        behavior: SnackBarBehavior.floating,
                        action: success
                            ? null
                            : SnackBarAction(
                                label: 'Retry',
                                onPressed: () => bookmarkProvider.addBookmark(
                                    drug, BookmarkType.drug),
                              ),
                      ),
                    );
                  }
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                Share.share(
                  'Check out ${drug.title} (${drug.molecularFormula}) on PubChem: ${drug.pubChemUrl}',
                );
              },
            ),
          ]),
          onImageTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChemistryFullScreenView(
                  title: drug.title,
                  cid: drug.cid,
                ),
              ),
            );
          },
        ),
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'CID: ${drug.cid}',
                              style: GoogleFonts.poppins(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (drug.iupacName.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'IUPAC Name:',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 300,
                              child: Text(
                                drug.iupacName,
                                maxLines: 2,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(
                            label: Text(
                              'MW: ${drug.molecularWeight.toStringAsFixed(2)} g/mol',
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            labelStyle: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(
                              drug.molecularFormula,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            backgroundColor:
                                theme.colorScheme.tertiaryContainer,
                            labelStyle: TextStyle(
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        DetailWidgets.buildChemicalBasicInfo(
          context: context,
          chemical: drug,
          title: drug.title,
          molecularFormula: drug.molecularFormula,
          molecularWeight: drug.molecularWeight,
          smiles: drug.smiles,
        ),

        // Description section
        if (drug.description.isNotEmpty)
          SliverToBoxAdapter(
            child: DetailWidgets.buildSection(
              context,
              title: 'Description',
              icon: Icons.description,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    drug.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  if (drug.descriptionSource.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Source: ${drug.descriptionSource}',
                    ),
                  ],
                ],
              ),
            ),
          ),
        // 3D Molecular Structure section
        SliverToBoxAdapter(
          child: DetailWidgets.buildSection(
            context,
            title: '3D Molecular Structure',
            icon: Icons.view_in_ar,
            content: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: DetailWidgets.build3DViewer(
                context,
                cid: drug.cid,
                title: drug.title,
              ),
            ),
          ),
        ),

        // Properties section
        SliverToBoxAdapter(
          child: DetailWidgets.buildSection(
            context,
            title: 'Physical Properties',
            icon: Icons.science,
            content: Column(
              children: [
                DetailWidgets.buildPropertyCard(
                  context,
                  title: 'Structure',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DetailWidgets.buildProperty(
                        context,
                        'Molecular Formula',
                        drug.molecularFormula,
                      ),
                      DetailWidgets.buildProperty(
                        context,
                        'SMILES',
                        drug.smiles,
                        isMultiLine: true,
                      ),
                    ],
                  ),
                ),
                DetailWidgets.buildPropertyCard(
                  context,
                  title: 'Physical & Chemical Properties',
                  content: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DetailWidgets.buildProperty(
                              context,
                              'XLogP',
                              drug.xLogP.toString(),
                            ),
                          ),
                          Expanded(
                            child: DetailWidgets.buildProperty(
                              context,
                              'Complexity',
                              drug.complexity.toString(),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: DetailWidgets.buildProperty(
                              context,
                              'H-Bond Donors',
                              drug.hBondDonorCount.toString(),
                            ),
                          ),
                          Expanded(
                            child: DetailWidgets.buildProperty(
                              context,
                              'H-Bond Acceptors',
                              drug.hBondAcceptorCount.toString(),
                            ),
                          ),
                        ],
                      ),
                      DetailWidgets.buildProperty(
                        context,
                        'Rotatable Bonds',
                        drug.rotatableBondCount.toString(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Drug Information section
        if (drug.indication != null ||
            drug.mechanismOfAction != null ||
            drug.toxicity != null ||
            drug.metabolism != null ||
            drug.pharmacology != null ||
            drug.proteinBinding != null ||
            drug.absorption != null ||
            drug.halfLife != null ||
            drug.routeOfElimination != null ||
            drug.volumeOfDistribution != null ||
            drug.clearance != null)
          SliverToBoxAdapter(
            child: DetailWidgets.buildSection(
              context,
              title: 'Drug Information',
              icon: Icons.medication,
              content: Column(
                children: [
                  if (drug.indication.isNotEmpty)
                    DetailWidgets.buildExpandableProperty(
                      context,
                      title: 'Indication',
                      content: drug.indication,
                    ),
                  if (drug.mechanismOfAction.isNotEmpty)
                    DetailWidgets.buildExpandableProperty(
                      context,
                      title: 'Mechanism of Action',
                      content: drug.mechanismOfAction,
                    ),
                  if (drug.toxicity.isNotEmpty)
                    DetailWidgets.buildExpandableProperty(
                      context,
                      title: 'Toxicity',
                      content: drug.toxicity,
                    ),
                  if (drug.pharmacology.isNotEmpty)
                    DetailWidgets.buildExpandableProperty(
                      context,
                      title: 'Pharmacology',
                      content: drug.pharmacology,
                    ),
                  if (drug.metabolism.isNotEmpty)
                    DetailWidgets.buildExpandableProperty(
                      context,
                      title: 'Metabolism',
                      content: drug.metabolism,
                    ),
                  if (drug.absorption.isNotEmpty)
                    DetailWidgets.buildExpandableProperty(
                      context,
                      title: 'Absorption',
                      content: drug.absorption,
                    ),
                  if (drug.halfLife.isNotEmpty)
                    DetailWidgets.buildExpandableProperty(
                      context,
                      title: 'Half Life',
                      content: drug.halfLife,
                    ),
                  if (drug.proteinBinding.isNotEmpty)
                    DetailWidgets.buildExpandableProperty(
                      context,
                      title: 'Protein Binding',
                      content: drug.proteinBinding,
                    ),
                  if (drug.routeOfElimination.isNotEmpty)
                    DetailWidgets.buildExpandableProperty(
                      context,
                      title: 'Route of Elimination',
                      content: drug.routeOfElimination,
                    ),
                  if (drug.volumeOfDistribution.isNotEmpty)
                    DetailWidgets.buildExpandableProperty(
                      context,
                      title: 'Volume of Distribution',
                      content: drug.volumeOfDistribution,
                    ),
                  if (drug.clearance.isNotEmpty)
                    DetailWidgets.buildExpandableProperty(
                      context,
                      title: 'Clearance',
                      content: drug.clearance,
                    ),
                ],
              ),
            ),
          ),

        // Synonyms section
        if (drug.synonyms.isNotEmpty)
          SliverToBoxAdapter(
            child: DetailWidgets.buildSection(
              context,
              title: 'Synonyms',
              icon: Icons.text_fields,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: drug.synonyms
                        .take(5)
                        .map((synonym) => Chip(
                              label: Text(
                                synonym,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              labelStyle: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ))
                        .toList(),
                  ),
                  if (drug.synonyms.length > 5) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text(
                              'All Synonyms',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total synonyms: ${drug.synonyms.length}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: drug.synonyms
                                        .map((synonym) => Chip(
                                              label: Text(
                                                synonym,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              backgroundColor: theme.colorScheme
                                                  .surfaceContainerHighest,
                                              labelStyle: TextStyle(
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.expand_more,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text(
                        'Show ${drug.synonyms.length - 5} more synonyms',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

        // Actions section
        SliverToBoxAdapter(
          child: DetailWidgets.buildSection(
            context,
            title: 'Actions',
            icon: Icons.menu_book,
            content: Column(
              children: [
                DetailWidgets.buildActionButton(
                  context,
                  title: 'View on PubChem',
                  icon: Icons.public,
                  onTap: () => UrlLauncherUtil.launchURL(
                    context,
                    drug.pubChemUrl,
                  ),
                ),
                DetailWidgets.buildActionButton(
                  context,
                  title: 'Export Data',
                  icon: Icons.download,
                  onTap: () => _exportDrugData(context, drug),
                ),
              ],
            ),
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }
}
