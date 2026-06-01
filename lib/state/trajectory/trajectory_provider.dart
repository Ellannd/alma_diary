import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:alma_diary/features/reflections/engine/trajectory_engine.dart";

final trajectoryProvider = Provider((ref) {
  return generarEstadisticasTrayectoria;
});