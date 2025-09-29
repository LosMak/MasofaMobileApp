import 'package:dala_ishchisi/domain/models/archive_model.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dala_ishchisi/domain/models/template_model.dart';

abstract class ArchiveFacade {
  Future<List<ArchiveModel>> fetchAll();
  Future<ArchiveModel> create(BidModel bid, TemplateModel template);
  Future<void> delete(String bidId);
  Future<void> updateStatus(ArchiveModel archive);
}
