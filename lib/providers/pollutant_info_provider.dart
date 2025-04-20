import 'package:flutter/foundation.dart';
import '../models/pollutant.dart';

class PollutantInfoProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  // Track loaded pollutants
  final Set<int> _loadedPollutants = {};

  // Add disposed flag to track if provider has been disposed
  bool _disposed = false;

  PollutantInfoProvider();

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Check if a pollutant is loaded
  bool isDetailLoaded(int cid) => _loadedPollutants.contains(cid);
  bool isSectionLoading(int cid) =>
      _isLoading && !_loadedPollutants.contains(cid);

  // Override dispose method to set disposed flag
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // Override notifyListeners to check disposal state first
  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

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

  Future<void> fetchPollutantDetails(Pollutant pollutant) async {
    try {
      // Debug
      print(
          'fetchPollutantDetails called for: ${pollutant.name} (CID: ${pollutant.cid})');

      // Check if data is already loaded for this pollutant
      if (_loadedPollutants.contains(pollutant.cid)) {
        print('Data already loaded for pollutant CID: ${pollutant.cid}');
        // Even if data is loaded, make sure properties are not empty
        _ensurePropertiesNotEmpty(pollutant);
        return;
      }

      setLoading(true);
      clearError();
      notifyListeners();

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      if (_disposed) return; // Check if disposed before continuing

      // Set static data with debug info
      print('Setting health effects for: ${pollutant.name}');
      pollutant.healthEffects = _getHealthEffects(pollutant);
      print('Setting safety info for: ${pollutant.name}');
      pollutant.safetyInfo = _getSafetyInfo(pollutant);
      print('Setting sources for: ${pollutant.name}');
      pollutant.sources = _getSources(pollutant);
      print('Setting chemical properties for: ${pollutant.name}');
      pollutant.chemicalProperties = _getChemicalProperties(pollutant);
      print('Setting detailed description for: ${pollutant.name}');
      pollutant.detailedDescription = _getDescription(pollutant);

      // Ensure properties are not empty
      _ensurePropertiesNotEmpty(pollutant);

      // Mark pollutant as loaded
      _loadedPollutants.add(pollutant.cid);
      print(
          'Successfully loaded data for pollutant: ${pollutant.name} (CID: ${pollutant.cid})');
    } catch (e) {
      print('Error in fetchPollutantDetails: $e');
      if (!_disposed) {
        // Check if disposed before setting error
        setError('Error fetching pollutant details: $e');
      }
    } finally {
      if (!_disposed) {
        // Check if disposed before updating state
        setLoading(false);
      }
    }
  }

  // Make sure all properties are populated, even if already "loaded"
  void _ensurePropertiesNotEmpty(Pollutant pollutant) {
    // Check if chemical properties are empty
    if (pollutant.chemicalProperties == null ||
        pollutant.chemicalProperties!.isEmpty) {
      print(
          'Chemical properties were empty for ${pollutant.name}, setting now');
      pollutant.chemicalProperties = _getChemicalProperties(pollutant);
    }

    // Check other properties and set if empty
    if (pollutant.healthEffects == null || pollutant.healthEffects!.isEmpty) {
      print('Health effects were empty for ${pollutant.name}, setting now');
      pollutant.healthEffects = _getHealthEffects(pollutant);
    }

    if (pollutant.safetyInfo == null || pollutant.safetyInfo!.isEmpty) {
      print('Safety info was empty for ${pollutant.name}, setting now');
      pollutant.safetyInfo = _getSafetyInfo(pollutant);
    }

    if (pollutant.sources == null || pollutant.sources!.isEmpty) {
      print('Sources were empty for ${pollutant.name}, setting now');
      pollutant.sources = _getSources(pollutant);
    }

    if (pollutant.detailedDescription == null ||
        pollutant.detailedDescription!.isEmpty) {
      print(
          'Detailed description was empty for ${pollutant.name}, setting now');
      pollutant.detailedDescription = _getDescription(pollutant);
    }
  }

  String _getHealthEffects(Pollutant pollutant) {
    switch (pollutant.name) {
      case 'PM2.5':
        return 'Fine particles can penetrate deep into lungs and even enter the bloodstream. '
            'They can cause respiratory symptoms, decreased lung function, aggravate asthma, '
            'and lead to premature death in people with heart or lung disease.';
      case 'PM10':
        return 'Coarse particles can aggravate respiratory conditions like asthma and bronchitis. '
            'They can cause coughing, wheezing, and decreased lung function. Long-term exposure '
            'is associated with respiratory and cardiovascular problems.';
      case 'O₃':
        return 'Ground-level ozone can trigger chest pain, coughing, throat irritation, and '
            'airway inflammation. It can worsen bronchitis, emphysema, and asthma. Long-term '
            'exposure may lead to permanent lung damage.';
      case 'NO₂':
        return 'Nitrogen dioxide can irritate airways, aggravate respiratory diseases, particularly '
            'asthma. It may lead to respiratory infections and reduced lung function. Long-term '
            'exposure can contribute to asthma development.';
      case 'SO₂':
        return 'Sulfur dioxide can cause respiratory irritation, bronchoconstriction, and increased '
            'asthma symptoms. High concentrations can cause breathing difficulties, especially '
            'during physical activity.';
      case 'CO':
        return 'Carbon monoxide reduces oxygen delivery to body organs. It can cause headaches, '
            'dizziness, and confusion. At high levels, it can cause unconsciousness and death. '
            'People with heart disease are particularly sensitive.';
      default:
        print('No health effects found for pollutant: ${pollutant.name}');
        return 'Health effects information not available.';
    }
  }

  String _getSafetyInfo(Pollutant pollutant) {
    switch (pollutant.name) {
      case 'PM2.5':
        return 'Limit outdoor activity during high PM2.5 days. Use air purifiers indoors. '
            'Wear N95 masks in heavily polluted areas. Keep windows closed during pollution events.';
      case 'PM10':
        return 'Reduce outdoor exercise during high pollution days. Consider wearing a mask in '
            'dusty conditions. Use air purifiers indoors to reduce exposure.';
      case 'O₃':
        return 'Limit outdoor activities during high ozone alerts, especially in the afternoon when '
            'levels are typically highest. People with respiratory conditions should be particularly cautious.';
      case 'NO₂':
        return 'Ensure proper ventilation when using gas stoves or heaters. Avoid idling vehicles, '
            'especially in enclosed spaces like garages. Limit time on or near busy roads during rush hour.';
      case 'SO₂':
        return 'Those with asthma should be vigilant during high SO2 days. Limit outdoor activities '
            'near industrial areas that emit sulfur dioxide. Ensure proper ventilation when using '
            'kerosene heaters.';
      case 'CO':
        return 'Install carbon monoxide detectors in your home. Ensure proper ventilation for fuel-burning '
            'appliances. Never run engines in enclosed spaces. Have heating systems and chimneys inspected annually.';
      default:
        print('No safety info found for pollutant: ${pollutant.name}');
        return 'Safety information not available.';
    }
  }

  String _getSources(Pollutant pollutant) {
    switch (pollutant.name) {
      case 'PM2.5':
        return 'Vehicle emissions, power plants, industrial processes, residential wood burning, '
            'forest fires, agricultural burning, and dust.';
      case 'PM10':
        return 'Construction sites, unpaved roads, fields, smokestacks, fires, and dust from '
            'agricultural, mining, and industrial activities.';
      case 'O₃':
        return 'Not directly emitted but formed by chemical reactions between oxides of nitrogen (NOx) '
            'and volatile organic compounds (VOCs) in the presence of sunlight.';
      case 'NO₂':
        return 'Vehicle exhaust, power plants, industrial emissions, and off-road equipment. Any process '
            'that burns fuel at high temperatures can create nitrogen dioxide.';
      case 'SO₂':
        return 'Burning of fossil fuels (coal and oil) in power plants and other industrial facilities, '
            'extraction of metal from ore, and certain industrial processes.';
      case 'CO':
        return 'Vehicle exhaust, especially in high-traffic areas, fuel combustion in industrial processes, '
            'residential wood burning, and natural sources like wildfires.';
      default:
        print('No source info found for pollutant: ${pollutant.name}');
        return 'Source information not available.';
    }
  }

  Map<String, dynamic> _getChemicalProperties(Pollutant pollutant) {
    switch (pollutant.name) {
      case 'PM2.5':
        return {
          'MolecularFormula': 'Various',
          'MolecularWeight': 'Varies',
          'Description': 'Complex mixture of solid and liquid particles',
          'Size': 'Particles with diameter of 2.5 micrometers or smaller',
          'Composition':
              'May include dust, pollen, soot, smoke, and liquid droplets',
          'Solubility': 'Varies by component',
        };
      case 'PM10':
        return {
          'MolecularFormula': 'Various',
          'MolecularWeight': 'Varies',
          'Description': 'Complex mixture of solid and liquid particles',
          'Size': 'Particles with diameter of 10 micrometers or smaller',
          'Composition':
              'Includes dust, pollen, mold, ash, and other particulates',
          'Solubility': 'Varies by component',
        };
      case 'O₃':
        return {
          'MolecularFormula': 'O₃',
          'MolecularWeight': '48.00 g/mol',
          'Description': 'Triatomic molecule, allotrope of oxygen',
          'MeltingPoint': '-192.2 °C',
          'BoilingPoint': '-112 °C',
          'Density': '2.144 g/L (at 0°C)',
          'Color': 'Pale blue gas',
          'Odor': 'Distinctive sharp, fresh smell',
          'Solubility': 'Slightly soluble in water',
        };
      case 'NO₂':
        return {
          'MolecularFormula': 'NO₂',
          'MolecularWeight': '46.01 g/mol',
          'Description': 'Nitrogen dioxide is a chemical compound',
          'MeltingPoint': '-11.2 °C',
          'BoilingPoint': '21.2 °C',
          'Density': '1.88 g/L (at 20°C)',
          'Color': 'Reddish-brown gas',
          'Odor': 'Sharp, biting odor',
          'Solubility': 'Moderately soluble in water, forming nitric acid',
        };
      case 'SO₂':
        return {
          'MolecularFormula': 'SO₂',
          'MolecularWeight': '64.07 g/mol',
          'Description': 'Sulfur dioxide is a toxic gas',
          'MeltingPoint': '-72 °C',
          'BoilingPoint': '-10 °C',
          'Density': '2.619 g/L (at 0°C)',
          'Color': 'Colorless gas',
          'Odor': 'Strong, suffocating odor',
          'Solubility': 'Highly soluble in water, forming sulfurous acid',
        };
      case 'CO':
        return {
          'MolecularFormula': 'CO',
          'MolecularWeight': '28.01 g/mol',
          'Description': 'Carbon monoxide is a colorless, odorless gas',
          'MeltingPoint': '-205 °C',
          'BoilingPoint': '-191.5 °C',
          'Density': '1.145 g/L (at 25°C)',
          'Color': 'Colorless',
          'Odor': 'Odorless',
          'Solubility': 'Slightly soluble in water',
          'FlammabilityLimits': '12.5–74.2% in air',
        };
      default:
        print('No chemical properties found for pollutant: ${pollutant.name}');
        return {
          'Description': 'Chemical properties information not available.',
        };
    }
  }

  String _getDescription(Pollutant pollutant) {
    switch (pollutant.name) {
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
        print('No description found for pollutant: ${pollutant.name}');
        return 'Detailed description not available for this pollutant.';
    }
  }

  // Method to reset loaded state for testing
  void clearLoadedPollutants() {
    _loadedPollutants.clear();
    notifyListeners();
  }
}
