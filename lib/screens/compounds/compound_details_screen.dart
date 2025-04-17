import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/compound_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/bookmark_provider.dart';
import '../../widgets/molecule_3d_viewer.dart';

class CompoundDetailsScreen extends StatefulWidget {
  const CompoundDetailsScreen({super.key});

  @override
  State<CompoundDetailsScreen> createState() => _CompoundDetailsScreenState();
}

class _CompoundDetailsScreenState extends State<CompoundDetailsScreen> {
  bool _isLoading3D = false;
  String? _3dError;

  Future<void> _load3DStructure(int cid) async {
    setState(() {
      _isLoading3D = true;
      _3dError = null;
    });

    try {
      await context.read<CompoundProvider>().fetch3DStructure(cid);
      // For now, we'll just simulate loading the structure
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      setState(() {
        _3dError = 'Failed to load 3D structure: $e';
      });
    } finally {
      setState(() {
        _isLoading3D = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);

    return Scaffold(
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

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                stretch: true,
                backgroundColor: theme.colorScheme.primaryContainer,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    compound.title,
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
                              title: Text(compound.title),
                              backgroundColor: Colors.black,
                            ),
                            backgroundColor: Colors.black,
                            body: Center(
                              child: Hero(
                                tag: 'compound_${compound.cid}',
                                child: CachedNetworkImage(
                                  imageUrl:
                                      'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${compound.cid}/PNG',
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
                          tag: 'compound_${compound.cid}',
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${compound.cid}/PNG',
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
                      bookmarkProvider.isBookmarked(
                              compound, BookmarkType.compound)
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                    ),
                    onPressed: () {
                      if (bookmarkProvider.isBookmarked(
                          compound, BookmarkType.compound)) {
                        bookmarkProvider.removeBookmark(
                            compound, BookmarkType.compound);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${compound.title} removed from bookmarks'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        bookmarkProvider.addBookmark(
                            compound, BookmarkType.compound);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${compound.title} added to bookmarks'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      Share.share(
                        'Check out ${compound.title} (${compound.molecularFormula}) on PubChem: ${compound.pubChemUrl}',
                      );
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
                                    'CID: ${compound.cid}',
                                    style: GoogleFonts.poppins(
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (compound.iupacName.isNotEmpty) ...[
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
                                      compound.iupacName,
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
                                    'MW: ${compound.molecularWeight.toStringAsFixed(2)} g/mol',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  backgroundColor:
                                      theme.colorScheme.surfaceVariant,
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
                                    color:
                                        theme.colorScheme.onTertiaryContainer,
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
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                compound.description,
                                style: GoogleFonts.poppins(
                                  height: 1.5,
                                ),
                              ),
                              if (compound.descriptionSource.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Source: ${compound.descriptionSource}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ],
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
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child:
                                        _build3DViewer(context, compound.cid),
                                  ),
                                  const SizedBox(height: 16),
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
                                          compound.complexity
                                              .toStringAsFixed(2),
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
                                          compound.hBondAcceptorCount
                                              .toString(),
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
                                          compound.rotatableBondCount
                                              .toString(),
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
                                  // Add new chemical properties
                                  if (compound
                                          .physicalProperties['MeltingPoint'] !=
                                      null)
                                    _buildProperty(
                                      'Melting Point',
                                      compound
                                          .physicalProperties['MeltingPoint'],
                                    ),
                                  if (compound
                                          .physicalProperties['BoilingPoint'] !=
                                      null)
                                    _buildProperty(
                                      'Boiling Point',
                                      compound
                                          .physicalProperties['BoilingPoint'],
                                    ),
                                  if (compound
                                          .physicalProperties['FlashPoint'] !=
                                      null)
                                    _buildProperty(
                                      'Flash Point',
                                      compound.physicalProperties['FlashPoint'],
                                    ),
                                  if (compound.physicalProperties['Density'] !=
                                      null)
                                    _buildProperty(
                                      'Density',
                                      compound.physicalProperties['Density'],
                                    ),
                                  if (compound
                                          .physicalProperties['Solubility'] !=
                                      null)
                                    _buildProperty(
                                      'Solubility',
                                      compound.physicalProperties['Solubility'],
                                    ),
                                  if (compound.physicalProperties[
                                          'VaporPressure'] !=
                                      null)
                                    _buildProperty(
                                      'Vapor Pressure',
                                      compound
                                          .physicalProperties['VaporPressure'],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Safety Data section
                      if (compound.safetyData.isNotEmpty)
                        _buildSection(
                          context,
                          title: 'Safety Information',
                          icon: Icons.warning_rounded,
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // GHS Classification
                              if (compound.safetyData['GHSClassification'] !=
                                      null &&
                                  (compound.safetyData['GHSClassification']
                                          as List)
                                      .isNotEmpty)
                                _buildPropertyCard(
                                  context,
                                  title: 'GHS Classification',
                                  content: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ...(compound.safetyData[
                                              'GHSClassification'] as List)
                                          .map<Widget>((ghs) => Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      ghs['Name'] ?? '',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      ghs['Value'] ?? '',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ))
                                          .toList(),
                                    ],
                                  ),
                                ),

                              // Hazard Statements
                              if (compound.safetyData['HazardStatements'] !=
                                      null &&
                                  (compound.safetyData['HazardStatements']
                                          as List)
                                      .isNotEmpty)
                                _buildPropertyCard(
                                  context,
                                  title: 'Hazard Statements',
                                  content: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ...(compound.safetyData[
                                              'HazardStatements'] as List)
                                          .map<Widget>((hazard) => Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      hazard['Code'] ?? '',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      hazard['Statement'] ?? '',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ))
                                          .toList(),
                                    ],
                                  ),
                                ),

                              // Precautionary Statements
                              if (compound.safetyData[
                                          'PrecautionaryStatements'] !=
                                      null &&
                                  (compound.safetyData[
                                          'PrecautionaryStatements'] as List)
                                      .isNotEmpty)
                                _buildPropertyCard(
                                  context,
                                  title: 'Precautionary Statements',
                                  content: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ...(compound.safetyData[
                                                  'PrecautionaryStatements']
                                              as List)
                                          .map<Widget>((precaution) => Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      precaution['Code'] ?? '',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      precaution['Statement'] ??
                                                          '',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ))
                                          .toList(),
                                    ],
                                  ),
                                ),

                              // Safety Data Sheets
                              if (compound.safetyData['SafetyDataSheets'] !=
                                      null &&
                                  (compound.safetyData['SafetyDataSheets']
                                          as List)
                                      .isNotEmpty)
                                _buildPropertyCard(
                                  context,
                                  title: 'Safety Data Sheets',
                                  content: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ...(compound.safetyData[
                                              'SafetyDataSheets'] as List)
                                          .map<Widget>((sds) => Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8),
                                                child: InkWell(
                                                  onTap: () =>
                                                      _launchUrl(sds['URL']),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.link,
                                                        size: 16,
                                                        color: theme.colorScheme
                                                            .primary,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        sds['Source'] ?? '',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 13,
                                                          color: theme
                                                              .colorScheme
                                                              .primary,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                      // Biological Properties section
                      if (compound.biologicalData.isNotEmpty)
                        _buildSection(
                          context,
                          title: 'Biological Properties',
                          icon: Icons.biotech_rounded,
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (compound.biologicalData['Section'] != null)
                                ...compound.biologicalData['Section']
                                    .map<Widget>((section) {
                                  if (section['TOCHeading'] ==
                                      'Biological Properties') {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (section['Information'] != null)
                                          ...section['Information']
                                              .map<Widget>((info) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    info['Name'] ?? '',
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    info['StringValue'] ?? '',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                      ],
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }).toList(),
                            ],
                          ),
                        ),

                      // Synonyms section
                      if (compound.synonyms.isNotEmpty)
                        _buildSection(
                          context,
                          title: 'Synonyms',
                          icon: Icons.text_fields,
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: compound.synonyms
                                    .take(5)
                                    .map((synonym) => Chip(
                                          label: Text(
                                            synonym,
                                            style: GoogleFonts.poppins(
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
                              if (compound.synonyms.length > 5) ...[
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(
                                          'All Synonyms',
                                          style: GoogleFonts.poppins(
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
                                                'Total synonyms: ${compound.synonyms.length}',
                                                style: GoogleFonts.poppins(
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
                                                children: compound.synonyms
                                                    .map((synonym) => Chip(
                                                          label: Text(
                                                            synonym,
                                                            style: GoogleFonts
                                                                .poppins(
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
                                            child: Text(
                                              'Close',
                                              style: GoogleFonts.poppins(),
                                            ),
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
                                    'Show ${compound.synonyms.length - 5} more synonyms',
                                    style: GoogleFonts.poppins(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                      // Stereochemistry section
                      if (compound.atomStereoCount > 0 ||
                          compound.bondStereoCount > 0)
                        _buildSection(
                          context,
                          title: 'Stereochemistry',
                          icon: Icons.science,
                          content: Column(
                            children: [
                              if (compound.atomStereoCount > 0)
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
                                              compound.atomStereoCount
                                                  .toString(),
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
                                        compound.undefinedAtomStereoCount
                                            .toString(),
                                      ),
                                    ],
                                  ),
                                ),
                              if (compound.bondStereoCount > 0)
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
                                              compound.bondStereoCount
                                                  .toString(),
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
                                        compound.undefinedBondStereoCount
                                            .toString(),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                      // Literature and Patents section
                      if (compound.patentCount > 0 ||
                          compound.literatureCount > 0)
                        _buildSection(
                          context,
                          title: 'Literature and Patents',
                          icon: Icons.menu_book,
                          content: Column(
                            children: [
                              if (compound.patentCount > 0)
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
                                              compound.patentFamilyCount
                                                  .toString(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              if (compound.literatureCount > 0)
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
                              onTap: () => _launchUrl(compound.pubChemUrl),
                            ),
                            _buildActionButton(
                              context,
                              title: 'Export Data',
                              icon: Icons.download,
                              onTap: () {
                                // TODO: Implement export functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Export functionality coming soon'),
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
              ),
            ],
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

  Widget _build3DViewer(BuildContext context, int cid) {
    final compound = context.read<CompoundProvider>().selectedCompound;
    if (compound == null) return const SizedBox.shrink();

    return Stack(
      children: [
        Complete3DMoleculeViewer(cid: cid),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'fullscreen_fab',
            mini: true,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FullScreenMoleculeView(
                    cid: cid,
                    title: compound.title,
                  ),
                ),
              );
            },
            tooltip: 'View in Full Screen',
            child: const Icon(Icons.fullscreen),
          ),
        ),
      ],
    );
  }
}
