import 'package:dala_ishchisi/application/device_info/device_info_bloc.dart';
import 'package:dala_ishchisi/application/language/language_bloc.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/common/widgets/custom_button.dart';
import 'package:dala_ishchisi/common/widgets/custom_icons.dart';
import 'package:dala_ishchisi/main.dart';
import 'package:dala_ishchisi/presentation/routes/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/language_button.dart';

class LanguageView extends StatelessWidget {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, languageState) {
            return BlocBuilder<DeviceInfoBloc, DeviceInfoState>(
              builder: (context, deviceInfoState) {
                if (deviceInfoState.packageInfo == null) {
                  return const SizedBox();
                }
                final isMasofa = deviceInfoState.packageInfo!.appName
                    .toLowerCase()
                    .contains('masofa');
                final appName =
                    isMasofa ? Words.appNameMasofa : Words.appNameUgd;
                return Column(
                  children: [
                    const Spacer(flex: 4),
                    Column(
                      spacing: 15,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIcons.logo.copyWith(height: 80),
                        isMasofa
                            ? Text(
                                appName.str.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 34,
                                  color: AppColors.gray.shade9,
                                  fontWeight: FontWeight.w900,
                                ),
                              )
                            : const SizedBox(height: 34),
                      ],
                    ),
                    const Spacer(),
                    ListView.separated(
                      itemCount: languageState.locales.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      separatorBuilder: (_, i) => const SizedBox(height: 6),
                      itemBuilder: (_, i) {
                        return LanguageButton(
                          langCode: languageState.locales[i].languageCode,
                          isSelected:
                              languageState.locales[i] == languageState.locale,
                          onTap: (langCode) {
                            context.read<LanguageBloc>().add(
                                  LanguageEvent.setLocale(langCode,
                                      context: context),
                                );
                          },
                        );
                      },
                    ),
                    const Spacer(),
                    CustomButton(
                      onTap: () => router.pushAndPopUntil(
                        const OnBoardRoute(),
                        predicate: (_) => false,
                      ),
                      text: Words.next.str,
                    ),
                    const SizedBox(height: 45),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
