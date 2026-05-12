# TODO - Fix Android debug build

- [ ] Fix Kotlin Gradle DSL block nesting in `android/app/build.gradle.kts`:
  - [ ] Ensure `defaultConfig {}` and `buildTypes {}` are inside the `android {}` block.
  - [ ] Ensure `dependencies {}` and `flutter {}` blocks are at the correct top level.
- [ ] Re-run `flutter run -v --debug` and verify Gradle no longer errors during script compilation.
- [ ] If additional build failures appear, inspect the new Gradle output and resolve next issues.

