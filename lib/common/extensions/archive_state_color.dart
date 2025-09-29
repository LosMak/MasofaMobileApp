import 'dart:ui';

import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/domain/models/archive_model.dart';

extension ArchiveStatus on ArchiveModel {
  static String archiveStatus(ArchiveSendStatus status) {
    return switch (status) {
      ArchiveSendStatus.sent => Words.archiveStatusSent.str,
      ArchiveSendStatus.unsent => Words.archiveStatusNotSent.str,
      _ => '',
    };
  }

  static Color archiveTextColor(ArchiveSendStatus status) {
    return switch (status) {
      ArchiveSendStatus.sent => const Color(0xFF22C55E),
      ArchiveSendStatus.unsent => const Color(0xFFAE590A),
      _ => AppColors.gray.shade7,
    };
  }

  static Color archiveChipColor(ArchiveSendStatus status) {
    return switch (status) {
      ArchiveSendStatus.sent => const Color(0xFFBBF7D0),
      ArchiveSendStatus.unsent => const Color(0xFFFDEAD8),
      _ => AppColors.gray.shade2,
    };
  }
}
