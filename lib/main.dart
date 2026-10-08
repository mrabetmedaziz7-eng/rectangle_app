import 'package:flutter/material.dart';
import 'models/node.dart';
import 'widgets/options_sheet.dart';

void main() {
  runApp(const RectangleApp());
}

class RectangleApp extends StatelessWidget {
  const RectangleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rectangle Splitter',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
      ),
      home: const RectangleSplitScreen(),
    );
  }
}

class RectangleSplitScreen extends StatefulWidget {
  const RectangleSplitScreen({super.key});

  @override
  State<RectangleSplitScreen> createState() => _RectangleSplitScreenState();
}

class _RectangleSplitScreenState extends State<RectangleSplitScreen> {
  // Tree root
  late Node _root;

  // Global settings
  double _borderWidth = 1.5;
  double _cornerRadius = 0.0;
  bool _gradientMode = false;
  Color _baseColor = const Color(0xFFF5F5DC); // Default starting color: Beige

  @override
  void initState() {
    super.initState();
    _root = Node(
      isLeaf: true,
      orientation: SplitOrientation.vertical,
      color: _baseColor,
    );
  }

  /// Resets the tree to a single full-screen rectangle with the starting color (beige or specified).
  void _resetTree([Color? color]) {
    setState(() {
      if (color != null) {
        _baseColor = color;
      } else {
        _baseColor = const Color(0xFFF5F5DC);
      }
      _root = Node(
        isLeaf: true,
        orientation: SplitOrientation.vertical,
        color: _baseColor,
      );
    });
  }

  /// Opens the Options modal bottom sheet.
  void _openOptionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return OptionsSheet(
          borderWidth: _borderWidth,
          cornerRadius: _cornerRadius,
          gradientMode: _gradientMode,
          baseColor: _baseColor,
          onBorderWidthChanged: (val) {
            setState(() {
              _borderWidth = val;
            });
          },
          onCornerRadiusChanged: (val) {
            setState(() {
              _cornerRadius = val;
            });
          },
          onGradientModeChanged: (val) {
            setState(() {
              _gradientMode = val;
            });
          },
          onBaseColorSelected: (newColor) {
            _resetTree(newColor);
          },
        );
      },
    );
  }

  /// Recursively renders the space-partitioning tree.
  Widget _buildNode(Node node) {
    if (node.isLeaf) {
      final isLight =
          ThemeData.estimateBrightnessForColor(node.color) == Brightness.light;
      final textColor = isLight ? const Color(0xFF2C2523) : Colors.white;

      return SizedBox.expand(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                node.split(gradientMode: _gradientMode);
              });
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_cornerRadius),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: node.color,
                  borderRadius: BorderRadius.circular(_cornerRadius),
                  border: _borderWidth > 0
                      ? Border.all(
                          color: const Color(0xFF2C2523),
                          width: _borderWidth,
                        )
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${node.depth}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        shadows: [
                          Shadow(
                            color: isLight ? Colors.white60 : Colors.black54,
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (node.orientation == SplitOrientation.vertical) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildNode(node.children[0])),
          Expanded(child: _buildNode(node.children[1])),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildNode(node.children[0])),
          Expanded(child: _buildNode(node.children[1])),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int rectangleCount = countRectangles(_root);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rectangles : $rectangleCount',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 1,
        shadowColor: Colors.black26,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C2523),
        leading: IconButton(
          icon: const Icon(Icons.tune),
          tooltip: 'Options',
          onPressed: _openOptionsSheet,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Réinitialiser',
            onPressed: () => _resetTree(),
          ),
        ],
      ),
      body: SizedBox.expand(
        child: _buildNode(_root),
      ),
    );
  }
}
