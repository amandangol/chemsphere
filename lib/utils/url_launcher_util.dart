import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'snackbar_util.dart';

/// A utility class for launching URLs, phone calls, emails, and maps
class UrlLauncherUtil {
  /// Launches a URL in the default browser
  static Future<void> launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        SnackbarUtil.showErrorSnackBar(
          context,
          'Could not launch URL: $url',
        );
      }
    } catch (e) {
      SnackbarUtil.showErrorSnackBar(
        context,
        'Error launching URL: ${e.toString()}',
      );
    }
  }

  /// Makes a phone call
  static Future<void> makePhoneCall(
      BuildContext context, String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        SnackbarUtil.showErrorSnackBar(
          context,
          'Could not make call to: $phoneNumber',
        );
      }
    } catch (e) {
      SnackbarUtil.showErrorSnackBar(
        context,
        'Error making call: ${e.toString()}',
      );
    }
  }

  /// Sends an email
  static Future<void> sendEmail(
    BuildContext context, {
    required String email,
    String subject = '',
    String body = '',
  }) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        SnackbarUtil.showErrorSnackBar(
          context,
          'Could not send email to: $email',
        );
      }
    } catch (e) {
      SnackbarUtil.showErrorSnackBar(
        context,
        'Error sending email: ${e.toString()}',
      );
    }
  }

  /// Opens a location in maps
  static Future<void> openMap(
    BuildContext context, {
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final query =
        label != null ? '$latitude,$longitude($label)' : '$latitude,$longitude';
    final Uri uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        SnackbarUtil.showErrorSnackBar(
          context,
          'Could not open maps',
        );
      }
    } catch (e) {
      SnackbarUtil.showErrorSnackBar(
        context,
        'Error opening maps: ${e.toString()}',
      );
    }
  }
}
