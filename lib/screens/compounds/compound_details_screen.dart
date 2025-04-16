import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/compound_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class CompoundDetailsScreen extends StatelessWidget {
  const CompoundDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Compound Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final compound =
                  context.read<CompoundProvider>().selectedCompound;
              if (compound != null) {
                Share.share(
                  'Check out ${compound.title} (${compound.molecularFormula}) on PubChem: ${compound.pubChemUrl}',
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<CompoundProvider>(
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
                    'Loading compound details...',
                    style: GoogleFonts.poppins(
                      color: theme.colorScheme.primary,
                    ),
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
                    style: GoogleFonts.poppins(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.fetchCompoundDetails(
                        provider.selectedCompound?.cid ?? 0),
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
            );
          }

          final compound = provider.selectedCompound;
          if (compound == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.science_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No compound selected',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }

          print('\n=== UI Display Data ===');
          print('Title: ${compound.title}');
          print('Molecular Formula: ${compound.molecularFormula}');
          print('Molecular Weight: ${compound.molecularWeight}');
          print('Description: ${compound.description}');
          print('Description Source: ${compound.descriptionSource}');
          print('Description URL: ${compound.descriptionUrl}');
          print('Synonyms: ${compound.synonyms}');
          print('Atom Stereo Count: ${compound.atomStereoCount}');
          print('Bond Stereo Count: ${compound.bondStereoCount}');
          print(
              'Defined Atom Stereo Count: ${compound.definedAtomStereoCount}');
          print(
              'Undefined Atom Stereo Count: ${compound.undefinedAtomStereoCount}');
          print(
              'Defined Bond Stereo Count: ${compound.definedBondStereoCount}');
          print(
              'Undefined Bond Stereo Count: ${compound.undefinedBondStereoCount}');
          print('Physical Properties: ${compound.physicalProperties}');
          print('XLogP: ${compound.xLogP}');
          print('Complexity: ${compound.complexity}');
          print('TPSA: ${compound.tpsa}');
          print('Charge: ${compound.charge}');
          print('Exact Mass: ${compound.exactMass}');
          print('Monoisotopic Mass: ${compound.monoisotopicMass}');
          print('InChI: ${compound.inchi}');
          print('InChI Key: ${compound.inchiKey}');

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
                  // Compound image header
                  SizedBox(
                    height: 240,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Center(
                          child: Hero(
                            tag: 'compound_${compound.cid}',
                            child: Image.network(
                              'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${compound.cid}/PNG',
                              fit: BoxFit.contain,
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
                            height: 10,
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
                                'CID: ${compound.cid}',
                                style: GoogleFonts.poppins(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          compound.title,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (compound.iupacName.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            compound.iupacName,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                'MW: ${compound.molecularWeight.toStringAsFixed(2)} g/mol',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: theme.colorScheme.surfaceVariant,
                              labelStyle: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(
                                compound.molecularFormula,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
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

                  // Description section
                  if (compound.description.isNotEmpty)
                    _buildSection(
                      context,
                      title: 'Description',
                      icon: Icons.description,
                      content: Text(
                        compound.description,
                        style: GoogleFonts.poppins(
                          height: 1.5,
                        ),
                      ),
                    ),

                  // Physical Properties section
                  _buildSection(
                    context,
                    title: 'Physical Properties',
                    icon: Icons.science,
                    content: Column(
                      children: [
                        _buildPropertyCard(
                          context,
                          title: 'Structure',
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProperty(
                                'Molecular Formula',
                                compound.molecularFormula,
                              ),
                              _buildProperty(
                                'SMILES',
                                compound.smiles,
                                isMultiLine: true,
                              ),
                              _buildProperty(
                                'InChI',
                                compound.inchi,
                                isMultiLine: true,
                              ),
                              _buildProperty(
                                'InChI Key',
                                compound.inchiKey,
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
                                      compound.xLogP.toStringAsFixed(2),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildProperty(
                                      'Complexity',
                                      compound.complexity.toStringAsFixed(2),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildProperty(
                                      'H-Bond Donors',
                                      compound.hBondDonorCount.toString(),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildProperty(
                                      'H-Bond Acceptors',
                                      compound.hBondAcceptorCount.toString(),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildProperty(
                                      'TPSA',
                                      '${compound.tpsa} Å²',
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildProperty(
                                      'Charge',
                                      compound.charge.toString(),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildProperty(
                                      'Exact Mass',
                                      '${compound.exactMass} g/mol',
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildProperty(
                                      'Monoisotopic Mass',
                                      '${compound.monoisotopicMass} g/mol',
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildProperty(
                                      'Rotatable Bonds',
                                      compound.rotatableBondCount.toString(),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildProperty(
                                      'Heavy Atoms',
                                      compound.heavyAtomCount.toString(),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildProperty(
                                      'Isotope Atoms',
                                      compound.isotopeAtomCount.toString(),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildProperty(
                                      'Covalent Units',
                                      compound.covalentUnitCount.toString(),
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

                  // Stereochemistry section
                  _buildSection(
                    context,
                    title: 'Stereochemistry',
                    icon: Icons.science,
                    content: Column(
                      children: [
                        _buildPropertyCard(
                          context,
                          title: 'Atom Stereochemistry',
                          content: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildProperty(
                                      'Total Atom Stereo Count',
                                      compound.atomStereoCount.toString(),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildProperty(
                                      'Defined Atom Stereo Count',
                                      compound.definedAtomStereoCount
                                          .toString(),
                                    ),
                                  ),
                                ],
                              ),
                              _buildProperty(
                                'Undefined Atom Stereo Count',
                                compound.undefinedAtomStereoCount.toString(),
                              ),
                            ],
                          ),
                        ),
                        _buildPropertyCard(
                          context,
                          title: 'Bond Stereochemistry',
                          content: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildProperty(
                                      'Total Bond Stereo Count',
                                      compound.bondStereoCount.toString(),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildProperty(
                                      'Defined Bond Stereo Count',
                                      compound.definedBondStereoCount
                                          .toString(),
                                    ),
                                  ),
                                ],
                              ),
                              _buildProperty(
                                'Undefined Bond Stereo Count',
                                compound.undefinedBondStereoCount.toString(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Literature and Patents section
                  _buildSection(
                    context,
                    title: 'Literature and Patents',
                    icon: Icons.menu_book,
                    content: Column(
                      children: [
                        _buildPropertyCard(
                          context,
                          title: 'Patents',
                          content: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildProperty(
                                      'Patent Count',
                                      compound.patentCount.toString(),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildProperty(
                                      'Patent Family Count',
                                      compound.patentFamilyCount.toString(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _buildPropertyCard(
                          context,
                          title: 'Literature',
                          content: Column(
                            children: [
                              _buildProperty(
                                'Literature Count',
                                compound.literatureCount.toString(),
                              ),
                              if (compound.annotationTypes.isNotEmpty)
                                _buildProperty(
                                  'Annotation Types',
                                  compound.annotationTypes.join(', '),
                                ),
                              _buildProperty(
                                'Annotation Type Count',
                                compound.annotationTypeCount.toString(),
                              ),
                              if (compound.sourceCategories.isNotEmpty)
                                _buildProperty(
                                  'Source Categories',
                                  compound.sourceCategories.join(', '),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Safety section
                  if (compound.safetyData.isNotEmpty &&
                      (compound.safetyData['ghs']?.isNotEmpty ??
                          false || compound.safetyData['hazards']?.isNotEmpty ??
                          false || compound.safetyData['safety']?.isNotEmpty ??
                          false))
                    _buildSection(
                      context,
                      title: 'Safety Information',
                      icon: Icons.warning,
                      content: Column(
                        children: [
                          if (compound.safetyData['ghs']?.isNotEmpty ?? false)
                            _buildPropertyCard(
                              context,
                              title: 'GHS Classification',
                              content: Column(
                                children: (compound.safetyData['ghs'] as List)
                                    .map((ghs) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.warning_amber_rounded,
                                                size: 16,
                                                color: theme.colorScheme.error,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  ghs,
                                                  style: GoogleFonts.poppins(
                                                    color:
                                                        theme.colorScheme.error,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          if (compound.safetyData['hazards']?.isNotEmpty ??
                              false)
                            _buildPropertyCard(
                              context,
                              title: 'Hazards',
                              content: Column(
                                children: (compound.safetyData['hazards']
                                        as List)
                                    .map((hazard) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.dangerous,
                                                size: 16,
                                                color: theme.colorScheme.error,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  hazard,
                                                  style: GoogleFonts.poppins(
                                                    color:
                                                        theme.colorScheme.error,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          if (compound.safetyData['safety']?.isNotEmpty ??
                              false)
                            _buildPropertyCard(
                              context,
                              title: 'Safety Precautions',
                              content: Column(
                                children: (compound.safetyData['safety']
                                        as List)
                                    .map((precaution) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.safety_check,
                                                size: 16,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  precaution,
                                                  style: GoogleFonts.poppins(
                                                    color: theme
                                                        .colorScheme.primary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                        ],
                      ),
                    ),

                  // Uses section
                  if (compound.uses.isNotEmpty)
                    _buildSection(
                      context,
                      title: 'Uses',
                      icon: Icons.work,
                      content: Column(
                        children: compound.uses
                            .map((use) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          use,
                                          style: GoogleFonts.poppins(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
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
                          onTap: () async {
                            final url = Uri.parse(compound.pubChemUrl);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Could not launch ${compound.pubChemUrl}'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                        _buildActionButton(
                          context,
                          title: 'Save to Favorites',
                          icon: Icons.bookmark_border,
                          onTap: () {
                            // TODO: Implement save functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${compound.title} saved to favorites'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        _buildActionButton(
                          context,
                          title: 'Export Data',
                          icon: Icons.download,
                          onTap: () {
                            // TODO: Implement export functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Export functionality coming soon'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
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
              color: Colors.black,
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
