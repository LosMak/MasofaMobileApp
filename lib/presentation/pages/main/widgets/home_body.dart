import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'calendar_view_body.dart';
import 'list_view_body.dart';

class HomeBody extends StatelessWidget {
  final String? foremanId;
  final String? workerId;
  final String? operatorId;
  final BidStateType? bidState;
  final RefreshController refreshController;
  final bool isListView;

  const HomeBody({
    super.key,
    required this.foremanId,
    required this.workerId,
    required this.operatorId,
    required this.bidState,
    required this.refreshController,
    required this.isListView,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: isListView
          ? ListViewBody(
              foremanId: foremanId,
              workerId: workerId,
              operatorId: operatorId,
              bidState: bidState,
              refreshController: refreshController,
            )
          : const CalendarViewBody(),
    );
  }
}
