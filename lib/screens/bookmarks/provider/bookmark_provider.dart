import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../drugs/model/drug.dart';
import '../../compounds/model/compound.dart';

enum BookmarkType {
  drug,
  compound,
  molecularStructure,
}

class BookmarkItem {
  final dynamic item;
  final BookmarkType type;
  final DateTime timestamp;

  BookmarkItem({
    required this.item,
    required this.type,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'item': _itemToJson(item),
    };
  }

  static BookmarkItem fromJson(Map<String, dynamic> json) {
    try {
      return BookmarkItem(
        type: BookmarkType.values.firstWhere(
          (e) => e.toString() == json['type'],
        ),
        timestamp: DateTime.parse(json['timestamp']),
        item: _itemFromJson(json['item'], json['type']),
      );
    } catch (e) {
      debugPrint('Error deserializing bookmark item: $e');
      rethrow;
    }
  }

  static Map<String, dynamic> _itemToJson(dynamic item) {
    if (item is Drug) {
      return {
        'type': 'Drug',
        'data': {
          'title': item.title,
          'cid': item.cid,
          'molecularFormula': item.molecularFormula,
          'molecularWeight': item.molecularWeight,
          'smiles': item.smiles,
          'xLogP': item.xLogP,
          'hBondDonorCount': item.hBondDonorCount,
          'hBondAcceptorCount': item.hBondAcceptorCount,
          'rotatableBondCount': item.rotatableBondCount,
          'heavyAtomCount': item.heavyAtomCount,
          'atomStereoCount': item.atomStereoCount,
          'bondStereoCount': item.bondStereoCount,
          'complexity': item.complexity,
          'iupacName': item.iupacName,
          'description': item.description,
          'descriptionSource': item.descriptionSource,
          'descriptionUrl': item.descriptionUrl,
          'synonyms': item.synonyms,
          'physicalProperties': item.physicalProperties,
          'pubChemUrl': item.pubChemUrl,
          'indication': item.indication,
          'mechanismOfAction': item.mechanismOfAction,
          'toxicity': item.toxicity,
          'pharmacology': item.pharmacology,
          'metabolism': item.metabolism,
          'absorption': item.absorption,
          'halfLife': item.halfLife,
          'proteinBinding': item.proteinBinding,
          'routeOfElimination': item.routeOfElimination,
          'volumeOfDistribution': item.volumeOfDistribution,
          'clearance': item.clearance,
          'name': item.name,
        },
      };
    } else if (item is Compound) {
      return {
        'type': 'Compound',
        'data': {
          'title': item.title,
          'cid': item.cid,
          'molecularFormula': item.molecularFormula,
          'molecularWeight': item.molecularWeight,
          'smiles': item.smiles,
          'xLogP': item.xLogP,
          'hBondDonorCount': item.hBondDonorCount,
          'hBondAcceptorCount': item.hBondAcceptorCount,
          'rotatableBondCount': item.rotatableBondCount,
          'heavyAtomCount': item.heavyAtomCount,
          'atomStereoCount': item.atomStereoCount,
          'bondStereoCount': item.bondStereoCount,
          'complexity': item.complexity,
          'iupacName': item.iupacName,
          'description': item.description,
          'descriptionSource': item.descriptionSource,
          'descriptionUrl': item.descriptionUrl,
          'synonyms': item.synonyms is List ? item.synonyms : [],
          'physicalProperties': item.physicalProperties,
          'safetyData': item.safetyData,
          'biologicalData': item.biologicalData,
          'pubChemUrl': item.pubChemUrl,
          'monoisotopicMass': item.monoisotopicMass,
          'tpsa': item.tpsa,
          'charge': item.charge,
          'isotopeAtomCount': item.isotopeAtomCount,
          'covalentUnitCount': item.covalentUnitCount,
          'inchi': item.inchi,
          'inchiKey': item.inchiKey,
          'definedAtomStereoCount': item.definedAtomStereoCount,
          'undefinedAtomStereoCount': item.undefinedAtomStereoCount,
          'definedBondStereoCount': item.definedBondStereoCount,
          'undefinedBondStereoCount': item.undefinedBondStereoCount,
          'patentCount': item.patentCount,
          'patentFamilyCount': item.patentFamilyCount,
          'annotationTypes': item.annotationTypes,
          'annotationTypeCount': item.annotationTypeCount,
          'sourceCategories': item.sourceCategories,
          'literatureCount': item.literatureCount,
        },
      };
    }
    throw Exception('Unknown item type');
  }

  static dynamic _itemFromJson(Map<String, dynamic> json, String type) {
    try {
      final data = json['data'];
      switch (json['type']) {
        case 'Drug':
          return Drug(
            title: data['title'] ?? '',
            cid: data['cid'] ?? 0,
            molecularFormula: data['molecularFormula'] ?? '',
            molecularWeight: (data['molecularWeight'] is num)
                ? data['molecularWeight'].toDouble()
                : double.tryParse(data['molecularWeight']?.toString() ?? '0') ??
                    0.0,
            smiles: data['smiles'] ?? '',
            xLogP: (data['xLogP'] is num)
                ? data['xLogP'].toDouble()
                : double.tryParse(data['xLogP']?.toString() ?? '0') ?? 0.0,
            hBondDonorCount: (data['hBondDonorCount'] is num)
                ? data['hBondDonorCount']
                : int.tryParse(data['hBondDonorCount']?.toString() ?? '0') ?? 0,
            hBondAcceptorCount: (data['hBondAcceptorCount'] is num)
                ? data['hBondAcceptorCount']
                : int.tryParse(data['hBondAcceptorCount']?.toString() ?? '0') ??
                    0,
            rotatableBondCount: (data['rotatableBondCount'] is num)
                ? data['rotatableBondCount']
                : int.tryParse(data['rotatableBondCount']?.toString() ?? '0') ??
                    0,
            heavyAtomCount: (data['heavyAtomCount'] is num)
                ? data['heavyAtomCount']
                : int.tryParse(data['heavyAtomCount']?.toString() ?? '0') ?? 0,
            atomStereoCount: (data['atomStereoCount'] is num)
                ? data['atomStereoCount']
                : int.tryParse(data['atomStereoCount']?.toString() ?? '0') ?? 0,
            bondStereoCount: (data['bondStereoCount'] is num)
                ? data['bondStereoCount']
                : int.tryParse(data['bondStereoCount']?.toString() ?? '0') ?? 0,
            complexity: (data['complexity'] is num)
                ? data['complexity'].toDouble()
                : double.tryParse(data['complexity']?.toString() ?? '0') ?? 0.0,
            iupacName: data['iupacName'] ?? '',
            description: data['description'] ?? '',
            descriptionSource: data['descriptionSource'] ?? '',
            descriptionUrl: data['descriptionUrl'] ?? '',
            synonyms: data['synonyms'] is List
                ? List<String>.from(data['synonyms'])
                : <String>[],
            physicalProperties: data['physicalProperties'] is Map
                ? Map<String, dynamic>.from(data['physicalProperties'])
                : <String, dynamic>{},
            pubChemUrl: data['pubChemUrl'] ?? '',
            indication: data['indication'] ?? '',
            mechanismOfAction: data['mechanismOfAction'] ?? '',
            toxicity: data['toxicity'] ?? '',
            pharmacology: data['pharmacology'] ?? '',
            metabolism: data['metabolism'] ?? '',
            absorption: data['absorption'] ?? '',
            halfLife: data['halfLife'] ?? '',
            proteinBinding: data['proteinBinding'] ?? '',
            routeOfElimination: data['routeOfElimination'] ?? '',
            volumeOfDistribution: data['volumeOfDistribution'] ?? '',
            clearance: data['clearance'] ?? '',
            name: data['name'] ?? '',
          );
        case 'Compound':
          return Compound(
            title: data['title'] ?? '',
            cid: data['cid'] ?? 0,
            molecularFormula: data['molecularFormula'] ?? '',
            molecularWeight: (data['molecularWeight'] is num)
                ? data['molecularWeight'].toDouble()
                : double.tryParse(data['molecularWeight']?.toString() ?? '0') ??
                    0.0,
            smiles: data['smiles'] ?? '',
            xLogP: (data['xLogP'] is num)
                ? data['xLogP'].toDouble()
                : double.tryParse(data['xLogP']?.toString() ?? '0') ?? 0.0,
            hBondDonorCount: (data['hBondDonorCount'] is num)
                ? data['hBondDonorCount']
                : int.tryParse(data['hBondDonorCount']?.toString() ?? '0') ?? 0,
            hBondAcceptorCount: (data['hBondAcceptorCount'] is num)
                ? data['hBondAcceptorCount']
                : int.tryParse(data['hBondAcceptorCount']?.toString() ?? '0') ??
                    0,
            rotatableBondCount: (data['rotatableBondCount'] is num)
                ? data['rotatableBondCount']
                : int.tryParse(data['rotatableBondCount']?.toString() ?? '0') ??
                    0,
            heavyAtomCount: (data['heavyAtomCount'] is num)
                ? data['heavyAtomCount']
                : int.tryParse(data['heavyAtomCount']?.toString() ?? '0') ?? 0,
            atomStereoCount: (data['atomStereoCount'] is num)
                ? data['atomStereoCount']
                : int.tryParse(data['atomStereoCount']?.toString() ?? '0') ?? 0,
            bondStereoCount: (data['bondStereoCount'] is num)
                ? data['bondStereoCount']
                : int.tryParse(data['bondStereoCount']?.toString() ?? '0') ?? 0,
            complexity: (data['complexity'] is num)
                ? data['complexity'].toDouble()
                : double.tryParse(data['complexity']?.toString() ?? '0') ?? 0.0,
            iupacName: data['iupacName'] ?? '',
            description: data['description'] ?? '',
            descriptionSource: data['descriptionSource'] ?? '',
            descriptionUrl: data['descriptionUrl'] ?? '',
            synonyms: data['synonyms'] is List
                ? List<String>.from(data['synonyms'])
                : <String>[],
            physicalProperties: data['physicalProperties'] is Map
                ? Map<String, dynamic>.from(data['physicalProperties'])
                : <String, dynamic>{},
            safetyData: data['safetyData'] is Map
                ? Map<String, dynamic>.from(data['safetyData'])
                : <String, dynamic>{},
            biologicalData: data['biologicalData'] is Map
                ? Map<String, dynamic>.from(data['biologicalData'])
                : <String, dynamic>{},
            pubChemUrl: data['pubChemUrl'] ?? '',
            monoisotopicMass: (data['monoisotopicMass'] is num)
                ? data['monoisotopicMass'].toDouble()
                : double.tryParse(
                        data['monoisotopicMass']?.toString() ?? '0') ??
                    0.0,
            tpsa: (data['tpsa'] is num)
                ? data['tpsa'].toDouble()
                : double.tryParse(data['tpsa']?.toString() ?? '0') ?? 0.0,
            charge: (data['charge'] is num)
                ? data['charge']
                : int.tryParse(data['charge']?.toString() ?? '0') ?? 0,
            isotopeAtomCount: (data['isotopeAtomCount'] is num)
                ? data['isotopeAtomCount']
                : int.tryParse(data['isotopeAtomCount']?.toString() ?? '0') ??
                    0,
            covalentUnitCount: (data['covalentUnitCount'] is num)
                ? data['covalentUnitCount']
                : int.tryParse(data['covalentUnitCount']?.toString() ?? '0') ??
                    0,
            inchi: data['inchi'] ?? '',
            inchiKey: data['inchiKey'] ?? '',
            definedAtomStereoCount: (data['definedAtomStereoCount'] is num)
                ? data['definedAtomStereoCount']
                : int.tryParse(
                        data['definedAtomStereoCount']?.toString() ?? '0') ??
                    0,
            undefinedAtomStereoCount: (data['undefinedAtomStereoCount'] is num)
                ? data['undefinedAtomStereoCount']
                : int.tryParse(
                        data['undefinedAtomStereoCount']?.toString() ?? '0') ??
                    0,
            definedBondStereoCount: (data['definedBondStereoCount'] is num)
                ? data['definedBondStereoCount']
                : int.tryParse(
                        data['definedBondStereoCount']?.toString() ?? '0') ??
                    0,
            undefinedBondStereoCount: (data['undefinedBondStereoCount'] is num)
                ? data['undefinedBondStereoCount']
                : int.tryParse(
                        data['undefinedBondStereoCount']?.toString() ?? '0') ??
                    0,
            patentCount: (data['patentCount'] is num)
                ? data['patentCount']
                : int.tryParse(data['patentCount']?.toString() ?? '0') ?? 0,
            patentFamilyCount: (data['patentFamilyCount'] is num)
                ? data['patentFamilyCount']
                : int.tryParse(data['patentFamilyCount']?.toString() ?? '0') ??
                    0,
            annotationTypes: data['annotationTypes'] is List
                ? List<String>.from(data['annotationTypes'])
                : <String>[],
            annotationTypeCount: (data['annotationTypeCount'] is num)
                ? data['annotationTypeCount']
                : int.tryParse(
                        data['annotationTypeCount']?.toString() ?? '0') ??
                    0,
            sourceCategories: data['sourceCategories'] is List
                ? List<String>.from(data['sourceCategories'])
                : <String>[],
            literatureCount: (data['literatureCount'] is num)
                ? data['literatureCount']
                : int.tryParse(data['literatureCount']?.toString() ?? '0') ?? 0,
          );
        default:
          throw Exception('Unknown item type: ${json['type']}');
      }
    } catch (e) {
      debugPrint('Error converting bookmark data: $e');
      rethrow;
    }
  }
}

class BookmarkProvider with ChangeNotifier {
  final List<BookmarkItem> _bookmarks = [];
  static const String _bookmarksKey = 'bookmarks';
  String? _lastError;

  List<BookmarkItem> get bookmarks => _bookmarks;
  String? get lastError => _lastError;

  List<Drug> get bookmarkedDrugs => _bookmarks
      .where((item) => item.type == BookmarkType.drug)
      .map((item) => item.item as Drug)
      .toList();

  List<Compound> get bookmarkedCompounds => _bookmarks
      .where((item) => item.type == BookmarkType.compound)
      .map((item) => item.item as Compound)
      .toList();

  BookmarkProvider() {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getString(_bookmarksKey);
      if (bookmarksJson != null) {
        final List<dynamic> decodedList = jsonDecode(bookmarksJson);
        _bookmarks.clear();
        for (final json in decodedList) {
          try {
            final bookmark = BookmarkItem.fromJson(json);
            _bookmarks.add(bookmark);
          } catch (e) {
            debugPrint('Error loading a bookmark: $e');
            // Skip this bookmark but continue loading others
          }
        }
        _lastError = null;
        notifyListeners();
      }
    } catch (e) {
      _lastError = e.toString();
      debugPrint('Error loading bookmarks: $e');
    }
  }

  Future<bool> _saveBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> bookmarksList =
          _bookmarks.map((bookmark) => bookmark.toJson()).toList();
      final bookmarksJson = jsonEncode(bookmarksList);

      final result = await prefs.setString(_bookmarksKey, bookmarksJson);
      _lastError = null;
      return result;
    } catch (e) {
      _lastError = e.toString();
      debugPrint('Error saving bookmarks: $e');
      return false;
    }
  }

  Future<bool> addBookmark(dynamic item, BookmarkType type) async {
    if (!_isBookmarked(item, type)) {
      _bookmarks.add(BookmarkItem(item: item, type: type));
      final result = await _saveBookmarks();
      notifyListeners();
      return result;
    }
    return true; // Already bookmarked
  }

  Future<bool> removeBookmark(dynamic item, BookmarkType type) async {
    _bookmarks.removeWhere((bookmark) =>
        bookmark.type == type && _areItemsEqual(bookmark.item, item));
    final result = await _saveBookmarks();
    notifyListeners();
    return result;
  }

  bool isBookmarked(dynamic item, BookmarkType type) {
    return _isBookmarked(item, type);
  }

  bool _isBookmarked(dynamic item, BookmarkType type) {
    return _bookmarks.any((bookmark) =>
        bookmark.type == type && _areItemsEqual(bookmark.item, item));
  }

  bool _areItemsEqual(dynamic item1, dynamic item2) {
    if (item1 is Drug && item2 is Drug) {
      return item1.cid == item2.cid;
    } else if (item1 is Compound && item2 is Compound) {
      return item1.cid == item2.cid;
    }
    return false;
  }

  // Added method to reload bookmarks manually
  Future<void> reloadBookmarks() async {
    await _loadBookmarks();
  }

  // Added method to clear all bookmarks
  Future<bool> clearBookmarks() async {
    _bookmarks.clear();
    final result = await _saveBookmarks();
    notifyListeners();
    return result;
  }
}
