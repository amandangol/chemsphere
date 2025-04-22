import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../models/pollutant.dart';
import 'provider/pollutant_info_provider.dart';

class PollutantDetailScreen extends StatefulWidget {
  final Pollutant pollutant;

  const PollutantDetailScreen({
    Key? key,
    required this.pollutant,
  }) : super(key: key);

  @override
  State<PollutantDetailScreen> createState() => _PollutantDetailScreenState();
}

class _PollutantDetailScreenState extends State<PollutantDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();

    // Add animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();

    // Fetch the pollutant details when the screen is initialized with retry
    _fetchPollutantDetails();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Add a method to fetch pollutant details with retry
  void _fetchPollutantDetails({int retryCount = 0}) {
    Future.microtask(() {
      final provider =
          Provider.of<PollutantInfoProvider>(context, listen: false);

      // Print pollutant details for debugging
      print(
          'Fetching details for pollutant: ${widget.pollutant.name}, CID: ${widget.pollutant.cid}');

      provider.fetchPollutantDetails(widget.pollutant);

      // If data is not loaded after 2 seconds, try again (up to 3 retries)
      if (retryCount < 3) {
        Future.delayed(const Duration(seconds: 2), () {
          if (!provider.isDetailLoaded(widget.pollutant.cid) &&
              !provider.isSectionLoading(widget.pollutant.cid) &&
              provider.error == null &&
              mounted) {
            print('Retrying pollutant data fetch, attempt ${retryCount + 1}');
            _fetchPollutantDetails(retryCount: retryCount + 1);
          }
        });
      }
    });
  }

  // Method to refresh data, with loading state
  Future<void> _refreshData() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      final provider =
          Provider.of<PollutantInfoProvider>(context, listen: false);
      await provider.fetchPollutantDetails(widget.pollutant);
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.5),
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          // Add refresh button with loading indicator
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isRefreshing ? null : _refreshData,
            tooltip: 'Refresh data',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _animation,
        child: Consumer<PollutantInfoProvider>(
          builder: (context, provider, child) {
            // If overall loading is happening on first fetch, show full screen loading
            if (provider.isLoading &&
                !provider.isDetailLoaded(widget.pollutant.cid) &&
                !_isRefreshing) {
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
                      onPressed: _refreshData,
                      child: _isRefreshing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Determine if any section is loading
            final bool isSectionLoading =
                provider.isSectionLoading(widget.pollutant.cid);

            return AnimationLimiter(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 375),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: widget,
                      ),
                    ),
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
                        isLoading: isSectionLoading,
                        content: isSectionLoading &&
                                widget.pollutant.healthEffects == null
                            ? const Text('Loading health impact information...')
                            : Text(
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
                        isLoading: isSectionLoading,
                        content: isSectionLoading &&
                                widget.pollutant.safetyInfo == null
                            ? const Text('Loading safety advice...')
                            : Text(
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
                        isLoading: isSectionLoading,
                        content:
                            isSectionLoading && widget.pollutant.sources == null
                                ? const Text('Loading source information...')
                                : Text(
                                    widget.pollutant.sources ??
                                        'Source information not available.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                    ),
                                  ),
                      ),

                      const SizedBox(height: 16),

                      // Chemical Properties
                      _buildSection(
                        theme,
                        title: 'Chemical Properties',
                        icon: Icons.science,
                        color: Colors.purple.shade400,
                        isLoading: isSectionLoading,
                        content: isSectionLoading &&
                                widget.pollutant.chemicalProperties == null
                            ? const Text('Loading chemical properties...')
                            : _buildPropertiesTable(
                                theme,
                                widget.pollutant.chemicalProperties ?? {},
                              ),
                      ),

                      const SizedBox(height: 16),

                      // Description from static data
                      _buildSection(
                        theme,
                        title: 'Description',
                        icon: Icons.description,
                        color: Colors.blue.shade600,
                        isLoading: isSectionLoading,
                        content: isSectionLoading &&
                                widget.pollutant.detailedDescription == null
                            ? const Text('Loading description...')
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getDetailedDescription(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                    ),
                                  ),
                                  // Source info is now static, so we can use a generic source
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Source: Environmental and health agencies',
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

                      // Reference links instead of PubChem button
                      if (provider.isDetailLoaded(widget.pollutant.cid))
                        Center(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.info_outline),
                            label: const Text('More Information'),
                            onPressed: () {
                              _showInfoDialog(context);
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
                ),
              ),
            );
          },
        ),
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
    bool isLoading = false,
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
              if (isLoading) ...[
                const Spacer(),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          isLoading &&
                  content is Text &&
                  (content.data == 'Loading chemical properties...' ||
                      content.data == 'Loading description...' ||
                      content.data == 'Loading health impact information...' ||
                      content.data == 'Loading safety advice...' ||
                      content.data == 'Loading source information...')
              ? _buildLoadingPlaceholder(theme)
              : content,
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 16,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity * 0.8,
          height: 16,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity * 0.6,
          height: 16,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertiesTable(
      ThemeData theme, Map<String, dynamic> properties) {
    List<TableRow> rows = [];

    // Debug output to see what properties we have
    print('Building properties table with properties: $properties');

    if (properties.isEmpty) {
      print(
          'Properties map is empty, generating fallback properties for ${widget.pollutant.name}');
      // Fallback properties for common pollutants
      switch (widget.pollutant.name) {
        case 'PM2.5':
          properties = {
            'MolecularFormula': 'Various',
            'MolecularWeight': 'Varies',
            'Size': 'Particles with diameter of 2.5 micrometers or smaller',
            'Composition':
                'May include dust, pollen, soot, smoke, and liquid droplets',
            'Solubility': 'Varies by component',
            'Danger Level': 'High - can enter bloodstream'
          };
          break;
        case 'PM10':
          properties = {
            'MolecularFormula': 'Various',
            'MolecularWeight': 'Varies',
            'Size': 'Particles with diameter of 10 micrometers or smaller',
            'Composition':
                'Includes dust, pollen, mold, ash, and other particulates',
            'Solubility': 'Varies by component',
            'Danger Level': 'Moderate - can penetrate into lungs'
          };
          break;
        case 'O₃':
          properties = {
            'MolecularFormula': 'O₃',
            'MolecularWeight': '48.00 g/mol',
            'MeltingPoint': '-192.2 °C',
            'BoilingPoint': '-112 °C',
            'Color': 'Pale blue gas',
            'Odor': 'Distinctive sharp, fresh smell',
          };
          break;
        case 'NO₂':
          properties = {
            'MolecularFormula': 'NO₂',
            'MolecularWeight': '46.01 g/mol',
            'MeltingPoint': '-11.2 °C',
            'BoilingPoint': '21.2 °C',
            'Color': 'Reddish-brown gas',
            'Odor': 'Sharp, biting odor',
          };
          break;
        case 'SO₂':
          properties = {
            'MolecularFormula': 'SO₂',
            'MolecularWeight': '64.07 g/mol',
            'MeltingPoint': '-72 °C',
            'BoilingPoint': '-10 °C',
            'Color': 'Colorless gas',
            'Odor': 'Strong, suffocating odor',
          };
          break;
        case 'CO':
          properties = {
            'MolecularFormula': 'CO',
            'MolecularWeight': '28.01 g/mol',
            'MeltingPoint': '-205 °C',
            'BoilingPoint': '-191.5 °C',
            'Color': 'Colorless',
            'Odor': 'Odorless',
          };
          break;
      }
    }

    // Iterate through all properties and add them to the table
    properties.forEach((key, value) {
      // Skip the Description property as it's shown in another section
      if (key != 'Description') {
        rows.add(_buildPropertyRow(
            theme, key, value?.toString() ?? 'Not available'));
      }
    });

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

  String _getDetailedDescription() {
    if (widget.pollutant.detailedDescription == null ||
        widget.pollutant.detailedDescription!.isEmpty) {
      // Fallback detailed descriptions for common pollutants
      switch (widget.pollutant.name) {
        case 'PM2.5':
          return 'PM2.5 refers to fine particulate matter that is 2.5 micrometers or smaller in diameter. These tiny particles are a mixture of solid and liquid droplets suspended in air. Due to their small size, they can penetrate deep into the lungs and may even enter the bloodstream. They originate from various sources including vehicle emissions, industrial processes, and natural events like wildfires. PM2.5 is one of the most harmful air pollutants to human health, contributing to respiratory and cardiovascular diseases, especially in vulnerable populations.';
        case 'PM10':
          return 'PM10 refers to inhalable particles with diameters of 10 micrometers or smaller. These particles include dust, pollen, mold spores, and other material that can be suspended in the air. They are primarily generated from crushing or grinding operations and dust from roads and construction sites. Though larger than PM2.5, they can still enter the respiratory system, potentially causing health problems, particularly for individuals with pre-existing respiratory conditions.';
        case 'O₃':
          return 'Ozone (O₃) is a gas composed of three oxygen atoms. While stratospheric ozone protects Earth from harmful UV radiation, ground-level ozone is a harmful air pollutant. It is not emitted directly into the air but is created by chemical reactions between nitrogen oxides (NOx) and volatile organic compounds (VOCs) in the presence of sunlight. Ozone forms readily in urban areas during hot, sunny weather. It is the main component of smog and can trigger a variety of health problems, particularly for children, the elderly, and people with lung diseases such as asthma.';
        case 'NO₂':
          return 'Nitrogen dioxide (NO₂) is a highly reactive gas that forms when fossil fuels such as coal, oil, gas, or diesel are burned at high temperatures. It belongs to a family of reactive gases called nitrogen oxides (NOx). NO₂ primarily gets in the air from the burning of fuel in cars, trucks, buses, power plants, and off-road equipment. In addition to contributing to the formation of ground-level ozone and fine particle pollution, NO₂ is linked with a number of adverse effects on the respiratory system, especially in people with asthma.';
        case 'SO₂':
          return 'Sulfur dioxide (SO₂) is a colorless gas with a pungent odor. It is produced from burning fuels containing sulfur, such as coal and oil, particularly in power plants and industrial processes. Volcanic eruptions also release SO₂ into the atmosphere. When SO₂ combines with water in the atmosphere, it forms sulfuric acid, which is the main component of acid rain. SO₂ can affect the respiratory system, causing irritation to the eyes and respiratory tract, exacerbating conditions like asthma and bronchitis.';
        case 'CO':
          return 'Carbon monoxide (CO) is a colorless, odorless, and tasteless gas that is toxic to humans and animals when encountered in higher concentrations. It is produced when fuels such as gas, oil, coal, or wood do not burn fully. In outdoor environments, vehicle exhaust is the primary source of CO, especially when engines are running in enclosed spaces or during cold weather. CO is dangerous because it binds to hemoglobin in the blood, reducing its ability to carry oxygen, which can lead to tissue damage and even death in severe cases of exposure.';
        default:
          return 'No detailed description available for this pollutant.';
      }
    } else {
      return widget.pollutant.detailedDescription!;
    }
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
