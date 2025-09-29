import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'splash_view.dart';

@RoutePage()
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) => const SplashView();
}
