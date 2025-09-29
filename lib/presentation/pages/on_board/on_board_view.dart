import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/widgets/custom_button.dart';
import 'package:dala_ishchisi/main.dart';
import 'package:dala_ishchisi/presentation/routes/app_router.gr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'widgets/widget_content.dart';
import 'widgets/widget_indicator.dart';

class OnBoardView extends StatefulWidget {
  const OnBoardView({super.key});

  @override
  State<OnBoardView> createState() => _OnBoardViewState();
}

class _OnBoardViewState extends State<OnBoardView> {
  late final controller = PageController()..addListener(() => setState(() {}));

  int get currentPage {
    if (controller.hasClients) {
      return controller.page!.round();
    }
    return 0;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          if (currentPage != 4)
            CupertinoButton(
              onPressed: () => controller.jumpToPage(4),
              child: Text(Words.skip.str),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: 5,
              controller: controller,
              itemBuilder: (_, i) => WidgetContent(index: i),
            ),
          ),
          WidgetIndicator(pageCount: 5, currentPage: currentPage),
          const SizedBox(height: 32),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomButton(
                text: Words.next.str,
                onTap: () {
                  if (controller.page == 4) {
                    router.pushAndPopUntil(
                      const LoginRoute(),
                      predicate: (_) => false,
                    );
                    return;
                  }
                  controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.linear,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
