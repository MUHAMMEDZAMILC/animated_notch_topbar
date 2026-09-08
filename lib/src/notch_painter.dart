import 'package:flutter/material.dart';

/// Paints the pill shape with two concave (circle-cutout) bottom
/// corners — the "notch" that sits behind the active tab, matching a
/// CSS radial-gradient cutout look.
class NotchPainter extends CustomPainter {
  final Color color;
  final double cornerRadius;

  const NotchPainter({required this.color, this.cornerRadius = 9.62});

  @override
  void paint(Canvas canvas, Size size) {
    final r = cornerRadius;
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
      ..lineTo(size.width - r, 0)
      ..arcToPoint(Offset(size.width, r), radius: Radius.circular(r))
      ..lineTo(size.width, size.height - r)
      ..arcToPoint(
        Offset(size.width + r, size.height),
        radius: Radius.circular(r),
        clockwise: false,
      )
      ..lineTo(-r, size.height)
      ..arcToPoint(
        Offset(0, size.height - r),
        radius: Radius.circular(r),
        clockwise: false,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant NotchPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.cornerRadius != cornerRadius;
}

/// Simple two-balloon decorative illustration used in the header.
class BalloonIcon extends StatelessWidget {
  final double width;
  final Color frontColor;
  final Color backColor;
  final Color stringColor;

  const BalloonIcon({
    super.key,
    this.width = 78,
    this.frontColor = const Color(0xFFB19CD9),
    this.backColor = const Color(0xFF8A6FC9),
    this.stringColor = const Color(0xFF555555),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * 140 / 100,
      child: CustomPaint(
        painter: _BalloonPainter(
          frontColor: frontColor,
          backColor: backColor,
          stringColor: stringColor,
        ),
      ),
    );
  }
}

class _BalloonPainter extends CustomPainter {
  final Color frontColor;
  final Color backColor;
  final Color stringColor;

  const _BalloonPainter({
    required this.frontColor,
    required this.backColor,
    required this.stringColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 100, sy = size.height / 140;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(40 * sx, 35 * sy), width: 60 * sx, height: 76 * sy),
      Paint()..color = frontColor,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(75 * sx, 55 * sy), width: 40 * sx, height: 52 * sy),
      Paint()..color = backColor,
    );
    final linePaint = Paint()
      ..color = stringColor
      ..strokeWidth = 2;
    canvas.drawLine(
        Offset(40 * sx, 73 * sy), Offset(40 * sx, 95 * sy), linePaint);
    canvas.drawLine(
        Offset(75 * sx, 81 * sy), Offset(75 * sx, 95 * sy), linePaint);
  }

  @override
  bool shouldRepaint(covariant _BalloonPainter oldDelegate) => false;
}
