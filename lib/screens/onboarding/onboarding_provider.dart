import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider with ChangeNotifier {
  int _currentPage = 0;
  bool _isLoading = false;

  int get currentPage => _currentPage;
  bool get isLoading => _isLoading;

  // Change current page
  void setPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  // Go to next page
  void nextPage() {
    _currentPage++;
    notifyListeners();
  }

  // Go to previous page
  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
  }

  // Complete onboarding
  Future<void> completeOnboarding() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_first_time', false);
    } catch (e) {
      debugPrint('Error saving onboarding status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if it's the first time launching the app
  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_first_time') ?? true;
  }
}
