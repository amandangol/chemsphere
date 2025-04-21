import 'package:flutter/material.dart';

class FullscreenTitleOverlay extends StatelessWidget {
  final String moleculeName;
  final String formula;

  const FullscreenTitleOverlay({
    Key? key,
    required this.moleculeName,
    this.formula = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 45,
      left: 16,
      right: 160,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              moleculeName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'JetBrainsMono',
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            if (formula.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  formula,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'JetBrainsMono',
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
