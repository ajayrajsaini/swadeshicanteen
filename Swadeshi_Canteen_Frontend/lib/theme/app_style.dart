import 'package:flutter/material.dart';
import 'app_colors.dart'; // Make sure this file contains your color palette

class AppStyles {
  // **AppBar Styles**
  static AppBar appBarStyle(String title) => AppBar(
        title: Text(
          title,
          style: heading3.copyWith(color: AppColors.textColor), // Used
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.appBarColor,
                AppColors.appBarColor
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
      );


  // **Text Styles**

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.accentColor,
  );
}
