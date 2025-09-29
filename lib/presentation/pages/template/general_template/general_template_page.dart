import 'package:auto_route/annotations.dart';
import 'package:dala_ishchisi/application/template/template_bloc.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'general_template_view.dart';

@RoutePage()
class GeneralTemplatePage extends StatelessWidget {
  final TemplateBloc templateBloc;
  final BidModel bid;

  const GeneralTemplatePage({
    super.key,
    required this.templateBloc,
    required this.bid,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<TemplateBloc>.value(value: templateBloc)],
      child: GeneralTemplateView(bid),
    );
  }
}
