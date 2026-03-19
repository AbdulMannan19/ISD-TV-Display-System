import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:apk_sideload/install_apk.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _repo = 'AbdulMannan19/ISD-TV-Display-System';
  static const _apiUrl = 'https://api.github.com/repos/$_repo/releases/latest';
  static const _prefKey = 'last_installed_release';

  String _status = '';
  String _currentVersion = '';
  String _latestVersion = '';
  String _downloadUrl = '';
  bool _checking = false;
  bool _downloading = false;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentVersion();
  }

  Future<void> _loadCurrentVersion() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentVersion = prefs.getString(_prefKey) ?? 'Unknown';
    });
  }

  Future<void> _checkForUpdate() async {
    setState(() { _checking = true; _status = ''; _latestVersion = ''; _downloadUrl = ''; });

    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        setState(() { _status = 'Failed to check (HTTP ${response.statusCode})'; _checking = false; });
        return;
      }

      final release = jsonDecode(response.body);
      final tagName = release['tag_name'] as String;
      setState(() => _latestVersion = tagName);

      if (tagName == _currentVersion) {
        setState(() { _status = 'up_to_date'; _checking = false; });
        return;
      }

      final assets = release['assets'] as List;
      final apkAsset = assets.cast<Map<String, dynamic>>().firstWhere(
        (a) => (a['name'] as String).endsWith('.apk'),
        orElse: () => <String, dynamic>{},
      );

      if (apkAsset.isEmpty) {
        setState(() { _status = 'No APK found in latest release'; _checking = false; });
        return;
      }

      setState(() {
        _downloadUrl = apkAsset['browser_download_url'] as String;
        _status = 'update_available';
        _checking = false;
      });
    } catch (e) {
      setState(() { _status = 'Error: $e'; _checking = false; });
    }
  }

  Future<void> _downloadAndInstall() async {
    if (_downloadUrl.isEmpty || !Platform.isAndroid) return;
    setState(() { _downloading = true; _progress = 0; });

    try {
      final response = await http.get(Uri.parse(_downloadUrl))
          .timeout(const Duration(minutes: 5));

      if (response.statusCode != 200) {
        setState(() { _status = 'Download failed'; _downloading = false; });
        return;
      }

      setState(() => _progress = 0.8);

      final dir = await getTemporaryDirectory();
      final apkPath = '${dir.path}/display_update.apk';
      await File(apkPath).writeAsBytes(response.bodyBytes);

      setState(() => _progress = 1.0);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, _latestVersion);
      await InstallApk().installApk(apkPath);

      setState(() { _status = 'Install triggered'; _downloading = false; _currentVersion = _latestVersion; });
    } catch (e) {
      setState(() { _status = 'Error: $e'; _downloading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF000428), Color(0xFF004E92), Color(0xFF001F54)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Text('Settings',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    width: 500,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mosque, size: 48, color: Colors.white.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        const Text('ISD Prayer Times',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('Installed: $_currentVersion',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
                        const SizedBox(height: 32),
                        _buildUpdateSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateSection() {
    if (_checking) {
      return Column(
        children: [
          const SizedBox(height: 8, width: 8, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
          const SizedBox(height: 12),
          Text('Checking for updates...', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
        ],
      );
    }

    if (_downloading) {
      return Column(
        children: [
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(value: _progress > 0 ? _progress : null, color: Colors.greenAccent, backgroundColor: Colors.white12),
          ),
          const SizedBox(height: 12),
          Text('Downloading update...', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
        ],
      );
    }

    if (_status == 'up_to_date') {
      return Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.greenAccent, size: 40),
          const SizedBox(height: 12),
          const Text('You\'re up to date', style: TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Version $_latestVersion', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
          const SizedBox(height: 20),
          _checkButton(),
        ],
      );
    }

    if (_status == 'update_available') {
      return Column(
        children: [
          const Icon(Icons.system_update, color: Colors.amberAccent, size: 40),
          const SizedBox(height: 12),
          Text('Update available: $_latestVersion',
            style: const TextStyle(color: Colors.amberAccent, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          if (Platform.isAndroid)
            ElevatedButton.icon(
              onPressed: _downloadAndInstall,
              icon: const Icon(Icons.download),
              label: const Text('Download & Install'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )
          else
            Text('Updates are only available on Android',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
        ],
      );
    }

    if (_status.isNotEmpty && !_status.startsWith('up_to_date') && !_status.startsWith('update_available')) {
      return Column(
        children: [
          Icon(Icons.error_outline, color: Colors.redAccent.shade100, size: 40),
          const SizedBox(height: 12),
          Text(_status, textAlign: TextAlign.center,
            style: TextStyle(color: Colors.redAccent.shade100, fontSize: 14)),
          const SizedBox(height: 20),
          _checkButton(),
        ],
      );
    }

    return _checkButton();
  }

  Widget _checkButton() {
    return ElevatedButton.icon(
      onPressed: _checkForUpdate,
      icon: const Icon(Icons.refresh),
      label: const Text('Check for Updates'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.12),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
    );
  }
}
