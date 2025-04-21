import 'package:chem_explore/widgets/chemistry_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'provider/chemical_search_provider.dart';
import 'compound_details_screen.dart';
import 'provider/compound_provider.dart';
import '../../utils/error_handler.dart';

class SimilarCompoundsScreen extends StatefulWidget {
  final int cid;
  final String compoundName;

  const SimilarCompoundsScreen({
    Key? key,
    required this.cid,
    required this.compoundName,
  }) : super(key: key);

  @override
  State<SimilarCompoundsScreen> createState() => _SimilarCompoundsScreenState();
}

class _SimilarCompoundsScreenState extends State<SimilarCompoundsScreen> {
  final int _threshold = 90; // Similarity threshold (90% by default)

  @override
  void initState() {
    super.initState();
    // Load data after the frame is built to ensure the provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSimilarCompounds();
    });
  }

  Future<void> _loadSimilarCompounds() async {
    if (!mounted) return;
    final provider =
        Provider.of<ChemicalSearchProvider>(context, listen: false);
    await provider.findSimilarCompounds(widget.cid, threshold: _threshold);
  }

  Future<void> _viewCompoundDetails(int cid) async {
    try {
      final compoundProvider =
          Provider.of<CompoundProvider>(context, listen: false);

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Loading compound details...'),
              ],
            ),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Fetch details
      await compoundProvider.fetchCompoundDetails(cid);

      if (!mounted) return;

      // Dismiss any snackbars
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CompoundDetailsScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Dismiss loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading compound details: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Similar to ${widget.compoundName}',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: Consumer<ChemicalSearchProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const ChemistryLoadingWidget();
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      provider.error!,
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadSimilarCompounds,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final relatedCompounds = provider.relatedCompounds;

          if (relatedCompounds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.science_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No similar compounds found',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: relatedCompounds.length,
              itemBuilder: (context, index) {
                final compound = relatedCompounds[index];
                final similarityScore = compound.similarityScore;
                final similarityInt = similarityScore.toInt();

                // Color gradient based on similarity score
                final similarityColor = ColorTween(
                  begin: Colors.orange,
                  end: Colors.green,
                ).lerp(similarityScore / 100)!;

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: InkWell(
                          onTap: () => _viewCompoundDetails(compound.cid),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Compound image
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${compound.cid}/PNG',
                                      placeholder: (context, url) =>
                                          const Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                      errorWidget: (context, url, error) {
                                        // Improved error handling for image loading
                                        print(
                                            'Error loading compound image: $error');
                                        String errorMessage =
                                            'Image not available';

                                        if (error is SocketException ||
                                            ErrorHandler.isNetworkError(
                                                error)) {
                                          errorMessage = 'Network error';
                                        }

                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                        );
                                      },
                                      fit: BoxFit.contain,
                                      // Add better caching options
                                      maxHeightDiskCache: 250,
                                      maxWidthDiskCache: 250,
                                      memCacheWidth: 250,
                                      memCacheHeight: 250,
                                      useOldImageOnUrlChange: true,
                                      fadeInDuration:
                                          const Duration(milliseconds: 300),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              compound.title,
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: similarityColor
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: similarityColor,
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              '$similarityInt% Match',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: similarityColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Formula: ${compound.molecularFormula}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        'MW: ${compound.molecularWeight.toStringAsFixed(2)} g/mol',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          onPressed: () => _viewCompoundDetails(
                                              compound.cid),
                                          icon: const Icon(
                                            Icons.visibility,
                                            size: 16,
                                          ),
                                          label: const Text('View Details'),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            textStyle: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Similarity threshold: $_threshold%',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            ElevatedButton.icon(
              onPressed: _loadSimilarCompounds,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
