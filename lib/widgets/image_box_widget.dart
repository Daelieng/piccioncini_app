import 'package:flutter/material.dart';

class ImageBoxWidget extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;

  const ImageBoxWidget({
    Key? key,
    required this.imagePath,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, 
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26, 
            blurRadius: 6, 
            spreadRadius: 2
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(imagePath, fit: BoxFit.cover),
      ),
    );
  }
}