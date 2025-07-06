import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class AnalyticsReaderPage extends StatefulWidget {
  const AnalyticsReaderPage({super.key});

  @override
  State<AnalyticsReaderPage> createState() => _AnalyticsReaderPageState();
}

class _AnalyticsReaderPageState extends State<AnalyticsReaderPage> {
  late File _analyticsFile;

  @override
  void initState() {
    super.initState();
    _initFile();
  }

  Future<void> _initFile() async {
    final directory = await getApplicationDocumentsDirectory();
    _analyticsFile = File('${directory.path}/analytics.json');
  }

  Future<void> saveAnalyticsData() async {
    final sampleAnalytics = {
      'propertyId': '123',
      'viewCount': 1,
      'timeSpentSeconds': 45,
      'imageUploadClicks': 2,
      'contactAgentClicks': 1,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      List<dynamic> analyticsList = [];

      if (await _analyticsFile.exists()) {
        final existing = await _analyticsFile.readAsString();
        analyticsList = json.decode(existing);
      }

      analyticsList.add(sampleAnalytics);
      await _analyticsFile.writeAsString(json.encode(analyticsList));
      print('[Analytics] Saved to ${_analyticsFile.path}');
    } catch (e) {
      print('[Error] Failed to save: $e');
    }
  }

  Future<void> readAnalyticsData() async {
    try {
      if (await _analyticsFile.exists()) {
        final contents = await _analyticsFile.readAsString();
        final data = json.decode(contents);
        print('[Analytics] Data: $data');
        _showDialog(data.toString());
      } else {
        print('[Analytics] File not found.');
        _showDialog('No analytics data found.');
      }
    } catch (e) {
      print('[Error] Read failed: $e');
      _showDialog('Error: $e');
    }
  }

  void _showDialog(String content) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Analytics Data'),
            content: SingleChildScrollView(child: Text(content)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Reader')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: saveAnalyticsData,
              child: const Text('Save Analytics Sample'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: readAnalyticsData,
              child: const Text('Read Analytics File'),
            ),
          ],
        ),
      ),
    );
  }
}
