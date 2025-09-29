import 'package:dala_ishchisi/application/bid/bid_bloc.dart';
import 'package:dala_ishchisi/common/extensions/failure_extensions.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/common/widgets/custom_refresh.dart';
import 'package:dala_ishchisi/common/widgets/custom_shimmer_text.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dala_ishchisi/main.dart';
import 'package:dala_ishchisi/presentation/pages/main/widgets/archive_task_item.dart';
import 'package:dala_ishchisi/presentation/routes/app_router.gr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'task_item.dart';

class ListViewBody extends StatelessWidget {
  final String? foremanId;
  final String? workerId;
  final String? operatorId;
  final BidStateType? bidState;
  final RefreshController refreshController;

  const ListViewBody({
    super.key,
    required this.foremanId,
    required this.workerId,
    required this.operatorId,
    required this.bidState,
    required this.refreshController,
  });

  void onRefresh(BuildContext context) {
    context.read<BidBloc>().add(BidEvent.refreshBids(
          clearCache: true,
          foremanId: foremanId,
          workerId: workerId,
          operatorId: operatorId,
          bidState: bidState,
        ));
  }

  void onRefreshArchive(BuildContext context) {
    context.read<BidBloc>().add(const BidEvent.getArchiveBids());
  }

  void onNext(BuildContext context) {
    context.read<BidBloc>().add(const BidEvent.nextBids());
  }

  void onTaskPage(BuildContext context, BidModel model) {
    router.push(TaskRoute(bidBloc: context.read<BidBloc>(), bid: model));
  }

  void onDeleteArchivePressed(BuildContext context, BidModel bid) {
    context.read<BidBloc>().add(BidEvent.deleteArchive(bid.id));
  }

  void onSendArchivePressed(BuildContext context, BidModel bid) {
    context.read<BidBloc>().add(BidEvent.sendArchive(bid));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BidBloc, BidState>(
      builder: (context, state) {
        if (!state.bidsStatus.isInitial) {
          if (state.bidsStatus.isLoading && state.bids.isEmpty) {
            return ListView.separated(
              itemCount: 20,
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, i) => const SizedBox(height: 16),
              itemBuilder: (_, i) => const CustomShimmerText(
                height: 150,
                radius: 10,
              ),
            );
          }
          if (state.bidsStatus.isFail) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Text(
                    Words.happenError.str,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.gray.shade9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if ("${state.bidsStatus.error}".isNotEmpty)
                    Text(
                      getError(state.bidsStatus.error),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gray.shade6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  CupertinoButton(
                    minSize: 0,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      if (bidState != null &&
                          bidState == BidStateType.archive) {
                        return onRefreshArchive(context);
                      }
                      onRefresh(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                              width: 1, color: AppColors.gray.shade2),
                        ),
                      ),
                      child: Row(
                        spacing: 6,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh, color: AppColors.gray.shade9),
                          Text(
                            Words.tryAgain.str,
                            style: TextStyle(color: AppColors.gray.shade9),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          if (state.bidsStatus.isSuccess && state.bids.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Center(
                    child: Text(
                      Words.noTasks.str,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.gray.shade9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    minSize: 0,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      if (bidState != null &&
                          bidState == BidStateType.archive) {
                        return onRefreshArchive(context);
                      }
                      onRefresh(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                              width: 1, color: AppColors.gray.shade2),
                        ),
                      ),
                      child: Row(
                        spacing: 6,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh, color: AppColors.gray.shade9),
                          Text(
                            Words.update.str,
                            style: TextStyle(color: AppColors.gray.shade9),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }
        if (!state.archiveStatus.isInitial) {
          if (state.archiveStatus.isLoading && state.archives.isEmpty) {
            return ListView.separated(
              itemCount: 20,
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, i) => const SizedBox(height: 16),
              itemBuilder: (_, i) => const CustomShimmerText(
                height: 150,
                radius: 10,
              ),
            );
          }
          if (state.archiveStatus.isSuccess && state.archives.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Center(
                    child: Text(
                      Words.noTasks.str,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.gray.shade9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    minSize: 0,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      return onRefreshArchive(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                              width: 1, color: AppColors.gray.shade2),
                        ),
                      ),
                      child: Row(
                        spacing: 6,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh, color: AppColors.gray.shade9),
                          Text(
                            Words.update.str,
                            style: TextStyle(color: AppColors.gray.shade9),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return CustomRefresh(
            controller: refreshController,
            enabledNext: false,
            enabledRefresh: state.archiveStatus.isSuccess,
            onRefresh: () => onRefreshArchive(context),
            // onNext: () => onNext(context),
            child: ListView.separated(
              itemCount: state.archives.length,
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, i) => const SizedBox(height: 16),
              itemBuilder: (_, i) {
                final archive = state.archives[i];
                return ArchiveTaskItem(
                  archive: state.archives[i],
                  currentArchiveUpload: state.currentArchiveUpload,
                  onDeletePressed: () =>
                      onDeleteArchivePressed(context, archive.bid),
                  onSendPressed: () =>
                      onSendArchivePressed(context, archive.bid),
                );
              },
            ),
          );
        }
        return CustomRefresh(
          controller: refreshController,
          enabledNext: state.bidsHasNext,
          enabledRefresh: state.bidsStatus.isSuccess,
          onRefresh: () => onRefresh(context),
          onNext: () => onNext(context),
          child: ListView.separated(
            itemCount: state.bids.length,
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, i) => const SizedBox(height: 16),
            itemBuilder: (_, i) {
              return TaskItem(
                bid: state.bids[i],
                onTap: () => onTaskPage(context, state.bids[i]),
              );
            },
          ),
        );
      },
    );
  }
}
