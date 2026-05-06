import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/features/profile/data/profile_repository.dart';

import "package:alma_diary/state/profile/profile_controller.dart";
import "package:alma_diary/state/profile/profile_state.dart";



/// =========================
/// PROVIDERS
/// =========================
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  throw UnimplementedError('Provide ProfileRepository in main');
});

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(
  ProfileController.new,
);
