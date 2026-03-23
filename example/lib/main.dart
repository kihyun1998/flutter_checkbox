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
      title: 'FlutterCheckbox Playground',
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
  // ── Preview mode ───────────────────────────────────────────────────────────
  bool _showTile = false;

  // ── Checkbox style ─────────────────────────────────────────────────────────
  CheckboxShape _shape = CheckboxShape.rectangle;
  double _size = 24;
  double _scale = 1.0;
  double _borderWidth = 2;
  double _borderRadius = 4;
  double _checkStrokeWidth = 2.5;
  Color _activeColor = Colors.indigo;
  Color _checkColor = Colors.white;
  double _animationDurationMs = 200;
  double _morphDurationMs = 150;
  double _hoverRingPadding = 4;
  CheckboxShape? _hoverRingShape;
  double? _hoverRingBorderRadius;

  // ── State ──────────────────────────────────────────────────────────────────
  bool _enabled = true;
  bool _tristate = false;
  bool? _checked = false;

  // ── Tile layout ────────────────────────────────────────────────────────────
  double _gap = 8;
  CheckboxPosition _position = CheckboxPosition.start;
  bool _expandWidth = true;
  bool _showSubtitle = false;
  double _paddingH = 12;
  double _paddingV = 10;

  // ── Tile background ────────────────────────────────────────────────────────
  Color? _backgroundColor;
  Color? _selectedColor;
  Color? _disabledColor;

  // ── Tile border ────────────────────────────────────────────────────────────
  double _tileBorderRadius = 8;
  bool _showBorder = true;

  // ── Tile animation ─────────────────────────────────────────────────────────
  double _tileAnimationDurationMs = 200;

  // ── Tile interaction ───────────────────────────────────────────────────────
  Color? _hoverColor;
  Color? _splashColor;

  // ── Tile shadow ────────────────────────────────────────────────────────────
  double _elevation = 0;

  // ── Color options ──────────────────────────────────────────────────────────
  static const Map<String, Color> _activeColors = {
    'Indigo': Colors.indigo,
    'Red': Colors.red,
    'Green': Colors.green,
    'Orange': Colors.orange,
    'Purple': Colors.purple,
    'Teal': Colors.teal,
  };

  static const Map<String, Color> _checkColors = {
    'White': Colors.white,
    'Black': Colors.black,
    'Yellow': Colors.yellow,
  };

  static const Map<String, Color?> _tileBackgroundColors = {
    'None': null,
    'White': Colors.white,
    'Indigo 50': Color(0xFFE8EAF6),
    'Blue 50': Color(0xFFE3F2FD),
    'Green 50': Color(0xFFE8F5E9),
    'Red 50': Color(0xFFFFEBEE),
    'Grey 100': Color(0xFFF5F5F5),
  };

  static const Map<String, Color?> _interactionColors = {
    'Default': null,
    'Indigo 10%': Color(0x1A3F51B5),
    'Red 10%': Color(0x1AF44336),
    'Green 10%': Color(0x1A4CAF50),
    'Grey 10%': Color(0x1A9E9E9E),
  };

  // ── Derived style ──────────────────────────────────────────────────────────
  CheckboxStyle get _checkboxStyle => CheckboxStyle(
    shape: _shape,
    size: _size,
    scale: _scale,
    borderWidth: _borderWidth,
    borderRadius: _borderRadius,
    checkStrokeWidth: _checkStrokeWidth,
    hoverRingPadding: _hoverRingPadding,
    hoverRingShape: _hoverRingShape,
    hoverRingBorderRadius: _hoverRingBorderRadius,
    activeColor: _activeColor,
    checkColor: _checkColor,
    animationDuration: Duration(milliseconds: _animationDurationMs.round()),
    morphDuration: Duration(milliseconds: _morphDurationMs.round()),
  );

  void _onChanged(bool? v) => setState(() => _checked = v);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildControlsPanel(),
          Expanded(child: _buildPreview()),
        ],
      ),
    );
  }

  // ── Controls panel ─────────────────────────────────────────────────────────

  Widget _buildControlsPanel() {
    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionTitle('Checkbox Style'),
          const SizedBox(height: 12),
          SegmentedButton<CheckboxShape>(
            segments: const [
              ButtonSegment(
                value: CheckboxShape.rectangle,
                label: Text('Rectangle'),
              ),
              ButtonSegment(value: CheckboxShape.circle, label: Text('Circle')),
            ],
            selected: {_shape},
            onSelectionChanged: (v) => setState(() => _shape = v.first),
          ),
          const SizedBox(height: 12),
          _slider('Size', _size, 12, 64, (v) => setState(() => _size = v)),
          _slider('Scale', _scale, 0.5, 2.0, (v) => setState(() => _scale = v)),
          _slider(
            'Border Width',
            _borderWidth,
            0.5,
            6,
            (v) => setState(() => _borderWidth = v),
          ),
          _slider(
            'Border Radius',
            _borderRadius,
            0,
            32,
            (v) => setState(() => _borderRadius = v),
          ),
          _slider(
            'Check Stroke',
            _checkStrokeWidth,
            1,
            6,
            (v) => setState(() => _checkStrokeWidth = v),
          ),
          _slider(
            'Hover Ring',
            _hoverRingPadding,
            0,
            20,
            (v) => setState(() => _hoverRingPadding = v),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 100, child: Text('Ring Shape')),
              Expanded(
                child: SegmentedButton<CheckboxShape?>(
                  segments: const [
                    ButtonSegment(value: null, label: Text('Auto')),
                    ButtonSegment(
                      value: CheckboxShape.circle,
                      label: Text('Circle'),
                    ),
                    ButtonSegment(
                      value: CheckboxShape.rectangle,
                      label: Text('Rect'),
                    ),
                  ],
                  selected: {_hoverRingShape},
                  onSelectionChanged: (v) =>
                      setState(() => _hoverRingShape = v.first),
                ),
              ),
            ],
          ),
          if (_hoverRingShape == CheckboxShape.rectangle ||
              _hoverRingShape == null)
            _slider(
              'Ring Radius',
              _hoverRingBorderRadius ?? (_borderRadius + 2),
              0,
              40,
              (v) => setState(() => _hoverRingBorderRadius = v),
            ),
          _slider(
            'Anim ms',
            _animationDurationMs,
            0,
            800,
            (v) => setState(() => _animationDurationMs = v),
            divisions: 16,
          ),
          _slider(
            'Morph ms',
            _morphDurationMs,
            0,
            500,
            (v) => setState(() => _morphDurationMs = v),
            divisions: 10,
          ),
          const SizedBox(height: 8),
          _colorPicker(
            'Active Color',
            _activeColors,
            _activeColor,
            (c) => setState(() => _activeColor = c),
          ),
          const SizedBox(height: 8),
          _colorPicker(
            'Check Color',
            _checkColors,
            _checkColor,
            (c) => setState(() => _checkColor = c),
          ),

          _divider('State'),
          SwitchListTile(
            title: const Text('Enabled'),
            value: _enabled,
            contentPadding: EdgeInsets.zero,
            onChanged: (v) => setState(() => _enabled = v),
          ),
          SwitchListTile(
            title: const Text('Tristate'),
            value: _tristate,
            contentPadding: EdgeInsets.zero,
            onChanged: (v) => setState(() {
              _tristate = v;
              if (!v) _checked = _checked ?? false;
            }),
          ),

          _divider('Tile Layout'),
          _slider('Gap', _gap, 0, 32, (v) => setState(() => _gap = v)),
          _slider(
            'Padding H',
            _paddingH,
            0,
            40,
            (v) => setState(() => _paddingH = v),
          ),
          _slider(
            'Padding V',
            _paddingV,
            0,
            40,
            (v) => setState(() => _paddingV = v),
          ),
          _slider(
            'Border Radius',
            _tileBorderRadius,
            0,
            24,
            (v) => setState(() => _tileBorderRadius = v),
          ),
          const SizedBox(height: 4),
          SegmentedButton<CheckboxPosition>(
            segments: const [
              ButtonSegment(
                value: CheckboxPosition.start,
                label: Text('Start'),
              ),
              ButtonSegment(value: CheckboxPosition.end, label: Text('End')),
            ],
            selected: {_position},
            onSelectionChanged: (v) => setState(() => _position = v.first),
          ),
          SwitchListTile(
            title: const Text('Expand Width'),
            value: _expandWidth,
            contentPadding: EdgeInsets.zero,
            onChanged: (v) => setState(() => _expandWidth = v),
          ),
          SwitchListTile(
            title: const Text('Show Subtitle'),
            value: _showSubtitle,
            contentPadding: EdgeInsets.zero,
            onChanged: (v) => setState(() => _showSubtitle = v),
          ),
          SwitchListTile(
            title: const Text('Show Border'),
            value: _showBorder,
            contentPadding: EdgeInsets.zero,
            onChanged: (v) => setState(() => _showBorder = v),
          ),

          _divider('Tile Background'),
          _nullableColorPicker(
            'Background',
            _tileBackgroundColors,
            _backgroundColor,
            (c) => setState(() => _backgroundColor = c),
          ),
          const SizedBox(height: 8),
          _nullableColorPicker(
            'Selected',
            _tileBackgroundColors,
            _selectedColor,
            (c) => setState(() => _selectedColor = c),
          ),
          const SizedBox(height: 8),
          _nullableColorPicker(
            'Disabled',
            _tileBackgroundColors,
            _disabledColor,
            (c) => setState(() => _disabledColor = c),
          ),

          _divider('Tile Interaction'),
          _nullableColorPicker(
            'Hover Color',
            _interactionColors,
            _hoverColor,
            (c) => setState(() => _hoverColor = c),
          ),
          const SizedBox(height: 8),
          _nullableColorPicker(
            'Splash Color',
            _interactionColors,
            _splashColor,
            (c) => setState(() => _splashColor = c),
          ),

          _divider('Tile Animation & Shadow'),
          _slider(
            'Tile Anim ms',
            _tileAnimationDurationMs,
            0,
            800,
            (v) => setState(() => _tileAnimationDurationMs = v),
            divisions: 16,
          ),
          _slider(
            'Elevation',
            _elevation,
            0,
            16,
            (v) => setState(() => _elevation = v),
          ),
        ],
      ),
    );
  }

  // ── Preview ────────────────────────────────────────────────────────────────

  Widget _buildPreview() {
    return Column(
      children: [
        // Mode toggle
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('FlutterCheckbox')),
              ButtonSegment(value: true, label: Text('FlutterCheckboxTile')),
            ],
            selected: {_showTile},
            onSelectionChanged: (v) => setState(() => _showTile = v.first),
          ),
        ),
        Expanded(
          child: _showTile ? _buildTilePreview() : _buildCheckboxPreview(),
        ),
      ],
    );
  }

  Widget _buildCheckboxPreview() {
    return Center(
      child: FlutterCheckbox(
        value: _checked,
        tristate: _tristate,
        style: _checkboxStyle,
        enabled: _enabled,
        onChanged: _onChanged,
      ),
    );
  }

  Widget _buildTilePreview() {
    final tile = FlutterCheckboxTile(
      value: _checked,
      tristate: _tristate,
      checkboxStyle: _checkboxStyle,
      label: 'Check me',
      subtitle: _showSubtitle ? 'This is a subtitle line' : null,
      gap: _gap,
      checkboxPosition: _position,
      expandWidth: _expandWidth,
      enabled: _enabled,
      backgroundColor: _backgroundColor,
      selectedColor: _selectedColor,
      disabledColor: _disabledColor,
      hoverColor: _hoverColor,
      splashColor: _splashColor,
      elevation: _elevation,
      tileBorderRadius: BorderRadius.circular(_tileBorderRadius),
      tileBorderSide: _showBorder
          ? BorderSide(color: Theme.of(context).dividerColor)
          : null,
      tileAnimationDuration: Duration(
        milliseconds: _tileAnimationDurationMs.round(),
      ),
      padding: EdgeInsets.symmetric(horizontal: _paddingH, vertical: _paddingV),
      onChanged: _onChanged,
    );

    if (_expandWidth) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Align(alignment: Alignment.topCenter, child: tile),
      );
    }

    return Center(child: tile);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _sectionTitle(String title) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }

  Widget _divider(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(width: 8),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    int? divisions,
  }) {
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 40, child: Text(value.toStringAsFixed(1))),
      ],
    );
  }

  Widget _colorPicker(
    String label,
    Map<String, Color> options,
    Color current,
    ValueChanged<Color> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: options.entries.map((e) {
            final isSelected = e.value == current;
            return GestureDetector(
              onTap: () => onChanged(e.value),
              child: _colorDot(e.value, isSelected),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _nullableColorPicker(
    String label,
    Map<String, Color?> options,
    Color? current,
    ValueChanged<Color?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: options.entries.map((e) {
            final isSelected = e.value == current;
            return GestureDetector(
              onTap: () => onChanged(e.value),
              child: e.value == null
                  ? _noneDot(isSelected)
                  : _colorDot(e.value!, isSelected),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _colorDot(Color color, bool isSelected) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.black87 : Colors.grey.shade300,
          width: isSelected ? 3 : 1,
        ),
      ),
    );
  }

  Widget _noneDot(bool isSelected) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.black87 : Colors.grey.shade300,
          width: isSelected ? 3 : 1,
        ),
      ),
      child: const Center(
        child: Text('✕', style: TextStyle(fontSize: 12, color: Colors.grey)),
      ),
    );
  }
}
