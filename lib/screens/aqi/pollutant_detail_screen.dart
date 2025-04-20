import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/pollutant.dart';
import '../../providers/pollutant_info_provider.dart';

class PollutantDetailScreen extends StatefulWidget {
  final Pollutant pollutant;

  const PollutantDetailScreen({
    Key? key,
    required this.pollutant,
  }) : super(key: key);

  @override
  State<PollutantDetailScreen> createState() => _PollutantDetailScreenState();
}

class _PollutantDetailScreenState extends State<PollutantDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the pollutant details when the screen is initialized
    Future.microtask(() {
      Provider.of<PollutantInfoProvider>(context, listen: false)
          .fetchPollutantDetails(widget.pollutant);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.pollutant.name} Details',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
      ),
      body: Consumer<PollutantInfoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchPollutantDetails(widget.pollutant);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with compound name and current value
                _buildHeader(theme),

                const SizedBox(height: 24),

                // Health Impact
                _buildSection(
                  theme,
                  title: 'Health Impact',
                  icon: Icons.health_and_safety,
                  color: Colors.red.shade400,
                  content: Text(
                    widget.pollutant.healthEffects ??
                        widget.pollutant.getHealthImpact(),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Safety Information
                _buildSection(
                  theme,
                  title: 'Safety Advice',
                  icon: Icons.security,
                  color: Colors.green.shade600,
                  content: Text(
                    widget.pollutant.safetyInfo ??
                        'No safety information available.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Sources
                _buildSection(
                  theme,
                  title: 'Common Sources',
                  icon: Icons.source,
                  color: Colors.amber.shade800,
                  content: Text(
                    widget.pollutant.sources ??
                        'Source information not available.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Chemical Properties
                if (provider.pollutantDetails.containsKey(widget.pollutant.cid))
                  _buildSection(
                    theme,
                    title: 'Chemical Properties',
                    icon: Icons.science,
                    color: Colors.purple.shade400,
                    content: _buildPropertiesTable(
                      theme,
                      provider.pollutantDetails[widget.pollutant.cid] ?? {},
                    ),
                  ),

                const SizedBox(height: 16),

                // Description from PubChem
                if (provider.pollutantDetails
                        .containsKey(widget.pollutant.cid) &&
                    provider.pollutantDetails[widget.pollutant.cid]
                            ?['description'] !=
                        null)
                  _buildSection(
                    theme,
                    title: 'Description',
                    icon: Icons.description,
                    color: Colors.blue.shade600,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.pollutantDetails[widget.pollutant.cid]
                                  ?['description'] ??
                              '',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                          ),
                        ),
                        if (provider.pollutantDetails[widget.pollutant.cid]
                                ?['descriptionSource'] !=
                            null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Source: ${provider.pollutantDetails[widget.pollutant.cid]?['descriptionSource']}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Open in PubChem button
                if (provider.pollutantDetails
                        .containsKey(widget.pollutant.cid) &&
                    provider.pollutantDetails[widget.pollutant.cid]
                            ?['pubChemUrl'] !=
                        null)
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('View in PubChem'),
                      onPressed: () {
                        // Open PubChem URL
                        // In a real app, you would use url_launcher package
                        final url =
                            provider.pollutantDetails[widget.pollutant.cid]
                                ?['pubChemUrl'];
                        if (url != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening $url'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.8),
            theme.colorScheme.secondary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.pollutant.name,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.pollutant.fullName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.pollutant.formattedValue,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.pollutant.description,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildPropertiesTable(
      ThemeData theme, Map<String, dynamic> properties) {
    List<TableRow> rows = [];

    // Add formula if available
    if (properties['formula'] != null) {
      rows.add(_buildPropertyRow(theme, 'Formula', properties['formula']));
    }

    // Add molecular weight if available
    if (properties['weight'] != null) {
      rows.add(_buildPropertyRow(
          theme, 'Molecular Weight', '${properties['weight']} g/mol'));
    }

    // Add other properties based on what's available
    final physicalProps = properties['properties'] as Map<String, dynamic>?;
    if (physicalProps != null) {
      if (physicalProps['Density'] != null) {
        rows.add(_buildPropertyRow(
            theme, 'Density', '${physicalProps['Density']} g/cm³'));
      }

      if (physicalProps['MeltingPoint'] != null) {
        rows.add(_buildPropertyRow(
            theme, 'Melting Point', '${physicalProps['MeltingPoint']} °C'));
      }

      if (physicalProps['BoilingPoint'] != null) {
        rows.add(_buildPropertyRow(
            theme, 'Boiling Point', '${physicalProps['BoilingPoint']} °C'));
      }

      if (physicalProps['Solubility'] != null) {
        rows.add(_buildPropertyRow(
            theme, 'Solubility', physicalProps['Solubility'].toString()));
      }
    }

    if (rows.isEmpty) {
      return Text(
        'No chemical properties available for this pollutant.',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
      },
      border: TableBorder.all(
        color: Colors.grey.withOpacity(0.2),
        width: 1,
      ),
      children: rows,
    );
  }

  TableRow _buildPropertyRow(ThemeData theme, String property, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            property,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'About ${widget.pollutant.name}',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This pollutant information is sourced from:',
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 8),
              Text(
                '• PubChem database (National Library of Medicine)',
                style: GoogleFonts.poppins(),
              ),
              Text(
                '• EPA (Environmental Protection Agency)',
                style: GoogleFonts.poppins(),
              ),
              Text(
                '• WHO (World Health Organization)',
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 16),
              Text(
                'The health impact analysis is based on established scientific standards and air quality guidelines.',
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
