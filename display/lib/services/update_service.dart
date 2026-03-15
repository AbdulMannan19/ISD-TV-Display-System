import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:apk_sideload/install_apk.dart';

/// Auto-update service.
/// On each app launch (Android only), checks GitHub Releases for a newer APK.
/// If found, downloads it and triggers the system installer (user taps "Install" once).
class UpdateService {
  // TODO: Replace with your actual GitHub repo
  static const _repo = 'AbdulMannan19/ISD-TV-Display-System';
  static const _apiUrl = 'https://api.github.com/repos/$_repo/releases/latest';
  static const _prefKey = 'last_installed_release';

  static Future<void> checkForUpdate() async {
    if (!Platform.isAndroid) return;

    try {
      debugPrint('[Update] Checking for updates...');

      final prefs = await SharedPreferences.getInstance();
      final lastInstalled = prefs.getString(_prefKey) ?? '';

      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        debugPrint('[Update] GitHub API returned ${response.statusCode}');
        return;
      }

      final release = jsonDecode(response.body);
      final tagName = release['tag_name'] as String;
      debugPrint('[Update] Latest: $tagName, installed: $lastInstalled');

      if (tagName == lastInstalled) {
        debugPrint('[Update] Already up to date');
        return;
      }

      // Find APK asset in the release
      final assets = release['assets'] as List;
      final apkAsset = assets.cast<Map<String, dynamic>>().firstWhere(
        (a) => (a['name'] as String).endsWith('.apk'),
        orElse: () => <String, dynamic>{},
      );

      if (apkAsset.isEmpty) {
        debugPrint('[Update] No APK found in release');
        return;
      }

      final downloadUrl = apkAsset['browser_download_url'] as String;
      debugPrint('[Update] Downloading: $downloadUrl');

      // Download APK to temp directory
      final apkResponse = await http.get(Uri.parse(downloadUrl))
          .timeout(const Duration(minutes: 5));

      if (apkResponse.statusCode != 200) {
        debugPrint('[Update] Download failed: ${apkResponse.statusCode}');
        return;
      }

      final dir = await getTemporaryDirectory();
      final apkPath = '${dir.path}/display_update.apk';
      final apkFile = File(apkPath);
      await apkFile.writeAsBytes(apkResponse.bodyBytes);
      debugPrint('[Update] Downloaded ${apkResponse.bodyBytes.length} bytes to $apkPath');

      // Save the tag so we don't re-download after install
      await prefs.setString(_prefKey, tagName);

      // Trigger system installer — user sees "Install?" prompt on TV
      await InstallApk().installApk(apkPath);
      debugPrint('[Update] Install triggered for $tagName');
    } catch (e) {
      debugPrint('[Update] Error: $e');
    }
  }
}
