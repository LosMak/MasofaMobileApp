import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:flutter/material.dart';

class CalendarViewBody extends StatelessWidget {
  const CalendarViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        Words.soon.str,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}
