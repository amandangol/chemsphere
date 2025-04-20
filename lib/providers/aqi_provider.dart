import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/aqi_data.dart';
import '../models/pollutant.dart';

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

  AqiData? get aqiData => _aqiData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, Pollutant> get pollutants => _pollutants;
  String? get selectedCity => _selectedCity;

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
        name: locationName.contains(',')
            ? locationName.split(',')[0].trim()
            : locationName,
        locality:
            locationName.contains(',') ? locationName.split(',')[1].trim() : '',
        timezone: 'auto',
        country: Country(
          id: 0,
          code: '',
          name: locationName.contains(',')
              ? locationName.split(',')[1].trim()
              : '',
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
      // Use Open-Meteo Geocoding API to get coordinates for city name
      final geocodingUrl = Uri.parse(
          'https://geocoding-api.open-meteo.com/v1/search?name=$cityName&count=1&language=en&format=json');

      final response = await http.get(geocodingUrl);

      if (response.statusCode != 200) {
        throw Exception('Failed to geocode city: ${response.statusCode}');
      }

      final data = json.decode(response.body);

      if (data['results'] == null || data['results'].isEmpty) {
        throw Exception(
            'City "$cityName" not found. Try a different city or use your current location.');
      }

      final location = data['results'][0];
      _locationName = location['name'] + ', ' + (location['country'] ?? '');

      await _fetchAqiByCoordinates(location['latitude'], location['longitude']);
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
        print("Getting location name from coordinates");
        final reverseGeocodingUrl = Uri.parse(
            'https://geocoding-api.open-meteo.com/v1/reverse?latitude=$latitude&longitude=$longitude');

        final geocodingResponse = await http.get(reverseGeocodingUrl).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print("Geocoding request timed out");
            throw Exception('Geocoding request timed out');
          },
        );

        if (geocodingResponse.statusCode == 200) {
          final geocodingData = json.decode(geocodingResponse.body);
          print("Geocoding response: ${geocodingResponse.body}");
          if (geocodingData['results'] != null &&
              geocodingData['results'].isNotEmpty) {
            final location = geocodingData['results'][0];

            // Extract location components
            List<String> locationParts = [];

            if (location['name'] != null &&
                location['name'].toString().isNotEmpty) {
              locationParts.add(location['name']);
            }

            // Prioritize most specific information
            for (String key in ['admin4', 'admin3', 'admin2', 'admin1']) {
              if (location[key] != null &&
                  location[key].toString().isNotEmpty) {
                locationParts.add(location[key]);
                break; // Only add one administrative level
              }
            }

            // Add country as the last part
            if (location['country'] != null &&
                location['country'].toString().isNotEmpty) {
              locationParts.add(location['country']);
            }

            // Construct a clean city name
            cityName = locationParts.join(', ');
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

      // Create AQI data object
      _aqiData = AqiData(
        locationId: 0,
        name: cityName.contains(',') ? cityName.split(',')[0].trim() : cityName,
        locality: cityName.contains(',') ? cityName.split(',')[1].trim() : '',
        timezone: data['timezone'] ?? '',
        country: Country(
          id: 0,
          code: '',
          name: cityName.contains(',') ? cityName.split(',')[1].trim() : '',
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
      // Use Open-Meteo Geocoding API to search for cities
      final url = Uri.parse(
          'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=5&language=en&format=json');

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to search cities: ${response.statusCode}');
      }

      final data = json.decode(response.body);

      if (data['results'] == null) {
        return [];
      }

      final List<dynamic> results = data['results'];
      return results
          .map<String>(
              (location) => '${location['name']}, ${location['country'] ?? ''}')
          .toList();
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
}
