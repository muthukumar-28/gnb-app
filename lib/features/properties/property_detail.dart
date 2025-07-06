import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class PropertyDetailPage extends StatefulWidget {
  final Map<String, dynamic> property;

  const PropertyDetailPage({super.key, required this.property});

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  File? _pickedImage;

  late DateTime _startTime;
  late String _propertyId;

  int _imageUploadClicks = 0;
  int _contactAgentClicks = 0;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _propertyId = widget.property['id']?.toString() ?? 'unknown';

    print('[Analytics] Viewed property: $_propertyId');
  }

  @override
  void dispose() {
    final duration = DateTime.now().difference(_startTime);

    final analyticsData = {
      'propertyId': _propertyId,
      'viewCount': 1,
      'timeSpentSeconds': duration.inSeconds,
      'imageUploadClicks': _imageUploadClicks,
      'contactAgentClicks': _contactAgentClicks,
    };

    _saveAnalyticsData(analyticsData);

    super.dispose();
  }

  Future<void> _saveAnalyticsData(Map<String, dynamic> data) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/analytics.json';
      final file = File(filePath);

      Map<String, dynamic> existingData = {};
      if (await file.exists()) {
        final contents = await file.readAsString();
        existingData = jsonDecode(contents);
      }

      existingData[_propertyId] = data;

      await file.writeAsString(jsonEncode(existingData), flush: true);
      print('[Analytics] Data saved to $filePath');
    } catch (e) {
      print('[Analytics] Error saving data: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });

      _imageUploadClicks++;
      print('[Analytics] Image upload clicked ($_imageUploadClicks times)');
    }
  }

  void _contactAgent() {
    _contactAgentClicks++;
    print('[Analytics] Contact Agent clicked ($_contactAgentClicks times)');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Contact Agent tapped')));
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final location = property['location'] ?? {};
    final agent = property['agent'] ?? {};

    return Scaffold(
      appBar: AppBar(title: Text(property['title'] ?? 'Property Detail')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_pickedImage != null)
              Image.file(
                _pickedImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            else if (property['images'] != null &&
                property['images'].isNotEmpty)
              SizedBox(
                height: 200,
                child: PageView(
                  children:
                      (property['images'] as List<dynamic>)
                          .map<Widget>(
                            (url) => Image.network(url, fit: BoxFit.cover),
                          )
                          .toList(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Upload from Gallery'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    property['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${property['bedrooms']} Beds • ${property['bathrooms']} Baths • ${property['areaSqFt']} sqft',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${property['currency'] ?? ''} ${(property['price'] ?? 0).toStringAsFixed(0)}',
                  ),
                  const SizedBox(height: 8),
                  Text(property['description'] ?? ''),
                  const SizedBox(height: 16),
                  const Text(
                    'Location:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${location['address'] ?? ''}, ${location['city'] ?? ''}, ${location['state'] ?? ''}, ${location['country'] ?? ''}',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Agent Info:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(agent['name'] ?? ''),
                  Text('Email: ${agent['email'] ?? ''}'),
                  Text('Phone: ${agent['contact'] ?? ''}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _contactAgent,
                    child: const Text('Contact Agent'),
                  ),
                  const SizedBox(height: 16),
                  if (property['tags'] != null &&
                      (property['tags'] as List).isNotEmpty) ...[
                    const Text(
                      'Tags:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8,
                      children:
                          (property['tags'] as List<dynamic>)
                              .map<Widget>((tag) => Chip(label: Text(tag)))
                              .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
