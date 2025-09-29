import 'dart:convert';
import 'dart:io';

import 'package:api_client_crop/api_client_crop.dart' as api;
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:dala_ishchisi/common/extensions/template_extensions.dart';
import 'package:dala_ishchisi/domain/facades/template_facade.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dala_ishchisi/domain/models/template_model.dart';
import 'package:dala_ishchisi/domain/models/user_info_model.dart';
import 'package:dala_ishchisi/infrastructure/mapper/template_mapper.dart';
import 'package:dala_ishchisi/infrastructure/services/archive/template_archive_service.dart';
import 'package:dala_ishchisi/infrastructure/services/cache/app_cache.dart';
import 'package:dala_ishchisi/infrastructure/services/http/services/crop_monitoring_service.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:share_plus/share_plus.dart';

@Injectable(as: TemplateFacade)
class TemplateSource implements TemplateFacade {
  final CropMonitoringService _cropMonitoring;
  final AppCache _cache;
  final TemplateArchiveService _archive;

  const TemplateSource(this._cropMonitoring, this._cache, this._archive);

  @override
  Future<Either<dynamic, TemplateModel>> template(
    String cropId, {
    required bool requiredRemote,
  }) async {
    final client = _cropMonitoring
        .client(
          requiredToken: true,
          requiredRemote: requiredRemote,
        )
        .getBidTemplatesApi();

    try {
      final filter = api.FieldFilterModel(
        (b) => b
          ..filterField = 'CropId'
          ..filterValue = JsonObject(cropId)
          ..filterOperator = api.FilterOperatorModel.number0,
      );
      final model = api.BidTemplateBaseGetQueryModel(
        (b) => b..filters = ListBuilder([filter]),
      );
      final response = await client.cropMonitoringBidTemplatesGetByQueryPost(
          bidTemplateBaseGetQueryModel: model);
      final result = TemplateMapper.transformList(response.data);
      if (result.isEmpty) {
        throw Exception('Template not found');
      }
      return right(result.first);
    } catch (e) {
      return left(e);
    }
  }

  Future<Map<String, dynamic>> _loadMockData(String path) async {
    final responseAsString = await rootBundle.loadString(path);
    return json.decode(responseAsString) as Map<String, dynamic>;
  }

  @override
  Future<Either<dynamic, void>> deleteTemplate(String bidId) async {
    await _cache.deleteTemplate(bidId);
    return right(null);
  }

  @override
  Future<Either<dynamic, void>> uploadTemplateByBid(
    BidModel bid, {
    Function(int sent, int total)? onSendProgress,
  }) async {
    final zipPath = await _archive.zipFilePath(bid.id);

    final client = _cropMonitoring
        .client(
          requiredToken: true,
          requiredRemote: true,
        )
        .getBidApi();

    try {
      await client.cropMonitoringBidSaveResultBidIdPost(
        bidId: bid.id,
        bidResultFile: await MultipartFile.fromFile(
          zipPath,
          filename: 'bid_${bid.id}.zip',
          contentType: DioMediaType('application', 'zip'),
        ),
        headers: {
          'Accept': 'application/json',
        },
        onSendProgress: onSendProgress,
      );

      return right(null);
    } catch (e) {
      _archive.unzipFile(bid.id);
      return left(e);
    }
  }

  @override
  Future<Either<dynamic, void>> uploadTemplate(
    BidModel bid,
    TemplateModel template, {
    Function(int sent, int total)? onSendProgress,
  }) async {
    await _archive.createZipFile(bid, template);
    final zipPath = await _archive.zipFilePath(bid.id);

    final client = _cropMonitoring
        .client(
          requiredToken: true,
          requiredRemote: true,
        )
        .getBidApi();

    try {
      await client.cropMonitoringBidSaveResultBidIdPost(
        bidId: bid.id,
        bidResultFile: await MultipartFile.fromFile(
          zipPath,
          filename: 'bid_${bid.id}.zip',
          contentType: DioMediaType('application', 'zip'),
        ),
        headers: {
          'Accept': 'text/plain',
        },
        onSendProgress: onSendProgress,
      );

      return right(null);
    } catch (e) {
      await _archive.unzipFile(bid.id);
      return left(e);
    }
  }

  @override
  Future<Either<dynamic, void>> shareTemplate(
    BidModel bid,
    TemplateModel template,
  ) async {
    await _archive.createZipFile(bid, template, deleteImages: false);
    final zipPath = await _archive.zipFilePath(bid.id);

    final file = File(zipPath);
    if (await file.exists()) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(zipPath)],
          text: 'Template zip file for bid ${bid.id}',
        ),
      );
    }

    return right(null);
  }

  @override
  Future<Either<dynamic, TemplateModel>> templateCache(String bidId) async {
    try {
      final result = _cache.template(bidId);
      return right(result);
    } catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<dynamic, void>> putTemplateCache(
    UserInfoModel user,
    BidModel bid,
    TemplateModel template,
  ) async {
    try {
      final newTemplate = template.updateTemplateCache(user: user, bid: bid);
      await _cache.setTemplate(bid.id, newTemplate);
      return right(null);
    } catch (e) {
      return left(e);
    }
  }
}
