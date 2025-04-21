import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../drugs/provider/drug_provider.dart';
import 'provider/bookmark_provider.dart';
import '../drugs/model/drug.dart';
import '../compounds/model/compound.dart';
import '../elements/model/periodic_element.dart';
import '../drugs/drug_detail_screen.dart';
import '../compounds/compound_details_screen.dart';
import '../compounds/provider/compound_provider.dart';
import '../elements/screens/element_detailscreen/element_detail_screen.dart';
import '../../widgets/chemistry_widgets.dart';

// Import our bookmark widgets
import 'widgets/bookmark_widgets.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    final bookmarkedDrugs = bookmarkProvider.bookmarkedDrugs;
    final bookmarkedCompounds = bookmarkProvider.bookmarkedCompounds;
    final bookmarkedElements = bookmarkProvider.bookmarkedElements;
    final hasError = bookmarkProvider.lastError != null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bookmarks',
          style: TextStyle(fontSize: 17),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.5),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Reload bookmarks',
            onPressed: () async {
              await bookmarkProvider.reloadBookmarks();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bookmarks reloaded'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
        bottom: (bookmarkedDrugs.isEmpty &&
                    bookmarkedCompounds.isEmpty &&
                    bookmarkedElements.isEmpty) ||
                hasError
            ? null
            : TabBar(
                controller: _tabController,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: Colors.white,
                indicatorColor: theme.colorScheme.primary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(
                    icon: const Icon(Icons.medication, size: 20),
                    text: 'Drugs (${bookmarkedDrugs.length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.science, size: 20),
                    text: 'Compounds (${bookmarkedCompounds.length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.api, size: 20),
                    text: 'Elements (${bookmarkedElements.length})',
                  ),
                ],
              ),
      ),
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
        child: hasError
            ? _buildErrorView(context, bookmarkProvider)
            : (bookmarkedDrugs.isEmpty &&
                    bookmarkedCompounds.isEmpty &&
                    bookmarkedElements.isEmpty)
                ? _buildEmptyView(context)
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Drugs Tab
                      bookmarkedDrugs.isEmpty
                          ? _buildEmptyCategoryView(
                              context, 'No drugs bookmarked')
                          : _buildDrugList(
                              context, bookmarkProvider, bookmarkedDrugs),

                      // Compounds Tab
                      bookmarkedCompounds.isEmpty
                          ? _buildEmptyCategoryView(
                              context, 'No compounds bookmarked')
                          : _buildCompoundList(
                              context, bookmarkProvider, bookmarkedCompounds),

                      // Elements Tab
                      bookmarkedElements.isEmpty
                          ? _buildEmptyCategoryView(
                              context, 'No elements bookmarked')
                          : _buildElementList(
                              context, bookmarkProvider, bookmarkedElements),
                    ],
                  ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, BookmarkProvider provider) {
    return BookmarkErrorWidget(
      errorMessage: provider.lastError,
      onRetry: () => provider.reloadBookmarks(),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return const EmptyBookmarksWidget();
  }

  Widget _buildEmptyCategoryView(BuildContext context, String message) {
    return EmptyCategoryWidget(message: message);
  }

  Widget _buildDrugList(
      BuildContext context, BookmarkProvider provider, List<Drug> drugs) {
    // Convert Drug objects to Maps for the BookmarkList
    List<Map<String, dynamic>> bookmarks = drugs.map((drug) {
      return {
        'type': 'drug',
        'data': {
          'name': drug.title,
          'description': drug.description,
          'atomicNumber': drug.molecularWeight,
          'imageUrl':
              'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${drug.cid}/PNG',
        },
      };
    }).toList();

    return BookmarkList(
      bookmarks: bookmarks,
      onTapBookmark: (bookmark) async {
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

          // Get the drug provider to fetch the full details
          final drugProvider =
              Provider.of<DrugProvider>(context, listen: false);
          drugProvider.clearSelectedDrug();

          // Fetch fresh data for the drug
          final drug = drugs.firstWhere((d) =>
              d.cid == bookmark['data']['cid'] ||
              d.title == bookmark['data']['name']);

          await drugProvider.getDrug(drug.cid).then((updatedDrug) {
            // Close loading dialog
            if (context.mounted) {
              Navigator.pop(context);
            }

            if (context.mounted && drugProvider.error == null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DrugDetailScreen(),
                ),
              );
            } else if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(drugProvider.error ?? 'Failed to load drug details'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }).catchError((e) {
            // Close loading dialog on error
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error loading details: ${e.toString()}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error viewing drug details: ${e.toString()}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onRemoveBookmark: (bookmark) async {
        final drug = drugs.firstWhere(
            (d) => d.title == bookmark['data']['name'],
            orElse: () => drugs.first);

        final success = await provider.removeBookmark(drug, BookmarkType.drug);
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
                      onPressed: () =>
                          provider.removeBookmark(drug, BookmarkType.drug),
                    ),
            ),
          );
        }
      },
    );
  }

  Widget _buildCompoundList(BuildContext context, BookmarkProvider provider,
      List<Compound> compounds) {
    // Convert Compound objects to Maps for the BookmarkList
    List<Map<String, dynamic>> bookmarks = compounds.map((compound) {
      return {
        'type': 'compound',
        'data': {
          'name': compound.title,
          'molecularFormula': compound.molecularFormula,
          'imageUrl':
              'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${compound.cid}/PNG',
          'cid': compound.cid,
        },
      };
    }).toList();

    return BookmarkList(
      bookmarks: bookmarks,
      onTapBookmark: (bookmark) async {
        try {
          // Show loading dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: ChemistryLoadingWidget(
                message: 'Loading compound details...',
              ),
            ),
          );

          // Get the compound provider to fetch the full details
          final compoundProvider =
              Provider.of<CompoundProvider>(context, listen: false);
          compoundProvider.clearSelectedCompound();

          // Fetch fresh data for the compound
          final compound = compounds.firstWhere((c) =>
              c.cid == bookmark['data']['cid'] ||
              c.title == bookmark['data']['name']);

          await compoundProvider
              .getCompound(compound.cid)
              .then((updatedCompound) {
            // Close loading dialog
            if (context.mounted) {
              Navigator.pop(context);
            }

            if (context.mounted && compoundProvider.error == null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CompoundDetailsScreen(),
                ),
              );
            } else if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(compoundProvider.error ??
                      'Failed to load compound details'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }).catchError((e) {
            // Close loading dialog on error
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error loading details: ${e.toString()}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error viewing compound details: ${e.toString()}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onRemoveBookmark: (bookmark) async {
        final compound = compounds.firstWhere(
            (c) => c.title == bookmark['data']['name'],
            orElse: () => compounds.first);

        final success =
            await provider.removeBookmark(compound, BookmarkType.compound);
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
                      onPressed: () => provider.removeBookmark(
                          compound, BookmarkType.compound),
                    ),
            ),
          );
        }
      },
    );
  }

  Widget _buildElementList(BuildContext context, BookmarkProvider provider,
      List<PeriodicElement> elements) {
    // Convert PeriodicElement objects to Maps for the BookmarkList
    List<Map<String, dynamic>> bookmarks = elements.map((element) {
      return {
        'type': 'element',
        'data': {
          'name': element.name,
          'symbol': element.symbol,
          'atomicNumber': element.atomicNumber,
          'groupBlock': element.groupBlock,
        },
      };
    }).toList();

    return BookmarkList(
      bookmarks: bookmarks,
      onTapBookmark: (bookmark) {
        try {
          // Find the actual element object
          final element = elements.firstWhere((e) =>
              e.name == bookmark['data']['name'] &&
              e.symbol == bookmark['data']['symbol']);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ElementDetailScreen(element: element),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error viewing element details: ${e.toString()}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onRemoveBookmark: (bookmark) async {
        // Find the actual element object
        final element = elements.firstWhere(
            (e) =>
                e.name == bookmark['data']['name'] &&
                e.symbol == bookmark['data']['symbol'],
            orElse: () => elements.first);

        final success =
            await provider.removeBookmark(element, BookmarkType.element);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success
                  ? '${element.name} removed from bookmarks'
                  : 'Error removing bookmark'),
              behavior: SnackBarBehavior.floating,
              action: success
                  ? null
                  : SnackBarAction(
                      label: 'Retry',
                      onPressed: () => provider.removeBookmark(
                          element, BookmarkType.element),
                    ),
            ),
          );
        }
      },
    );
  }
}
