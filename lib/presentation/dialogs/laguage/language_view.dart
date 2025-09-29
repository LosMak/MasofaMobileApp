import 'package:dala_ishchisi/application/language/language_bloc.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageView extends StatelessWidget {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Words.selectLanguage.str,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, state) {
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.locales.length,
              separatorBuilder: (_, i) => const SizedBox(height: 16),
              itemBuilder: (_, i) => _WidgetItem(
                strKey: state.locales[i].languageCode,
                isSelected: state.locale == state.locales[i],
                onTap: (strKey) {
                  context.read<LanguageBloc>().add(
                        LanguageEvent.setLocale(strKey, context: context),
                      );
                  Navigator.pop(context);
                },
              ),
            );
          },
        ),
        const SizedBox(height: 45),
      ],
    );
  }
}

class _WidgetItem extends StatelessWidget {
  final String strKey;
  final bool isSelected;
  final Function(String strKey)? onTap;

  const _WidgetItem({
    required this.strKey,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minSize: 0,
      padding: EdgeInsets.zero,
      onPressed: () => onTap?.call(strKey),
      child: Row(
        children: [
          Expanded(
            child: Text(
              strKey.str,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color:
                    isSelected ? AppColors.gray.shade7 : AppColors.gray.shade4,
              ),
            ),
          ),
          if (isSelected)
            Icon(Icons.check, size: 24, color: AppColors.gray.shade7),
        ],
      ),
    );
  }
}
