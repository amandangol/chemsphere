import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/drug.dart';
import '../models/compound.dart';
import '../models/molecular_structure.dart';

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
    return BookmarkItem(
      type: BookmarkType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      item: _itemFromJson(json['item'], json['type']),
    );
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
          'synonyms': item.synonyms,
          'physicalProperties': item.physicalProperties,
          'pubChemUrl': item.pubChemUrl,
          'monoisotopicMass': item.monoisotopicMass,
          'tpsa': item.tpsa,
          'charge': item.charge,
          'isotopeAtomCount': item.isotopeAtomCount,
          'covalentUnitCount': item.covalentUnitCount,
          'inchi': item.inchi,
          'inchiKey': item.inchiKey,
        },
      };
    } else if (item is MolecularStructure) {
      return {
        'type': 'MolecularStructure',
        'data': {
          'title': item.title,
          'cid': item.cid,
          'molecularFormula': item.molecularFormula,
          'molecularWeight': item.molecularWeight,
          'smiles': item.smiles,
          'inchi': item.inchi,
          'inchiKey': item.inchiKey,
          'iupacName': item.iupacName,
          'xLogP': item.xLogP,
          'complexity': item.complexity,
          'hBondDonorCount': item.hBondDonorCount,
          'hBondAcceptorCount': item.hBondAcceptorCount,
          'rotatableBondCount': item.rotatableBondCount,
          'heavyAtomCount': item.heavyAtomCount,
          'atomStereoCount': item.atomStereoCount,
          'bondStereoCount': item.bondStereoCount,
        },
      };
    }
    throw Exception('Unknown item type');
  }

  static dynamic _itemFromJson(Map<String, dynamic> json, String type) {
    final data = json['data'];
    switch (json['type']) {
      case 'Drug':
        return Drug(
          title: data['title'],
          cid: data['cid'],
          molecularFormula: data['molecularFormula'],
          molecularWeight: data['molecularWeight'],
          smiles: data['smiles'],
          xLogP: data['xLogP'],
          hBondDonorCount: data['hBondDonorCount'],
          hBondAcceptorCount: data['hBondAcceptorCount'],
          rotatableBondCount: data['rotatableBondCount'],
          heavyAtomCount: data['heavyAtomCount'],
          atomStereoCount: data['atomStereoCount'],
          bondStereoCount: data['bondStereoCount'],
          complexity: data['complexity'],
          iupacName: data['iupacName'],
          description: data['description'],
          descriptionSource: data['descriptionSource'],
          descriptionUrl: data['descriptionUrl'],
          synonyms: data['synonyms'],
          physicalProperties: data['physicalProperties'],
          pubChemUrl: data['pubChemUrl'],
          indication: data['indication'],
          mechanismOfAction: data['mechanismOfAction'],
          toxicity: data['toxicity'],
          pharmacology: data['pharmacology'],
          metabolism: data['metabolism'],
          absorption: data['absorption'],
          halfLife: data['halfLife'],
          proteinBinding: data['proteinBinding'],
          routeOfElimination: data['routeOfElimination'],
          volumeOfDistribution: data['volumeOfDistribution'],
          clearance: data['clearance'],
          name: data['name'],
        );
      case 'Compound':
        return Compound(
          title: data['title'],
          cid: data['cid'],
          molecularFormula: data['molecularFormula'],
          molecularWeight: data['molecularWeight'],
          smiles: data['smiles'],
          xLogP: data['xLogP'],
          hBondDonorCount: data['hBondDonorCount'],
          hBondAcceptorCount: data['hBondAcceptorCount'],
          rotatableBondCount: data['rotatableBondCount'],
          heavyAtomCount: data['heavyAtomCount'],
          atomStereoCount: data['atomStereoCount'],
          bondStereoCount: data['bondStereoCount'],
          complexity: data['complexity'],
          iupacName: data['iupacName'],
          description: data['description'],
          descriptionSource: data['descriptionSource'],
          descriptionUrl: data['descriptionUrl'],
          synonyms: data['synonyms'],
          physicalProperties: data['physicalProperties'],
          pubChemUrl: data['pubChemUrl'],
          monoisotopicMass: data['monoisotopicMass'],
          tpsa: data['tpsa'],
          charge: data['charge'],
          isotopeAtomCount: data['isotopeAtomCount'],
          covalentUnitCount: data['covalentUnitCount'],
          inchi: data['inchi'],
          inchiKey: data['inchiKey'],
        );
      case 'MolecularStructure':
        return MolecularStructure(
          title: data['title'],
          cid: data['cid'],
          molecularFormula: data['molecularFormula'],
          molecularWeight: data['molecularWeight'],
          smiles: data['smiles'],
          inchi: data['inchi'],
          inchiKey: data['inchiKey'],
          iupacName: data['iupacName'],
          xLogP: data['xLogP'],
          complexity: data['complexity'],
          hBondDonorCount: data['hBondDonorCount'],
          hBondAcceptorCount: data['hBondAcceptorCount'],
          rotatableBondCount: data['rotatableBondCount'],
          heavyAtomCount: data['heavyAtomCount'],
          atomStereoCount: data['atomStereoCount'],
          bondStereoCount: data['bondStereoCount'],
        );
      default:
        throw Exception('Unknown item type');
    }
  }
}

class BookmarkProvider with ChangeNotifier {
  final List<BookmarkItem> _bookmarks = [];
  static const String _bookmarksKey = 'bookmarks';

  List<BookmarkItem> get bookmarks => _bookmarks;

  List<Drug> get bookmarkedDrugs => _bookmarks
      .where((item) => item.type == BookmarkType.drug)
      .map((item) => item.item as Drug)
      .toList();

  List<Compound> get bookmarkedCompounds => _bookmarks
      .where((item) => item.type == BookmarkType.compound)
      .map((item) => item.item as Compound)
      .toList();

  List<MolecularStructure> get bookmarkedMolecularStructures => _bookmarks
      .where((item) => item.type == BookmarkType.molecularStructure)
      .map((item) => item.item as MolecularStructure)
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
          final bookmark = BookmarkItem.fromJson(json);
          _bookmarks.add(bookmark);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
    }
  }

  Future<void> _saveBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson =
          jsonEncode(_bookmarks.map((bookmark) => bookmark.toJson()).toList());
      await prefs.setString(_bookmarksKey, bookmarksJson);
    } catch (e) {
      debugPrint('Error saving bookmarks: $e');
    }
  }

  void addBookmark(dynamic item, BookmarkType type) {
    if (!_isBookmarked(item, type)) {
      _bookmarks.add(BookmarkItem(item: item, type: type));
      _saveBookmarks();
      notifyListeners();
    }
  }

  void removeBookmark(dynamic item, BookmarkType type) {
    _bookmarks.removeWhere((bookmark) =>
        bookmark.type == type && _areItemsEqual(bookmark.item, item));
    _saveBookmarks();
    notifyListeners();
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
    } else if (item1 is MolecularStructure && item2 is MolecularStructure) {
      return item1.cid == item2.cid;
    }
    return false;
  }
}
