// ignore_for_file: public_member_api_docs, sort_constructors_first
enum DownloadStatus {
  undefined,
  enqueued,
  running,
  complete,
  canceled,
  paused,
  failed,
}

class DownloadStatusModel {
  final String taskId;
  final String filename;
  final String ext;
  final double progress;
  final DownloadStatus status;
  final String path;

  DownloadStatusModel({
    required this.taskId,
    required this.filename,
    required this.ext,
    this.progress = 0.0,
    required this.status,
    this.path = '',
  });

  DownloadStatusModel copyWith({
    String? taskId,
    String? filename,
    String? ext,
    double? progress,
    DownloadStatus? status,
    String? path,
  }) {
    return DownloadStatusModel(
      taskId: taskId ?? this.taskId,
      filename: filename ?? this.filename,
      ext: ext ?? this.ext,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      path: path ?? this.path,
    );
  }

  @override
  bool operator ==(covariant DownloadStatusModel other) {
    if (identical(this, other)) return true;

    return other.taskId == taskId &&
        other.filename == filename &&
        other.ext == ext &&
        other.progress == progress &&
        other.status == status &&
        other.path == path;
  }

  @override
  int get hashCode {
    return taskId.hashCode ^
        filename.hashCode ^
        ext.hashCode ^
        progress.hashCode ^
        status.hashCode ^
        path.hashCode;
  }
}
