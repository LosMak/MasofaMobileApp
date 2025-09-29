import 'package:dala_ishchisi/application/region/region_bloc.dart';
import 'package:dala_ishchisi/application/user/user_bloc.dart';
import 'package:dala_ishchisi/common/di.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'application/auth/auth_bloc.dart';
import 'application/device_info/device_info_bloc.dart';
import 'application/language/language_bloc.dart';
import 'application/location/location_bloc.dart';
import 'application/network_info/network_info_bloc.dart';
import 'common/theme/app_theme.dart';
import 'common/widgets/custom_app.dart';
import 'presentation/routes/app_router.dart';

void main() async {
  await configureDependencies();
  // ChuckerFlutter.showOnRelease = false;
  runApp(const CustomApp(child: MyApp()));
}

final router = AppRouter();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) {
          return di<AuthBloc>()..add(const AuthEvent.init());
        }),
        BlocProvider<UserBloc>(create: (_) => di<UserBloc>()),
        BlocProvider<NetworkInfoBloc>(
          lazy: false,
          create: (_) {
            return di<NetworkInfoBloc>()..add(const NetworkInfoEvent.init());
          },
        ),
        BlocProvider<LocationBloc>(create: (_) => di<LocationBloc>()),
        BlocProvider<LanguageBloc>(
          create: (_) {
            return di<LanguageBloc>()
              ..add(LanguageEvent.getLocale(context: context));
          },
        ),
        BlocProvider<DeviceInfoBloc>(
          create: (_) {
            return di<DeviceInfoBloc>()
              ..add(const DeviceInfoEvent.checkNotJailBroken())
              ..add(const DeviceInfoEvent.checkRealDevice())
              ..add(const DeviceInfoEvent.checkRealLocation())
              ..add(const DeviceInfoEvent.getProjectInfo());
          },
        ),
        BlocProvider<RegionBloc>(
          create: (_) => di<RegionBloc>()
            ..add(
              const RegionEvent.fetchRegions(),
            ),
        ),
      ],
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Dala ishchisi',
            debugShowCheckedModeBanner: false,
            routerConfig: router.config(),
            theme: AppTheme.light,
            scrollBehavior: ScrollConfiguration.of(
              context,
            ).copyWith(physics: const BouncingScrollPhysics()),
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: state.locale,
            builder: EasyLoading.init(),
          );
        },
      ),
    );
  }
}
