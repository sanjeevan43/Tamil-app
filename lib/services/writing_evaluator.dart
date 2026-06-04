import 'dart:math';
import 'package:flutter/material.dart';

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
    if (similarity >= 0.82) return 3;
    if (similarity >= 0.58) return 2;
    return 1;
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
}
