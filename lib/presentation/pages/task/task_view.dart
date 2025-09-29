import 'package:dala_ishchisi/application/auth/auth_bloc.dart';
import 'package:dala_ishchisi/application/bid/bid_bloc.dart';
import 'package:dala_ishchisi/application/template/template_bloc.dart';
import 'package:dala_ishchisi/application/user/user_bloc.dart';
import 'package:dala_ishchisi/common/extensions/failure_extensions.dart';
import 'package:dala_ishchisi/common/extensions/message_extensions.dart';
import 'package:dala_ishchisi/common/extensions/template_extensions.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/widgets/custom_refresh.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dala_ishchisi/domain/models/user_info_model.dart';
import 'package:dala_ishchisi/infrastructure/services/http/interceptors/exception_interceptor.dart';
import 'package:dala_ishchisi/presentation/pages/task/widgets/region_inherited_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'widgets/action_buttons.dart';
import 'widgets/status_list.dart';
import 'widgets/task_appbar.dart';
import 'widgets/task_location.dart';
import 'widgets/task_main_info.dart';
import 'widgets/task_worker.dart';
import 'widgets/template_button.dart';

class TaskView extends StatefulWidget {
  final BidModel bid;

  const TaskView({super.key, required this.bid});

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  late final user = context.read<AuthBloc>().state.userInfo;
  final controller = RefreshController();
  var workerId = '';

  @override
  void initState() {
    loadData();
    super.initState();
  }

  Future<void> loadData() async {
    context
        .read<BidBloc>()
        .add(BidEvent.bid(bid: widget.bid, id: widget.bid.id));
    if (user.role.contains(UserRole.foreman)) {
      if (context.read<UserBloc>().state.users.isEmpty) {
        context.read<UserBloc>().add(UserEvent.users(parentId: user.id));
      }
    }
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
          listenWhen: (old, e) => old.bidsStatus != e.bidsStatus,
          listener: (context, state) {
            if (EasyLoading.isShow) EasyLoading.dismiss();

            if (state.bidsStatus.isLoading) {
              EasyLoading.show();
            }
          },
        ),
        BlocListener<BidBloc, BidState>(
          listenWhen: (old, e) =>
              old.bidStatus != e.bidStatus && workerId != e.bid.workerId,
          listener: (context, state) {
            if (EasyLoading.isShow) EasyLoading.dismiss();

            if (state.bidStatus.isFail) {
              showError(context, state.bidStatus.error);
            } else if (state.bidStatus.isLoading) {
              EasyLoading.show();
            } else if (state.bidStatus.isSuccess) {
              workerId = state.bid.workerId;
              setState(() {});
              if (context
                  .read<TemplateBloc>()
                  .state
                  .templateCache
                  .blocks
                  .isEmpty) {
                context
                    .read<TemplateBloc>()
                    .add(TemplateEvent.templateCache(bidId: state.bid.id));
              }
            }
          },
        ),
        BlocListener<BidBloc, BidState>(
          listenWhen: (old, e) =>
              old.updateWorkerStatus != e.updateWorkerStatus,
          listener: (context, state) {
            if (EasyLoading.isShow) EasyLoading.dismiss();

            if (state.updateWorkerStatus.isFail) {
              showError(context, state.updateWorkerStatus.error);
            } else if (state.updateWorkerStatus.isLoading) {
              EasyLoading.show();
            } else if (state.updateWorkerStatus.isFail) {
              EasyLoading.show();
            } else if (state.updateWorkerStatus.isSuccess) {
              context.read<BidBloc>().add(
                    BidEvent.bid(
                      bid: state.bid,
                      id: state.bid.id,
                      clearCache: true,
                    ),
                  );
            }
          },
        ),
        BlocListener<BidBloc, BidState>(
          listenWhen: (old, e) => old.cancelBidStatus != e.cancelBidStatus,
          listener: (context, state) {
            if (EasyLoading.isShow) EasyLoading.dismiss();

            if (state.cancelBidStatus.isFail) {
              showError(context, state.cancelBidStatus.error);
            } else if (state.cancelBidStatus.isLoading) {
              EasyLoading.show();
            } else if (state.cancelBidStatus.isFail) {
              EasyLoading.show();
            } else if (state.cancelBidStatus.isSuccess) {
              context.read<BidBloc>().add(
                    BidEvent.bid(
                      bid: state.bid,
                      id: state.bid.id,
                      clearCache: true,
                    ),
                  );
            }
          },
        ),
        BlocListener<BidBloc, BidState>(
          listenWhen: (old, e) =>
              old.updateWorkerStatus != e.updateWorkerStatus,
          listener: (context, state) {
            if (EasyLoading.isShow) EasyLoading.dismiss();

            if (state.updateWorkerStatus.isFail) {
              showError(context, state.updateWorkerStatus.error);
            } else if (state.updateWorkerStatus.isLoading) {
              EasyLoading.show();
            } else if (state.updateWorkerStatus.isFail) {
              EasyLoading.show();
            } else if (state.updateWorkerStatus.isSuccess) {
              context.read<BidBloc>().add(
                    BidEvent.bid(
                      bid: state.bid,
                      id: state.bid.id,
                      clearCache: true,
                    ),
                  );
            }
          },
        ),
        BlocListener<TemplateBloc, TemplateState>(
          listenWhen: (old, e) =>
              old.templateCacheStatus != e.templateCacheStatus,
          listener: (context, state) {
            if (EasyLoading.isShow) EasyLoading.dismiss();

            if (state.templateCacheStatus.isSuccess) {
              if (state.templateCache.blocks.isNotEmpty) return;
              if (state.templateStatus.isSuccess) return;
              final bid = context.read<BidBloc>().state.bid;

              context
                  .read<TemplateBloc>()
                  .add(TemplateEvent.template(bid: bid));
            }
          },
        ),
        BlocListener<TemplateBloc, TemplateState>(
          listenWhen: (old, e) => old.templateStatus != e.templateStatus,
          listener: (context, state) {
            if (EasyLoading.isShow) EasyLoading.dismiss();

            if (state.templateStatus.isFail) {
              showError(context, state.templateStatus.error);
            } else if (state.templateStatus.isSuccess) {
              if (state.template.blocks.isEmpty) {
                showError(context,
                    Words.templateNotFound.str); // TODO: Перевести ошибку
              }
              final bid = context.read<BidBloc>().state.bid;
              context.read<TemplateBloc>().add(TemplateEvent.putTemplateCache(
                    user: context.read<AuthBloc>().state.userInfo,
                    bid: bid,
                    template: state.template.updateTemplateWith10Steps(),
                  ));
            }
          },
        ),
        BlocListener<TemplateBloc, TemplateState>(
          listenWhen: (old, e) =>
              old.putTemplateCacheStatus != e.putTemplateCacheStatus,
          listener: (context, state) {
            if (EasyLoading.isShow) EasyLoading.dismiss();

            if (state.putTemplateCacheStatus.isFail) {
              showError(context, state.putTemplateCacheStatus.error);
            } else if (state.putTemplateCacheStatus.isSuccess) {
              final bidId = context.read<BidBloc>().state.bid.id;
              context
                  .read<TemplateBloc>()
                  .add(TemplateEvent.templateCache(bidId: bidId));
            }
          },
        ),
        BlocListener<TemplateBloc, TemplateState>(
          listenWhen: (old, e) =>
              old.uploadTemplateStatus != e.uploadTemplateStatus,
          listener: (context, state) {
            if (EasyLoading.isShow) EasyLoading.dismiss();
            if (state.uploadTemplateStatus.isLoading) {
              EasyLoading.show();
            } else if (state.uploadTemplateStatus.isFail) {
              final error = state.uploadTemplateStatus.error;
              if (error is DioException &&
                  error.type == DioExceptionType.connectionError) {
                final template =
                    context.read<TemplateBloc>().state.templateCache;
                context.read<BidBloc>().add(BidEvent.createArchive(
                    bid: widget.bid, template: template));
                showMessage(context, Words.saveToArchive.str);
              } else {
                showError(context, error);
              }
            } else if (state.uploadTemplateStatus.isSuccess) {
              final bid = context.read<BidBloc>().state.bid;
              context.read<BidBloc>()
                ..add(BidEvent.bid(id: bid.id, clearCache: true))
                ..add(BidEvent.updateArchiveStatus(bid))
                ..add(const BidEvent.refreshBids());
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: const TaskAppbar(),
        // floatingActionButton: BlocBuilder<BidBloc, BidState>(
        //   builder: (context, state) {
        //     return FloatingActionButton(
        //       backgroundColor: Colors.white,
        //       onPressed: () {
        //         final template =
        //             context.read<TemplateBloc>().state.templateCache;
        //         if (template.validateGeneral() == null) {
        //           context
        //               .read<TemplateBloc>()
        //               .add(TemplateEvent.shareTemplate(bid: state.bid));
        //         } else {
        //           showError(context, Words.noInfo.str);
        //         }
        //       },
        //       child: Icon(
        //         Icons.archive_outlined,
        //         color: AppColors.blue.shade5,
        //       ),
        //     );
        //   },
        // ),
        body: BlocBuilder<BidBloc, BidState>(
          builder: (context, state) {
            return BlocBuilder<TemplateBloc, TemplateState>(
              builder: (context, templateState) {
                return CustomRefresh(
                  controller: controller,
                  enabledRefresh: kDebugMode ||
                      (state.bidStatus.isSuccess &&
                          !templateState.templateCache.canEdit),
                  onRefresh: () {
                    EasyLoading.show();
                    context
                        .read<TemplateBloc>()
                        .add(TemplateEvent.deleteTemplate(widget.bid));
                    context.read<BidBloc>().add(BidEvent.bid(
                          id: widget.bid.id,
                          bid: const BidModel(),
                          requiredRemote: true,
                        ));
                    controller.refreshCompleted();
                  },
                  child: RegionInheritedWidget(
                    regionId: state.bid.regionId,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 16,
                        right: 16,
                        bottom: 60,
                      ),
                      child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: ShapeDecoration(
                            color: Theme.of(context).cardColor,
                            shape: Theme.of(context).cardTheme.shape!,
                          ),
                          child: Column(
                            spacing: 16,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const StatusList(),
                              const TaskMainInfo(),
                              const TaskLocation(),
                              TaskWorker(
                                workerId: workerId,
                                onWorkerSelected: (id) =>
                                    setState(() => workerId = id),
                              ),
                              const TemplateButton(),
                              if (user.id == state.bid.workerId)
                                const ActionButtons(),
                            ],
                          )),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
