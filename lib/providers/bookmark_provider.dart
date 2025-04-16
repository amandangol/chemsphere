import 'package:flutter/foundation.dart';
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
}

class BookmarkProvider with ChangeNotifier {
  final List<BookmarkItem> _bookmarks = [];

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

  void addBookmark(dynamic item, BookmarkType type) {
    if (!_isBookmarked(item, type)) {
      _bookmarks.add(BookmarkItem(item: item, type: type));
      notifyListeners();
    }
  }

  void removeBookmark(dynamic item, BookmarkType type) {
    _bookmarks.removeWhere((bookmark) =>
        bookmark.type == type && _areItemsEqual(bookmark.item, item));
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
