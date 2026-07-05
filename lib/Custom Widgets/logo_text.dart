import 'package:flutter/material.dart';

class LogoAndText extends StatelessWidget {
  const LogoAndText({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Image(
            image: const AssetImage('assets/kuvaka_logo.png'),
            width: width / 4,
          ),
          const SizedBox(height: 8),
          Text(
            "Clinical AI platform by Kuvaka".toUpperCase(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}