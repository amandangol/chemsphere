import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/reaction_provider.dart';
import '../../../services/search_history_service.dart';
import '../../../theme/app_theme.dart';

class ReactionScreen extends StatefulWidget {
  const ReactionScreen({Key? key}) : super(key: key);

  @override
  State<ReactionScreen> createState() => _ReactionScreenState();
}

class _ReactionScreenState extends State<ReactionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  bool _isSearching = false;
  List<String> _searchHistory = [];
  final List<String> _quickSearchItems = [
    'Combustion',
    'Synthesis',
    'Decomposition',
    'Single Displacement',
    'Double Displacement',
    'Acid-Base',
    'Redox',
    'Precipitation',
    'Neutralization',
    'Hydrolysis'
  ];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReactionProvider>(context, listen: false)
          .searchReactions('Combustion');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final history =
        await _searchHistoryService.getSearchHistory(SearchType.reaction);
    setState(() {
      _searchHistory = history;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isNotEmpty) {
      await _searchHistoryService.addToSearchHistory(
          query, SearchType.reaction);
      await _loadSearchHistory();
      context.read<ReactionProvider>().searchReactions(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chemical Reactions'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
      ),
      body: Consumer<ReactionProvider>(
        builder: (context, reactionProvider, child) {
          if (reactionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (reactionProvider.error != null) {
            return Center(
              child: Text(
                reactionProvider.error!,
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: reactionProvider.reactions.length,
            itemBuilder: (context, index) {
              final reaction = reactionProvider.reactions[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    reaction.name,
                    style: AppTheme.lightTheme.textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    reaction.type,
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  onTap: () {
                    // Navigate to reaction detail screen
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
