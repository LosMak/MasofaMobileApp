import 'dart:convert';
import 'dart:io';

import 'package:dala_ishchisi/domain/facades/archive_facade.dart';
import 'package:dala_ishchisi/domain/models/archive_model.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dala_ishchisi/domain/models/template_model.dart';
import 'package:dala_ishchisi/infrastructure/services/archive/template_archive_service.dart';
import 'package:dala_ishchisi/infrastructure/services/cache/archive_cache.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

@Injectable(as: ArchiveFacade)
class ArchiveDatasource implements ArchiveFacade {
  final ArchiveCache _cache;
  final TemplateArchiveService _archive;

  const ArchiveDatasource(this._cache, this._archive);

  @override
  Future<ArchiveModel> create(BidModel bid, TemplateModel template) async {
    await _archive.createZipFile(bid, template, deleteImages: false);
    final zipFile = await _getPathToZipFile(bid.id);

    final size = await _archive.getZipSize(zipFile);

    final archive = ArchiveModel(
      bid: bid,
      template: template,
      id: bid.id,
      status: ArchiveSendStatus.unsent,
      path: zipFile,
      size: size,
    );
    await _cache.setArchive(bid.id, jsonEncode(archive.toJson()));
    return archive;
  }

  @override
  Future<void> updateStatus(ArchiveModel archive) async {
    final updatedArchive = archive.copyWith(status: ArchiveSendStatus.sent);
    await _cache.setArchive(
        archive.bid.id, jsonEncode(updatedArchive.toJson()));
  }

  @override
  Future<void> delete(String bidId) async {
    await _cache.deleteArchive(bidId);
  }

  @override
  Future<List<ArchiveModel>> fetchAll() async {
    final rawArchives = await _cache.getArchives();
    final values = rawArchives.values.toList();
    final data = List.generate(
      values.length,
      (index) => ArchiveModel.fromJson(jsonDecode(values[index])),
    );
    return data;
  }

  Future<String> _getPathToZipFile(String bidId) async {
    final dir = await getApplicationCacheDirectory();
    final zipFile = File("${dir.path}/bid_$bidId.zip");
    return zipFile.path;
  }
}
