import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.size = 40,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBorderRadius = BorderRadius.circular(size * 0.25);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? defaultBorderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? defaultBorderRadius,
        child: Image.asset(
          'assets/icons/logo.png',
          width: size,
          height: size,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to a gradient container with icon
            return Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0D9488), // primaryTeal
                    Color(0xFF2563EB), // accentBlue
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: borderRadius ?? defaultBorderRadius,
              ),
              child: Icon(
                Icons.dashboard,
                color: Colors.white,
                size: size * 0.5,
              ),
            );
          },
        ),
      ),
    );
  }
}
