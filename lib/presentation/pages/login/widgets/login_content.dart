import 'package:dala_ishchisi/application/auth/auth_bloc.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/common/widgets/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons/heroicons.dart';

class LoginContent extends StatefulWidget {
  const LoginContent({super.key});

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  final formKey = GlobalKey<FormState>();
  late final loginController = TextEditingController()
    ..addListener(() => setState(() {}));
  late final passwordController = TextEditingController()
    ..addListener(() => setState(() {}));

  @override
  void initState() {
    if (kDebugMode) {
      // loginController.text = 'foreman_cc@uz.uz'; // foreman
      loginController.text = 'fw_cc@uz.uz'; // worker
      passwordController.text = 'Z!x2c3v4'; // password for both of them
    }
    super.initState();
  }

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return IgnorePointer(
          ignoring: state.loginStatus.isLoading ||
              state.metaStatus.isLoading ||
              state.userInfoStatus.isLoading,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: ShapeDecoration(
              color: AppColors.gray.shade0,
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: AppColors.gray.shade2),
                borderRadius: BorderRadius.circular(16),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 5,
                  offset: Offset(2, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                spacing: 16,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: loginController,
                    decoration: InputDecoration(hintText: Words.enterLogin.str),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    inputFormatters: [
                      // UpperCaseTextFormatter(),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return Words.enterLogin.str;
                      }
                      return null;
                    },
                  ),
                  _PasswordField(controller: passwordController),
                  CustomButton(
                    text: Words.signIn.str,
                    loading: state.loginStatus.isLoading ||
                        state.metaStatus.isLoading ||
                        state.userInfoStatus.isLoading,
                    onTap: () {
                      if (formKey.currentState?.validate() ?? false) {
                        context.read<AuthBloc>().add(AuthEvent.login(
                              username: loginController.text,
                              password: passwordController.text,
                            ));
                      }
                    },
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      minSize: 0,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: Text(Words.forgotPassword.str),
                            content: Text(Words.resetPassword.str),
                            actions: [
                              CupertinoButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  Words.cancel.str,
                                  style: TextStyle(color: AppColors.red.shade5),
                                ),
                              ),
                              CupertinoButton(
                                child: Text(Words.confirm.str),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        Words.forgotPassword.str,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.gray.shade9,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const _PasswordField({required this.controller});

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  var obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: Words.enterPassword.str,
        suffixIcon: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => setState(() => obscureText = !obscureText),
          child: HeroIcon(
            obscureText ? HeroIcons.eye : HeroIcons.eyeSlash,
            color: AppColors.gray.shade5,
            size: 22,
          ),
        ),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return Words.enterPassword.str;
        }
        return null;
      },
    );
  }
}
