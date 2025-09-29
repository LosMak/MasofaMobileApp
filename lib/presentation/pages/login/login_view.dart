import 'package:dala_ishchisi/application/auth/auth_bloc.dart';
import 'package:dala_ishchisi/application/device_info/device_info_bloc.dart';
import 'package:dala_ishchisi/common/extensions/failure_extensions.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/common/widgets/custom_hide_keyboard.dart';
import 'package:dala_ishchisi/main.dart';
import 'package:dala_ishchisi/presentation/routes/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/connect_support.dart';
import 'widgets/login_content.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (old, e) => old.loginStatus != e.loginStatus,
          listener: (context, state) {
            if (state.loginStatus.isFail) {
              showError(context, state.loginStatus.error);
            } else if (state.loginStatus.isSuccess) {
              context.read<AuthBloc>().add(const AuthEvent.meta());
            }
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (old, e) => old.metaStatus != e.metaStatus,
          listener: (context, state) {
            if (state.metaStatus.isFail) {
              showError(context, state.metaStatus.error);
            } else if (state.metaStatus.isSuccess) {
              context.read<AuthBloc>().add(const AuthEvent.userInfo());
            }
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (old, e) => old.userInfoStatus != e.userInfoStatus,
          listener: (context, state) {
            if (state.userInfoStatus.isFail) {
              showError(context, state.userInfoStatus.error);
            } else if (state.userInfoStatus.isSuccess) {
              router.pushAndPopUntil(
                const MainRoute(),
                predicate: (_) => false,
              );
            }
          },
        ),
      ],
      child: BlocBuilder<DeviceInfoBloc, DeviceInfoState>(
        builder: (context, state) {
          if (state.packageInfo == null) {
            return const SizedBox();
          }
          final isMasofa =
              state.packageInfo!.appName.toLowerCase().contains('masofa');
          final appName = isMasofa ? Words.appNameMasofa : Words.appNameUgd;
          final copyright =
              isMasofa ? Words.copyrightMasofa : Words.copyrightUgd;
          return CustomHideKeyboard(
            child: Scaffold(
              body: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).viewPadding.top,
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                isMasofa
                                    ? Text(
                                        appName.str,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppColors.gray.shade9,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )
                                    : const SizedBox(height: 24),
                                const SizedBox(height: 8),
                                Text(
                                  Words.enterSystem.str,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.gray.shade5,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const LoginContent(),
                                const SizedBox(height: 16),
                                const ConnectSupport(),
                                const SizedBox(height: 16),
                                Text(
                                  Words.connectSupport.str,
                                  style: TextStyle(
                                    color: AppColors.gray.shade9,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        isMasofa
                            ? SizedBox(
                                width: double.infinity,
                                child: Text(
                                  copyright.str,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.gray.shade5,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              )
                            : const SizedBox(height: 12),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
