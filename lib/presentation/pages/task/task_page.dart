import 'package:auto_route/annotations.dart';
import 'package:dala_ishchisi/application/bid/bid_bloc.dart';
import 'package:dala_ishchisi/application/template/template_bloc.dart';
import 'package:dala_ishchisi/common/di.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'task_view.dart';

@RoutePage()
class TaskPage extends StatelessWidget {
  final BidBloc bidBloc;
  final BidModel bid;

  const TaskPage({super.key, required this.bidBloc, required this.bid});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BidBloc>.value(value: bidBloc),
        BlocProvider<TemplateBloc>(create: (_) => di<TemplateBloc>()),
      ],
      child: TaskView(bid: bid),
    );
  }
}
