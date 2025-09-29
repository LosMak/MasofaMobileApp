import 'package:dala_ishchisi/application/bid/bid_bloc.dart';
import 'package:dala_ishchisi/application/language/language_bloc.dart';
import 'package:dala_ishchisi/application/location/location_bloc.dart';
import 'package:dala_ishchisi/common/extensions/failure_extensions.dart';
import 'package:dala_ishchisi/common/extensions/message_extensions.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/widgets/custom_hide_keyboard.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'widgets/home_appbar.dart';
import 'widgets/home_body.dart';

class MainView extends StatefulWidget {
  final String? foremanId;
  final String? workerId;
  final String? operatorId;

  const MainView({
    super.key,
    this.foremanId,
    this.workerId,
    this.operatorId,
  });

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final controller = RefreshController();
  BidStateType? bidState;
  var isListView = true;
  var tabIndex = 0;

  @override
  void initState() {
    context.read<LocationBloc>().add(const LocationEvent.init());
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<BidBloc, BidState>(
          listenWhen: (old, e) {
            if (old.archiveStatus != e.archiveStatus) {
              if (e.archiveStatus.isFail) {
                showError(context, e.archiveStatus.error);
              }
              return true;
            }
            if (old.currentArchiveUpload != e.currentArchiveUpload) {
              return true;
            }
            return old.bidsStatus != e.bidsStatus;
          },
          listener: (context, state) {
            setState(() => bidState = state.bidState);

            if (!state.archiveStatus.isInitial) {
              if (state.archiveStatus.isFail) {
                showError(context, state.bidsStatus.error);
                controller.loadComplete();
                controller.refreshCompleted();
              } else if (state.archiveStatus.isSuccess) {
                controller.loadComplete();
                controller.refreshCompleted();
              }
            }
            if (!state.bidStatus.isInitial) {
              if (state.bidsStatus.isFail) {
                showError(context, state.bidsStatus.error);
                controller.loadComplete();
                controller.refreshCompleted();
              } else if (state.bidsStatus.isSuccess) {
                controller.loadComplete();
                controller.refreshCompleted();
              }
            }
          },
        ),
      ],
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, state) {
          return CustomHideKeyboard(
            child: Scaffold(
              appBar: HomeAppBar(
                title: Words.tasks.str,
                isListView: isListView,
                bidState: bidState,
                onViewToggle: () => setState(() => isListView = !isListView),
                onTabChange: (bidState) {
                  if (bidState != null && bidState == BidStateType.archive) {
                    context
                        .read<BidBloc>()
                        .add(const BidEvent.getArchiveBids());
                  } else {
                    context.read<BidBloc>().add(
                          BidEvent.refreshBids(
                            foremanId: widget.foremanId,
                            workerId: widget.workerId,
                            operatorId: widget.operatorId,
                            bidState: bidState,
                          ),
                        );
                  }
                },
                onFilter: showRecently,
                extensions: [
                  AddictionChip(
                    id: BidStateType.archive,
                    title: Words.archive.str,
                    onSelected: (id) {
                      context
                          .read<BidBloc>()
                          .add(const BidEvent.getArchiveBids());
                    },
                  ),
                ],
              ),
              body: HomeBody(
                foremanId: widget.foremanId,
                workerId: widget.workerId,
                operatorId: widget.operatorId,
                bidState: bidState,
                isListView: isListView,
                refreshController: controller,
              ),
            ),
          );
        },
      ),
    );
  }
}
