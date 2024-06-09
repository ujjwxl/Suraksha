import 'package:flutter/material.dart';

class OnboardingContent {
  String image;
  String title;
  String description;
  Color backgroundColor;

  OnboardingContent({
    required this.image,
    required this.title,
    required this.description,
    required this.backgroundColor,
  });
}

List<OnboardingContent> contentsList = [
  OnboardingContent(
    image: 'images/image1.png',
    title: 'Share your location',
    description: 'while travelling or when in transit',
    backgroundColor: const Color(0xffF0CF69),
  ),
  OnboardingContent(
    image: 'images/image2.png',
    title: 'Send an SOS',
    description: 'when in an emergency',
    backgroundColor: const Color(0xffB7ABFD),
  ),
  OnboardingContent(
    image: 'images/image8.png',
    title: 'Schdeule a Fake Call',
    description: 'to get out of uncomfortable situations',
    backgroundColor: const Color(0xff95B4FE),
  ),
];
