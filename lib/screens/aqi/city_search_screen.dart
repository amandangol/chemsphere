import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/aqi_provider.dart';
import 'aqi_info_screen.dart';

class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({Key? key}) : super(key: key);

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];
  bool _isSearching = false;
  final _debounce = Debounce(milliseconds: 500);

  @override
  void dispose() {
    _searchController.dispose();
    _debounce.dispose();
    super.dispose();
  }

  Future<void> _searchCities(String query) async {
    if (query.length < 3) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final provider = Provider.of<AqiProvider>(context, listen: false);
    final results = await provider.searchCities(query);

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _selectCity(String cityName) async {
    setState(() {
      _isSearching = true;
    });

    try {
      print("Selecting city: $cityName");
      final provider = Provider.of<AqiProvider>(context, listen: false);
      await provider.fetchAqiData(cityName: cityName);

      if (!mounted) return;
      print("City selection complete, navigating to main screen");

      // No matter if we used real or mock data, go back to the main screen
      Navigator.of(context).pushReplacementNamed('/main', arguments: 2);
    } catch (e) {
      print("Error selecting city: $e");
      if (!mounted) return;

      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('timed out')
                ? 'Connection timed out - showing available data instead'
                : e.toString().replaceAll('Exception: ', ''),
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: e.toString().contains('timed out')
              ? Colors.orange
              : Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );

      // If we had a timeout, we might still have mock data to show
      final provider = Provider.of<AqiProvider>(context, listen: false);
      if (e.toString().contains('timed out') && provider.aqiData != null) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/main', arguments: 2);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
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
          'Search City',
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
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a city...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              onChanged: (value) {
                _debounce.run(() {
                  _searchCities(value);
                });
              },
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                _searchCities(value);
              },
            ),
          ),
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Show current AQI data if available
                            Consumer<AqiProvider>(
                              builder: (context, provider, child) {
                                if (provider.aqiData != null) {
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    margin: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: provider.aqiData!.aqi > 0
                                          ? provider
                                              .getAqiColor(
                                                  provider.aqiData!.aqi)
                                              .withOpacity(0.2)
                                          : Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: provider.aqiData!.aqi > 0
                                            ? provider
                                                .getAqiColor(
                                                    provider.aqiData!.aqi)
                                                .withOpacity(0.5)
                                            : Colors.grey.withOpacity(0.5),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Current AQI for ${provider.aqiData!.name}',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: provider.aqiData!.aqi > 0
                                                    ? provider.getAqiColor(
                                                        provider.aqiData!.aqi)
                                                    : Colors.grey,
                                                shape: BoxShape.circle,
                                              ),
                                              child: provider.aqiData!.aqi > 0
                                                  ? Text(
                                                      provider.aqiData!.aqi
                                                          .toString(),
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 22,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : const Icon(
                                                      Icons.question_mark,
                                                      color: Colors.white,
                                                      size: 22,
                                                    ),
                                            ),
                                            const SizedBox(width: 16),
                                            Text(
                                              provider.aqiData!.aqi > 0
                                                  ? provider.getAqiCategory(
                                                      provider.aqiData!.aqi)
                                                  : 'Data Unavailable',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        if (provider
                                            .aqiData!.measurements.isNotEmpty)
                                          Text(
                                            'PM2.5: ${provider.aqiData!.measurements['pm25']?.value.toStringAsFixed(1) ?? 'N/A'} μg/m³',
                                            style: GoogleFonts.poppins(),
                                          ),
                                      ],
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            Icon(
                              Icons.location_city,
                              size: 64,
                              color: theme.colorScheme.primary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Search for a city to get air quality data'
                                  : _searchController.text.length < 3
                                      ? 'Enter at least 3 characters'
                                      : 'No cities found',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Powered by Open-Meteo',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final city = _searchResults[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              leading: const Icon(Icons.location_on),
                              title: Text(
                                city,
                                style: GoogleFonts.poppins(),
                              ),
                              onTap: () {
                                _selectCity(city);
                              },
                            ),
                          );
                        },
                      ),
          ),
          // Use GPS location button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.my_location),
                label: Text(
                  'Use My Location',
                  style: GoogleFonts.poppins(),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    _isSearching = true;
                  });

                  try {
                    final provider =
                        Provider.of<AqiProvider>(context, listen: false);
                    await provider.fetchAqiData();

                    if (!mounted) return;

                    // No matter if we used real or mock data, go back to the main screen
                    Navigator.of(context)
                        .pushReplacementNamed('/main', arguments: 2);
                  } catch (e) {
                    if (!mounted) return;

                    // Show error to user
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString().contains('timed out')
                              ? 'Connection timed out - showing available data instead'
                              : e.toString().replaceAll('Exception: ', ''),
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: e.toString().contains('timed out')
                            ? Colors.orange
                            : Colors.red.shade700,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 4),
                        action: SnackBarAction(
                          label: 'OK',
                          textColor: Colors.white,
                          onPressed: () {},
                        ),
                      ),
                    );

                    // If we had a timeout, we might still have mock data to show
                    final provider =
                        Provider.of<AqiProvider>(context, listen: false);
                    if (e.toString().contains('timed out') &&
                        provider.aqiData != null) {
                      if (!mounted) return;
                      Navigator.of(context)
                          .pushReplacementNamed('/main', arguments: 2);
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isSearching = false;
                      });
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Debounce class to delay searches while typing
class Debounce {
  final int milliseconds;
  Timer? _timer;

  Debounce({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
