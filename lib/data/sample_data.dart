import '../models/exercise.dart';

Exercise _exercise(String id) => exercises.firstWhere((e) => e.id == id);

WorkoutEntry _entry(
  String id,
  Intensity intensity,
  int minutes,
  DateTime time, {
  double weightKg = 70,
}) {
  final exercise = _exercise(id);
  return WorkoutEntry(
    exercise: exercise,
    intensity: intensity,
    minutes: minutes,
    weightKg: weightKg,
    calories: caloriesBurned(
      met: exercise.metFor(intensity),
      weightKg: weightKg,
      minutes: minutes,
    ),
    time: time,
  );
}

/// Workouts already logged earlier today, newest first, so the dashboard
/// opens with something to look at.
List<WorkoutEntry> sampleTodayWorkouts(DateTime now) => [
  _entry(
    'yoga',
    Intensity.light,
    25,
    now.subtract(const Duration(minutes: 45)),
  ),
  _entry(
    'strength',
    Intensity.moderate,
    40,
    now.subtract(const Duration(hours: 3)),
  ),
];

/// Calories burned on each of the six days before today, oldest first.
/// A zero is a rest day.
const sampleWeeklyKcal = [380, 540, 260, 610, 0, 450];
