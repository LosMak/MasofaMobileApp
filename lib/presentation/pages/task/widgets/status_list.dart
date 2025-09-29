import 'package:dala_ishchisi/application/bid/bid_bloc.dart';
import 'package:dala_ishchisi/common/extensions/bid_state_colors.dart';
import 'package:dala_ishchisi/common/extensions/bid_state_extension.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/domain/models/meta_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatusList extends StatelessWidget {
  const StatusList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BidBloc, BidState>(
      buildWhen: (old, e) => old.bid != e.bid,
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 4,
              ),
              decoration: ShapeDecoration(
                color: bidStateBGColor(state.bid.bidState),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                state.bid.bidState.value,
                style: TextStyle(
                  color: bidStateTextColor(state.bid.bidState),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Spacer(),
            Text(
              'ID ${state.bid.number}',
              style: TextStyle(
                color: AppColors.blue.shade5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}
