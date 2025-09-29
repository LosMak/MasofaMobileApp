import 'package:auto_route/annotations.dart';
import 'package:dala_ishchisi/application/auth/auth_bloc.dart';
import 'package:dala_ishchisi/application/bid/bid_bloc.dart';
import 'package:dala_ishchisi/domain/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'users_view.dart';

@RoutePage()
class UsersPage extends StatelessWidget {
  final BidBloc bidBloc;

  const UsersPage({super.key, required this.bidBloc});

  @override
  Widget build(BuildContext context) {
    final userInfo = context.read<AuthBloc>().state.userInfo;
    final user = UserModel(
      id: userInfo.id,
      name: userInfo.email,
      active: true,
    );

    return BlocProvider.value(value: bidBloc, child: UsersView(user));
  }
}
