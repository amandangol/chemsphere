import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ElementCategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const ElementCategoryFilter({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Get unique categories with emojis
    final categories = [
      {'name': 'All', 'emoji': '🔍'},
      {'name': 'Alkali Metal', 'emoji': '🔥'},
      {'name': 'Alkaline Earth Metal', 'emoji': '🌍'},
      {'name': 'Transition Metal', 'emoji': '⚙️'},
      {'name': 'Metalloid', 'emoji': '🔋'},
      {'name': 'Polyatomic Nonmetal', 'emoji': '💨'},
      {'name': 'Diatomic Nonmetal', 'emoji': '💫'},
      {'name': 'Noble Gas', 'emoji': '✨'},
      {'name': 'Lanthanide', 'emoji': '🌟'},
      {'name': 'Actinide', 'emoji': '☢️'},
      {'name': 'Halogen', 'emoji': '💎'},
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: AnimationLimiter(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory == category['name'];

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: FilterChip(
                        label: Row(
                          children: [
                            Text(
                              category['emoji']!,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              category['name']!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? theme.colorScheme.onPrimaryContainer
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          onCategorySelected(category['name']!);
                        },
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        selectedColor: theme.colorScheme.primaryContainer,
                        checkmarkColor: theme.colorScheme.primary,
                        elevation: isSelected ? 2 : 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary.withOpacity(0.5)
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        showCheckmark: false,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
