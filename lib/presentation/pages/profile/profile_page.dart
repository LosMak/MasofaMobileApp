import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

import 'profile_view.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => const ProfileView();
}
