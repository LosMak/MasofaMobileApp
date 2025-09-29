import 'dart:convert';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../di.dart';

Future<String?> pickImage({required ImageSource source}) async {
  final file = await di<ImagePicker>().pickImage(
    source: source,
    imageQuality: 70,
  );
  return file?.path;

  // if (file != null) {
  //   final position = AppGlobals.position;
  //   final now = DateTime.now();
  //   await saveImageMetadata(file.path, position, now);
  //
  //   return file.path;
  // }
  //
  // return null;
}

Future<void> saveImageMetadata(
  String imagePath,
  Position? position,
  DateTime timestamp,
) async {
  try {
    final String metadataPath = '$imagePath.meta';

    final Map<String, dynamic> metadata = {
      'originalPath': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'position': position != null
          ? {
              'latitude': position.latitude,
              'longitude': position.longitude,
              'altitude': position.altitude,
              'accuracy': position.accuracy,
              'speed': position.speed,
              'speedAccuracy': position.speedAccuracy,
              'heading': position.heading,
            }
          : null,
    };

    final File metadataFile = File(metadataPath);
    await metadataFile.writeAsString(jsonEncode(metadata));
  } catch (_) {}
}

Future<Map<String, dynamic>?> readImageMetadata(String imagePath) async {
  try {
    final String metadataPath = '$imagePath.meta';
    final File metadataFile = File(metadataPath);

    if (await metadataFile.exists()) {
      final String jsonContent = await metadataFile.readAsString();
      return jsonDecode(jsonContent) as Map<String, dynamic>;
    }
  } catch (_) {}

  return null;
}
