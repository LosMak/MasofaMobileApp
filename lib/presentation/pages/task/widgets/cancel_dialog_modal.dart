import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<bool> showCancelDialog(
  BuildContext context, {
  required String title,
  required String content,
  required TextEditingController controller,
  required GlobalKey<FormState> formKey,
}) async {
  return await showCupertinoModalPopup(
        context: context,
        builder: (_) {
          return StatefulBuilder(
            builder: (context, setState) {
              bool disableYes = controller.text.isEmpty;

              controller.addListener(() {
                if (disableYes != controller.text.isEmpty) {
                  disableYes = controller.text.isEmpty;
                  setState(() {});
                }
              });

              return CupertinoAlertDialog(
                title: Text(title),
                content: Column(
                  children: [
                    const SizedBox(height: 8),
                    Text(content),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(Words.comment.str),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Form(
                              key: formKey,
                              child: TextFormField(
                                controller: controller,
                                decoration: InputDecoration(
                                  hintText: Words.enterComment.str,
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return Words.enterComment.str;
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(Words.no.str),
                  ),
                  CupertinoDialogAction(
                    isDestructiveAction: true,
                    onPressed: disableYes
                        ? null
                        : () => Navigator.of(context).pop(true),
                    child: Text(Words.yes.str),
                  ),
                ],
              );
            },
          );
        },
      ) ??
      false;
}
