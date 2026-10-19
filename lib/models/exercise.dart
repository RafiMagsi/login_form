import 'package:flutter/material.dart';

enum Intensity {
  light('Light'),
  moderate('Moderate'),
  vigorous('Vigorous');

  const Intensity(this.label);

  final String label;
}

/// An activity with its MET (metabolic equivalent of task) value per
/// intensity, taken from the Compendium of Physical Activities.
class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.tagline,
    required this.image,
    required this.icon,
    required this.mets,
    required this.hints,
  });

  final String id;
  final String name;
  final String tagline;
  final String image;
  final IconData icon;

  /// MET values indexed by [Intensity].
  final List<double> mets;

  /// Short description of what each [Intensity] feels like.
  final List<String> hints;

  double metFor(Intensity intensity) => mets[intensity.index];
  String hintFor(Intensity intensity) => hints[intensity.index];

  String get imageTag => 'exercise-image-$id';
}

const exercises = <Exercise>[
  Exercise(
    id: 'running',
    name: 'Running',
    tagline: 'Trails, tracks and sunrise miles',
    image: 'assets/images/running.jpg',
    icon: Icons.directions_run_rounded,
    mets: [6.0, 9.8, 12.3],
    hints: [
      'Easy jog, about 6 km/h',
      'Steady run, about 9 km/h',
      'Fast run, 12 km/h+',
    ],
  ),
  Exercise(
    id: 'cycling',
    name: 'Cycling',
    tagline: 'Open roads, easy on the joints',
    image: 'assets/images/cycling.jpg',
    icon: Icons.directions_bike_rounded,
    mets: [4.0, 8.0, 12.0],
    hints: [
      'Leisurely, under 16 km/h',
      'Brisk, 20 to 22 km/h',
      'Racing pace, 26 km/h+',
    ],
  ),
  Exercise(
    id: 'strength',
    name: 'Strength',
    tagline: 'Build muscle, burn longer',
    image: 'assets/images/strength.jpg',
    icon: Icons.fitness_center_rounded,
    mets: [3.5, 5.0, 6.0],
    hints: [
      'Light weights, long rests',
      'Standard sets and reps',
      'Heavy lifts, short rests',
    ],
  ),
  Exercise(
    id: 'hiit',
    name: 'HIIT',
    tagline: 'Short, brutal, effective',
    image: 'assets/images/hiit.jpg',
    icon: Icons.bolt_rounded,
    mets: [6.0, 8.0, 10.0],
    hints: [
      'Long intervals, lots of rest',
      'Circuit training',
      'All-out intervals',
    ],
  ),
  Exercise(
    id: 'yoga',
    name: 'Yoga',
    tagline: 'Stretch, breathe, recover',
    image: 'assets/images/yoga.jpg',
    icon: Icons.self_improvement_rounded,
    mets: [2.0, 3.0, 4.0],
    hints: ['Gentle stretching', 'Hatha or vinyasa flow', 'Power yoga'],
  ),
];

/// Energy burned: MET x body weight (kg) x duration (hours).
double caloriesBurned({
  required double met,
  required double weightKg,
  required num minutes,
}) => met * weightKg * minutes / 60;

class WorkoutEntry {
  const WorkoutEntry({
    required this.exercise,
    required this.intensity,
    required this.minutes,
    required this.weightKg,
    required this.calories,
    required this.time,
  });

  final Exercise exercise;
  final Intensity intensity;
  final int minutes;
  final double weightKg;
  final double calories;
  final DateTime time;
}

/// A food used to make a calorie number tangible.
class FoodEquivalent {
  const FoodEquivalent(this.name, this.icon, this.kcal);

  final String name;
  final IconData icon;
  final double kcal;
}

const foodEquivalents = <FoodEquivalent>[
  FoodEquivalent('Pizza slice', Icons.local_pizza_rounded, 285),
  FoodEquivalent('Burger', Icons.lunch_dining_rounded, 300),
  FoodEquivalent('Cookie', Icons.cookie_rounded, 160),
];
