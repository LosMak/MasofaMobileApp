import 'package:dala_ishchisi/common/constants/app_constants.dart';
import 'package:dala_ishchisi/common/extensions/message_extensions.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

class ConnectSupport extends StatelessWidget {
  const ConnectSupport({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minSize: 0,
      onPressed: () async {
        final result = await showConfirmMsg(
          context,
          title: Words.confirm.str,
          content: Words.connectSupport.str,
        );
        if (result) {
          launchUrl(
            Uri.parse(AppConstants.supportUrl),
            mode: LaunchMode.externalApplication,
          );
        }
      },
      padding: EdgeInsets.zero,
      child: Text(
        Words.yesProblem.str,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      ),
    );
  }
}
