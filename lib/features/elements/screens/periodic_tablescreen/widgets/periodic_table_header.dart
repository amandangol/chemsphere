import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PeriodicTableHeader extends StatelessWidget {
  final VoidCallback onToggleView;
  final VoidCallback onModernViewTap;
  final bool isGridView;
  final Function(bool) onRefresh;
  final Function() onClearCache;

  const PeriodicTableHeader({
    Key? key,
    required this.onToggleView,
    required this.onModernViewTap,
    required this.isGridView,
    required this.onRefresh,
    required this.onClearCache,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.table_chart_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Periodic Table',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Explore chemical elements',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              // Traditional view button
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.grid_on,
                    color: theme.colorScheme.secondary,
                  ),
                  onPressed: onModernViewTap,
                ),
              ),
              const SizedBox(width: 8),
              // Toggle view button with improved design
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    isGridView
                        ? Icons.view_list_rounded
                        : Icons.grid_view_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: onToggleView,
                ),
              ),
              const SizedBox(width: 8),

              PopupMenuButton(
                icon: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.refresh_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: ListTile(
                      leading:
                          Icon(Icons.refresh, color: theme.colorScheme.primary),
                      title: const Text('Refresh'),
                      subtitle: const Text('Use cached data if available'),
                    ),
                    onTap: () => onRefresh(false),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading:
                          Icon(Icons.sync, color: theme.colorScheme.secondary),
                      title: const Text('Force Refresh'),
                      subtitle: const Text('Fetch fresh data from server'),
                    ),
                    onTap: () => onRefresh(true),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.delete_outline,
                          color: theme.colorScheme.error),
                      title: const Text('Clear Cache'),
                      subtitle: const Text('Remove stored data'),
                    ),
                    onTap: onClearCache,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
