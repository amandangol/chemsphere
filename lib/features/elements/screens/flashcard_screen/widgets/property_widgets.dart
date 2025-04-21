import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Widget for detail chips on the front card
class PropertyChip extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  final IconData icon;
  final int maxLines;

  const PropertyChip({
    Key? key,
    required this.label,
    required this.value,
    required this.textColor,
    required this.icon,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$label: $value',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          color: textColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, size: 12, color: textColor.withOpacity(0.8)),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                value.isEmpty ? 'N/A' : value,
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: textColor,
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: maxLines,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for detail rows on the front card
class PropertyRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  final IconData icon;
  final bool allowWrap;
  final int maxLines;
  final bool useChipStyle;

  const PropertyRow({
    Key? key,
    required this.label,
    required this.value,
    required this.textColor,
    required this.icon,
    this.allowWrap = false,
    this.maxLines = 1,
    this.useChipStyle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (useChipStyle) {
      return PropertyChip(
        label: label,
        value: value,
        textColor: textColor,
        icon: icon,
        maxLines: maxLines,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(icon, size: 14, color: textColor.withOpacity(0.9)),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: GoogleFonts.lato(
                fontSize: 13,
                color: textColor,
                height: 1.2,
              ),
              textAlign: TextAlign.left,
              softWrap: allowWrap,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for detail items on the back card
class PropertyItem extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  final IconData icon;
  final bool allowWrap;

  const PropertyItem({
    Key? key,
    required this.label,
    required this.value,
    required this.textColor,
    required this.icon,
    this.allowWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment:
            allowWrap ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          FaIcon(
            icon,
            size: 14,
            color: textColor.withOpacity(0.8),
          ),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: GoogleFonts.lato(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textColor.withOpacity(0.9),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              textAlign: TextAlign.right,
              softWrap: allowWrap,
              maxLines: allowWrap ? 4 : 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lato(fontSize: 13, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
