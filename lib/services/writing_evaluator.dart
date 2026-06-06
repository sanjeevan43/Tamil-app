import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class WritingEvaluator {
  // Normalized key-points for each vowel (0.0 to 1.0)
  static final Map<String, List<Offset>> templates = {
    'அ': [
      const Offset(0.3, 0.3), const Offset(0.4, 0.2), const Offset(0.5, 0.3),
      const Offset(0.4, 0.4), const Offset(0.25, 0.5), const Offset(0.2, 0.7),
      const Offset(0.4, 0.85), const Offset(0.6, 0.75), const Offset(0.5, 0.55),
      const Offset(0.35, 0.55), const Offset(0.75, 0.55), const Offset(0.75, 0.25),
      const Offset(0.75, 0.85)
    ],
    'ஆ': [
      const Offset(0.3, 0.3), const Offset(0.4, 0.2), const Offset(0.5, 0.3),
      const Offset(0.4, 0.4), const Offset(0.25, 0.5), const Offset(0.2, 0.7),
      const Offset(0.4, 0.85), const Offset(0.6, 0.75), const Offset(0.5, 0.55),
      const Offset(0.35, 0.55), const Offset(0.75, 0.55), const Offset(0.75, 0.25),
      const Offset(0.75, 0.85), const Offset(0.85, 0.85), const Offset(0.9, 0.7),
      const Offset(0.8, 0.6), const Offset(0.7, 0.75), const Offset(0.8, 0.9)
    ],
    'இ': [
      const Offset(0.3, 0.3), const Offset(0.4, 0.2), const Offset(0.5, 0.3),
      const Offset(0.4, 0.4), const Offset(0.25, 0.5), const Offset(0.3, 0.7),
      const Offset(0.5, 0.8), const Offset(0.7, 0.65), const Offset(0.6, 0.45),
      const Offset(0.4, 0.5), const Offset(0.25, 0.6), const Offset(0.4, 0.85),
      const Offset(0.65, 0.9), const Offset(0.85, 0.75)
    ],
    'ஈ': [
      const Offset(0.2, 0.2), const Offset(0.2, 0.8), const Offset(0.2, 0.2),
      const Offset(0.8, 0.2), const Offset(0.8, 0.8), const Offset(0.5, 0.2),
      const Offset(0.5, 0.8), const Offset(0.35, 0.5), const Offset(0.65, 0.5)
    ],
    'உ': [
      const Offset(0.3, 0.3), const Offset(0.4, 0.2), const Offset(0.5, 0.3),
      const Offset(0.4, 0.4), const Offset(0.25, 0.6), const Offset(0.3, 0.8),
      const Offset(0.6, 0.8), const Offset(0.8, 0.8)
    ],
    'ஊ': [
      const Offset(0.2, 0.3), const Offset(0.3, 0.2), const Offset(0.4, 0.3),
      const Offset(0.3, 0.4), const Offset(0.2, 0.6), const Offset(0.25, 0.8),
      const Offset(0.5, 0.8), const Offset(0.6, 0.8), const Offset(0.6, 0.5),
      const Offset(0.7, 0.4), const Offset(0.8, 0.5), const Offset(0.7, 0.6),
      const Offset(0.65, 0.8), const Offset(0.85, 0.8)
    ],
    'எ': [
      const Offset(0.2, 0.6), const Offset(0.3, 0.5), const Offset(0.4, 0.6),
      const Offset(0.3, 0.7), const Offset(0.2, 0.8), const Offset(0.5, 0.8),
      const Offset(0.8, 0.8), const Offset(0.8, 0.3)
    ],
    'ஏ': [
      const Offset(0.2, 0.6), const Offset(0.3, 0.5), const Offset(0.4, 0.6),
      const Offset(0.3, 0.7), const Offset(0.2, 0.8), const Offset(0.5, 0.8),
      const Offset(0.8, 0.8), const Offset(0.8, 0.3), const Offset(0.8, 0.8),
      const Offset(0.9, 0.95)
    ],
    'ஐ': [
      const Offset(0.2, 0.3), const Offset(0.3, 0.2), const Offset(0.4, 0.3),
      const Offset(0.3, 0.4), const Offset(0.2, 0.5), const Offset(0.4, 0.5),
      const Offset(0.6, 0.5), const Offset(0.5, 0.7), const Offset(0.4, 0.9),
      const Offset(0.6, 0.9), const Offset(0.8, 0.8), const Offset(0.8, 0.4)
    ],
    'ஒ': [
      const Offset(0.3, 0.3), const Offset(0.4, 0.2), const Offset(0.5, 0.3),
      const Offset(0.4, 0.4), const Offset(0.25, 0.5), const Offset(0.3, 0.7),
      const Offset(0.5, 0.6), const Offset(0.65, 0.75), const Offset(0.5, 0.9),
      const Offset(0.35, 0.85), const Offset(0.65, 0.9), const Offset(0.8, 0.7)
    ],
    'ஓ': [
      const Offset(0.3, 0.3), const Offset(0.4, 0.2), const Offset(0.5, 0.3),
      const Offset(0.4, 0.4), const Offset(0.25, 0.5), const Offset(0.3, 0.7),
      const Offset(0.5, 0.6), const Offset(0.65, 0.75), const Offset(0.5, 0.9),
      const Offset(0.35, 0.85), const Offset(0.65, 0.9), const Offset(0.8, 0.7),
      const Offset(0.85, 0.85), const Offset(0.75, 0.9)
    ],
    'ஔ': [
      const Offset(0.15, 0.3), const Offset(0.25, 0.2), const Offset(0.35, 0.3),
      const Offset(0.25, 0.4), const Offset(0.15, 0.5), const Offset(0.2, 0.7),
      const Offset(0.35, 0.6), const Offset(0.45, 0.75), const Offset(0.35, 0.9),
      const Offset(0.2, 0.85), const Offset(0.45, 0.9), const Offset(0.55, 0.7),
      const Offset(0.65, 0.5), const Offset(0.75, 0.4), const Offset(0.85, 0.5),
      const Offset(0.75, 0.6), const Offset(0.7, 0.8), const Offset(0.9, 0.8)
    ],
    'ஃ': [
      const Offset(0.5, 0.25), const Offset(0.3, 0.75), const Offset(0.7, 0.75)
    ],
  };

  /// Normalizes a list of drawn points to a 0.0 to 1.0 bounding box coordinate space.
  static List<Offset> normalizePoints(List<Offset> points) {
    final validPoints = points.where((p) => p != Offset.infinite).toList();
    if (validPoints.isEmpty) return [];

    double minX = validPoints.first.dx;
    double maxX = validPoints.first.dx;
    double minY = validPoints.first.dy;
    double maxY = validPoints.first.dy;

    for (final p in validPoints) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }

    double width = maxX - minX;
    double height = maxY - minY;
    
    // Prevent division by zero for single points or vertical/horizontal lines
    if (width < 5) width = 5;
    if (height < 5) height = 5;

    return validPoints.map((p) {
      return Offset(
        (p.dx - minX) / width,
        (p.dy - minY) / height,
      );
    }).toList();
  }

  /// Calculates similarity percentage between user drawn points and reference templates for all 247 characters
  static double evaluateSimilarity(String letter, List<Offset> userPoints, double canvasWidth, double canvasHeight) {
    if (canvasWidth <= 0) canvasWidth = 400.0;
    if (canvasHeight <= 0) canvasHeight = 400.0;

    final template = templates[letter];
    if (template == null || template.isEmpty) {
      // Fallback for letters without skeletons: check how much is drawn on/near the actual letter region
      // The letter guide is centered, occupying about 64% of the canvas.
      // So the bounding box is roughly x in [0.18, 0.82] and y in [0.18, 0.82].
      // Any points drawn outside this central box (i.e. in the white space / margins) are considered incorrect/noise points.
      final validPoints = userPoints.where((p) => p != Offset.infinite).toList();
      if (validPoints.isEmpty) return 0.0;
      
      int onLetterPoints = 0;
      double totalLength = 0.0;
      for (int i = 0; i < validPoints.length; i++) {
        final p = validPoints[i];
        final nx = p.dx / canvasWidth;
        final ny = p.dy / canvasHeight;
        
        // Is the point inside the central letter guide area?
        if (nx >= 0.18 && nx <= 0.82 && ny >= 0.18 && ny <= 0.82) {
          onLetterPoints++;
        }
        
        if (i < validPoints.length - 1) {
          final nextPoint = validPoints[i+1];
          totalLength += (p - nextPoint).distance;
        }
      }
      
      final double accuracy = onLetterPoints / validPoints.length;
      final double targetLength = (canvasWidth + canvasHeight) * 0.38; // Proportional target length for handwriting
      final double coverage = (totalLength / targetLength).clamp(0.0, 1.0);
      
      return accuracy * coverage;
    }

    final validPoints = userPoints.where((p) => p != Offset.infinite).toList();
    if (validPoints.isEmpty) return 0.0;

    // Normalize points relative to the actual canvas size so coordinates match the template's space [0.0, 1.0]
    final normalizedUser = validPoints.map((p) {
      return Offset(
        (p.dx / canvasWidth).clamp(0.0, 1.0),
        (p.dy / canvasHeight).clamp(0.0, 1.0),
      );
    }).toList();

    // 1. Calculate how many user points are actually close to the template path (accuracy)
    int correctPoints = 0;
    for (final uPoint in normalizedUser) {
      double minDist = double.infinity;
      for (final tPoint in template) {
        final dist = (uPoint - tPoint).distance;
        if (dist < minDist) {
          minDist = dist;
        }
      }
      // If the point is within 11% of any template point, it's correct!
      if (minDist <= 0.11) {
        correctPoints++;
      }
    }

    // Accuracy is the percentage of user drawn points that were on the letter path
    final double accuracy = correctPoints / normalizedUser.length;

    // 2. Calculate coverage (recall): how much of the template did the user cover?
    int coveredPoints = 0;
    for (final tPoint in template) {
      bool isCovered = false;
      for (final uPoint in normalizedUser) {
        final dist = (tPoint - uPoint).distance;
        if (dist <= 0.11) {
          isCovered = true;
          break;
        }
      }
      if (isCovered) {
        coveredPoints++;
      }
    }
    final double coverage = coveredPoints / template.length;

    // Overall similarity is the product of accuracy and coverage!
    // If the user draws in the white space, accuracy drops extremely low, keeping the stars down.
    final double similarity = accuracy * coverage;

    return similarity;
  }

  /// Evaluates stars earned: 3 stars (excellent), 2 stars (good), 1 star (needs improvement)
  static int getStarsEarned(double similarity) {
    if (similarity >= 0.70) return 3;
    if (similarity >= 0.45) return 2;
    return 0;
  }

  /// Checks if a local coordinate point is close to the letter path (strict template skeleton proximity)
  static bool isNearPath(String letter, Offset localPoint, double canvasWidth, double canvasHeight) {
    final template = templates[letter];
    if (template == null || template.isEmpty) {
      // Fallback to central 80% tracing zone for combinations/mei letters that don't have hardcoded skeletons yet
      final double nx = localPoint.dx / canvasWidth;
      final double ny = localPoint.dy / canvasHeight;
      return nx >= 0.1 && nx <= 0.9 && ny >= 0.1 && ny <= 0.9;
    }
    
    // Normalize the local point to [0.0, 1.0] range
    final double nx = localPoint.dx / canvasWidth;
    final double ny = localPoint.dy / canvasHeight;
    final normalizedPoint = Offset(nx, ny);
    
    // Find the minimum distance to any skeletal segment/point of the target letter
    double minDistance = double.infinity;
    for (final tPoint in template) {
      final distance = (tPoint - normalizedPoint).distance;
      if (distance < minDistance) {
        minDistance = distance;
      }
    }
    
    // Strict threshold (13% of canvas size) - only registers points directly on top of the letter path!
    return minDistance <= 0.13;
  }

  /// Dynamically generates a binary mask of the target character rendered off-screen
  static Future<List<bool>> generateTemplateMask(String letter, double targetSize) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, targetSize, targetSize));

    // Paint white background
    final bgPaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawRect(Rect.fromLTWH(0, 0, targetSize, targetSize), bgPaint);

    // Paint text in black, sized to fit the offscreen canvas
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: GoogleFonts.notoSansTamil(
          fontSize: targetSize * 0.58,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF000000),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final textOffset = Offset(
      (targetSize - textPainter.width) / 2,
      (targetSize - textPainter.height) / 2,
    );
    textPainter.paint(canvas, textOffset);

    final picture = recorder.endRecording();
    final image = await picture.toImage(targetSize.toInt(), targetSize.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();

    if (byteData == null) return List.filled(targetSize.toInt() * targetSize.toInt(), false);

    final bytes = byteData.buffer.asUint8List();
    final int totalPixels = targetSize.toInt() * targetSize.toInt();
    final mask = List<bool>.filled(totalPixels, false);

    for (int i = 0; i < totalPixels; i++) {
      final offset = i * 4;
      if (offset + 3 >= bytes.length) continue;
      final r = bytes[offset];
      final g = bytes[offset + 1];
      final b = bytes[offset + 2];
      final a = bytes[offset + 3];

      final luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b;
      if (luminance < 150 && a > 50) {
        mask[i] = true;
      }
    }

    return mask;
  }

  /// Dynamically generates a binary mask of the user's drawing scaled to the targetSize
  static Future<List<bool>> generateUserMask(
    List<Offset> userPoints,
    double canvasWidth,
    double canvasHeight,
    double targetSize,
  ) async {
    if (canvasWidth <= 0) canvasWidth = 400.0;
    if (canvasHeight <= 0) canvasHeight = 400.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, targetSize, targetSize));

    // Paint white background
    final bgPaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawRect(Rect.fromLTWH(0, 0, targetSize, targetSize), bgPaint);

    // Paint user strokes in black with proportional stroke width
    final paint = Paint()
      ..color = const Color(0xFF000000)
      ..strokeWidth = targetSize * 0.045 // Proportional stroke width (approx 6.7 pixels)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final double scaleX = targetSize / canvasWidth;
    final double scaleY = targetSize / canvasHeight;

    for (int i = 0; i < userPoints.length - 1; i++) {
      if (userPoints[i] != Offset.infinite && userPoints[i + 1] != Offset.infinite) {
        final p1 = Offset(userPoints[i].dx * scaleX, userPoints[i].dy * scaleY);
        final p2 = Offset(userPoints[i + 1].dx * scaleX, userPoints[i + 1].dy * scaleY);
        canvas.drawLine(p1, p2, paint);
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(targetSize.toInt(), targetSize.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();

    if (byteData == null) return List.filled(targetSize.toInt() * targetSize.toInt(), false);

    final bytes = byteData.buffer.asUint8List();
    final int totalPixels = targetSize.toInt() * targetSize.toInt();
    final mask = List<bool>.filled(totalPixels, false);

    for (int i = 0; i < totalPixels; i++) {
      final offset = i * 4;
      if (offset + 3 >= bytes.length) continue;
      final r = bytes[offset];
      final g = bytes[offset + 1];
      final b = bytes[offset + 2];
      final a = bytes[offset + 3];

      final luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b;
      if (luminance < 150 && a > 50) {
        mask[i] = true;
      }
    }

    return mask;
  }

  /// Dilates a binary pixel mask with a given radius to allow natural tracing tolerance
  static List<bool> dilateMask(List<bool> mask, int size, int radius) {
    final dilated = List<bool>.filled(mask.length, false);
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        if (mask[y * size + x]) {
          for (int dy = -radius; dy <= radius; dy++) {
            final ny = y + dy;
            if (ny < 0 || ny >= size) continue;
            for (int dx = -radius; dx <= radius; dx++) {
              final nx = x + dx;
              if (nx < 0 || nx >= size) continue;
              dilated[ny * size + nx] = true;
            }
          }
        }
      }
    }
    return dilated;
  }

  /// Calculates Intersection over Union (IoU) similarity between template and user drawing masks
  static double evaluateIoUSimilarity(List<bool> templateMask, List<bool> userMask) {
    if (templateMask.length != userMask.length) return 0.0;

    int intersection = 0;
    int union = 0;

    for (int i = 0; i < templateMask.length; i++) {
      final t = templateMask[i];
      final u = userMask[i];

      if (t && u) {
        intersection++;
      }
      if (t || u) {
        union++;
      }
    }

    if (union == 0) return 0.0;
    return intersection / union;
  }

  /// Calculates Cosine Similarity between X and Y projection profiles of two masks
  static double calculateProjectionSimilarity(List<bool> templateMask, List<bool> userMask, int size) {
    final tX = List<double>.filled(size, 0.0);
    final tY = List<double>.filled(size, 0.0);
    final uX = List<double>.filled(size, 0.0);
    final uY = List<double>.filled(size, 0.0);

    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        if (templateMask[y * size + x]) {
          tX[x] += 1.0;
          tY[y] += 1.0;
        }
        if (userMask[y * size + x]) {
          uX[x] += 1.0;
          uY[y] += 1.0;
        }
      }
    }

    double dotX = 0.0;
    double normTX = 0.0;
    double normUX = 0.0;

    double dotY = 0.0;
    double normTY = 0.0;
    double normUY = 0.0;

    for (int i = 0; i < size; i++) {
      dotX += tX[i] * uX[i];
      normTX += tX[i] * tX[i];
      normUX += uX[i] * uX[i];

      dotY += tY[i] * uY[i];
      normTY += tY[i] * tY[i];
      normUY += uY[i] * uY[i];
    }

    if (normTX == 0 || normUX == 0 || normTY == 0 || normUY == 0) return 0.0;

    final cosX = dotX / (math.sqrt(normTX) * math.sqrt(normUX));
    final cosY = dotY / (math.sqrt(normTY) * math.sqrt(normUY));

    return (cosX + cosY) / 2.0;
  }

  // Helper method to compute the 2D Rosenfeld-Pfaltz Distance Transform
  static List<double> _computeDistanceTransform(List<bool> mask, int size) {
    final dist = List<double>.filled(size * size, 1e9);
    for (int i = 0; i < mask.length; i++) {
      if (mask[i]) {
        dist[i] = 0.0;
      }
    }

    // Forward pass: left-to-right, top-to-bottom
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final idx = y * size + x;
        double d = dist[idx];
        if (x > 0) {
          d = math.min(d, dist[idx - 1] + 1.0);
        }
        if (y > 0) {
          d = math.min(d, dist[idx - size] + 1.0);
        }
        if (x > 0 && y > 0) {
          d = math.min(d, dist[idx - size - 1] + 1.414);
        }
        if (x < size - 1 && y > 0) {
          d = math.min(d, dist[idx - size + 1] + 1.414);
        }
        dist[idx] = d;
      }
    }

    // Backward pass: right-to-left, bottom-to-top
    for (int y = size - 1; y >= 0; y--) {
      for (int x = size - 1; x >= 0; x--) {
        final idx = y * size + x;
        double d = dist[idx];
        if (x < size - 1) {
          d = math.min(d, dist[idx + 1] + 1.0);
        }
        if (y < size - 1) {
          d = math.min(d, dist[idx + size] + 1.0);
        }
        if (x < size - 1 && y < size - 1) {
          d = math.min(d, dist[idx + size + 1] + 1.414);
        }
        if (x > 0 && y < size - 1) {
          d = math.min(d, dist[idx + size - 1] + 1.414);
        }
        dist[idx] = d;
      }
    }

    return dist;
  }

  /// Calculates Bidirectional Chamfer Distance Similarity between template and user drawing masks
  static double evaluateChamferSimilarity(List<bool> templateMask, List<bool> userMask, int size) {
    final tIndices = <int>[];
    final uIndices = <int>[];

    for (int i = 0; i < templateMask.length; i++) {
      if (templateMask[i]) tIndices.add(i);
      if (userMask[i]) uIndices.add(i);
    }

    if (tIndices.isEmpty || uIndices.isEmpty) return 0.0;

    // 1. Compute Distance Transforms for template and user masks
    final dtTemplate = _computeDistanceTransform(templateMask, size);
    final dtUser = _computeDistanceTransform(userMask, size);

    // 2. User Error: Average distance from user pixels to the template
    double totalUserDist = 0.0;
    for (final uIdx in uIndices) {
      totalUserDist += dtTemplate[uIdx];
    }
    final double userError = totalUserDist / uIndices.length;

    // 3. Template Error: Average distance from template pixels to the user's drawing
    double totalTemplateDist = 0.0;
    for (final tIdx in tIndices) {
      totalTemplateDist += dtUser[tIdx];
    }
    final double templateError = totalTemplateDist / tIndices.length;

    // Average shape error
    final double averageError = (userError + templateError) / 2.0;
    final double baseSimilarity = math.exp(-averageError / 8.0);

    // Apply strict penalty for excessive drawing (scribbling/shading/filling canvas)
    final double userPixels = uIndices.length.toDouble();
    final double templatePixels = tIndices.length.toDouble();
    double penalty = 1.0;
    if (userPixels > templatePixels * 1.35) {
      final double excessRatio = userPixels / (templatePixels * 1.35);
      penalty = math.exp(-(excessRatio - 1.0) * 1.8);
    }

    return baseSimilarity * penalty;
  }
}
