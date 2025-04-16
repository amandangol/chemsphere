import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/drug_provider.dart';
import '../../models/drug.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DrugDetailScreen extends StatelessWidget {
  const DrugDetailScreen({Key? key}) : super(key: key);

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
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
      appBar: AppBar(
        title: const Text(
          'Drug Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          Consumer<DrugProvider>(
            builder: (context, provider, child) {
              final drug = provider.selectedDrug;
              if (drug != null) {
                return IconButton(
                  icon: Icon(
                    bookmarkProvider.isBookmarked(drug, BookmarkType.drug)
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                  ),
                  onPressed: () {
                    if (bookmarkProvider.isBookmarked(
                        drug, BookmarkType.drug)) {
                      bookmarkProvider.removeBookmark(drug, BookmarkType.drug);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${drug.title} removed from bookmarks'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      bookmarkProvider.addBookmark(drug, BookmarkType.drug);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${drug.title} added to bookmarks'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<DrugProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading drug details...',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    style: TextStyle(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider
                        .fetchDrugDetails(provider.selectedDrug?.cid ?? 0),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final drug = provider.selectedDrug;
          if (drug == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medication_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No drug selected',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primaryContainer.withOpacity(0.3),
                  theme.colorScheme.background,
                ],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drug image header
                  SizedBox(
                    height: 240,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Center(
                          child: Hero(
                            tag: 'drug_${drug.cid}',
                            child: Image.network(
                              'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${drug.cid}/PNG',
                              width: 200,
                              height: 200,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.image_not_supported,
                                      size: 100,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5)),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  theme.colorScheme.surface.withOpacity(0.8),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Title section
                  Padding(
                    padding: const EdgeInsets.all(16),
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
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          drug.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              label: Text('MW: ${drug.molecularWeight} g/mol'),
                              backgroundColor: theme.colorScheme.surfaceVariant,
                              labelStyle: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(drug.molecularFormula),
                              backgroundColor:
                                  theme.colorScheme.tertiaryContainer,
                              labelStyle: TextStyle(
                                color: theme.colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Properties section
                  _buildSection(
                    context,
                    title: 'Physical Properties',
                    icon: Icons.science,
                    content: Column(
                      children: [
                        _buildPropertyCard(
                          context,
                          title: 'Structure',
                          content: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildProperty(
                                      'Molecular Formula',
                                      drug.molecularFormula,
                                    ),
                                    _buildProperty(
                                      'SMILES',
                                      drug.smiles,
                                      isMultiLine: true,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildPropertyCard(
                          context,
                          title: 'Physical & Chemical Properties',
                          content: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildProperty(
                                      'XLogP',
                                      drug.xLogP.toString(),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildProperty(
                                      'Complexity',
                                      drug.complexity.toString(),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildProperty(
                                      'H-Bond Donors',
                                      drug.hBondDonorCount.toString(),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildProperty(
                                      'H-Bond Acceptors',
                                      drug.hBondAcceptorCount.toString(),
                                    ),
                                  ),
                                ],
                              ),
                              _buildProperty(
                                'Rotatable Bonds',
                                drug.rotatableBondCount.toString(),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                    _buildSection(
                      context,
                      title: 'Drug Information',
                      icon: Icons.medication,
                      content: Column(
                        children: [
                          if (drug.indication != null &&
                              drug.indication!.isNotEmpty)
                            _buildPropertyCard(
                              context,
                              title: 'Indication',
                              content: Text(drug.indication!),
                            ),
                          if (drug.mechanismOfAction != null &&
                              drug.mechanismOfAction!.isNotEmpty)
                            _buildPropertyCard(
                              context,
                              title: 'Mechanism of Action',
                              content: Text(drug.mechanismOfAction!),
                            ),
                          if (drug.toxicity != null &&
                              drug.toxicity!.isNotEmpty)
                            _buildPropertyCard(
                              context,
                              title: 'Toxicity',
                              content: Text(drug.toxicity!),
                            ),
                          if (drug.pharmacology != null &&
                              drug.pharmacology!.isNotEmpty)
                            _buildPropertyCard(
                              context,
                              title: 'Pharmacology',
                              content: Text(drug.pharmacology!),
                            ),
                          if (drug.metabolism != null &&
                              drug.metabolism!.isNotEmpty)
                            _buildPropertyCard(
                              context,
                              title: 'Metabolism',
                              content: Text(drug.metabolism!),
                            ),
                          if (drug.absorption != null &&
                              drug.absorption!.isNotEmpty)
                            _buildPropertyCard(
                              context,
                              title: 'Absorption',
                              content: Text(drug.absorption!),
                            ),
                          if (drug.halfLife != null &&
                              drug.halfLife!.isNotEmpty)
                            _buildPropertyCard(
                              context,
                              title: 'Half Life',
                              content: Text(drug.halfLife!),
                            ),
                          if (drug.proteinBinding != null &&
                              drug.proteinBinding!.isNotEmpty)
                            _buildPropertyCard(
                              context,
                              title: 'Protein Binding',
                              content: Text(drug.proteinBinding!),
                            ),
                          if (drug.routeOfElimination != null &&
                              drug.routeOfElimination!.isNotEmpty)
                            _buildPropertyCard(
                              context,
                              title: 'Route of Elimination',
                              content: Text(drug.routeOfElimination!),
                            ),
                          if (drug.volumeOfDistribution != null &&
                              drug.volumeOfDistribution!.isNotEmpty)
                            _buildPropertyCard(
                              context,
                              title: 'Volume of Distribution',
                              content: Text(drug.volumeOfDistribution!),
                            ),
                          if (drug.clearance != null &&
                              drug.clearance!.isNotEmpty)
                            _buildPropertyCard(
                              context,
                              title: 'Clearance',
                              content: Text(drug.clearance!),
                            ),
                        ],
                      ),
                    ),

                  // Actions section
                  _buildSection(
                    context,
                    title: 'Actions',
                    icon: Icons.menu_book,
                    content: Column(
                      children: [
                        _buildActionButton(
                          context,
                          title: 'View on PubChem',
                          icon: Icons.public,
                          onTap: () => _launchUrl(drug.pubChemUrl),
                        ),
                        _buildActionButton(
                          context,
                          title: 'Export Data',
                          icon: Icons.download,
                          onTap: () => _exportDrugData(context, drug),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              content,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyCard(
    BuildContext context, {
    required String title,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          if (content is Text)
            StatefulBuilder(
              builder: (context, setState) {
                final text = content.data!;
                final isLongText = text.length > 100;
                final showFullText = ValueNotifier<bool>(false);

                return ValueListenableBuilder<bool>(
                  valueListenable: showFullText,
                  builder: (context, value, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value || !isLongText
                              ? text
                              : '${text.substring(0, text.length > 200 ? 200 : text.length)}...',
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (isLongText)
                          TextButton(
                            onPressed: () {
                              showFullText.value = !showFullText.value;
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              value ? 'Show Less' : 'View More',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            )
          else
            content,
        ],
      ),
    );
  }

  Widget _buildProperty(String label, String value,
      {bool isMultiLine = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isMultiLine ? 13 : 14,
              fontWeight: isMultiLine ? FontWeight.normal : FontWeight.w500,
            ),
            maxLines: isMultiLine ? 3 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
