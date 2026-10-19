import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'glass_card.dart';

/// Seven bars (six past days plus today) against a dashed daily-goal line.
class WeeklyChart extends StatelessWidget {
  const WeeklyChart({
    super.key,
    required this.previousDays,
    required this.todayKcal,
    required this.goal,
    required this.today,
  });

  /// Calories for the six days before [today], oldest first.
  final List<int> previousDays;
  final int todayKcal;
  final int goal;
  final DateTime today;

  static const _barArea = 104.0;
  static const _letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final values = [...previousDays, todayKcal];
    final total = values.fold(0, (a, b) => a + b);
    final activeDays = values.where((v) => v > 0).length;
    final average = activeDays == 0 ? 0 : (total / activeDays).round();
    final peak = values.fold<int>(goal, (a, b) => b > a ? b : a) * 1.12;

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last 7 days',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
                            '$total',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'kcal',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$average',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ember,
                    ),
                  ),
                  Text(
                    'avg / active day',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: _barArea,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: goal / peak * _barArea,
                  child: Row(
                    children: [
                      for (var i = 0; i < 40; i++)
                        Expanded(
                          child: Container(
                            height: 1,
                            margin: const EdgeInsets.only(right: 3),
                            color: Colors.white.withValues(
                              alpha: i.isEven ? 0.28 : 0.0,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < values.length; i++)
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: _Bar(
                            height: values[i] == 0
                                ? 5
                                : (values[i] / peak * _barArea).clamp(
                                    8.0,
                                    _barArea,
                                  ),
                            isToday: i == values.length - 1,
                            reachedGoal: values[i] >= goal,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < values.length; i++)
                Expanded(
                  child: Text(
                    _letters[today
                            .subtract(Duration(days: values.length - 1 - i))
                            .weekday -
                        1],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: i == values.length - 1
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: i == values.length - 1
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.height,
    required this.isToday,
    required this.reachedGoal,
  });

  final double height;
  final bool isToday;
  final bool reachedGoal;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: height),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (_, h, _) => Container(
        width: 22,
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: isToday
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.rose, AppColors.ember],
                )
              : null,
          color: isToday
              ? null
              : reachedGoal
              ? AppColors.ember.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.16),
        ),
      ),
    );
  }
}
