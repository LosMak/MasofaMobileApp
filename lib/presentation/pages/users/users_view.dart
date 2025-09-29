import 'package:dala_ishchisi/application/bid/bid_bloc.dart';
import 'package:dala_ishchisi/application/user/user_bloc.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/widgets/custom_appbar_back.dart';
import 'package:dala_ishchisi/domain/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/foreman_action_buttons.dart';
import 'widgets/user_item.dart';

class UsersView extends StatefulWidget {
  final UserModel foreman;

  const UsersView(this.foreman, {super.key});

  @override
  State<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  late final bidId = context.read<BidBloc>().state.bid.id;
  late var workerId = context.read<BidBloc>().state.bid.workerId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 100,
        leading: const CustomAppbarBack(),
        title: Text(Words.workers.str),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<BidBloc, BidState>(
                builder: (context, bidState) {
                  return BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      return ListView.builder(
                        itemCount: state.users.length + 1,
                        itemBuilder: (_, i) {
                          if (state.users.length == i) {
                            return UserItem(
                              user: widget.foreman,
                              isSelected: widget.foreman.id == workerId,
                              isFirst: false,
                              isLast: true,
                              onTap: () => setState(
                                () => workerId = widget.foreman.id,
                              ),
                            );
                          }
                          final model = state.users[i];
                          return UserItem(
                            user: model,
                            isSelected: model.id == workerId,
                            isFirst: i == 0,
                            isLast: false,
                            onTap: () => setState(() => workerId = model.id),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SafeArea(
              child: ForemanActionButtons(
                onCancel: () => Navigator.pop(context),
                onSave: () {
                  context.read<BidBloc>().add(BidEvent.updateWorker(
                        bidId: bidId,
                        workerId: workerId,
                      ));
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
