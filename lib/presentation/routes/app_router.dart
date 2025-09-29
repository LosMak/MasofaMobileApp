import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: LanguageRoute.page),
        AutoRoute(page: OnBoardRoute.page),
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: TaskRoute.page),
        AutoRoute(page: MainRoute.page),
        AutoRoute(page: ProfileRoute.page),
        AutoRoute(page: UsersRoute.page),
        AutoRoute(page: MapRoute.page),
        AutoRoute(page: GeneralTemplateRoute.page),
        AutoRoute(page: StepTemplateRoute.page),
        AutoRoute(page: ContourEditorRoute.page),
        AutoRoute(page: RegionRoute.page),
      ];
}
