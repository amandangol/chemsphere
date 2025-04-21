import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../providers/aqi_provider.dart';
import 'pollutant_detail_screen.dart';
import 'dart:math';

class AqiInfoScreen extends StatefulWidget {
  const AqiInfoScreen({Key? key}) : super(key: key);

  @override
  State<AqiInfoScreen> createState() => _AqiInfoScreenState();
}

class _AqiInfoScreenState extends State<AqiInfoScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize animation controller separately
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this, // This is the correct usage with TickerProviderStateMixin
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    // Important to dispose both controllers
    _tabController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      _refreshing = true;
    });

    try {
      final provider = Provider.of<AqiProvider>(context, listen: false);
      await provider.fetchAqiData();
    } finally {
      if (mounted) {
        setState(() {
          _refreshing = false;
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
          'Atmospheric Analysis',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: _refreshing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ))
                : const Icon(Icons.refresh_rounded, size: 18),
            onPressed: _refreshing ? null : _refreshData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded, size: 18),
            onPressed: () {
              Navigator.of(context).pushNamed('/city-search');
            },
            tooltip: 'Search Location',
          ),
          const SizedBox(width: 6),
        ],
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black26,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          indicatorColor: Colors.white,
          indicatorWeight: 2,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.air, size: 16),
              text: 'Air Quality',
              iconMargin: EdgeInsets.only(bottom: 2),
            ),
            Tab(
              icon: Icon(Icons.science_outlined, size: 16),
              text: 'Pollutants',
              iconMargin: EdgeInsets.only(bottom: 2),
            ),
          ],
        ),
      ),
      body: Consumer<AqiProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && !_refreshing) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(strokeWidth: 2),
                  const SizedBox(height: 16),
                  Text(
                    'Loading air quality data...',
                    style: GoogleFonts.poppins(
                      color: theme.colorScheme.primary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.error != null) {
            final bool isNetworkError = provider.error!.contains("Network") ||
                provider.error!.contains("internet") ||
                provider.error!.contains("connection");

            return FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: AnimationLimiter(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 500),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 30.0,
                        child: FadeInAnimation(
                          child: widget,
                        ),
                      ),
                      children: [
                        Icon(
                          isNetworkError ? Icons.wifi_off : Icons.error_outline,
                          color: isNetworkError ? Colors.orange : Colors.red,
                          size: 36,
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            isNetworkError
                                ? 'Network Connection Error'
                                : 'Error',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  isNetworkError ? Colors.orange : Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            isNetworkError
                                ? 'Unable to connect to the air quality service. Please check your internet connection and try again.'
                                : provider.error!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color:
                                  isNetworkError ? Colors.black87 : Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _refreshing ? null : _refreshData,
                          icon: _refreshing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ))
                              : const Icon(Icons.refresh, size: 16),
                          label: Text(
                            'Retry',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        if (isNetworkError)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/city-search');
                              },
                              icon: const Icon(Icons.search, size: 16),
                              label: Text(
                                'Try Searching for a City',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          if (provider.aqiData == null) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.air,
                      color: Colors.grey,
                      size: 36,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No AQI data available',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Try refreshing to fetch latest data',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: _refreshing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ))
                          : const Icon(Icons.refresh, size: 16),
                      label:
                          const Text('Refresh', style: TextStyle(fontSize: 12)),
                      onPressed: _refreshing ? null : _refreshData,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: TabBarView(
              controller: _tabController,
              children: [
                // AQI Overview Tab
                _buildAqiOverview(provider, theme),

                // Pollutants Tab
                _buildPollutantsTab(provider, theme),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAqiOverview(AqiProvider provider, ThemeData theme) {
    final aqiData = provider.aqiData!;
    final aqiValue = aqiData.aqi;
    final aqiCategory =
        aqiValue > 0 ? provider.getAqiCategory(aqiValue) : "No Data";
    final aqiColor =
        aqiValue > 0 ? provider.getAqiColor(aqiValue) : Colors.grey;

    String formattedDate = '';
    try {
      formattedDate = DateFormat('EEEE, MMMM d, y').format(aqiData.lastUpdated);
    } catch (e) {
      // Use empty string if formatting fails
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AQI Gauge
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  aqiColor,
                  Color.lerp(aqiColor, Colors.black, 0.3) ?? aqiColor,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: aqiColor.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Add molecular background pattern
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CustomPaint(
                    size: const Size(double.infinity, 200),
                    painter: MolecularBackgroundPainter(
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Air Quality Index',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),

                          // Mock data badge if applicable
                          if (provider.error != null &&
                              provider.error!.contains('timed out'))
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.white24, width: 1),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Estimated Data',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // AQI Value with glowing effect
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 16,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: aqiValue > 0
                            ? Text(
                                aqiValue.toString(),
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.white.withOpacity(0.5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              )
                            : const Icon(
                                Icons.question_mark,
                                size: 36,
                                color: Colors.white,
                              ),
                      ),

                      const SizedBox(height: 12),

                      // Category with custom pill background
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          aqiCategory,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Description in a stylized container
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white10,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          aqiValue > 0
                              ? provider.getAqiDescription(aqiValue)
                              : "Air quality data is not available for this location at the moment.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Location
          if (aqiData.name.isNotEmpty)
            _buildInfoCard(
              theme,
              title: 'Location',
              icon: Icons.location_on,
              color: Colors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${aqiData.name}, ${aqiData.country.name}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (formattedDate.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_searching,
                        size: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Coordinates: ${aqiData.coordinates.latitude.toStringAsFixed(4)}, ${aqiData.coordinates.longitude.toStringAsFixed(4)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Dominant Pollutant
          if (aqiData.dominantPollutant.isNotEmpty)
            _buildInfoCard(
              theme,
              title: 'Dominant Pollutant',
              icon: Icons.warning,
              color: Colors.orange,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      aqiData.dominantPollutant.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getPollutantDescription(aqiData.dominantPollutant),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // No Measurements Available Message
          if (aqiData.measurements.isEmpty)
            _buildInfoCard(
              theme,
              title: 'No Measurements Available',
              icon: Icons.info_outline,
              color: Colors.amber,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This location is registered in the OpenAQ database, but it doesn\'t have any current measurements available.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try another location or check back later.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Only show recommendations if AQI is available
          if (aqiValue > 0) ...[
            const SizedBox(height: 16),

            // Main Recommendations
            _buildInfoCard(
              theme,
              title: 'Health Recommendations',
              icon: Icons.health_and_safety,
              color: Colors.green,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._getHealthRecommendations(aqiValue)
                      .map(
                        (recommendation) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                margin: const EdgeInsets.only(top: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.green.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  recommendation,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Air Purifier Recommendation with modern design
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.air_outlined,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Equipment Recommendation',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Card content with padding
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (aqiValue <= 50)
                          _buildRecommendationChip(
                            'No air purifier needed',
                            Colors.green,
                            theme,
                          )
                        else if (aqiValue <= 100)
                          _buildRecommendationChip(
                            'Standard air purifier recommended',
                            Colors.yellow.shade700,
                            theme,
                          )
                        else if (aqiValue <= 150)
                          _buildRecommendationChip(
                            'HEPA air purifier recommended',
                            Colors.orange,
                            theme,
                          )
                        else
                          _buildRecommendationChip(
                            'High-efficiency HEPA air purifier required',
                            Colors.red,
                            theme,
                          ),
                        const SizedBox(height: 12),
                        Text(
                          _getAirPurifierRecommendationDetails(aqiValue),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            height: 1.4,
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Data Source
          _buildInfoCard(
            theme,
            title: 'Data Source',
            icon: Icons.info,
            color: Colors.purple,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data source: Open-Meteo\nLast updated: ${_formatDateTime(aqiData.lastUpdated)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This data is sourced from Open-Meteo\'s Air Quality API, which provides worldwide air quality data based on the Copernicus Atmosphere Monitoring Service (CAMS) global model. Values shown are calculated using the US EPA Air Quality Index standard.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildPollutantsTab(AqiProvider provider, ThemeData theme) {
    final pollutants = provider.pollutants;

    if (pollutants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.science_outlined,
              color: theme.colorScheme.primary.withOpacity(0.5),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No pollutant data available',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try searching for a different location',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: pollutants.length,
      itemBuilder: (context, index) {
        final pollutantKey = pollutants.keys.elementAt(index);
        final pollutant = pollutants[pollutantKey]!;
        final pollutantColor =
            _getPollutantColor(pollutant.name, pollutant.value);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: pollutantColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PollutantDetailScreen(
                    pollutant: pollutant,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side - Chemical formula
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: pollutantColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: pollutantColor.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          pollutant.name,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: pollutantColor,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Right side - Pollutant information
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pollutant.fullName,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: pollutantColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.analytics_outlined,
                                        size: 12,
                                        color: pollutantColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        pollutant.formattedValue,
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: pollutantColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.chevron_right,
                                  color: theme.colorScheme.primary,
                                  size: 16,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 6),

                  // Health impact with icon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.health_and_safety_outlined,
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          pollutant.getHealthImpact(),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  color.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Card content with padding
          Padding(
            padding: const EdgeInsets.all(12),
            child: child,
          ),
        ],
      ),
    );
  }

  String _getAqiDescription(int aqi) {
    if (aqi <= 50) {
      return 'Air quality is considered satisfactory, and air pollution poses little or no risk.';
    } else if (aqi <= 100) {
      return 'Air quality is acceptable; however, some pollutants may be a concern for a small number of sensitive individuals.';
    } else if (aqi <= 150) {
      return 'Members of sensitive groups may experience health effects, but the general public is not likely to be affected.';
    } else if (aqi <= 200) {
      return 'Everyone may begin to experience health effects; members of sensitive groups may experience more serious health effects.';
    } else if (aqi <= 300) {
      return 'Health warnings of emergency conditions. The entire population is more likely to be affected.';
    } else {
      return 'Health alert: everyone may experience more serious health effects.';
    }
  }

  List<String> _getHealthRecommendations(int aqi) {
    if (aqi <= 50) {
      return [
        'Enjoy outdoor activities',
        'Open windows to bring clean, fresh air indoors',
        'Perfect for extended outdoor exercise',
      ];
    } else if (aqi <= 100) {
      return [
        'Unusually sensitive people should consider reducing prolonged or heavy exertion',
        "It's a good day to watch for changes in air quality",
        'Most people can enjoy outdoor activities',
      ];
    } else if (aqi <= 150) {
      return [
        'People with heart or lung disease, older adults, and children should reduce prolonged or heavy exertion',
        'Take more breaks during outdoor activities',
        'Consider moving longer or high-intensity activities indoors',
      ];
    } else if (aqi <= 200) {
      return [
        'Everyone should reduce prolonged or heavy exertion',
        'Consider moving all activities indoors or rescheduling for a better air quality day',
        'People with asthma should follow their asthma action plans',
        'Keep quick-relief medicine handy',
      ];
    } else if (aqi <= 300) {
      return [
        'Avoid all physical activity outdoors',
        'Move activities indoors or reschedule for a better air quality day',
        'People with asthma should keep quick-relief medicine handy',
        'Consider using air purifiers indoors',
        'Wear masks (N95) when outdoors if unavoidable',
      ];
    } else {
      return [
        'Avoid all physical activity outdoors',
        'Remain indoors and keep activity levels low',
        'Use air purifiers if available',
        'Wear masks (N95) if you need to go outdoors',
        'Close all windows and doors to prevent outdoor air from coming in',
        'Consider leaving the area until air quality improves',
      ];
    }
  }

  String _getPollutantDescription(String pollutantCode) {
    switch (pollutantCode.toLowerCase()) {
      case 'pm25':
        return 'Fine particulate matter - tiny particles in the air that can penetrate deep into lungs.';
      case 'pm10':
        return 'Coarse particulate matter - inhalable particles that can cause respiratory issues.';
      case 'o3':
        return 'Ozone - a harmful gas formed when pollutants react in sunlight.';
      case 'no2':
        return 'Nitrogen Dioxide - a harmful gas from vehicle exhaust and power plants.';
      case 'so2':
        return 'Sulfur Dioxide - a gas from burning fossil fuels that can harm the respiratory system.';
      case 'co':
        return 'Carbon Monoxide - a harmful gas from vehicle exhaust and incomplete combustion.';
      default:
        return 'Primary air pollutant that affects air quality.';
    }
  }

  Color _getPollutantColor(String pollutantName, double value) {
    // This is a simplified color selection based on pollutant type
    // In a real app, you'd base this on the actual concentration levels
    switch (pollutantName) {
      case 'PM2.5':
        if (value <= 12) return Colors.green;
        if (value <= 35.4) return Colors.yellow;
        if (value <= 55.4) return Colors.orange;
        if (value <= 150.4) return Colors.red;
        if (value <= 250.4) return Colors.purple;
        return Colors.brown;
      case 'PM10':
        if (value <= 54) return Colors.green;
        if (value <= 154) return Colors.yellow;
        if (value <= 254) return Colors.orange;
        if (value <= 354) return Colors.red;
        if (value <= 424) return Colors.purple;
        return Colors.brown;
      case 'O₃':
        if (value <= 54) return Colors.green;
        if (value <= 70) return Colors.yellow;
        if (value <= 85) return Colors.orange;
        if (value <= 105) return Colors.red;
        return Colors.purple;
      case 'NO₂':
        if (value <= 53) return Colors.green;
        if (value <= 100) return Colors.yellow;
        if (value <= 360) return Colors.orange;
        if (value <= 649) return Colors.red;
        return Colors.purple;
      case 'SO₂':
        if (value <= 35) return Colors.green;
        if (value <= 75) return Colors.yellow;
        if (value <= 185) return Colors.orange;
        if (value <= 304) return Colors.red;
        return Colors.purple;
      case 'CO':
        if (value <= 4.4) return Colors.green;
        if (value <= 9.4) return Colors.yellow;
        if (value <= 12.4) return Colors.orange;
        if (value <= 15.4) return Colors.red;
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  String _getAirPurifierRecommendation(int aqi) {
    if (aqi <= 50) {
      return 'No recommendation';
    } else if (aqi <= 100) {
      return 'Consider using an air purifier';
    } else if (aqi <= 150) {
      return 'Consider using an air purifier';
    } else if (aqi <= 200) {
      return 'Consider using an air purifier';
    } else if (aqi <= 300) {
      return 'Consider using an air purifier';
    } else {
      return 'Consider using an air purifier';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy h:mm a').format(dateTime);
  }

  Widget _buildRecommendationChip(String text, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_right_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getAirPurifierRecommendationDetails(int aqi) {
    if (aqi <= 50) {
      return 'With good air quality, natural ventilation is sufficient. Open windows regularly to maintain fresh air circulation.';
    } else if (aqi <= 100) {
      return 'Consider a standard air purifier with a HEPA filter that can remove at least 99% of airborne particles as a precautionary measure, especially if you have allergies.';
    } else if (aqi <= 150) {
      return 'A HEPA air purifier is recommended for removing fine particles. Look for models with activated carbon filters that can also remove gases and odors. Keep windows closed when air quality is poor.';
    } else if (aqi <= 200) {
      return 'Use a high-efficiency HEPA air purifier in main living areas. Consider multiple units for larger spaces. Look for models with real-time air quality monitoring and automatic mode.';
    } else {
      return 'High-efficiency air purifiers with medical-grade filtration are strongly recommended. Use in multiple rooms, especially bedrooms. Seal windows and doors properly, and consider wearing N95 masks when outdoors.';
    }
  }
}

// Custom painter for molecular pattern background
class MolecularBackgroundPainter extends CustomPainter {
  final Color color;

  MolecularBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final random = Random(42); // Fixed seed for consistent pattern

    // Draw hexagons and bonds
    for (int i = 0; i < 3; i++) {
      final centerX = size.width * (0.3 + 0.4 * random.nextDouble());
      final centerY = size.height * (0.2 + 0.6 * random.nextDouble());
      final radius = size.width * (0.05 + 0.08 * random.nextDouble());

      // Draw a hexagon
      _drawHexagon(canvas, centerX, centerY, radius, paint);

      // Draw some random bonds
      for (int j = 0; j < 2; j++) {
        final angle1 = random.nextDouble() * 2 * pi;
        final angle2 = angle1 + (pi / 2 + random.nextDouble() * pi / 2);

        final x1 = centerX + radius * 1.5 * cos(angle1);
        final y1 = centerY + radius * 1.5 * sin(angle1);

        final x2 = x1 + radius * 2 * cos(angle2);
        final y2 = y1 + radius * 2 * sin(angle2);

        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
        canvas.drawCircle(Offset(x2, y2), 3, circlePaint);
      }
    }
  }

  void _drawHexagon(Canvas canvas, double centerX, double centerY,
      double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * (pi / 180);
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(MolecularBackgroundPainter oldDelegate) => false;
}
