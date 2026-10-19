import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'models/exercise.dart';
import 'widgets/aurora_background.dart';
import 'widgets/gradient_button.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({
    super.key,
    required this.exercise,
    this.initialWeight = 70,
  });

  final Exercise exercise;
  final double initialWeight;

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  late double _weight = widget.initialWeight.clamp(30, 150);
  double _minutes = 30;
  Intensity _intensity = Intensity.moderate;

  Exercise get _exercise => widget.exercise;
  double get _met => _exercise.metFor(_intensity);
  double get _kcal =>
      caloriesBurned(met: _met, weightKg: _weight, minutes: _minutes);

  void _save() {
    Navigator.of(context).pop(
      WorkoutEntry(
        exercise: _exercise,
        intensity: _intensity,
        minutes: _minutes.round(),
        weightKg: _weight,
        calories: _kcal,
        time: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuroraBackground(),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    sliver: SliverList.list(
                      children: [
                        Text(
                          _exercise.tagline,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _ResultCard(kcal: _kcal, met: _met),
                        const SizedBox(height: 16),
                        _SliderCard(
                          icon: Icons.monitor_weight_outlined,
                          label: 'Body weight',
                          value: '${_weight.round()} kg',
                          slider: Slider(
                            min: 30,
                            max: 150,
                            divisions: 120,
                            value: _weight,
                            semanticFormatterCallback: (v) =>
                                '${v.round()} kilograms',
                            onChanged: (v) => setState(() => _weight = v),
                          ),
                          footer: const _ScaleLabels('30 kg', '150 kg'),
                        ),
                        const SizedBox(height: 12),
                        _SliderCard(
                          icon: Icons.timer_outlined,
                          label: 'Duration',
                          value: '${_minutes.round()} min',
                          slider: Slider(
                            min: 5,
                            max: 180,
                            divisions: 35,
                            value: _minutes,
                            semanticFormatterCallback: (v) =>
                                '${v.round()} minutes',
                            onChanged: (v) => setState(() => _minutes = v),
                          ),
                          footer: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final m in const [15, 30, 45, 60, 90])
                                _QuickChip(
                                  label: '$m min',
                                  selected: _minutes.round() == m,
                                  onTap: () =>
                                      setState(() => _minutes = m.toDouble()),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildIntensity(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 280,
      backgroundColor: const Color(0xFF0E1019),
      surfaceTintColor: Colors.transparent,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: 0.4),
          ),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 20, bottom: 16),
        expandedTitleScale: 1.7,
        centerTitle: false,
        title: Text(
          _exercise.name,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: Colors.white,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: _exercise.imageTag,
              child: Image.asset(
                _exercise.image,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const ColoredBox(color: Color(0xFF2A1B3D)),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66000000),
                    Color(0x00000000),
                    Color(0xCC0A0C14),
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntensity() {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(icon: Icons.speed_rounded, label: 'Intensity'),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final level in Intensity.values) ...[
                Expanded(
                  child: _IntensityButton(
                    label: level.label,
                    selected: level == _intensity,
                    onTap: () => setState(() => _intensity = level),
                  ),
                ),
                if (level != Intensity.values.last) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _exercise.hintFor(_intensity),
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0E1019),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: GradientButton(
                label: "Add to today's log",
                icon: Icons.add_rounded,
                onPressed: _save,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: child,
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.icon, required this.label, this.value});

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.ember),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ),
        if (value != null)
          Text(
            value!,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: Colors.white,
            ),
          ),
      ],
    );
  }
}

class _SliderCard extends StatelessWidget {
  const _SliderCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.slider,
    required this.footer,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget slider;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(icon: icon, label: label, value: value),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: AppColors.ember,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.14),
              thumbColor: Colors.white,
              overlayColor: AppColors.ember.withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
              trackShape: const RoundedRectSliderTrackShape(),
              showValueIndicator: ShowValueIndicator.never,
              tickMarkShape: SliderTickMarkShape.noTickMark,
            ),
            child: slider,
          ),
          footer,
        ],
      ),
    );
  }
}

class _ScaleLabels extends StatelessWidget {
  const _ScaleLabels(this.start, this.end);

  final String start;
  final String end;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 12,
      color: Colors.white.withValues(alpha: 0.45),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(start, style: style),
          Text(end, style: style),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.ember.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.ember
                : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}

class _IntensityButton extends StatelessWidget {
  const _IntensityButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$label intensity',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: selected ? AppColors.accent : null,
            color: selected ? null : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: selected
                ? null
                : Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.kcal, required this.met});

  final double kcal;
  final double met;

  String _count(double v) =>
      v >= 10 ? v.round().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [AppColors.ember, AppColors.rose],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ember.withValues(alpha: 0.4),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Estimated burn',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'MET ${met.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: kcal),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
                builder: (_, value, _) => Text(
                  value.round().toString(),
                  key: const ValueKey('kcal-result'),
                  style: const TextStyle(
                    fontSize: 64,
                    height: 1.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -2,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'kcal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 14),
          Text(
            "That's about",
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final food in foodEquivalents) ...[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(food.icon, color: Colors.white, size: 22),
                        const SizedBox(height: 4),
                        Text(
                          _count(kcal / food.kcal),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          food.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (food != foodEquivalents.last) const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
