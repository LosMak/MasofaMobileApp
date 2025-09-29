import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

import 'login_view.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) => const LoginView();
}
