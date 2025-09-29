import 'package:dala_ishchisi/application/auth/auth_bloc.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dala_ishchisi/common/extensions/bid_state_extension.dart';
import 'package:dala_ishchisi/domain/models/user_info_model.dart';
import 'package:dala_ishchisi/main.dart';
import 'package:dala_ishchisi/presentation/routes/app_router.gr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddictionChip {
  final BidStateType id;
  final String title;
  final Function(BidStateType bidState) onSelected;
  final bool isSelected;

  AddictionChip({
    required this.id,
    required this.title,
    required this.onSelected,
    this.isSelected = false,
  });
}

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isListView;
  final BidStateType? bidState;
  final Function()? onViewToggle;
  final Function()? onFilter;
  final Function(BidStateType? bidState)? onTabChange;
  final List<AddictionChip> extensions;

  const HomeAppBar({
    super.key,
    required this.title,
    required this.isListView,
    this.bidState,
    this.onViewToggle,
    this.onFilter,
    this.onTabChange,
    this.extensions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      title: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (old, e) => old.userInfo != e.userInfo,
        builder: (context, state) {
          return CupertinoButton(
            minSize: 0,
            padding: EdgeInsets.zero,
            onPressed: () => router.push(const ProfileRoute()),
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.userInfo.email,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.gray.shade7,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  state.userInfo.role.contains(UserRole.foreman)
                      ? Words.foreman.str
                      : Words.worker.str,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray.shade5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      actions: const [
        // TODO : add filters and calendar view
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 6),
        //   margin: const EdgeInsets.symmetric(vertical: 6),
        //   decoration: ShapeDecoration(
        //     color: Colors.white,
        //     shape: RoundedRectangleBorder(
        //       side: BorderSide(
        //         width: 1,
        //         color: AppColors.gray.shade2,
        //       ),
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //   ),
        //   child: ListView.separated(
        //     shrinkWrap: true,
        //     itemCount: icons.length,
        //     scrollDirection: Axis.horizontal,
        //     physics: const NeverScrollableScrollPhysics(),
        //     separatorBuilder: (_, i) => const SizedBox(width: 4),
        //     itemBuilder: (_, i) {
        //       return CupertinoButton(
        //         minSize: 0,
        //         padding: EdgeInsets.zero,
        //         onPressed: onViewToggle,
        //         child: Container(
        //           padding: const EdgeInsets.all(6),
        //           decoration: index == i
        //               ? ShapeDecoration(
        //                   color: Colors.black,
        //                   shape: RoundedRectangleBorder(
        //                     borderRadius: BorderRadius.circular(4),
        //                   ),
        //                 )
        //               : null,
        //           child: HeroIcon(
        //             icons[i],
        //             style:
        //                 index == i ? HeroIconStyle.mini : HeroIconStyle.solid,
        //             color: index == i ? Colors.white : AppColors.gray.shade4,
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        // ),
        // const SizedBox(width: 6),
        // CupertinoButton(
        //   minSize: 0,
        //   padding: EdgeInsets.zero,
        //   onPressed: onFilter,
        //   child: Container(
        //     width: 40,
        //     height: 40,
        //     padding: const EdgeInsets.symmetric(vertical: 2),
        //     decoration: ShapeDecoration(
        //       color: Colors.white,
        //       shape: RoundedRectangleBorder(
        //         side: BorderSide(
        //           width: 1,
        //           color: AppColors.gray.shade2,
        //         ),
        //         borderRadius: BorderRadius.circular(8),
        //       ),
        //     ),
        //     child: HeroIcon(HeroIcons.funnel, color: AppColors.slate.shade9),
        //   ),
        // ),
        // const SizedBox(width: 16),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
          child: Container(
            height: 40,
            padding: const EdgeInsets.all(4),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: AppColors.gray.shade2),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (old, e) => old.meta != e.meta,
              builder: (context, state) {
                const items = [
                  BidStateType.none,
                  BidStateType.created,
                  BidStateType.active,
                  BidStateType.inProgress,
                  BidStateType.finished,
                  BidStateType.rejected,
                  BidStateType.cancelled,
                  BidStateType.archive,
                ];
                return ListView.separated(
                  itemCount: items.length + extensions.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, i) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    if (i > items.length) {
                      final extension = extensions[(items.length + 1) - i];
                      return CupertinoButton(
                        minSize: 0,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          extension.onSelected(extension.id);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: ((extension.id == bidState))
                              ? ShapeDecoration(
                                  color: AppColors.gray.shade9,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                )
                              : null,
                          child: Text(
                            extension.title,
                            style: TextStyle(
                              color: ((extension.id == bidState))
                                  ? Colors.white
                                  : AppColors.gray.shade5,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }
                    if (i < items.length) {
                      final BidStateType model = items[i];
                      if (model == BidStateType.none) {
                        return CupertinoButton(
                          minSize: 0,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            if (bidState != null) {
                              onTabChange?.call(null);
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: bidState == null
                                ? ShapeDecoration(
                                    color: AppColors.gray.shade9,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  )
                                : null,
                            child: Text(
                              Words.all.str,
                              style: TextStyle(
                                color: bidState == null
                                    ? Colors.white
                                    : AppColors.gray.shade5,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }
                      return CupertinoButton(
                        minSize: 0,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (bidState != model) {
                            onTabChange?.call(model);
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: model == bidState
                              ? ShapeDecoration(
                                  color: AppColors.gray.shade9,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                )
                              : null,
                          child: Text(
                            model.value,
                            style: TextStyle(
                              color: model == bidState
                                  ? Colors.white
                                  : AppColors.gray.shade5,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 2.2);
}
