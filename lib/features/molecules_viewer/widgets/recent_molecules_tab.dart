import 'package:flutter/material.dart';
import 'recent_molecule_item.dart';
import 'package:intl/intl.dart';

class RecentMoleculesTab extends StatelessWidget {
  final List<Map<String, dynamic>> recentMolecules;
  final Function(int cid, String name, String formula) onMoleculeSelected;
  final Function()? onClearAll;
  final Function(int cid)? onRemoveItem;

  const RecentMoleculesTab({
    Key? key,
    required this.recentMolecules,
    required this.onMoleculeSelected,
    this.onClearAll,
    this.onRemoveItem,
  }) : super(key: key);

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null) return '';

    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      // Today - show time only
      return 'Today, ${DateFormat.jm().format(dateTime)}';
    } else if (date == yesterday) {
      // Yesterday - show as 'Yesterday'
      return 'Yesterday, ${DateFormat.jm().format(dateTime)}';
    } else if (now.difference(dateTime).inDays < 7) {
      // Within the last week - show day of week
      return DateFormat('EEEE, h:mm a').format(dateTime);
    } else {
      // Older - show full date
      return DateFormat('MMM d, yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (recentMolecules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No recent molecules',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Molecules you view will appear here',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header with clear all button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Molecules',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              if (onClearAll != null)
                TextButton.icon(
                  icon: const Icon(Icons.delete_outlined, size: 18),
                  label: const Text('Clear All'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Clear History'),
                        content: const Text(
                            'Are you sure you want to clear all molecule viewing history?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              onClearAll!();
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          // List of recent molecules
          Expanded(
            child: ListView.builder(
              itemCount: recentMolecules.length,
              itemBuilder: (context, index) {
                final molecule = recentMolecules[index];
                final timestamp = molecule['timestamp'] as int?;
                final timeAgo = _formatTimestamp(timestamp);

                return Dismissible(
                  key: Key('molecule-${molecule['cid']}'),
                  background: Container(
                    color: Colors.red[400],
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16.0),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Remove from History'),
                        content: Text(
                            'Remove "${molecule['name']}" from your history?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    if (onRemoveItem != null) {
                      onRemoveItem!(molecule['cid']);
                    }
                  },
                  child: RecentMoleculeItem(
                    name: molecule['name'],
                    cid: molecule['cid'],
                    formula: molecule['formula'] ?? '',
                    timeAgo: timeAgo,
                    onTap: () => onMoleculeSelected(
                      molecule['cid'],
                      molecule['name'],
                      molecule['formula'] ?? '',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
