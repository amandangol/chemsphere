import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';

/// Utility class to handle errors in a consistent way across the app
class ErrorHandler {
  /// Get a user-friendly error message based on the type of error
  static String getErrorMessage(dynamic error) {
    // Handle socket exceptions (network issues)
    if (error is SocketException) {
      return 'Network connection error. Please check your internet connection and try again.';
    }

    // Handle timeout errors
    if (error is TimeoutException) {
      return 'Request timed out. Please try again later.';
    }

    // Handle HTTP status codes
    if (error is HttpException || error.toString().contains('HttpException')) {
      final errorString = error.toString().toLowerCase();

      if (errorString.contains('404') || errorString.contains('not found')) {
        return 'The requested resource was not found. Please try again later.';
      }

      if (errorString.contains('500') ||
          errorString.contains('internal server error')) {
        return 'Server error. Please try again later.';
      }

      if (errorString.contains('503') ||
          errorString.contains('service unavailable')) {
        return 'Service temporarily unavailable. Please try again later.';
      }

      if (errorString.contains('401') || errorString.contains('unauthorized')) {
        return 'Unauthorized access. Please log in again.';
      }

      if (errorString.contains('403') || errorString.contains('forbidden')) {
        return 'Access forbidden. You don\'t have permission to access this resource.';
      }

      if (errorString.contains('429') ||
          errorString.contains('too many requests')) {
        return 'Too many requests. Please try again later.';
      }

      if (errorString.contains('502') || errorString.contains('bad gateway')) {
        return 'Bad gateway error. Please try again later.';
      }

      if (errorString.contains('504') ||
          errorString.contains('gateway timeout')) {
        return 'Gateway timeout. Please try again later.';
      }

      // Generic HTTP error
      return 'Network error. Please try again later.';
    }

    // Handle format exceptions
    if (error is FormatException) {
      return 'Data format error. Please try again later.';
    }

    // Handle other errors
    if (error is Error) {
      // Only show detailed error in debug mode
      assert(() {
        debugPrint('Error details: $error');
        return true;
      }());
      return 'An unexpected error occurred. Please try again.';
    }

    // Default error message
    return error?.toString() ?? 'An unknown error occurred. Please try again.';
  }

  /// Create an error widget to display in place of content
  static Widget buildErrorWidget({
    required String errorMessage,
    required VoidCallback onRetry,
    Color? iconColor,
    IconData icon = Icons.error_outline,
    double iconSize = 60,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor ?? Colors.red,
              size: iconSize,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Checks if the error is related to network connectivity
  static bool isNetworkError(dynamic error) {
    return error is SocketException ||
        error.toString().contains('SocketException') ||
        error.toString().contains('Failed host lookup');
  }

  /// Shows a snackbar with the error message
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
