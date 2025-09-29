import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

import 'on_board_view.dart';

@RoutePage()
class OnBoardPage extends StatelessWidget {
  const OnBoardPage({super.key});

  @override
  Widget build(BuildContext context) => const OnBoardView();
}
