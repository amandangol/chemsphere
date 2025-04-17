import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/drug_provider.dart';
import '../../models/drug.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../widgets/molecule_3d_viewer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/detail_widgets.dart';

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

          return CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                stretch: true,
                backgroundColor: theme.colorScheme.primaryContainer,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    drug.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: Text(drug.title),
                              backgroundColor: Colors.black,
                            ),
                            backgroundColor: Colors.black,
                            body: Center(
                              child: Hero(
                                tag: 'drug_${drug.cid}',
                                child: CachedNetworkImage(
                                  imageUrl:
                                      'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${drug.cid}/PNG',
                                  fit: BoxFit.contain,
                                  errorWidget: (context, error, stackTrace) =>
                                      Icon(
                                    Icons.image_not_supported,
                                    size: 100,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'drug_${drug.cid}',
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${drug.cid}/PNG',
                            fit: BoxFit.cover,
                            errorWidget: (context, error, stackTrace) => Icon(
                              Icons.image_not_supported,
                              size: 100,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ),
                        Container(
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
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      bookmarkProvider.isBookmarked(drug, BookmarkType.drug)
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                    ),
                    onPressed: () {
                      if (bookmarkProvider.isBookmarked(
                          drug, BookmarkType.drug)) {
                        bookmarkProvider.removeBookmark(
                            drug, BookmarkType.drug);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${drug.title} removed from bookmarks'),
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
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Chip(
                                  label:
                                      Text('MW: ${drug.molecularWeight} g/mol'),
                                  backgroundColor:
                                      theme.colorScheme.surfaceVariant,
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
                                    color:
                                        theme.colorScheme.onTertiaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Description section
                      if (drug.description.isNotEmpty)
                        DetailWidgets.buildSection(
                          context,
                          title: 'Description',
                          icon: Icons.description,
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                drug.description,
                                style: GoogleFonts.poppins(
                                  height: 1.5,
                                ),
                              ),
                              if (drug.descriptionSource.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Source: ${drug.descriptionSource}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ],
                              if (drug.descriptionUrl.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _launchUrl(drug.descriptionUrl),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.link,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'View Source',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: theme.colorScheme.primary,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                      // Properties section
                      DetailWidgets.buildSection(
                        context,
                        title: 'Physical Properties',
                        icon: Icons.science,
                        content: Column(
                          children: [
                            DetailWidgets.buildPropertyCard(
                              context,
                              title: 'Structure',
                              content: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                        DetailWidgets.buildSection(
                          context,
                          title: 'Drug Information',
                          icon: Icons.medication,
                          content: Column(
                            children: [
                              if (drug.indication!.isNotEmpty)
                                DetailWidgets.buildPropertyCard(
                                  context,
                                  title: 'Indication',
                                  content: Text(drug.indication!),
                                ),
                              if (drug.mechanismOfAction!.isNotEmpty)
                                DetailWidgets.buildPropertyCard(
                                  context,
                                  title: 'Mechanism of Action',
                                  content: Text(drug.mechanismOfAction!),
                                ),
                              if (drug.toxicity.isNotEmpty)
                                DetailWidgets.buildPropertyCard(
                                  context,
                                  title: 'Toxicity',
                                  content: Text(drug.toxicity!),
                                ),
                              if (drug.pharmacology.isNotEmpty)
                                DetailWidgets.buildPropertyCard(
                                  context,
                                  title: 'Pharmacology',
                                  content: Text(drug.pharmacology!),
                                ),
                              if (drug.metabolism!.isNotEmpty)
                                DetailWidgets.buildPropertyCard(
                                  context,
                                  title: 'Metabolism',
                                  content: Text(drug.metabolism!),
                                ),
                              if (drug.absorption.isNotEmpty)
                                DetailWidgets.buildPropertyCard(
                                  context,
                                  title: 'Absorption',
                                  content: Text(drug.absorption!),
                                ),
                              if (drug.halfLife != null &&
                                  drug.halfLife!.isNotEmpty)
                                DetailWidgets.buildPropertyCard(
                                  context,
                                  title: 'Half Life',
                                  content: Text(drug.halfLife!),
                                ),
                              if (drug.proteinBinding != null &&
                                  drug.proteinBinding!.isNotEmpty)
                                DetailWidgets.buildPropertyCard(
                                  context,
                                  title: 'Protein Binding',
                                  content: Text(drug.proteinBinding!),
                                ),
                              if (drug.routeOfElimination != null &&
                                  drug.routeOfElimination!.isNotEmpty)
                                DetailWidgets.buildPropertyCard(
                                  context,
                                  title: 'Route of Elimination',
                                  content: Text(drug.routeOfElimination!),
                                ),
                              if (drug.volumeOfDistribution != null &&
                                  drug.volumeOfDistribution!.isNotEmpty)
                                DetailWidgets.buildPropertyCard(
                                  context,
                                  title: 'Volume of Distribution',
                                  content: Text(drug.volumeOfDistribution!),
                                ),
                              if (drug.clearance != null &&
                                  drug.clearance!.isNotEmpty)
                                DetailWidgets.buildPropertyCard(
                                  context,
                                  title: 'Clearance',
                                  content: Text(drug.clearance!),
                                ),
                            ],
                          ),
                        ),

                      // Synonyms section
                      if (drug.synonyms.isNotEmpty)
                        DetailWidgets.buildSection(
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
                                              theme.colorScheme.surfaceVariant,
                                          labelStyle: TextStyle(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Total synonyms: ${drug.synonyms.length}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: theme
                                                      .colorScheme.onSurface
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
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          backgroundColor: theme
                                                              .colorScheme
                                                              .surfaceVariant,
                                                          labelStyle: TextStyle(
                                                            color: theme
                                                                .colorScheme
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
                                            onPressed: () =>
                                                Navigator.pop(context),
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

                      // Actions section
                      DetailWidgets.buildSection(
                        context,
                        title: 'Actions',
                        icon: Icons.menu_book,
                        content: Column(
                          children: [
                            DetailWidgets.buildActionButton(
                              context,
                              title: 'View on PubChem',
                              icon: Icons.public,
                              onTap: () => _launchUrl(drug.pubChemUrl),
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

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
