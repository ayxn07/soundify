import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotify_app_clone/data/sources/local/local_storage_service.dart';
import 'package:spotify_app_clone/common/helpers/is_dark_mode.dart';
import 'package:spotify_app_clone/common/widgets/appbar/app_bar.dart';
import 'package:spotify_app_clone/common/widgets/button/basic_app_button.dart';
import 'package:spotify_app_clone/core/configs/assets/app_vectors.dart';
import 'package:spotify_app_clone/core/configs/theme/app_colors.dart';
import 'package:spotify_app_clone/data/models/auth/google_user_req.dart';
import 'package:spotify_app_clone/data/models/auth/signin_user_req.dart';
import 'package:spotify_app_clone/domain/usecases/auth/signin.dart';
import 'package:spotify_app_clone/domain/usecases/auth/signin_with_google.dart';
import 'package:spotify_app_clone/presentation/auth/pages/signup_page.dart';
import 'package:spotify_app_clone/presentation/navigation/pages/nav_scaffold.dart';

import '../../../service_locator.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool obscureText = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppBar(
        title: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: SvgPicture.asset(AppVectors.logo, height: 40, width: 40),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _signinText(),
              SizedBox(height: 15),
              _supportText(),
              SizedBox(height: 30),
              _usernameEmailField(context),
              SizedBox(height: 20),
              _passwordField(context),
              SizedBox(height: 20),
              _recoverAccount(),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3,
                    )
                  : BasicAppButton(
                      onPressed: () async {
                        try {
                          setState(() {
                            isLoading = true;
                          });
                          var result = await sl<SigninUseCase>().call(
                            params: SigninUserReq(
                              email: _email.text.toString(),
                              password: _password.text.toString(),
                            ),
                          );
                          result.fold(
                            (l) {
                              var snackbar = SnackBar(
                                content: Text(
                                  l,
                                  style: TextStyle(color: Colors.white),
                                ),
                                showCloseIcon: true,
                                closeIconColor: Colors.white,
                                backgroundColor: AppColors.primary,
                              );
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(snackbar);
                            },
                            (r) async {
                              final uid =
                                  FirebaseAuth.instance.currentUser?.uid;
                              if (uid != null) {
                                await sl<LocalStorageService>().setUid(uid);
                              }
                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const NavScaffold(),
                                  ),
                                  (root) => false,
                                );
                              }
                            },
                          );
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      title: "Sign In",
                    ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Colors.transparent, Colors.grey],
                          stops: [0.0, 0.7],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text("Or"),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [Colors.transparent, Colors.grey],
                          stops: [0.0, 0.7],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      var result = await sl<SigninWithGoogleUsecase>().call(
                        params: GoogleUserReq(),
                      );
                      result.fold(
                        (l) {
                          var snackbar = SnackBar(
                            content: Text(
                              l,
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: AppColors.primary,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackbar);
                        },
                        (r) async {
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid != null) {
                            await sl<LocalStorageService>().setUid(uid);
                          }
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const NavScaffold(),
                              ),
                              (root) => false,
                            );
                          }
                        },
                      );
                    },
                    child: SvgPicture.asset(AppVectors.googleLogo),
                  ),
                  SizedBox(width: 50),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                    },
                    child: SvgPicture.asset(
                      AppVectors.appleLogo,
                      colorFilter: ColorFilter.mode(
                        context.isDarkMode ? Colors.white70 : Colors.black45,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              _createAccount(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _signinText() {
    return const Text(
      "Sign In",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    );
  }

  Widget _supportText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("If you need any support", style: TextStyle(fontSize: 12)),
        SizedBox(width: 4),
        const Text(
          "click here",
          style: TextStyle(fontSize: 12, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _recoverAccount() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Text(
          "Recovery Password",
          style: TextStyle(
            fontSize: 14,
            color: context.isDarkMode ? Color(0xffAEAEAE) : Color(0xff383838),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _createAccount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Not a Member Yet?",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 5),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => SignupPage(),
              ),
            );
          },
          child: const Text(
            "Register Now",
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue,

              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _usernameEmailField(BuildContext context) {
    return TextField(
      controller: _email,
      decoration: InputDecoration(
        labelText: "Enter Email",
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _passwordField(BuildContext context) {
    return TextField(
      controller: _password,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: "Password",

        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              obscureText = !obscureText;
            });
          },
          icon: SvgPicture.asset(AppVectors.hidePassword),
          padding: const EdgeInsets.only(right: 20.0),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }
}
