class Detection {
  final double x;
  final double y;
  final double width;
  final double height;
  final double confidence;
  final int classId;
  final String className;

  Detection({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.confidence,
    required this.classId,
    required this.className,
  });
}
