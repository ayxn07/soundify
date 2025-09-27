import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotify_app_clone/data/sources/local/local_storage_service.dart';
import 'package:spotify_app_clone/presentation/navigation/pages/nav_scaffold.dart';
import 'package:spotify_app_clone/service_locator.dart';
import 'package:spotify_app_clone/core/configs/assets/app_images.dart';
import 'package:spotify_app_clone/core/configs/assets/app_vectors.dart';
import 'package:spotify_app_clone/presentation/intro/pages/get_started_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppImages.onboardingImage), context);
    precacheImage(const AssetImage(AppImages.introBg), context);
    precacheImage(const AssetImage(AppImages.chooseMode), context);
    precacheImage(const AssetImage(AppImages.topCardImage), context);
  }

  @override
  void initState() {
    super.initState();
    redirect(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: SvgPicture.asset(AppVectors.logo)));
  }

  Future<void> redirect(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));

    final cachedUid = await sl<LocalStorageService>().getUid();
    final fbUser = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    final isLoggedIn = (fbUser != null) && (cachedUid == fbUser.uid);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              isLoggedIn ? const NavScaffold() : const GetStartedPage(),
        ),
      );
    }
  }
}
