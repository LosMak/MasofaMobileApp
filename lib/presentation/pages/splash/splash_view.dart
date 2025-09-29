import 'package:dala_ishchisi/application/auth/auth_bloc.dart';
import 'package:dala_ishchisi/application/device_info/device_info_bloc.dart';
import 'package:dala_ishchisi/common/extensions/failure_extensions.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/widgets/custom_icons.dart';
import 'package:dala_ishchisi/common/widgets/custom_images.dart';
import 'package:dala_ishchisi/main.dart';
import 'package:dala_ishchisi/presentation/routes/app_router.gr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (old, e) => old.initPage != e.initPage,
          listener: (context, state) {
            if (state.initPage == AuthPages.noLanguage) {
              router.pushAndPopUntil(
                const LanguageRoute(),
                predicate: (_) => false,
              );
            } else if (state.initPage == AuthPages.hasLanguage) {
              router.pushAndPopUntil(
                const LoginRoute(),
                predicate: (_) => false,
              );
            } else {
              context.read<AuthBloc>()
                ..add(const AuthEvent.meta())
                ..add(const AuthEvent.userInfo());
            }
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (old, e) => old.loginStatus != e.loginStatus,
          listener: (context, state) {
            if (state.loginStatus.isFail) {
              showError(context, state.loginStatus.error);
            } else if (state.loginStatus.isSuccess) {
              context.read<AuthBloc>()
                ..add(const AuthEvent.meta())
                ..add(const AuthEvent.userInfo());
            }
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (old, e) =>
              old.metaStatus != e.metaStatus ||
              old.userInfoStatus != e.userInfoStatus,
          listener: (context, state) {
            if (state.metaStatus.isFail) {
              showError(context, state.metaStatus.error);
            } else if (state.userInfoStatus.isFail) {
              showError(context, state.userInfoStatus.error);
            } else if (state.metaStatus.isSuccess &&
                state.userInfoStatus.isSuccess) {
              router.pushAndPopUntil(
                const MainRoute(),
                predicate: (_) => false,
              );
            }
          },
        ),
      ],
      child: Scaffold(
        body: BlocBuilder<DeviceInfoBloc, DeviceInfoState>(
          builder: (context, state) {
            return Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(CustomImages.splash.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: state.packageInfo?.appName == null
                      ? null
                      : Column(
                          spacing: 15,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIcons.logo.copyWith(height: 80),
                            state.packageInfo!.appName
                                    .toLowerCase()
                                    .contains('masofa')
                                ? TextAnimator(
                                    state.packageInfo!.appName.toUpperCase(),
                                    key: UniqueKey(),
                                    atRestEffect: WidgetRestingEffects.wave(),
                                    style: const TextStyle(
                                      fontSize: 34,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                ),
                if (state.packageInfo != null)
                  Positioned(
                    left: 16,
                    bottom: 60,
                    right: 16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Text(
                          "${Words.version.str}: ${state.packageInfo?.version}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const CupertinoActivityIndicator(color: Colors.white),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
