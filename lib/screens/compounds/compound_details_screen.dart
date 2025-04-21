import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'provider/compound_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/error_handler.dart';
import '../bookmarks/provider/bookmark_provider.dart';
import 'model/compound.dart';
import '../../widgets/detail_widgets.dart';
import '../../widgets/chemistry_widgets.dart';
import 'similar_compounds_screen.dart';
import 'provider/chemical_search_provider.dart';

class CompoundDetailsScreen extends StatefulWidget {
  final Compound? selectedCompound;

  const CompoundDetailsScreen({
    super.key,
    this.selectedCompound,
  });

  @override
  State<CompoundDetailsScreen> createState() => _CompoundDetailsScreenState();
}

class _CompoundDetailsScreenState extends State<CompoundDetailsScreen> {
  bool _isLoading3D = false;
  String? _3dError;
  bool _isLoadingFullDetails = false;
  bool _isInitialized = false; // Track if we've initialized

  @override
  void initState() {
    super.initState();

    // Initialize state with a delay to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCompound();
    });
  }

  // New method to handle initialization or re-initialization
  void _initializeCompound() {
    if (_isInitialized) return;

    final compoundProvider =
        Provider.of<CompoundProvider>(context, listen: false);

    // If we have a selected compound either from the widget or provider, load its 3D structure
    final compound =
        widget.selectedCompound ?? compoundProvider.selectedCompound;

    if (compound != null) {
      setState(() {
        _isInitialized = true;
        _isLoadingFullDetails = true;
      });

      // If we have a compound from the widget but not in the provider, we need to fetch its details
      if (widget.selectedCompound != null &&
          compoundProvider.selectedCompound == null) {
        // Show loading state
        setState(() {
          _isLoadingFullDetails = true;
        });

        compoundProvider
            .fetchCompoundDetails(widget.selectedCompound!.cid)
            .then((_) {
          setState(() {
            _isLoadingFullDetails = false;
          });
        }).catchError((e) {
          debugPrint('Error fetching compound details: $e');
          setState(() {
            _isLoadingFullDetails = false;
          });

          if (mounted) {
            ErrorHandler.showErrorSnackBar(
                context, ErrorHandler.getErrorMessage(e));
          }
        });
      } else {
        setState(() {
          _isLoadingFullDetails = false;
        });
      }

      // Start loading 3D structure in parallel
      _load3DStructure(compound.cid);
    }
  }

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
        _3dError = ErrorHandler.getErrorMessage(e);
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
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      ErrorHandler.showErrorSnackBar(
          context, 'Could not open URL: ${ErrorHandler.getErrorMessage(e)}');
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
              Colors.white.withOpacity(0.95),
              BlendMode.luminosity,
            ),
          ),
        ),
        child: Consumer<CompoundProvider>(
          builder: (context, provider, child) {
            // Reinitialize if a compound has become available and we haven't initialized yet
            if (!_isInitialized && provider.selectedCompound != null) {
              // Use a post-frame callback to ensure the widget is fully built
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _initializeCompound();
              });
            }

            // Show loading indicator only for initial loading, not for detail updates
            if ((provider.isLoading && provider.selectedCompound == null) ||
                (!_isInitialized && widget.selectedCompound == null)) {
              return SafeArea(
                child: Column(
                  children: [
                    // Back button at the top
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
                    const Expanded(
                      child: Center(
                        child: ChemistryLoadingWidget(
                          message: 'Loading compound details...',
                        ),
                      ),
                    ),
                  ],
                ),
              );
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
                          onPressed: () => provider.fetchCompoundDetails(
                              provider.selectedCompound?.cid ??
                                  widget.selectedCompound?.cid ??
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

            final compound =
                provider.selectedCompound ?? widget.selectedCompound;
            if (compound == null) {
              return Center(
                child: ChemistryCardBackground(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                  ),
                ),
              );
            }

            return Stack(
              children: [
                _buildCompoundDetailContent(
                  context,
                  compound,
                  bookmarkProvider,
                  theme,
                ),

                // Show a loading indicator for full details that doesn't block interaction
                if (_isLoadingFullDetails || provider.isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: ChemistryLoadingWidget(
                          message: 'Loading compound details...',
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompoundDetailContent(
    BuildContext context,
    Compound compound,
    BookmarkProvider bookmarkProvider,
    ThemeData theme,
  ) {
    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        ChemistryDetailHeader(
          title: compound.title,
          cid: compound.cid,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.explore),
                tooltip: 'Explore Related',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider.value(
                              value: Provider.of<CompoundProvider>(context,
                                  listen: false)),
                          ChangeNotifierProvider(
                              create: (_) => ChemicalSearchProvider()),
                        ],
                        child: SimilarCompoundsScreen(
                          cid: compound.cid,
                          compoundName: compound.title,
                        ),
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  bookmarkProvider.isBookmarked(compound, BookmarkType.compound)
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                ),
                onPressed: () async {
                  if (bookmarkProvider.isBookmarked(
                      compound, BookmarkType.compound)) {
                    final success = await bookmarkProvider.removeBookmark(
                        compound, BookmarkType.compound);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? '${compound.title} removed from bookmarks'
                              : 'Error removing bookmark'),
                          behavior: SnackBarBehavior.floating,
                          action: success
                              ? null
                              : SnackBarAction(
                                  label: 'Retry',
                                  onPressed: () =>
                                      bookmarkProvider.removeBookmark(
                                          compound, BookmarkType.compound),
                                ),
                        ),
                      );
                    }
                  } else {
                    final success = await bookmarkProvider.addBookmark(
                        compound, BookmarkType.compound);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? '${compound.title} added to bookmarks'
                              : 'Error adding bookmark'),
                          behavior: SnackBarBehavior.floating,
                          action: success
                              ? null
                              : SnackBarAction(
                                  label: 'Retry',
                                  onPressed: () => bookmarkProvider.addBookmark(
                                      compound, BookmarkType.compound),
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
                    'Check out ${compound.title} (${compound.molecularFormula}) on PubChem: ${compound.pubChemUrl}',
                  );
                },
              ),
            ],
          ),
          onImageTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChemistryFullScreenView(
                  title: compound.title,
                  cid: compound.cid,
                ),
              ),
            );
          },
        ),
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
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
                              'CID: ${compound.cid}',
                              style: GoogleFonts.poppins(
                                color: theme.colorScheme.onPrimaryContainer,
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
                              compound.molecularFormula,
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

                // Description section
                if (compound.description.isNotEmpty)
                  DetailWidgets.buildSection(
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
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                // 3D Molecular Structure section
                DetailWidgets.buildSection(
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
                    child: Column(
                      children: [
                        if (_isLoading3D)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: ChemistryLoadingWidget(
                                message: 'Loading 3D structure...',
                              ),
                            ),
                          )
                        else if (_3dError != null)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: theme.colorScheme.error,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _3dError!,
                                    style: TextStyle(
                                        color: theme.colorScheme.error),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _load3DStructure(compound.cid),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          DetailWidgets.build3DViewer(
                            context,
                            cid: compound.cid,
                            title: compound.title,
                          ),
                      ],
                    ),
                  ),
                ),

                // Physical Properties section
                DetailWidgets.buildSection(
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
                              compound.molecularFormula,
                            ),
                            DetailWidgets.buildProperty(
                              context,
                              'SMILES',
                              compound.smiles,
                              isMultiLine: true,
                            ),
                            DetailWidgets.buildProperty(
                              context,
                              'InChI',
                              compound.inchi,
                              isMultiLine: true,
                            ),
                            DetailWidgets.buildProperty(
                              context,
                              'InChI Key',
                              compound.inchiKey,
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
                                    compound.xLogP.toStringAsFixed(2),
                                  ),
                                ),
                                Expanded(
                                  child: DetailWidgets.buildProperty(
                                    context,
                                    'Complexity',
                                    compound.complexity.toStringAsFixed(2),
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
                                    compound.hBondDonorCount.toString(),
                                  ),
                                ),
                                Expanded(
                                  child: DetailWidgets.buildProperty(
                                    context,
                                    'H-Bond Acceptors',
                                    compound.hBondAcceptorCount.toString(),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: DetailWidgets.buildProperty(
                                    context,
                                    'TPSA',
                                    '${compound.tpsa} Å²',
                                  ),
                                ),
                                Expanded(
                                  child: DetailWidgets.buildProperty(
                                    context,
                                    'Charge',
                                    compound.charge.toString(),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: DetailWidgets.buildProperty(
                                    context,
                                    'Monoisotopic Mass',
                                    '${compound.monoisotopicMass} g/mol',
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: DetailWidgets.buildProperty(
                                    context,
                                    'Rotatable Bonds',
                                    compound.rotatableBondCount.toString(),
                                  ),
                                ),
                                Expanded(
                                  child: DetailWidgets.buildProperty(
                                    context,
                                    'Heavy Atoms',
                                    compound.heavyAtomCount.toString(),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: DetailWidgets.buildProperty(
                                    context,
                                    'Isotope Atoms',
                                    compound.isotopeAtomCount.toString(),
                                  ),
                                ),
                                Expanded(
                                  child: DetailWidgets.buildProperty(
                                    context,
                                    'Covalent Units',
                                    compound.covalentUnitCount.toString(),
                                  ),
                                ),
                              ],
                            ),
                            // Add new chemical properties
                            if (compound.physicalProperties['MeltingPoint'] !=
                                null)
                              DetailWidgets.buildProperty(
                                context,
                                'Melting Point',
                                compound.physicalProperties['MeltingPoint'],
                              ),
                            if (compound.physicalProperties['BoilingPoint'] !=
                                null)
                              DetailWidgets.buildProperty(
                                context,
                                'Boiling Point',
                                compound.physicalProperties['BoilingPoint'],
                              ),
                            if (compound.physicalProperties['FlashPoint'] !=
                                null)
                              DetailWidgets.buildProperty(
                                context,
                                'Flash Point',
                                compound.physicalProperties['FlashPoint'],
                              ),
                            if (compound.physicalProperties['Density'] != null)
                              DetailWidgets.buildProperty(
                                context,
                                'Density',
                                compound.physicalProperties['Density'],
                              ),
                            if (compound.physicalProperties['Solubility'] !=
                                null)
                              DetailWidgets.buildProperty(
                                context,
                                'Solubility',
                                compound.physicalProperties['Solubility'],
                              ),
                            if (compound.physicalProperties['VaporPressure'] !=
                                null)
                              DetailWidgets.buildProperty(
                                context,
                                'Vapor Pressure',
                                compound.physicalProperties['VaporPressure'],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Stereochemistry section
                if (compound.atomStereoCount > 0 ||
                    compound.bondStereoCount > 0)
                  DetailWidgets.buildSection(
                    context,
                    title: 'Stereochemistry',
                    icon: Icons.science,
                    content: Column(
                      children: [
                        if (compound.atomStereoCount > 0)
                          DetailWidgets.buildPropertyCard(
                            context,
                            title: 'Atom Stereochemistry',
                            content: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: DetailWidgets.buildProperty(
                                        context,
                                        'Total Atom Stereo Count',
                                        compound.atomStereoCount.toString(),
                                      ),
                                    ),
                                    Expanded(
                                      child: DetailWidgets.buildProperty(
                                        context,
                                        'Defined Atom Stereo Count',
                                        compound.definedAtomStereoCount
                                            .toString(),
                                      ),
                                    ),
                                  ],
                                ),
                                DetailWidgets.buildProperty(
                                  context,
                                  'Undefined Atom Stereo Count',
                                  compound.undefinedAtomStereoCount.toString(),
                                ),
                              ],
                            ),
                          ),
                        if (compound.bondStereoCount > 0)
                          DetailWidgets.buildPropertyCard(
                            context,
                            title: 'Bond Stereochemistry',
                            content: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: DetailWidgets.buildProperty(
                                        context,
                                        'Total Bond Stereo Count',
                                        compound.bondStereoCount.toString(),
                                      ),
                                    ),
                                    Expanded(
                                      child: DetailWidgets.buildProperty(
                                        context,
                                        'Defined Bond Stereo Count',
                                        compound.definedBondStereoCount
                                            .toString(),
                                      ),
                                    ),
                                  ],
                                ),
                                DetailWidgets.buildProperty(
                                  context,
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
                if (compound.patentCount > 0 || compound.literatureCount > 0)
                  DetailWidgets.buildSection(
                    context,
                    title: 'Literature and Patents',
                    icon: Icons.menu_book,
                    content: Column(
                      children: [
                        if (compound.patentCount > 0)
                          DetailWidgets.buildPropertyCard(
                            context,
                            title: 'Patents',
                            content: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: DetailWidgets.buildProperty(
                                        context,
                                        'Patent Count',
                                        compound.patentCount.toString(),
                                      ),
                                    ),
                                    Expanded(
                                      child: DetailWidgets.buildProperty(
                                        context,
                                        'Patent Family Count',
                                        compound.patentFamilyCount.toString(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        if (compound.literatureCount > 0)
                          DetailWidgets.buildPropertyCard(
                            context,
                            title: 'Literature',
                            content: Column(
                              children: [
                                DetailWidgets.buildProperty(
                                  context,
                                  'Literature Count',
                                  compound.literatureCount.toString(),
                                ),
                                if (compound.annotationTypes.isNotEmpty)
                                  DetailWidgets.buildProperty(
                                    context,
                                    'Annotation Types',
                                    compound.annotationTypes.join(', '),
                                  ),
                                DetailWidgets.buildProperty(
                                  context,
                                  'Annotation Type Count',
                                  compound.annotationTypeCount.toString(),
                                ),
                                if (compound.sourceCategories.isNotEmpty)
                                  DetailWidgets.buildProperty(
                                    context,
                                    'Source Categories',
                                    compound.sourceCategories.join(', '),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                // Synonyms section
                if (compound.synonyms.isNotEmpty)
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
                          children: compound.synonyms
                              .take(5)
                              .map((synonym) => Chip(
                                    label: Text(
                                      synonym,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                      ),
                                    ),
                                    backgroundColor: theme
                                        .colorScheme.surfaceContainerHighest,
                                    labelStyle: TextStyle(
                                      color: theme.colorScheme.onSurfaceVariant,
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
                                            color: theme.colorScheme.onSurface
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
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    backgroundColor: theme
                                                        .colorScheme
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
                  )
                else
                  DetailWidgets.buildSection(
                    context,
                    title: 'Synonyms',
                    icon: Icons.text_fields,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'No synonyms available for this compound',
                            style: GoogleFonts.poppins(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Related Compounds section
                DetailWidgets.buildSection(
                  context,
                  title: 'Related Information',
                  icon: Icons.explore,
                  content: DetailWidgets.buildActionButton(
                    context,
                    title: 'Find Similar Compounds',
                    icon: Icons.compare,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SimilarCompoundsScreen(
                            cid: compound.cid,
                            compoundName: compound.title,
                          ),
                        ),
                      );
                    },
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
                        onTap: () => _launchUrl(compound.pubChemUrl),
                      ),
                      DetailWidgets.buildActionButton(
                        context,
                        title: 'Export Data',
                        icon: Icons.download,
                        onTap: () {
                          // TODO: Implement export functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Export functionality coming soon'),
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
  }

  // New method to handle widget updates
  @override
  void didUpdateWidget(CompoundDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the selectedCompound has changed, we need to reinitialize
    if (widget.selectedCompound?.cid != oldWidget.selectedCompound?.cid) {
      setState(() {
        _isInitialized = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeCompound();
      });
    }
  }
}
