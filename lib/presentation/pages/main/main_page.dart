import 'package:auto_route/annotations.dart';
import 'package:dala_ishchisi/application/auth/auth_bloc.dart';
import 'package:dala_ishchisi/application/bid/bid_bloc.dart';
import 'package:dala_ishchisi/common/di.dart';
import 'package:dala_ishchisi/domain/models/user_info_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'main_view.dart';

@RoutePage()
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.userInfo;
    final foremanId = user.role.contains(UserRole.foreman) ? user.id : null;
    final workerId = user.role.contains(UserRole.worker) ? user.id : null;
    final operatorId = user.role.contains(UserRole.operator) ? user.id : null;

    return MultiBlocProvider(
      providers: [
        BlocProvider<BidBloc>(
          create: (_) => di<BidBloc>()
            ..add(
              BidEvent.refreshBids(
                foremanId: foremanId,
                workerId: workerId,
                operatorId: operatorId,
              ),
            ),
        ),
      ],
      child: MainView(
        foremanId: foremanId,
        workerId: workerId,
        operatorId: operatorId,
      ),
    );
  }
}
