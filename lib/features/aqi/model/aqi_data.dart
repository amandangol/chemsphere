class AqiData {
  final int locationId;
  final String name;
  final String locality;
  final String timezone;
  final Country country;
  final Coordinates coordinates;
  final List<Sensor> sensors;
  final DateTime lastUpdated;
  final Map<String, Measurement> measurements;
  final int aqi;
  final String dominantPollutant;

  AqiData({
    required this.locationId,
    required this.name,
    required this.locality,
    required this.timezone,
    required this.country,
    required this.coordinates,
    required this.sensors,
    required this.lastUpdated,
    required this.measurements,
    required this.aqi,
    required this.dominantPollutant,
  });

  factory AqiData.fromJson(Map<String, dynamic> json) {
    final result = json['results'][0];
    final sensorsData = result['sensors'] as List<dynamic>;
    List<Sensor> sensors = sensorsData.map((s) => Sensor.fromJson(s)).toList();

    // Parse last datetime
    DateTime lastUpdated = DateTime.now();
    if (result['datetimeLast'] != null) {
      try {
        lastUpdated = DateTime.parse(result['datetimeLast']['utc']);
      } catch (e) {
        // Use current time if parsing fails
      }
    }

    // Initialize empty measurements
    Map<String, Measurement> measurements = {};

    // Default AQI and dominant pollutant (will be set by provider)
    int aqi = 0;
    String dominantPollutant = '';

    return AqiData(
      locationId: result['id'] ?? 0,
      name: result['name'] ?? '',
      locality: result['locality'] ?? '',
      timezone: result['timezone'] ?? '',
      country: Country.fromJson(result['country'] ?? {}),
      coordinates: Coordinates.fromJson(result['coordinates'] ?? {}),
      sensors: sensors,
      lastUpdated: lastUpdated,
      measurements: measurements,
      aqi: aqi,
      dominantPollutant: dominantPollutant,
    );
  }
}

class Country {
  final int id;
  final String code;
  final String name;

  Country({
    required this.id,
    required this.code,
    required this.name,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({
    required this.latitude,
    required this.longitude,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
    );
  }
}

class Sensor {
  final int id;
  final String name;
  final Parameter parameter;

  Sensor({
    required this.id,
    required this.name,
    required this.parameter,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      parameter: Parameter.fromJson(json['parameter'] ?? {}),
    );
  }
}

class Parameter {
  final int id;
  final String name;
  final String units;
  final String displayName;

  Parameter({
    required this.id,
    required this.name,
    required this.units,
    required this.displayName,
  });

  factory Parameter.fromJson(Map<String, dynamic> json) {
    return Parameter(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      units: json['units'] ?? '',
      displayName: json['displayName'] ?? '',
    );
  }
}

class Measurement {
  final double value;
  final String unit;
  final DateTime lastUpdated;

  Measurement({
    required this.value,
    required this.unit,
    required this.lastUpdated,
  });

  factory Measurement.fromJson(Map<String, dynamic> json) {
    DateTime lastUpdated = DateTime.now();
    if (json['date'] != null) {
      try {
        lastUpdated = DateTime.parse(json['date']['utc']);
      } catch (e) {
        // Use current time if parsing fails
      }
    }

    return Measurement(
      value: json['value'] is num ? json['value'].toDouble() : 0.0,
      unit: json['unit'] ?? '',
      lastUpdated: lastUpdated,
    );
  }
}
