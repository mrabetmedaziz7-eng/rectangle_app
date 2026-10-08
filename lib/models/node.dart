import 'dart:math';
import 'package:flutter/material.dart';

/// The split orientation:
/// - [SplitOrientation.vertical]: cut vertically -> 2 rectangles side-by-side (left/right) in a Row.
/// - [SplitOrientation.horizontal]: cut horizontally -> 2 rectangles top/bottom in a Column.
enum SplitOrientation {
  vertical,
  horizontal,
}

/// A node in the recursive space-partitioning tree.
class Node {
  bool isLeaf;
  SplitOrientation orientation; // Direction to use IF this node splits next
  List<Node> children;
  Color color;
  int depth;

  Node({
    this.isLeaf = true,
    this.orientation = SplitOrientation.vertical,
    List<Node>? children,
    this.color = const Color(0xFFF5F5DC), // Default starting color: Beige
    this.depth = 0,
  }) : children = children ?? [];

  /// Curated palette of harmonious, vibrant, non-muddy colors
  static const List<Color> aestheticPalette = [
    Color(0xFFE57373), // Coral Red
    Color(0xFFF06292), // Vibrant Pink
    Color(0xFFBA68C8), // Medium Orchid
    Color(0xFF9575CD), // Lavender Purple
    Color(0xFF7986CB), // Indigo
    Color(0xFF64B5F6), // Sky Blue
    Color(0xFF4FC3F7), // Light Blue
    Color(0xFF4DD0E1), // Cyan
    Color(0xFF4DB6AC), // Soft Teal
    Color(0xFF81C784), // Mint Green
    Color(0xFFAED581), // Light Olive Green
    Color(0xFFFFD54F), // Warm Amber
    Color(0xFFFFB74D), // Tangerine
    Color(0xFFFF8A65), // Coral Orange
    Color(0xFFA1887F), // Warm Taupe
    Color(0xFF90A4AE), // Slate Blue Grey
    Color(0xFFD4E157), // Lime
    Color(0xFF26A69A), // Persian Teal
    Color(0xFF26C6DA), // Aqua
    Color(0xFFFFA726), // Orange
  ];

  /// Base color options for Gradient Mode
  static const List<Color> baseColorOptions = [
    Color(0xFFF5F5DC), // Beige (classic default)
    Color(0xFF3F51B5), // Deep Indigo
    Color(0xFF009688), // Emerald Teal
    Color(0xFFE91E63), // Rose Pink
    Color(0xFFFF9800), // Sunset Amber
    Color(0xFF4CAF50), // Forest Green
    Color(0xFF9C27B0), // Royal Purple
    Color(0xFF00BCD4), // Ocean Cyan
    Color(0xFFF44336), // Crimson Red
    Color(0xFF607D8B), // Slate Grey
  ];

  static final Random _random = Random();

  /// Returns a random color from the curated palette
  static Color getRandomColor() {
    return aestheticPalette[_random.nextInt(aestheticPalette.length)];
  }

  /// Splits this leaf node into two child leaf nodes.
  /// - If [gradientMode] is true: child colors are shades/tints of the parent's color using HSL.
  /// - If [gradientMode] is false: each child gets a fresh random color from the palette.
  void split({required bool gradientMode}) {
    if (!isLeaf) return;
    isLeaf = false;

    final nextOrientation = orientation == SplitOrientation.vertical
        ? SplitOrientation.horizontal
        : SplitOrientation.vertical;

    Color childColor1;
    Color childColor2;

    if (gradientMode) {
      final hsl = HSLColor.fromColor(color);
      // Produce two complementary shades: one darker/richer, one lighter/softer
      final double l1 = (hsl.lightness - 0.10).clamp(0.12, 0.90);
      final double l2 = (hsl.lightness + 0.10).clamp(0.12, 0.90);
      final double s1 = (hsl.saturation + 0.05).clamp(0.20, 0.98);
      final double s2 = (hsl.saturation - 0.05).clamp(0.20, 0.98);

      childColor1 = hsl.withLightness(l1).withSaturation(s1).toColor();
      childColor2 = hsl.withLightness(l2).withSaturation(s2).toColor();
    } else {
      childColor1 = getRandomColor();
      Color c2 = getRandomColor();
      // Try to pick a different color for the sibling
      if (aestheticPalette.length > 1) {
        int attempts = 0;
        while (c2 == childColor1 && attempts < 10) {
          c2 = getRandomColor();
          attempts++;
        }
      }
      childColor2 = c2;
    }

    children = [
      Node(
        isLeaf: true,
        orientation: nextOrientation,
        color: childColor1,
        depth: depth + 1,
      ),
      Node(
        isLeaf: true,
        orientation: nextOrientation,
        color: childColor2,
        depth: depth + 1,
      ),
    ];
  }

  /// Returns the total count of leaf rectangles currently in this sub-tree.
  int get leafCount {
    if (isLeaf) return 1;
    if (children.isEmpty) return 1;
    return children.fold(0, (sum, child) => sum + child.leafCount);
  }
}

/// Recursively counts the number of leaf rectangles in the tree.
int countRectangles(Node node) {
  if (node.isLeaf) return 1;
  if (node.children.isEmpty) return 1;
  return node.children.map(countRectangles).reduce((a, b) => a + b);
}

