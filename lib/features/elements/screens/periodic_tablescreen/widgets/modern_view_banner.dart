import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ModernViewBanner extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onArrowTap;

  const ModernViewBanner({
    Key? key,
    required this.onTap,
    required this.onArrowTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.secondary.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: theme.colorScheme.secondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Try the modern view to explore elements arranged by period and group!',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_forward,
                color: theme.colorScheme.secondary,
                size: 20,
              ),
              onPressed: onArrowTap,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(4),
            ),
          ],
        ),
      ),
    );
  }
}
