import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'provider/aqi_provider.dart';
import '../../models/aqi_data.dart';
import 'aqi_info_screen.dart';

class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({Key? key}) : super(key: key);

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchResults = false;
  final _debounce = Debounce(milliseconds: 500);

  // Map controller
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  bool _mapInitialized = false;

  // Toggle for showing major cities
  bool _showMajorCities = false;

  @override
  void initState() {
    super.initState();

    // Initialize the map with user's current location or any existing AQI data
    Future.microtask(() {
      _initializeMap();
    });

    // Handle focus changes for the search field
    _searchFocusNode.addListener(() {
      setState(() {
        _showSearchResults = _searchFocusNode.hasFocus &&
            _searchController.text.isNotEmpty &&
            _searchResults.isNotEmpty;
      });
    });

    // Check if we already have AQI data and initialize marker
    Future.microtask(() {
      final provider = Provider.of<AqiProvider>(context, listen: false);
      if (provider.aqiData != null) {
        _addAqiMarker(provider);
      }

      // Fetch AQI data for major cities in the background
      provider.fetchMajorCitiesAqi();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce.dispose();
    super.dispose();
  }

  void _initializeMap() async {
    // If we have AQI data, center the map there
    final provider = Provider.of<AqiProvider>(context, listen: false);
    if (provider.aqiData != null) {
      final lat = provider.aqiData!.coordinates.latitude;
      final lng = provider.aqiData!.coordinates.longitude;
      _mapController.move(LatLng(lat, lng), 10);
      _addAqiMarker(provider);
    } else {
      // Otherwise try to get current location
      await _moveToCurrentLocation();
    }

    setState(() {
      _mapInitialized = true;
    });
  }

  // Add all major cities markers to the map
  void _updateMajorCitiesMarkers(AqiProvider provider) {
    if (!_showMajorCities) {
      // If not showing major cities, only keep current location marker
      _markers = _markers
          .where((marker) =>
              marker.point.latitude == provider.aqiData?.coordinates.latitude &&
              marker.point.longitude == provider.aqiData?.coordinates.longitude)
          .toList();
      return;
    }

    // Get all major cities with AQI data
    List<Marker> cityMarkers = [];

    // Add marker for current location if available
    if (provider.aqiData != null) {
      final lat = provider.aqiData!.coordinates.latitude;
      final lng = provider.aqiData!.coordinates.longitude;

      cityMarkers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(lat, lng),
          child: _buildMarkerWidget(provider, provider.aqiData!),
        ),
      );
    }

    // Add markers for all major cities
    provider.citiesAqiData.forEach((cityName, aqiData) {
      // Skip if coordinates are too close to current location
      if (provider.aqiData != null) {
        final currentLat = provider.aqiData!.coordinates.latitude;
        final currentLng = provider.aqiData!.coordinates.longitude;
        final cityLat = aqiData.coordinates.latitude;
        final cityLng = aqiData.coordinates.longitude;

        // Calculate rough distance
        final distance =
            sqrt(pow(cityLat - currentLat, 2) + pow(cityLng - currentLng, 2));
        if (distance < 0.5) {
          // Approximate 50km at equator
          return; // Skip this city as it's too close to current location
        }
      }

      cityMarkers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(
              aqiData.coordinates.latitude, aqiData.coordinates.longitude),
          child: _buildMarkerWidget(provider, aqiData),
        ),
      );
    });

    setState(() {
      _markers = cityMarkers;
    });
  }

  Future<bool> _moveToCurrentLocation() async {
    setState(() {
      _isSearching = true;
    });

    try {
      // Get device location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Move map to the current location
      _mapController.move(LatLng(position.latitude, position.longitude), 12);

      // Clear any previous search results and search text
      _searchController.clear();
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });

      // Always fetch fresh AQI data for the current location
      final provider = Provider.of<AqiProvider>(context, listen: false);
      await provider.fetchAqiData();

      if (provider.aqiData != null) {
        _updateMajorCitiesMarkers(provider);
      }

      setState(() {
        _isSearching = false;
      });
      return true;
    } catch (e) {
      print("Error getting current location: $e");

      // Default to a generic location if we can't get the user's
      _mapController.move(const LatLng(40.7128, -74.0060), 4); // Default to NYC
      setState(() {
        _isSearching = false;
      });

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to access your location. Please check location permissions.',
              style: GoogleFonts.poppins(),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _showSearchResults = false;
    });

    // Clear AQI data when search is cleared
    final provider = Provider.of<AqiProvider>(context, listen: false);
    // We don't actually clear the data here, just prompt the user to use current location again
    if (provider.aqiData != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Search cleared. Use location button to get current air quality.',
            style: GoogleFonts.poppins(),
          ),
          action: SnackBarAction(
            label: 'Use Location',
            onPressed: _moveToCurrentLocation,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _addAqiMarker(AqiProvider provider) {
    if (provider.aqiData == null) return;

    _updateMajorCitiesMarkers(provider);
  }

  Widget _buildMarkerWidget(AqiProvider provider, AqiData aqiData) {
    final aqiValue = aqiData.aqi;
    final aqiColor =
        aqiValue > 0 ? provider.getAqiColor(aqiValue) : Colors.grey;

    // Determine if this is the main location or a major city
    final bool isMainLocation = provider.aqiData != null &&
        aqiData.coordinates.latitude ==
            provider.aqiData!.coordinates.latitude &&
        aqiData.coordinates.longitude ==
            provider.aqiData!.coordinates.longitude;

    return GestureDetector(
      onTap: () {
        _showAqiInfoBottomSheet(provider, aqiData, isMainLocation);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add city name above marker for major cities
          if (!isMainLocation && _showMajorCities)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                aqiData.name,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: aqiColor.withOpacity(0.6),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(
                color: aqiColor,
                width: isMainLocation ? 3 : 2,
              ),
            ),
            child: Text(
              aqiValue.toString(),
              style: GoogleFonts.jetBrainsMono(
                fontSize: isMainLocation ? 16 : 14,
                fontWeight: FontWeight.bold,
                color: aqiColor,
              ),
            ),
          ),
          // Simple triangle indicator
          const Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
            size: 24,
          ),
        ],
      ),
    );
  }

  void _showAqiInfoBottomSheet(
      AqiProvider provider, AqiData aqiData, bool isMainLocation) {
    final aqiValue = aqiData.aqi;
    final aqiColor =
        aqiValue > 0 ? provider.getAqiColor(aqiValue) : Colors.grey;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        aqiData.name,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        aqiData.country.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: aqiColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: aqiColor,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    aqiValue.toString(),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: aqiColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: aqiColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: aqiColor.withOpacity(0.3),
                ),
              ),
              child: Text(
                provider.getAqiCategory(aqiValue),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: aqiColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              provider.getAqiDescription(aqiValue),
              style: GoogleFonts.poppins(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            if (aqiData.dominantPollutant.isNotEmpty)
              RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Dominant pollutant: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: aqiData.dominantPollutant.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: aqiColor,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            if (isMainLocation)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: aqiColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AqiInfoScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'View Full Details',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            if (!isMainLocation)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: aqiColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // Set the selected city and fetch detailed data
                    _selectCity(aqiData.name);
                  },
                  child: Text(
                    'Show Detailed Data',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchCities(String query) async {
    if (query.length < 3) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _showSearchResults = false;
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
      _showSearchResults = _searchFocusNode.hasFocus && results.isNotEmpty;
    });
  }

  void _selectCity(String cityName) async {
    // Clear search and hide results
    setState(() {
      _isSearching = true;
      _showSearchResults = false;
      _searchFocusNode.unfocus();
    });

    try {
      print("Selecting city: $cityName");
      final provider = Provider.of<AqiProvider>(context, listen: false);
      await provider.fetchAqiData(cityName: cityName);

      if (!mounted) return;
      print("City selection complete, updating map");

      // Update map marker and center map on the selected location
      if (provider.aqiData != null) {
        final lat = provider.aqiData!.coordinates.latitude;
        final lng = provider.aqiData!.coordinates.longitude;
        _mapController.move(LatLng(lat, lng), 10);
        _addAqiMarker(provider);

        // Show the AQI info bottom sheet
        _showAqiInfoBottomSheet(provider, provider.aqiData!, true);
      }
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
        _addAqiMarker(provider);
        _showAqiInfoBottomSheet(provider, provider.aqiData!, true);
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
          'Air Quality Map',
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
        backgroundColor: theme.colorScheme.primary.withOpacity(0.7),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Map as background
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(0, 0),
              initialZoom: 2,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.chem_explore',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: _markers),
            ],
          ),

          // Search UI overlay
          SafeArea(
            child: Column(
              children: [
                // Search bar
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search for a city...',
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      _debounce.run(() {
                        _searchCities(value);
                      });
                    },
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      if (value.isNotEmpty && _searchResults.isNotEmpty) {
                        _selectCity(_searchResults.first);
                      } else {
                        _searchCities(value);
                      }
                    },
                  ),
                ),

                // Search results
                if (_showSearchResults)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final city = _searchResults[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text(
                              city,
                              style: GoogleFonts.poppins(),
                            ),
                            onTap: () {
                              _selectCity(city);
                            },
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Show AQI indicator if available
          Consumer<AqiProvider>(
            builder: (context, provider, child) {
              if (provider.aqiData != null && !_showSearchResults) {
                final aqiData = provider.aqiData!;
                final aqiValue = aqiData.aqi;
                final aqiColor =
                    aqiValue > 0 ? provider.getAqiColor(aqiValue) : Colors.grey;

                return Positioned(
                  left: 16,
                  right: 16,
                  bottom: 90,
                  child: GestureDetector(
                    onTap: () {
                      _showAqiInfoBottomSheet(provider, aqiData, true);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: aqiColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: aqiColor,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              aqiValue.toString(),
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: aqiColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  aqiData.name,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  provider.getAqiCategory(aqiValue),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: aqiColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_up,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Button to toggle showing major cities
          Positioned(
            bottom: 16,
            left: 16,
            child: Consumer<AqiProvider>(
              builder: (context, provider, child) {
                return FloatingActionButton.extended(
                  heroTag: "global_cities_fab",
                  backgroundColor: _showMajorCities
                      ? theme.colorScheme.primary
                      : Colors.white,
                  onPressed: () {
                    setState(() {
                      _showMajorCities = !_showMajorCities;

                      // If turning on, make sure we fetch data
                      if (_showMajorCities && provider.citiesAqiData.isEmpty) {
                        provider.fetchMajorCitiesAqi();
                      }

                      // Update markers
                      _updateMajorCitiesMarkers(provider);

                      // Zoom out a bit when showing global cities
                      if (_showMajorCities) {
                        _mapController.move(_mapController.camera.center, 2);
                      }
                    });
                  },
                  icon: Icon(
                    _showMajorCities ? Icons.public : Icons.public_outlined,
                    color: _showMajorCities
                        ? Colors.white
                        : theme.colorScheme.primary,
                  ),
                  label: Text(
                    _showMajorCities ? "Hide Global AQI" : "Show Global AQI",
                    style: GoogleFonts.poppins(
                      color: _showMajorCities
                          ? Colors.white
                          : theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),

          // Current location button
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: "location_fab",
              backgroundColor: Colors.white,
              onPressed: _moveToCurrentLocation,
              child: Icon(
                Icons.my_location,
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          // Loading indicator
          if (_isSearching)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),

          // Show instruction if map is initialized but no AQI data
          if (_mapInitialized &&
              Provider.of<AqiProvider>(context).aqiData == null &&
              !_showSearchResults &&
              !_isSearching)
            Positioned(
              left: 16,
              right: 16,
              bottom: 90,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Search for a city or use your current location to view air quality data',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _moveToCurrentLocation,
                      icon: const Icon(Icons.my_location),
                      label: Text(
                        'Use My Location',
                        style: GoogleFonts.poppins(),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
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
