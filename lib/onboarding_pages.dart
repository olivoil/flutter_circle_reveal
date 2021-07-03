import 'package:flutter/material.dart';

class Page {
  Page({
    required this.imageAssetPath,
    required this.imageAlignment,
    required this.backgroundColor,
    required this.title,
    required this.description,
    required this.backgroundBrightness,
    required this.textColor,
  });

  final Color backgroundColor;
  final String imageAssetPath;
  final Alignment imageAlignment;
  final String title;
  final String description;
  final Brightness backgroundBrightness;
  final Color textColor;
}

List<Page> pages = [
  Page(
    backgroundColor: Color(0xFF0638C2),
    imageAssetPath: "assets/images/page_01.jpg",
    imageAlignment: Alignment.center,
    title: "News",
    description: "Local news stories",
    textColor: Colors.white,
    backgroundBrightness: Brightness.dark,
  ),
  Page(
    backgroundColor: Color(0xFFF7AED6),
    imageAssetPath: "assets/images/page_02.jpg",
    imageAlignment: Alignment.center,
    title: "Topics",
    description: "Choose your interests",
    textColor: Colors.white,
    backgroundBrightness: Brightness.dark,
  ),
  Page(
    backgroundColor: Colors.white,
    imageAssetPath: "assets/images/page_03.jpg",
    imageAlignment: Alignment.center,
    title: "Browse",
    description: "Drag and drop to move",
    textColor: Colors.black,
    backgroundBrightness: Brightness.light,
  ),
];
