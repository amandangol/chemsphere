import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/aqi_provider.dart';
import '../../models/aqi_data.dart';
import '../../models/pollutant.dart';
import 'pollutant_detail_screen.dart';

class AqiInfoScreen extends StatefulWidget {
  const AqiInfoScreen({Key? key}) : super(key: key);

  @override
  State<AqiInfoScreen> createState() => _AqiInfoScreenState();
}

class _AqiInfoScreenState extends State<AqiInfoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Air Quality',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/main');
          },
        ),
        backgroundColor: theme.colorScheme.primary.withOpacity(0.5),
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: theme.colorScheme.primary,
          tabs: [
            Tab(
              icon: const Icon(Icons.air),
              text: 'AQI Overview',
              iconMargin: const EdgeInsets.only(bottom: 4),
            ),
            Tab(
              icon: const Icon(Icons.science),
              text: 'Pollutants',
              iconMargin: const EdgeInsets.only(bottom: 4),
            ),
          ],
        ),
      ),
      body: Consumer<AqiProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            final bool isNetworkError = provider.error!.contains("Network") ||
                provider.error!.contains("internet") ||
                provider.error!.contains("connection");

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isNetworkError ? Icons.wifi_off : Icons.error_outline,
                    color: isNetworkError ? Colors.orange : Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      isNetworkError ? 'Network Connection Error' : 'Error',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isNetworkError ? Colors.orange : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      isNetworkError
                          ? 'Unable to connect to the air quality service. Please check your internet connection and try again.'
                          : provider.error!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: isNetworkError ? Colors.black87 : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      provider.fetchAqiData();
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      'Retry',
                      style: GoogleFonts.poppins(),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (isNetworkError)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/city-search');
                        },
                        icon: const Icon(Icons.search),
                        label: Text(
                          'Try Searching for a City',
                          style: GoogleFonts.poppins(),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          if (provider.aqiData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.air,
                    color: Colors.grey,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No AQI data available',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try refreshing to fetch latest data',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    onPressed: () {
                      provider.fetchAqiData();
                    },
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // AQI Overview Tab
              _buildAqiOverview(provider, theme),

              // Pollutants Tab
              _buildPollutantsTab(provider, theme),
            ],
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
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AQI Gauge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  aqiColor.withOpacity(0.8),
                  aqiColor.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: aqiColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Air Quality Index',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (provider.error != null &&
                    provider.error!.contains('timed out'))
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Mock Data',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: aqiValue > 0
                          ? Text(
                              aqiValue.toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              Icons.question_mark,
                              size: 36,
                              color: Colors.white,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  aqiCategory,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  aqiValue > 0
                      ? provider.getAqiDescription(aqiValue)
                      : "Air quality data is not available for this location at the moment.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

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
              title: 'Recommendations',
              icon: Icons.health_and_safety,
              color: Colors.green,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._getHealthRecommendations(aqiValue)
                      .map(
                        (recommendation) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• ',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  recommendation,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
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

            // Air Purifier Recommendation
            _buildRecommendationTile(
              context,
              icon: Icons.air,
              title: 'Air Purifier',
              recommendation: _getAirPurifierRecommendation(aqiValue),
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
            const Icon(
              Icons.science,
              color: Colors.grey,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'No pollutant data available',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pollutants.length,
      itemBuilder: (context, index) {
        final pollutantKey = pollutants.keys.elementAt(index);
        final pollutant = pollutants[pollutantKey]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getPollutantColor(
                                      pollutant.name, pollutant.value)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              pollutant.name,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _getPollutantColor(
                                    pollutant.name, pollutant.value),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pollutant.fullName,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Value: ${pollutant.formattedValue}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    pollutant.getHealthImpact(),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: const Text('More Details'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PollutantDetailScreen(
                                pollutant: pollutant,
                              ),
                            ),
                          );
                        },
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
          child,
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

  Widget _buildRecommendationTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String recommendation,
  }) {
    return _buildInfoCard(
      Theme.of(context),
      title: title,
      icon: icon,
      color: Colors.green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.green,
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
          Text(
            recommendation,
            style: GoogleFonts.poppins(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
