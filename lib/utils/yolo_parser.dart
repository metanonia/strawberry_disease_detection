import 'dart:math';
import '../models/detection.dart';

class YoloParser {
  // Class names for strawberry diseases
  static const List<String> classNames = [
    '열매_잿빛곰팡이병',
    '열매_흰가루병',
    '잎_흰가루병',
    '잎_역병',
    '잎_시들음병',
    '잎_잎끝마름',
    '잎_황화',
  ];

  static List<Detection> parseYoloOutput(
    List<double> output,
    double confidenceThreshold,
    double iouThreshold,
  ) {
    // YOLO output is typically [1, 84, 8400] for YOLOv8
    // Transposed to [8400, 84] where each row is [x, y, w, h, class0_conf, class1_conf, ...]
    
    final int numDetections = 8400;
    final int numClasses = classNames.length;
    final int stride = 4 + numClasses; // x, y, w, h + class scores

    List<Detection> detections = [];

    for (int i = 0; i < numDetections; i++) {
      final int offset = i * stride;
      
      // Get bounding box
      final double x = output[offset];
      final double y = output[offset + 1];
      final double w = output[offset + 2];
      final double h = output[offset + 3];

      // Find max class score
      double maxScore = 0;
      int maxClassId = 0;
      
      for (int c = 0; c < numClasses; c++) {
        final double score = output[offset + 4 + c];
        if (score > maxScore) {
          maxScore = score;
          maxClassId = c;
        }
      }

      // Filter by confidence
      if (maxScore > confidenceThreshold) {
        detections.add(Detection(
          x: x,
          y: y,
          width: w,
          height: h,
          confidence: maxScore,
          classId: maxClassId,
          className: classNames[maxClassId],
        ));
      }
    }

    // Apply NMS
    return _nonMaxSuppression(detections, iouThreshold);
  }

  static List<Detection> _nonMaxSuppression(
    List<Detection> detections,
    double iouThreshold,
  ) {
    // Sort by confidence
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));

    List<Detection> result = [];
    List<bool> suppressed = List.filled(detections.length, false);

    for (int i = 0; i < detections.length; i++) {
      if (suppressed[i]) continue;
      
      result.add(detections[i]);

      for (int j = i + 1; j < detections.length; j++) {
        if (suppressed[j]) continue;
        
        final double iou = _calculateIoU(detections[i], detections[j]);
        if (iou > iouThreshold) {
          suppressed[j] = true;
        }
      }
    }

    return result;
  }

  static double _calculateIoU(Detection a, Detection b) {
    final double x1 = max(a.x - a.width / 2, b.x - b.width / 2);
    final double y1 = max(a.y - a.height / 2, b.y - b.height / 2);
    final double x2 = min(a.x + a.width / 2, b.x + b.width / 2);
    final double y2 = min(a.y + a.height / 2, b.y + b.height / 2);

    final double intersectionArea = max(0, x2 - x1) * max(0, y2 - y1);
    final double unionArea = a.width * a.height + b.width * b.height - intersectionArea;

    return intersectionArea / unionArea;
  }
}
