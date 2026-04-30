# Alma Diary - Google Auth Refactor TODO

## Status: In Progress (1/4 complete)

### Step 1: ✅ Create this TODO.md (done)

### Step 2: Update lib/ui/auth_gate.dart ✅ (GoogleSignInButton added with import, compiles cleanly)
- Remove manual `initGoogleSignInWeb()` call from LoginScreen initState (moved to service init if needed)
- Remove `_signInWithGoogle()` method and `_checkPlatform()`
- Web: `GoogleSignInButton` (GIS official renderButton equivalent, triggers stream)
- Mobile: Inline button with `SupabaseService.instance.signInWithGoogle()`
- Ensure `kIsWeb` import used properly

### Step 3: Test the changes
- Web: `flutter run -d chrome` → renderButton triggers stream login
- Mobile: `flutter run` → traditional signIn() works
- Verify no token null errors, auth state changes correctly

### Step 4: Cleanup & Completion
- Mark all steps done
- Update README.md or comments if needed
- Run `flutter analyze` and `flutter test`
- Attempt completion

**Next Action:** Implement Step 2 (edit auth_gate.dart)
