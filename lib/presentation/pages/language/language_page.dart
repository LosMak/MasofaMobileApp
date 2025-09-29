import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

import 'language_view.dart';

@RoutePage()
class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  // Global blocs used in this page:
  // - LanguageBloc

  @override
  Widget build(BuildContext context) => const LanguageView();
}
