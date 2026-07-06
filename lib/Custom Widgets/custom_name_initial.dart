import 'package:flutter/material.dart';

import '../colors.dart';
import '../functions.dart';


class CustomNameInitial extends StatelessWidget {
  const CustomNameInitial({
    super.key,
    required this.gender,
    required this.name,
    this.size = 40,
  });

  final String gender;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: gender == "Male"
            ? AppColors.secondaryMale
            : gender == "Female"
            ? AppColors.secondaryFemale
            : AppColors.secondaryOther,
      ),
      width: size,
      height: size,
      child: Center(
        child: Text(
          getInitials(name),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: gender == "Male"
                ? AppColors.primaryMale
                : gender == "Female"
                ? AppColors.primaryFemale
                : AppColors.primaryOther,
            fontSize: size/2.5
          ),
        ),
      ),
    );
  }
}