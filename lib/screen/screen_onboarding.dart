import 'package:flutter/material.dart';

import '_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});
  static const name = 'onboarding';
  static const path = '/onboarding';
  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: OnBoardingSubmittedButton(
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
