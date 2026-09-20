import 'package:flutter/material.dart';

class AranLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AranLogo({super.key, this.size = 100, this.showText = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/aran_logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback if image fails to load
            return Icon(Icons.shield, size: size, color: const Color(0xFFE91E63));
          },
        ),
        if (showText) ...[
          const SizedBox(height: 15),
          const Text(
            'ARAN | அரண்',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE91E63),
              letterSpacing: 1.5,
            ),
          ),
          const Text(
            'உங்கள் பாதுகாப்பின் அரண்',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
