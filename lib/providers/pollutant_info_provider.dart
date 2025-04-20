import 'package:flutter/foundation.dart';
import '../models/pollutant.dart';
import '../screens/compounds/provider/compound_provider.dart';

class PollutantInfoProvider with ChangeNotifier {
  final CompoundProvider _compoundProvider;
  final Map<int, Map<String, dynamic>> _pollutantDetails = {};
  bool _isLoading = false;
  String? _error;

  PollutantInfoProvider(this._compoundProvider);

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<int, Map<String, dynamic>> get pollutantDetails => _pollutantDetails;

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
      setLoading(true);
      clearError();

      // Check if we already have the details cached
      if (_pollutantDetails.containsKey(pollutant.cid)) {
        setLoading(false);
        return;
      }

      // Fetch compound details using CompoundProvider
      await _compoundProvider.fetchCompoundDetails(pollutant.cid);

      if (_compoundProvider.selectedCompound != null) {
        // Extract relevant information
        final compound = _compoundProvider.selectedCompound!;

        _pollutantDetails[pollutant.cid] = {
          'description': compound.description,
          'descriptionSource': compound.descriptionSource,
          'synonyms': compound.synonyms,
          'properties': compound.physicalProperties,
          'formula': compound.molecularFormula,
          'weight': compound.molecularWeight,
          'inchi': compound.inchi,
          'inchiKey': compound.inchiKey,
          'pubChemUrl': compound.pubChemUrl,
        };

        // Update pollutant with additional information
        pollutant.healthEffects = _getHealthEffects(compound);
        pollutant.safetyInfo = _getSafetyInfo(compound);
        pollutant.sources = _getSources(pollutant);
        pollutant.chemicalProperties = compound.physicalProperties;

        notifyListeners();
      }
    } catch (e) {
      setError('Error fetching pollutant details: $e');
    } finally {
      setLoading(false);
    }
  }

  String _getHealthEffects(dynamic compound) {
    // Extract health effects from compound data
    // This is a simplified version - in a real app, you would parse the compound data
    switch (compound.cid) {
      case 44778645: // PM2.5
        return 'Fine particles can penetrate deep into lungs and even enter the bloodstream. '
            'They can cause respiratory symptoms, decreased lung function, aggravate asthma, '
            'and lead to premature death in people with heart or lung disease.';
      case 518232: // PM10
        return 'Coarse particles can aggravate respiratory conditions like asthma and bronchitis. '
            'They can cause coughing, wheezing, and decreased lung function. Long-term exposure '
            'is associated with respiratory and cardiovascular problems.';
      case 24823: // O3 (Ozone)
        return 'Ground-level ozone can trigger chest pain, coughing, throat irritation, and '
            'airway inflammation. It can worsen bronchitis, emphysema, and asthma. Long-term '
            'exposure may lead to permanent lung damage.';
      case 3032552: // NO2
        return 'Nitrogen dioxide can irritate airways, aggravate respiratory diseases, particularly '
            'asthma. It may lead to respiratory infections and reduced lung function. Long-term '
            'exposure can contribute to asthma development.';
      case 1119: // SO2
        return 'Sulfur dioxide can cause respiratory irritation, bronchoconstriction, and increased '
            'asthma symptoms. High concentrations can cause breathing difficulties, especially '
            'during physical activity.';
      case 281: // CO
        return 'Carbon monoxide reduces oxygen delivery to body organs. It can cause headaches, '
            'dizziness, and confusion. At high levels, it can cause unconsciousness and death. '
            'People with heart disease are particularly sensitive.';
      default:
        return 'Health effects information not available.';
    }
  }

  String _getSafetyInfo(dynamic compound) {
    // Extract safety information from compound data
    switch (compound.cid) {
      case 44778645: // PM2.5
        return 'Limit outdoor activity during high PM2.5 days. Use air purifiers indoors. '
            'Wear N95 masks in heavily polluted areas. Keep windows closed during pollution events.';
      case 518232: // PM10
        return 'Reduce outdoor exercise during high pollution days. Consider wearing a mask in '
            'dusty conditions. Use air purifiers indoors to reduce exposure.';
      case 24823: // O3 (Ozone)
        return 'Limit outdoor activities during high ozone alerts, especially in the afternoon when '
            'levels are typically highest. People with respiratory conditions should be particularly cautious.';
      case 3032552: // NO2
        return 'Ensure proper ventilation when using gas stoves or heaters. Avoid idling vehicles, '
            'especially in enclosed spaces like garages. Limit time on or near busy roads during rush hour.';
      case 1119: // SO2
        return 'Those with asthma should be vigilant during high SO2 days. Limit outdoor activities '
            'near industrial areas that emit sulfur dioxide. Ensure proper ventilation when using '
            'kerosene heaters.';
      case 281: // CO
        return 'Install carbon monoxide detectors in your home. Ensure proper ventilation for fuel-burning '
            'appliances. Never run engines in enclosed spaces. Have heating systems and chimneys inspected annually.';
      default:
        return 'Safety information not available.';
    }
  }

  String _getSources(Pollutant pollutant) {
    // Return common sources of the pollutant
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
        return 'Source information not available.';
    }
  }
}
