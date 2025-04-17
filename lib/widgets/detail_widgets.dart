import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'molecule_3d_viewer.dart';

class DetailWidgets {
  static Widget buildSection(
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

  static Widget buildPropertyCard(
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

  static Widget buildProperty(
    BuildContext context,
    String label,
    String value, {
    bool isMultiLine = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isMultiLine ? 13 : 14,
              fontWeight: isMultiLine ? FontWeight.normal : FontWeight.w500,
            ),
            maxLines: isMultiLine ? 3 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  static Widget buildActionButton(
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
                style: GoogleFonts.poppins(
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

  static Widget build3DViewer(
    BuildContext context, {
    required int cid,
    required String title,
  }) {
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
                    title: title,
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
