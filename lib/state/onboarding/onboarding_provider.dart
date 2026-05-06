import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:alma_diary/features/profile/data/profile_repository.dart";

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});