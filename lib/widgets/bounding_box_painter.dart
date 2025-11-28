import 'package:flutter/material.dart';
import '../models/detection.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<Detection> detections;
  final Size imageSize;

  BoundingBoxPainter({
    required this.detections,
    required this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var detection in detections) {
      // Scale coordinates from model output (640x640) to screen size
      final scaleX = size.width / 640;
      final scaleY = size.height / 640;

      final left = (detection.x - detection.width / 2) * scaleX;
      final top = (detection.y - detection.height / 2) * scaleY;
      final width = detection.width * scaleX;
      final height = detection.height * scaleY;

      final rect = Rect.fromLTWH(left, top, width, height);

      // Draw bounding box (red for disease)
      paint.color = Colors.red;
      canvas.drawRect(rect, paint);

      // Draw label background
      final label = '${detection.className} ${(detection.confidence * 100).toStringAsFixed(0)}%';
      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();

      final labelRect = Rect.fromLTWH(
        left,
        top - 20,
        textPainter.width + 8,
        20,
      );

      canvas.drawRect(labelRect, Paint()..color = Colors.red);
      textPainter.paint(canvas, Offset(left + 4, top - 18));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
