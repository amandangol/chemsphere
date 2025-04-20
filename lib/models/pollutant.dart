class Pollutant {
  final String name;
  final String fullName;
  final double value;
  final String unit;
  final String description;
  final int cid; // PubChem Compound ID for fetching more details

  // Optional fields for safety and health information
  String? healthEffects;
  String? safetyInfo;
  String? sources;
  Map<String, dynamic>? chemicalProperties;
  String? detailedDescription; // Add a new field for detailed description

  Pollutant({
    required this.name,
    required this.fullName,
    required this.value,
    required this.unit,
    required this.description,
    required this.cid,
    this.healthEffects,
    this.safetyInfo,
    this.sources,
    this.chemicalProperties,
    this.detailedDescription,
  });

  String get formattedValue => '$value $unit';

  String getHealthImpact() {
    if (name == 'PM2.5') {
      if (value <= 12) {
        return 'Good: Little to no health risk.';
      } else if (value <= 35.4) {
        return 'Moderate: Unusually sensitive people should consider reducing prolonged or heavy exertion.';
      } else if (value <= 55.4) {
        return 'Unhealthy for Sensitive Groups: People with respiratory or heart disease, children and older adults should limit prolonged exertion.';
      } else if (value <= 150.4) {
        return 'Unhealthy: Everyone may begin to experience health effects. Sensitive groups should limit outdoor exertion.';
      } else if (value <= 250.4) {
        return 'Very Unhealthy: Health warnings of emergency conditions. Entire population is more likely to be affected.';
      } else {
        return 'Hazardous: Health alert - everyone may experience more serious health effects.';
      }
    } else if (name == 'PM10') {
      if (value <= 54) {
        return 'Good: Little to no health risk.';
      } else if (value <= 154) {
        return 'Moderate: Unusually sensitive people should consider reducing prolonged or heavy exertion.';
      } else if (value <= 254) {
        return 'Unhealthy for Sensitive Groups: People with respiratory disease should limit outdoor exertion.';
      } else if (value <= 354) {
        return 'Unhealthy: Everyone may begin to experience health effects. Sensitive groups should limit outdoor exertion.';
      } else if (value <= 424) {
        return 'Very Unhealthy: Health warnings of emergency conditions. Entire population is more likely to be affected.';
      } else {
        return 'Hazardous: Health alert - everyone may experience more serious health effects.';
      }
    } else if (name == 'O₃') {
      if (value <= 54) {
        return 'Good: Little to no health risk.';
      } else if (value <= 70) {
        return 'Moderate: Unusually sensitive individuals may experience respiratory symptoms.';
      } else if (value <= 85) {
        return 'Unhealthy for Sensitive Groups: People with lung disease are at risk.';
      } else if (value <= 105) {
        return 'Unhealthy: Increased likelihood of respiratory symptoms in sensitive individuals.';
      } else if (value <= 200) {
        return 'Very Unhealthy: Significant increase in respiratory effects in general population.';
      } else {
        return 'Hazardous: Serious respiratory effects and impaired breathing likely in general population.';
      }
    } else if (name == 'NO₂') {
      if (value <= 53) {
        return 'Good: Little to no health risk.';
      } else if (value <= 100) {
        return 'Moderate: Unusually sensitive individuals may experience respiratory symptoms.';
      } else if (value <= 360) {
        return 'Unhealthy for Sensitive Groups: People with respiratory disease should limit outdoor exertion.';
      } else if (value <= 649) {
        return 'Unhealthy: Increased respiratory effects in general population.';
      } else if (value <= 1249) {
        return 'Very Unhealthy: Significant increase in respiratory effects in general population.';
      } else {
        return 'Hazardous: Serious respiratory effects likely in general population.';
      }
    } else if (name == 'SO₂') {
      if (value <= 35) {
        return 'Good: Little to no health risk.';
      } else if (value <= 75) {
        return 'Moderate: Few hypersensitive individuals may experience respiratory symptoms.';
      } else if (value <= 185) {
        return 'Unhealthy for Sensitive Groups: Increasing likelihood of respiratory symptoms in sensitive individuals.';
      } else if (value <= 304) {
        return 'Unhealthy: Increased respiratory effects in general population.';
      } else if (value <= 604) {
        return 'Very Unhealthy: Significant increase in respiratory effects in general population.';
      } else {
        return 'Hazardous: Serious respiratory effects likely in general population.';
      }
    } else if (name == 'CO') {
      if (value <= 4.4) {
        return 'Good: Little to no health risk.';
      } else if (value <= 9.4) {
        return 'Moderate: Unusually sensitive individuals may experience some adverse effects.';
      } else if (value <= 12.4) {
        return 'Unhealthy for Sensitive Groups: People with heart disease may experience some effects.';
      } else if (value <= 15.4) {
        return 'Unhealthy: Increasing likelihood of reduced exercise tolerance in people with heart disease.';
      } else if (value <= 30.4) {
        return 'Very Unhealthy: Significant aggravation of cardiovascular symptoms.';
      } else {
        return 'Hazardous: Serious risk of cardiovascular effects in general population.';
      }
    } else {
      return 'No specific health impact information available.';
    }
  }
}
