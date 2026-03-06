import 'package:flutter/material.dart';
import 'package:flutter_checkbox/flutter_checkbox.dart';

void main() {
  runApp(const PlaygroundApp());
}

class PlaygroundApp extends StatelessWidget {
  const PlaygroundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CustomCheckbox Playground',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const PlaygroundPage(),
    );
  }
}

class PlaygroundPage extends StatefulWidget {
  const PlaygroundPage({super.key});

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> {
  // --- Playground controls ---
  double _size = 24;
  double _borderWidth = 2;
  double _borderRadius = 4;
  double _checkStrokeWidth = 2.5;
  Color _activeColor = Colors.indigo;
  Color _checkColor = Colors.white;
  bool _enabled = true;

  // --- Checkbox states ---
  bool _check1 = false;
  bool _check2 = true;
  bool _check3 = false;

  static const _colorOptions = {
    'Indigo': Colors.indigo,
    'Red': Colors.red,
    'Green': Colors.green,
    'Orange': Colors.orange,
    'Purple': Colors.purple,
    'Teal': Colors.teal,
  };

  static const _checkColorOptions = {
    'White': Colors.white,
    'Black': Colors.black,
    'Yellow': Colors.yellow,
  };

  CheckboxStyle get _currentStyle => CheckboxStyle(
        size: _size,
        borderWidth: _borderWidth,
        borderRadius: _borderRadius,
        checkStrokeWidth: _checkStrokeWidth,
        activeColor: _activeColor,
        checkColor: _checkColor,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CustomCheckbox Playground')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildPreviewSection(),
          const Divider(height: 40),
          _buildControlsSection(),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // Preview
  // ──────────────────────────────────────────

  Widget _buildPreviewSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preview', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            Wrap(
              spacing: 32,
              runSpacing: 20,
              children: [
                CustomCheckbox(
                  value: _check1,
                  label: 'Default label',
                  style: _currentStyle,
                  enabled: _enabled,
                  onChanged: (v) => setState(() => _check1 = v),
                ),
                CustomCheckbox(
                  value: _check2,
                  style: _currentStyle,
                  enabled: _enabled,
                  onChanged: (v) => setState(() => _check2 = v),
                ),
                CustomCheckbox(
                  value: _check3,
                  labelWidget: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      SizedBox(width: 4),
                      Text('Custom widget'),
                    ],
                  ),
                  style: _currentStyle,
                  enabled: _enabled,
                  onChanged: (v) => setState(() => _check3 = v),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // Controls
  // ──────────────────────────────────────────

  Widget _buildControlsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Controls', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _buildSlider('Size', _size, 12, 64, (v) => setState(() => _size = v)),
        _buildSlider('Border Width', _borderWidth, 0.5, 6,
            (v) => setState(() => _borderWidth = v)),
        _buildSlider('Border Radius', _borderRadius, 0, 32,
            (v) => setState(() => _borderRadius = v)),
        _buildSlider('Check Stroke', _checkStrokeWidth, 1, 6,
            (v) => setState(() => _checkStrokeWidth = v)),
        const SizedBox(height: 8),
        _buildColorPicker('Active Color', _colorOptions, _activeColor,
            (c) => setState(() => _activeColor = c)),
        const SizedBox(height: 8),
        _buildColorPicker('Check Color', _checkColorOptions, _checkColor,
            (c) => setState(() => _checkColor = c)),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Enabled'),
          value: _enabled,
          contentPadding: EdgeInsets.zero,
          onChanged: (v) => setState(() => _enabled = v),
        ),
      ],
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 48, child: Text(value.toStringAsFixed(1))),
      ],
    );
  }

  Widget _buildColorPicker(
    String label,
    Map<String, Color> options,
    Color current,
    ValueChanged<Color> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text(label)),
        const SizedBox(width: 16),
        ...options.entries.map((e) {
          final isSelected = e.value == current;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(e.value),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: e.value,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black87 : Colors.grey.shade300,
                    width: isSelected ? 3 : 1,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

}
