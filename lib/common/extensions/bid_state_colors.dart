import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:flutter/material.dart';

Color bidStateTextColor(BidStateType type) {
  switch (type) {
    case BidStateType.created:
      return AppColors.green.shade5;
    case BidStateType.active:
      return AppColors.blue.shade5;
    case BidStateType.inProgress:
      return AppColors.indigo.shade5;
    case BidStateType.finished:
      return AppColors.teal.shade6;
    case BidStateType.rejected:
      return AppColors.red.shade6;
    case BidStateType.cancelled:
      return AppColors.orange.shade6;
    default:
      return AppColors.gray.shade7;
  }
}

Color bidStateBGColor(BidStateType type) {
  switch (type) {
    case BidStateType.created:
      return AppColors.green.shade2;
    case BidStateType.active:
      return AppColors.blue.shade2;
    case BidStateType.inProgress:
      return AppColors.indigo.shade2;
    case BidStateType.finished:
      return AppColors.teal.shade2;
    case BidStateType.rejected:
      return AppColors.red.shade2;
    case BidStateType.cancelled:
      return AppColors.orange.shade2;
    default:
      return AppColors.gray.shade2;
  }
}
