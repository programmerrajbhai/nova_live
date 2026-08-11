import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomCachedAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final String fallbackText;

  const CustomCachedAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 50,
    this.fallbackText = 'U',
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF1A1A2E), // Dark theme background
      child: imageUrl.isEmpty
          ? Text(
        fallbackText.substring(0, 1).toUpperCase(),
        style: TextStyle(
          fontSize: radius * 0.8,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      )
          : ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (context, url) => CircularProgressIndicator(
            color: Colors.purpleAccent.withOpacity(0.5),
            strokeWidth: 2,
          ),
          errorWidget: (context, url, error) => const Icon(
            Icons.person,
            color: Colors.white54,
            size: 40,
          ),
        ),
      ),
    );
  }
}