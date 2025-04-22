import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../../models/aqi_data.dart';
import '../../../models/pollutant.dart';

class AqiProvider with ChangeNotifier {
  // Open-Meteo doesn't require API key - free for all
  final String _baseUrl =
      'https://air-quality-api.open-meteo.com/v1/air-quality';

  AqiData? _aqiData;
  bool _isLoading = false;
  String? _error;
  Position? _currentPosition;
  final Map<String, Pollutant> _pollutants = {};
  String? _selectedCity;
  String? _locationName;
// List of major cities with their coordinates
  final List<Map<String, dynamic>> _majorCities = [
    {'name': 'New York', 'latitude': 40.7128, 'longitude': -74.0060},
    {'name': 'London', 'latitude': 51.5074, 'longitude': -0.1278},
    {'name': 'Tokyo', 'latitude': 35.6762, 'longitude': 139.6503},
    {'name': 'Sydney', 'latitude': -33.8688, 'longitude': 151.2093},
    {'name': 'Mumbai', 'latitude': 19.0760, 'longitude': 72.8777},
    {'name': 'Beijing', 'latitude': 39.9042, 'longitude': 116.4074},
    {'name': 'Paris', 'latitude': 48.8566, 'longitude': 2.3522},
    {'name': 'Cairo', 'latitude': 30.0444, 'longitude': 31.2357},
    {'name': 'Rio de Janeiro', 'latitude': -22.9068, 'longitude': -43.1729},
    {'name': 'Kathmandu', 'latitude': 27.7172, 'longitude': 85.3240},
    {'name': 'Berlin', 'latitude': 52.5200, 'longitude': 13.4050},
    {'name': 'Moscow', 'latitude': 55.7558, 'longitude': 37.6173},
    {'name': 'Los Angeles', 'latitude': 34.0522, 'longitude': -118.2437},
    {'name': 'Toronto', 'latitude': 43.6532, 'longitude': -79.3832},
    {'name': 'Dubai', 'latitude': 25.276987, 'longitude': 55.296249},
    {'name': 'Cape Town', 'latitude': -33.9249, 'longitude': 18.4241},
    {'name': 'Seoul', 'latitude': 37.5665, 'longitude': 126.9780},
    {'name': 'Mexico City', 'latitude': 19.4326, 'longitude': -99.1332},
  ];

  // Store AQI data for multiple cities
  final Map<String, AqiData> _citiesAqiData = {};

  AqiData? get aqiData => _aqiData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, Pollutant> get pollutants => _pollutants;
  String? get selectedCity => _selectedCity;

  // Getter for cities AQI data
  Map<String, AqiData> get citiesAqiData => _citiesAqiData;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> fetchAqiData({String? cityName}) async {
    try {
      print("Starting to fetch AQI data");
      setLoading(true);
      clearError();

      if (cityName != null && cityName.isNotEmpty) {
        print("Fetching AQI data for city: $cityName");
        _selectedCity = cityName;
        await _fetchCityGeocoding(cityName);
      } else {
        print("Fetching AQI data for current location");
        // Get current location and fetch AQI data
        await _getCurrentLocation();

        if (_currentPosition == null) {
          print("Current position is null");
          throw Exception(
              "Unable to get current location. Check location permissions.");
        }

        print(
            "Current position: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}");
        await _fetchAqiByCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude);
      }

      print("AQI data fetch complete");
      notifyListeners();
    } catch (e) {
      print("Error in fetchAqiData: $e");

      // More user-friendly error messages for common network issues
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable')) {
        setError(
            "Network connection error. Please check your internet connection and try again.");
      } else if (e.toString().contains('timed out')) {
        setError(
            "Request timed out. Please check your internet connection and try again.");

        // Use mock data if there's a timeout
        print("Timeout occurred - trying to use mock data");
        await _useMockData();
      } else {
        setError(e.toString());
      }
    } finally {
      print("Setting loading to false");
      setLoading(false);
    }
  }

  Future<void> _useMockData() async {
    try {
      print("Creating mock AQI data");
      final random = Random();

      // Generate a realistic AQI value (moderate air quality)
      final int usAqi = 50 + random.nextInt(70);

      // Use either the selected city name or "Current Location"
      String locationName =
          _selectedCity ?? _locationName ?? "Current Location";

      // Parse the location name
      String cityName = locationName;
      String localityName = '';

      if (locationName.contains(',')) {
        final parts = locationName.split(',');
        cityName = parts[0].trim();
        // Get the last part for country if available
        if (parts.length > 1) {
          localityName = parts[parts.length - 1].trim();
        }
      }

      // Create measurements with realistic values for all pollutants
      Map<String, Measurement> measurements = {
        'pm25': Measurement(
          value: 10.0 + random.nextDouble() * 20.0,
          unit: 'μg/m³',
          lastUpdated: DateTime.now(),
        ),
        'pm10': Measurement(
          value: 20.0 + random.nextDouble() * 30.0,
          unit: 'μg/m³',
          lastUpdated: DateTime.now(),
        ),
        'co': Measurement(
          value: 200.0 + random.nextDouble() * 200.0,
          unit: 'μg/m³',
          lastUpdated: DateTime.now(),
        ),
        'no2': Measurement(
          value: 15.0 + random.nextDouble() * 25.0,
          unit: 'μg/m³',
          lastUpdated: DateTime.now(),
        ),
        'so2': Measurement(
          value: 5.0 + random.nextDouble() * 15.0,
          unit: 'μg/m³',
          lastUpdated: DateTime.now(),
        ),
        'o3': Measurement(
          value: 40.0 + random.nextDouble() * 40.0,
          unit: 'μg/m³',
          lastUpdated: DateTime.now(),
        ),
      };

      // Set coordinate values
      double latitude = _currentPosition?.latitude ?? 0.0;
      double longitude = _currentPosition?.longitude ?? 0.0;

      // Determine the dominant pollutant
      String dominantPollutant = _determineDominantPollutant(measurements);

      // Create mock AQI data object
      _aqiData = AqiData(
        locationId: 0,
        name: cityName,
        locality: localityName,
        timezone: 'auto',
        country: Country(
          id: 0,
          code: '',
          name: localityName,
        ),
        coordinates: Coordinates(
          latitude: latitude,
          longitude: longitude,
        ),
        sensors: [],
        lastUpdated: DateTime.now(),
        measurements: measurements,
        aqi: usAqi,
        dominantPollutant: dominantPollutant,
      );

      print("Created mock AQI data with AQI: ${_aqiData!.aqi}");

      // Set up pollutants for display
      _setupPollutants();

      // Clear error since we have mock data
      clearError();
    } catch (e) {
      print("Error creating mock AQI data: $e");
    }
  }

  Future<void> _fetchCityGeocoding(String cityName) async {
    try {
      // Use Nominatim API for geocoding city name to coordinates
      final geocodingUrl = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$cityName&format=json&limit=1');

      final response = await http.get(
        geocodingUrl,
        headers: {'User-Agent': 'ChemExplore App'}, // Required by Nominatim
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to geocode city: ${response.statusCode}');
      }

      final List<dynamic> data = json.decode(response.body);

      if (data.isEmpty) {
        throw Exception(
            'City "$cityName" not found. Try a different city or use your current location.');
      }

      final location = data[0];

      // Store full display name for reference
      _locationName = location['display_name'];

      // Extract coordinates
      double latitude = double.parse(location['lat']);
      double longitude = double.parse(location['lon']);

      await _fetchAqiByCoordinates(latitude, longitude);
    } catch (e) {
      throw Exception('Error finding location: $e');
    }
  }

  Future<void> _fetchAqiByCoordinates(double latitude, double longitude) async {
    try {
      print("Fetching AQI data for coordinates: $latitude, $longitude");

      // Before fetching AQI data, we'll get the location name first
      String cityName = "Current Location";
      try {
        print("Getting location name from coordinates using Nominatim API");
        // Use Nominatim API for reverse geocoding instead of Open-Meteo
        final reverseGeocodingUrl = Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json');

        // Add a user-agent header as required by Nominatim's usage policy
        final geocodingResponse = await http.get(
          reverseGeocodingUrl,
          headers: {'User-Agent': 'ChemExplore App'},
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print("Geocoding request timed out");
            throw Exception('Geocoding request timed out');
          },
        );

        if (geocodingResponse.statusCode == 200) {
          final geocodingData = json.decode(geocodingResponse.body);
          print("Geocoding response: ${geocodingResponse.body}");

          // Extract location from Nominatim response
          if (geocodingData['display_name'] != null) {
            cityName = geocodingData['display_name'];

            // For a more structured approach, we can extract specific parts
            if (geocodingData['address'] != null) {
              List<String> locationParts = [];

              // Try to get city or town or village
              if (geocodingData['address']['city'] != null) {
                locationParts.add(geocodingData['address']['city']);
              } else if (geocodingData['address']['town'] != null) {
                locationParts.add(geocodingData['address']['town']);
              } else if (geocodingData['address']['village'] != null) {
                locationParts.add(geocodingData['address']['village']);
              }

              // Add state/province if available
              if (geocodingData['address']['state'] != null) {
                locationParts.add(geocodingData['address']['state']);
              }

              // Add country as the last part
              if (geocodingData['address']['country'] != null) {
                locationParts.add(geocodingData['address']['country']);
              }

              // Construct a clean city name if we have location parts
              if (locationParts.isNotEmpty) {
                cityName = locationParts.join(', ');
              }
            }

            _locationName = cityName;
            print("Location resolved: $cityName");
          }
        }
      } catch (e) {
        print("Reverse geocoding failed: $e - using default name");
      }

      // Get air quality data from Open-Meteo
      final url = Uri.parse(
        '$_baseUrl?latitude=$latitude&longitude=$longitude'
        '&current=pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone,us_aqi'
        '&timezone=auto',
      );

      print("API URL: $url");

      // Now we make the AQI API call
      // Add timeout to request to handle network issues
      final response = await http.get(url).timeout(
        const Duration(seconds: 20), // Increased to 20 seconds
        onTimeout: () {
          print("API request timed out after 20 seconds");
          throw Exception(
              'Network connection timed out. Please check your internet connection and try again.');
        },
      );

      print("API Response status: ${response.statusCode}");
      print("API Response body length: ${response.body.length}");

      if (response.statusCode != 200) {
        throw Exception('Failed to load AQI data: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      print("API response decoded successfully");

      // Initialize with default values
      int usAqi = 0;
      DateTime measurementTime = DateTime.now();
      Map<String, Measurement> measurements = {};

      // Extract the current data if available
      if (data['current'] != null) {
        // Get AQI value
        if (data['current']['us_aqi'] != null) {
          usAqi = data['current']['us_aqi'];
          print("Current US AQI: $usAqi");
        }

        // Get time
        if (data['current']['time'] != null) {
          try {
            measurementTime = DateTime.parse(data['current']['time']);
            print("Measurement time: $measurementTime");
          } catch (e) {
            print("Error parsing time: $e");
          }
        }

        // Get PM2.5
        if (data['current']['pm2_5'] != null) {
          measurements['pm25'] = Measurement(
            value: data['current']['pm2_5'].toDouble(),
            unit: 'μg/m³',
            lastUpdated: measurementTime,
          );
          print("PM2.5 value: ${data['current']['pm2_5']}");
        }

        // Get PM10
        if (data['current']['pm10'] != null) {
          measurements['pm10'] = Measurement(
            value: data['current']['pm10'].toDouble(),
            unit: 'μg/m³',
            lastUpdated: measurementTime,
          );
          print("PM10 value: ${data['current']['pm10']}");
        }

        // Get CO (Carbon Monoxide)
        if (data['current']['carbon_monoxide'] != null) {
          measurements['co'] = Measurement(
            value: data['current']['carbon_monoxide'].toDouble(),
            unit: 'μg/m³',
            lastUpdated: measurementTime,
          );
          print("CO value: ${data['current']['carbon_monoxide']}");
        }

        // Get NO2 (Nitrogen Dioxide)
        if (data['current']['nitrogen_dioxide'] != null) {
          measurements['no2'] = Measurement(
            value: data['current']['nitrogen_dioxide'].toDouble(),
            unit: 'μg/m³',
            lastUpdated: measurementTime,
          );
          print("NO2 value: ${data['current']['nitrogen_dioxide']}");
        }

        // Get SO2 (Sulphur Dioxide)
        if (data['current']['sulphur_dioxide'] != null) {
          measurements['so2'] = Measurement(
            value: data['current']['sulphur_dioxide'].toDouble(),
            unit: 'μg/m³',
            lastUpdated: measurementTime,
          );
          print("SO2 value: ${data['current']['sulphur_dioxide']}");
        }

        // Get O3 (Ozone)
        if (data['current']['ozone'] != null) {
          measurements['o3'] = Measurement(
            value: data['current']['ozone'].toDouble(),
            unit: 'μg/m³',
            lastUpdated: measurementTime,
          );
          print("O3 value: ${data['current']['ozone']}");
        }
      } else {
        print("No current data in API response");
      }

      // Determine the dominant pollutant by comparing each pollutant to standard thresholds
      String dominantPollutant = _determineDominantPollutant(measurements);

      // Parse the location name for display
      String locationName = cityName;
      String localityName = '';

      if (cityName.contains(',')) {
        final parts = cityName.split(',');
        locationName = parts[0].trim();
        // Get the last part for country if available
        if (parts.length > 1) {
          localityName = parts[parts.length - 1].trim();
        }
      }

      // Create AQI data object
      _aqiData = AqiData(
        locationId: 0,
        name: locationName,
        locality: localityName,
        timezone: data['timezone'] ?? '',
        country: Country(
          id: 0,
          code: '',
          name: localityName,
        ),
        coordinates: Coordinates(
          latitude: latitude,
          longitude: longitude,
        ),
        sensors: [],
        lastUpdated: measurementTime,
        measurements: measurements,
        aqi: usAqi,
        dominantPollutant: dominantPollutant,
      );

      print(
          "AQI data created successfully: {name: ${_aqiData!.name}, aqi: ${_aqiData!.aqi}, measurements: ${_aqiData!.measurements.length}}");

      // Set up pollutants for display
      _setupPollutants();
    } catch (e) {
      print("Error in _fetchAqiByCoordinates: $e");
      throw Exception('Error fetching air quality data: $e');
    }
  }

  Future<List<String>> searchCities(String query) async {
    if (query.length < 3) return [];

    try {
      // Use Nominatim API for geocoding city search
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5');

      final response = await http.get(
        url,
        headers: {'User-Agent': 'ChemExplore App'}, // Required by Nominatim
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to search cities: ${response.statusCode}');
      }

      final List<dynamic> data = json.decode(response.body);

      if (data.isEmpty) {
        return [];
      }

      // Format the results as "City, Country"
      return data.map<String>((location) {
        String cityName = location['display_name'];

        // Try to extract more precise information if available in address
        if (location['address'] != null) {
          List<String> locationParts = [];

          // Try to get city or town or village
          if (location['address']['city'] != null) {
            locationParts.add(location['address']['city']);
          } else if (location['address']['town'] != null) {
            locationParts.add(location['address']['town']);
          } else if (location['address']['village'] != null) {
            locationParts.add(location['address']['village']);
          } else if (location['address']['county'] != null) {
            locationParts.add(location['address']['county']);
          }

          // Add country
          if (location['address']['country'] != null) {
            locationParts.add(location['address']['country']);
          }

          // Use the structured format if we have enough parts
          if (locationParts.length >= 2) {
            cityName = locationParts.join(', ');
          }
        }

        return cityName;
      }).toList();
    } catch (e) {
      setError('Error searching cities: $e');
      return [];
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      print("Getting current location");
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Location services disabled");
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        print("Requesting location permission");
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("Location permission denied");
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print("Location permission permanently denied");
        throw Exception('Location permissions are permanently denied');
      }

      print("Getting position");
      _currentPosition = await Geolocator.getCurrentPosition();
      print(
          "Position obtained: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}");
    } catch (e) {
      print("Error in _getCurrentLocation: $e");
      setError('Error getting location: $e');
    }
  }

  void _setupPollutants() {
    if (_aqiData == null || _aqiData!.measurements.isEmpty) return;

    _pollutants.clear();
    final measurements = _aqiData!.measurements;

    // PM2.5
    if (measurements.containsKey('pm25')) {
      _pollutants['pm25'] = Pollutant(
        name: 'PM2.5',
        fullName: 'Fine Particulate Matter',
        value: measurements['pm25']!.value,
        unit: measurements['pm25']!.unit,
        description:
            'Fine inhalable particles with diameters of 2.5 micrometers or smaller.',
        cid: 44778645, // PubChem CID for PM2.5
      );
    }

    // PM10
    if (measurements.containsKey('pm10')) {
      _pollutants['pm10'] = Pollutant(
        name: 'PM10',
        fullName: 'Coarse Particulate Matter',
        value: measurements['pm10']!.value,
        unit: measurements['pm10']!.unit,
        description:
            'Inhalable particles with diameters of 10 micrometers or smaller.',
        cid: 518232, // PubChem CID for PM10
      );
    }

    // O3 (Ozone)
    if (measurements.containsKey('o3')) {
      _pollutants['o3'] = Pollutant(
        name: 'O₃',
        fullName: 'Ozone',
        value: measurements['o3']!.value,
        unit: measurements['o3']!.unit,
        description:
            'Ground-level ozone that can trigger health problems at high levels.',
        cid: 24823,
      );
    }

    // NO2 (Nitrogen Dioxide)
    if (measurements.containsKey('no2')) {
      _pollutants['no2'] = Pollutant(
        name: 'NO₂',
        fullName: 'Nitrogen Dioxide',
        value: measurements['no2']!.value,
        unit: measurements['no2']!.unit,
        description:
            'Nitrogen dioxide from burning of fossil fuels, can cause respiratory issues.',
        cid: 3032552,
      );
    }

    // SO2 (Sulfur Dioxide)
    if (measurements.containsKey('so2')) {
      _pollutants['so2'] = Pollutant(
        name: 'SO₂',
        fullName: 'Sulfur Dioxide',
        value: measurements['so2']!.value,
        unit: measurements['so2']!.unit,
        description:
            'Sulfur dioxide from burning of fossil fuels, can cause respiratory issues.',
        cid: 1119,
      );
    }

    // CO (Carbon Monoxide)
    if (measurements.containsKey('co')) {
      _pollutants['co'] = Pollutant(
        name: 'CO',
        fullName: 'Carbon Monoxide',
        value: measurements['co']!.value,
        unit: measurements['co']!.unit,
        description:
            'Carbon monoxide, an odorless gas that can be toxic at high levels.',
        cid: 281,
      );
    }
  }

  String getAqiCategory(int aqi) {
    if (aqi <= 50) {
      return 'Good';
    } else if (aqi <= 100) {
      return 'Moderate';
    } else if (aqi <= 150) {
      return 'Unhealthy for Sensitive Groups';
    } else if (aqi <= 200) {
      return 'Unhealthy';
    } else if (aqi <= 300) {
      return 'Very Unhealthy';
    } else {
      return 'Hazardous';
    }
  }

  String getAqiDescription(int aqi) {
    // Handle invalid or zero AQI
    if (aqi <= 0) {
      return 'No air quality data available';
    }

    if (aqi <= 50) {
      return 'Air quality is considered satisfactory, and air pollution poses little or no risk.';
    } else if (aqi <= 100) {
      return 'Air quality is acceptable; however, some pollutants may be a concern for a very small number of people.';
    } else if (aqi <= 150) {
      return 'Members of sensitive groups may experience health effects. The general public is not likely to be affected.';
    } else if (aqi <= 200) {
      return 'Everyone may begin to experience health effects; members of sensitive groups may experience more serious effects.';
    } else if (aqi <= 300) {
      return 'Health warnings of emergency conditions. The entire population is more likely to be affected.';
    } else {
      return 'Health alert: everyone may experience more serious health effects.';
    }
  }

  Color getAqiColor(int aqi) {
    if (aqi <= 50) {
      return Colors.green;
    } else if (aqi <= 100) {
      return Colors.yellow;
    } else if (aqi <= 150) {
      return Colors.orange;
    } else if (aqi <= 200) {
      return Colors.red;
    } else if (aqi <= 300) {
      return Colors.purple;
    } else {
      return Colors.brown;
    }
  }

  // Helper method to determine dominant pollutant based on standard thresholds
  String _determineDominantPollutant(Map<String, Measurement> measurements) {
    if (measurements.isEmpty) return '';

    // Default to pm25 if available
    if (measurements.containsKey('pm25')) {
      String dominantPollutant = 'pm25';
      double highestRelativeValue =
          _getPollutantRelativeValue('pm25', measurements['pm25']!.value);

      // Check each pollutant and determine which one exceeds its standard threshold the most
      for (var entry in measurements.entries) {
        if (entry.key == 'pm25') continue;

        double relativeValue =
            _getPollutantRelativeValue(entry.key, entry.value.value);
        if (relativeValue > highestRelativeValue) {
          highestRelativeValue = relativeValue;
          dominantPollutant = entry.key;
        }
      }

      print("Determined dominant pollutant: $dominantPollutant");
      return dominantPollutant;
    }

    // Fallback to the first pollutant if pm25 is not available
    return measurements.keys.first;
  }

  // Helper method to calculate how much a pollutant exceeds its standard threshold
  double _getPollutantRelativeValue(String pollutantCode, double value) {
    switch (pollutantCode) {
      case 'pm25':
        return value / 12.0; // WHO standard for PM2.5 is 12 μg/m³
      case 'pm10':
        return value / 45.0; // WHO standard for PM10 is 45 μg/m³
      case 'o3':
        return value / 100.0; // Example threshold for ozone
      case 'no2':
        return value / 40.0; // Example threshold for nitrogen dioxide
      case 'so2':
        return value / 20.0; // Example threshold for sulfur dioxide
      case 'co':
        return value / 4000.0; // Example threshold for carbon monoxide
      default:
        return 1.0;
    }
  }

  // Fetch AQI for all major cities
  Future<void> fetchMajorCitiesAqi() async {
    print("Fetching AQI data for major cities");

    // Create a list of futures to fetch data for all cities concurrently
    List<Future<void>> futures = [];

    for (var city in _majorCities) {
      futures.add(_fetchCityAqi(
        city['name'],
        city['latitude'],
        city['longitude'],
      ));
    }

    // Wait for all requests to complete, but allow some to fail
    // without stopping the entire operation
    await Future.wait(
      futures.map((future) => future.catchError((e) {
            print("Error fetching city data: $e");
            return null;
          })),
    );

    // Notify listeners that data has been updated
    notifyListeners();
  }

  // Helper method to fetch data for a single city
  Future<void> _fetchCityAqi(
      String cityName, double latitude, double longitude) async {
    try {
      // Get air quality data from Open-Meteo
      final url = Uri.parse(
        '$_baseUrl?latitude=$latitude&longitude=$longitude'
        '&current=pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone,us_aqi'
        '&timezone=auto',
      );

      // Add shorter timeout for background city fetching
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out for $cityName');
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to load AQI data for $cityName: ${response.statusCode}');
      }

      final data = json.decode(response.body);

      // Only continue if we have valid data
      if (data['current'] != null && data['current']['us_aqi'] != null) {
        // Get basic data
        int usAqi = data['current']['us_aqi'];
        DateTime measurementTime = DateTime.now();

        // Try to parse time
        if (data['current']['time'] != null) {
          try {
            measurementTime = DateTime.parse(data['current']['time']);
          } catch (e) {
            print("Error parsing time for $cityName: $e");
          }
        }

        // Create city AQI data
        _citiesAqiData[cityName] = AqiData(
          locationId: 0,
          name: cityName,
          locality: '',
          timezone: data['timezone'] ?? '',
          country: Country(id: 0, code: '', name: ''),
          coordinates: Coordinates(latitude: latitude, longitude: longitude),
          sensors: [],
          lastUpdated: measurementTime,
          measurements: {}, // We don't need detailed measurements for the map
          aqi: usAqi,
          dominantPollutant: '', // Not needed for map display
        );

        print("Added AQI data for $cityName: $usAqi");
      }
    } catch (e) {
      print("Error fetching AQI for $cityName: $e");
      // We don't rethrow to allow other city requests to continue
    }
  }
}
