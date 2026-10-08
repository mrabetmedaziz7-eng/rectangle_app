import 'package:flutter/material.dart';
import '../models/node.dart';

class OptionsSheet extends StatefulWidget {
  final double borderWidth;
  final double cornerRadius;
  final bool gradientMode;
  final Color baseColor;
  final ValueChanged<double> onBorderWidthChanged;
  final ValueChanged<double> onCornerRadiusChanged;
  final ValueChanged<bool> onGradientModeChanged;
  final ValueChanged<Color> onBaseColorSelected;

  const OptionsSheet({
    super.key,
    required this.borderWidth,
    required this.cornerRadius,
    required this.gradientMode,
    required this.baseColor,
    required this.onBorderWidthChanged,
    required this.onCornerRadiusChanged,
    required this.onGradientModeChanged,
    required this.onBaseColorSelected,
  });

  @override
  State<OptionsSheet> createState() => _OptionsSheetState();
}

class _OptionsSheetState extends State<OptionsSheet> {
  late double _currentBorderWidth;
  late double _currentCornerRadius;
  late bool _currentGradientMode;
  late Color _currentBaseColor;

  @override
  void initState() {
    super.initState();
    _currentBorderWidth = widget.borderWidth;
    _currentCornerRadius = widget.cornerRadius;
    _currentGradientMode = widget.gradientMode;
    _currentBaseColor = widget.baseColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Paramètres',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2523),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Fermer',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. Largeur de bordure
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Largeur de bordure',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                '${_currentBorderWidth.toStringAsFixed(1)} px',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade700,
                ),
              ),
            ],
          ),
          Slider(
            value: _currentBorderWidth,
            min: 0.0,
            max: 12.0,
            divisions: 24,
            activeColor: const Color(0xFF3F51B5),
            onChanged: (val) {
              setState(() {
                _currentBorderWidth = val;
              });
              widget.onBorderWidthChanged(val);
            },
          ),
          const SizedBox(height: 12),

          // 2. Rayon des coins
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rayon des coins',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                '${_currentCornerRadius.toStringAsFixed(1)} px',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade700,
                ),
              ),
            ],
          ),
          Slider(
            value: _currentCornerRadius,
            min: 0.0,
            max: 32.0,
            divisions: 32,
            activeColor: const Color(0xFF3F51B5),
            onChanged: (val) {
              setState(() {
                _currentCornerRadius = val;
              });
              widget.onCornerRadiusChanged(val);
            },
          ),
          const SizedBox(height: 12),

          // 3. Mode dégradé (Switch)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mode dégradé',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _currentGradientMode
                          ? 'Nuances progressives de la couleur de base'
                          : 'Couleurs aléatoires à chaque découpe',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _currentGradientMode,
                activeThumbColor: const Color(0xFF3F51B5),
                onChanged: (val) {
                  setState(() {
                    _currentGradientMode = val;
                  });
                  widget.onGradientModeChanged(val);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4. Base color selection palette
          const Text(
            'Couleur de base',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Appuyez sur une couleur pour réinitialiser le rectangle de départ',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: Node.baseColorOptions.map((color) {
              final isSelected = color == _currentBaseColor;
              final isLight =
                  ThemeData.estimateBrightnessForColor(color) == Brightness.light;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentBaseColor = color;
                  });
                  widget.onBaseColorSelected(color);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2C2523)
                          : Colors.grey.shade400,
                      width: isSelected ? 3.0 : 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 20,
                          color: isLight ? Colors.black87 : Colors.white,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
