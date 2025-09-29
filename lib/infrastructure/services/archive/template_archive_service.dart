import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dala_ishchisi/common/constants/app_globals.dart';
import 'package:dala_ishchisi/common/extensions/template_extensions.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dala_ishchisi/domain/models/template_model.dart';
import 'package:dala_ishchisi/infrastructure/services/cache/location_cache.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

@Injectable()
class TemplateArchiveService {
  final LocationCache _cache;

  const TemplateArchiveService(this._cache);

  Future<String> zipFilePath(String bidId) async {
    final dir = await getApplicationCacheDirectory();
    return "${dir.path}/bid_$bidId.zip";
  }

  Future<void> createZipFile(
    BidModel bid,
    TemplateModel template, {
    bool deleteImages = true, // ignore: need to test
  }) async {
    final newTemplate = template.updateTemplateEndDate().uploadTemplate();
    try {
      final dir = await getApplicationCacheDirectory();
      final zipFolder = Directory("${dir.path}/bid_${bid.id}");
      final zipFile = File("${dir.path}/bid_${bid.id}.zip");

      // Delete old zip file if exists and create new one
      if (await zipFolder.exists()) await zipFolder.delete(recursive: true);
      await zipFolder.create();

      // Write template json to zip folder
      await File('${zipFolder.path}/template.json')
          .writeAsString(jsonEncode(newTemplate.toJson()));

      // Write locations to zip folder
      final startDate = template.startDate;
      if (startDate != null) {
        final startTimestamp = startDate.millisecondsSinceEpoch;
        final locationsData = _cache.locations
            .where((location) =>
                location.timestamp.millisecondsSinceEpoch >= startTimestamp)
            .toList();

        if (locationsData.isNotEmpty) {
          final locationFile = File('${zipFolder.path}/track.txt');
          final buffer = StringBuffer();
          buffer.writeln('Date\tTime(UTC+0)\tLat\tLon');

          DateTime? lastAddedTime;
          const minTimeInterval = Duration(seconds: 5);

          for (final location in locationsData) {
            final currentDateTime = DateTime.fromMillisecondsSinceEpoch(
              location.timestamp.millisecondsSinceEpoch,
            ).toUtc();

            if (lastAddedTime != null) {
              final difference = currentDateTime.difference(lastAddedTime);
              if (difference < minTimeInterval) {
                continue;
              }
            }

            final formattedTime =
                DateFormat('HH:mm:ss').format(currentDateTime);
            final formattedDate =
                DateFormat('yyyy-MM-dd').format(currentDateTime);

            buffer.writeln(
              '$formattedDate $formattedTime ${location.latitude} ${location.longitude}',
            );

            lastAddedTime = currentDateTime;
          }

          await locationFile.writeAsString(buffer.toString());
        }
      }
      // Copy images to zip folder
      for (final image in template.imagePaths) {
        if (image.path.isNotEmpty) {
          final imageFile = File(image.path);
          if (await imageFile.exists()) {
            final fileName = image.name;
            final targetPath = '${zipFolder.path}/$fileName.${image.type}';
            await imageFile.copy(targetPath);
            if (deleteImages) {
              await imageFile.delete();
            }
          }
        }
      }

      // Create zip file
      final archive = createArchiveFromDirectory(
        zipFolder,
        includeDirName: false,
      );
      final zipData = ZipEncoder().encode(archive);
      await zipFile.writeAsBytes(zipData);
    } catch (_) {}
  }

  Future<double> getZipSize(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return -1;
    }

    final int sizeInBytes = await file.length();
    final double sizeInMb = sizeInBytes / (1024 * 1024);

    return double.parse(
        sizeInMb.toStringAsFixed(2)); // Округление до 2-ух знаков
  }

  Future<void> unzipFile(String bidId) async {
    final dir = await getApplicationCacheDirectory();
    final path = Directory("${dir.path}/bid_$bidId").path;
    await extractFileToDisk('$path.zip', path);
    final templateFile = File('$path/template.json');
    if (await templateFile.exists()) {
      final jsonString = await templateFile.readAsString();
      final jsonMap = json.decode(jsonString);
      final template = TemplateModel.fromJson(jsonMap);
      await _movePhoto(template, path);
    }
  }

  Future<void> _movePhoto(TemplateModel template, String pathToFolder) async {
    for (final block in template.blocks) {
      for (final step in block.steps) {
        for (var control in step.controls) {
          if (control.type != ControlType.photo) continue;
          final value = _getValue(control);
          if (value.isNotEmpty) {
            await File('$pathToFolder/$value').copy(control.resultValues);
          }
        }
      }
    }
  }

  String _getValue(ControlModel control) {
    if (control.valuesEn.isNotEmpty) {
      return control.valuesEn;
    }
    if (control.valuesRu.isNotEmpty) {
      return control.valuesRu;
    }
    if (control.valuesUz.isNotEmpty) {
      return control.valuesUz;
    }
    return '';
  }

  Future<void> deleteZipFile(String bidId) async {
    final dir = await getApplicationCacheDirectory();
    await Directory("${dir.path}/bid_$bidId").delete(recursive: true);
    await File("${dir.path}/bid_$bidId.zip").delete(recursive: true);
  }
}
