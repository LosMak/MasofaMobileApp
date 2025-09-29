import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showRecently() => showMsg(Words.soon.str);

void showMsg(dynamic msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: AppColors.gray.shade9,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    
    SnackBar(
      backgroundColor: Colors.blue,
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

Future<bool> showConfirmMsg(
  BuildContext context, {
  required String title,
  required String content,
  Widget? body,
}) async {
  return await showCupertinoModalPopup(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            if (body != null) body,
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(Words.no.str),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(Words.yes.str),
            ),
          ],
        ),
      ) ??
      false;
}
