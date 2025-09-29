import 'package:flutter/material.dart';

class CustomHideKeyboard extends StatefulWidget {
  final Widget child;
  final GestureTapCallback? onTap;

  const CustomHideKeyboard({super.key, required this.child, this.onTap});

  @override
  State<CustomHideKeyboard> createState() => _CustomHideKeyboardState();
}

class _CustomHideKeyboardState extends State<CustomHideKeyboard> {
  bool hasFocus = false;

  @override
  Widget build(BuildContext context) {
    final hideKeyboard = MediaQuery.of(context).viewInsets.bottom == 0;
    if (hasFocus && hideKeyboard) {
      FocusScope.of(context).unfocus();
      hasFocus = false;
    } else if (!hideKeyboard) {
      hasFocus = true;
    }
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (widget.onTap != null) widget.onTap!();
      },
      behavior: HitTestBehavior.opaque,
      child: widget.child,
    );
  }
}
