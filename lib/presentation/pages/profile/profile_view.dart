import 'package:auto_route/auto_route.dart';
import 'package:dala_ishchisi/application/auth/auth_bloc.dart';
import 'package:dala_ishchisi/application/cache/cache_bloc.dart';
import 'package:dala_ishchisi/application/device_info/device_info_bloc.dart';
import 'package:dala_ishchisi/application/language/language_bloc.dart';
import 'package:dala_ishchisi/common/di.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/common/widgets/custom_appbar_back.dart';
import 'package:dala_ishchisi/common/widgets/custom_user_appbar.dart';
import 'package:dala_ishchisi/main.dart';
import 'package:dala_ishchisi/presentation/dialogs/laguage/language_dialog.dart';
import 'package:dala_ishchisi/presentation/routes/app_router.gr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:heroicons/heroicons.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  Future<bool?> showDeleteCacheDialog(BuildContext context) {
    return showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(Words.warning.str),
          content: Text(
            Words.cacheWillBeCleared.str,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(Words.cancel.str),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              isDestructiveAction: true,
              child: Text(Words.delete.str),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CacheBloc>(
          create: (context) => di<CacheBloc>()..add(const CacheEvent.getSize()),
        ),
        BlocProvider<LanguageBloc>(
          create: (context) => di<LanguageBloc>(),
        ),
      ],
      child: BlocBuilder<DeviceInfoBloc, DeviceInfoState>(
        builder: (context, deviceState) {
          return BlocBuilder<LanguageBloc, LanguageState>(
            buildWhen: (old, e) => old.locale != e.locale,
            builder: (context, languageState) {
              return BlocConsumer<CacheBloc, CacheState>(
                listener: (context, state) {
                  state.maybeWhen(
                    initial: () => EasyLoading.show(),
                    loading: () => EasyLoading.show(),
                    loadingOnDelete: () => EasyLoading.show(),
                    orElse: () => EasyLoading.dismiss(),
                  );
                },
                builder: (context, cacheState) {
                  return Scaffold(
                    key: UniqueKey(),
                    appBar: AppBar(
                      title: Text(Words.profile.str),
                      leadingWidth: 100,
                      leading: const CustomAppbarBack(),
                    ),
                    body: Column(
                      children: [
                        const CustomUserAppbar(),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: ShapeDecoration(
                                    color: Theme.of(context).cardColor,
                                    shape: Theme.of(context).cardTheme.shape!,
                                  ),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          const LanguageDialog().show(context);
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            spacing: 8,
                                            children: [
                                              HeroIcon(
                                                HeroIcons.globeAmericas,
                                                color:
                                                    Theme.of(context).hintColor,
                                              ),
                                              Expanded(
                                                  child: Text(
                                                      Words.appLanguage.str)),
                                              Text(
                                                languageState
                                                    .locale.languageCode.str,
                                                style: TextStyle(
                                                  color: AppColors.gray.shade5,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              HeroIcon(
                                                HeroIcons.chevronRight,
                                                color: AppColors.gray.shade5,
                                                style: HeroIconStyle.mini,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Divider(),
                                      GestureDetector(
                                        // onTap: () => launchUrl(
                                        //   Uri.parse(AppConstants.supportUrl),
                                        //   mode: LaunchMode.externalApplication,
                                        // ),
                                        behavior: HitTestBehavior.opaque,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            spacing: 8,
                                            children: [
                                              HeroIcon(
                                                HeroIcons.informationCircle,
                                                color:
                                                    Theme.of(context).hintColor,
                                              ),
                                              Expanded(
                                                  child:
                                                      Text(Words.support.str)),
                                              HeroIcon(
                                                HeroIcons.chevronRight,
                                                color: AppColors.gray.shade5,
                                                style: HeroIconStyle.mini,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Divider(),
                                      GestureDetector(
                                        // onTap: () => launchUrl(
                                        //   Uri.parse(AppConstants.policyUrl),
                                        //   mode: LaunchMode.externalApplication,
                                        // ),
                                        behavior: HitTestBehavior.opaque,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            spacing: 8,
                                            children: [
                                              HeroIcon(
                                                HeroIcons.shieldExclamation,
                                                color:
                                                    Theme.of(context).hintColor,
                                              ),
                                              Expanded(
                                                child: Text(Words.policy.str),
                                              ),
                                              HeroIcon(
                                                HeroIcons.chevronRight,
                                                color: AppColors.gray.shade5,
                                                style: HeroIconStyle.mini,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Divider(),
                                      GestureDetector(
                                        onTap: () => context.router.push(
                                          const RegionRoute(),
                                        ),
                                        behavior: HitTestBehavior.opaque,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            spacing: 8,
                                            children: [
                                              HeroIcon(
                                                HeroIcons.map,
                                                color:
                                                    Theme.of(context).hintColor,
                                              ),
                                              Expanded(
                                                child:
                                                    Text(Words.offlineMaps.str),
                                              ),
                                              HeroIcon(
                                                HeroIcons.chevronRight,
                                                color: AppColors.gray.shade5,
                                                style: HeroIconStyle.mini,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Divider(),
                                      GestureDetector(
                                        onTap: () async {
                                          final result =
                                              await showDeleteCacheDialog(
                                                  context);
                                          if (result ?? false) {
                                            context.read<CacheBloc>().add(
                                                  const CacheEvent
                                                      .deleteCache(),
                                                );
                                          }
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            spacing: 8,
                                            children: [
                                              HeroIcon(
                                                HeroIcons.chartPie,
                                                color:
                                                    Theme.of(context).hintColor,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  Words.clearApplicationCache
                                                      .str,
                                                ),
                                              ),
                                              Text(
                                                '${cacheState.mapOrNull(
                                                      success: (value) =>
                                                          value.size,
                                                    ) ?? '-'} MB',
                                              ),
                                              HeroIcon(
                                                HeroIcons.chevronRight,
                                                color: AppColors.gray.shade5,
                                                style: HeroIconStyle.mini,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                CupertinoButton(
                                  color: Colors.black,
                                  padding: const EdgeInsets.all(12),
                                  onPressed: () {
                                    context
                                        .read<AuthBloc>()
                                        .add(const AuthEvent.logout());
                                    router.pushAndPopUntil(
                                      const LoginRoute(),
                                      predicate: (_) => false,
                                    );
                                  },
                                  child: Row(
                                    spacing: 8,
                                    children: [
                                      const HeroIcon(
                                        HeroIcons.arrowRightStartOnRectangle,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      Expanded(
                                        child: Text(
                                          Words.logout.str,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const HeroIcon(
                                        HeroIcons.chevronRight,
                                        color: Colors.white,
                                        style: HeroIconStyle.mini,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                              "${Words.version.str}: ${deviceState.packageInfo?.version}"),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
