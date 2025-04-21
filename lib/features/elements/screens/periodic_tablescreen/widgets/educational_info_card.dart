import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EducationalInfoCard extends StatelessWidget {
  final bool visible;
  final VoidCallback onClose;

  const EducationalInfoCard({
    Key? key,
    required this.visible,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.tertiaryContainer.withOpacity(0.8),
            theme.colorScheme.tertiaryContainer.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          "Understanding the Periodic Table",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onTertiaryContainer,
          ),
        ),
        leading: Icon(
          Icons.school,
          color: theme.colorScheme.onTertiaryContainer,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.expand_more,
              color: Theme.of(context)
                  .colorScheme
                  .onSecondaryContainer
                  .withOpacity(0.7),
              size: 20,
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                color: theme.colorScheme.onTertiaryContainer.withOpacity(0.7),
                size: 20,
              ),
              onPressed: onClose,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "The periodic table organizes chemical elements according to their atomic number, electron configuration, and recurring chemical properties. Elements are arranged in rows (periods) and columns (groups).",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color:
                        theme.colorScheme.onTertiaryContainer.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                _buildElementCategoryLegend(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementCategoryLegend(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Element Categories:",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onTertiaryContainer,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildCategoryChip("Metals", const Color(0xFFF44336), theme),
            _buildCategoryChip("Nonmetals", const Color(0xFF4CAF50), theme),
            _buildCategoryChip("Metalloids", const Color(0xFF9C27B0), theme),
            _buildCategoryChip("Noble Gases", const Color(0xFF2196F3), theme),
            _buildCategoryChip("Halogens", const Color(0xFF29B6F6), theme),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
