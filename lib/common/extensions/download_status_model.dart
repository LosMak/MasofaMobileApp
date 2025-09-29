import 'package:dala_ishchisi/domain/models/download_status_model.dart';

extension TransformationStatus on DownloadStatus {
  static DownloadStatus transform(int status) {
    return switch (status) {
      -1 => DownloadStatus.failed,
      1 => DownloadStatus.enqueued,
      2 => DownloadStatus.running,
      3 => DownloadStatus.complete,
      int() => throw UnimplementedError(),
    };
  }
}
