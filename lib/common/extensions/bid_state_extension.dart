import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';

extension BidStateTypeToString on BidStateType {
  String get value {
    return switch (this) {
      BidStateType.active => Words.active.str,
      BidStateType.created => Words.created.str,
      BidStateType.cancelled => Words.cancelled.str,
      BidStateType.finished => Words.finished.str,
      BidStateType.inProgress => Words.inProgress.str,
      BidStateType.rejected => Words.rejected.str,
      BidStateType.archive => Words.archive.str,
      BidStateType.none => '',
    };
  }
}
