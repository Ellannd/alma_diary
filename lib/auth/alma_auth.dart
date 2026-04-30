// import 'package:local_auth/local_auth.dart';

class AlmaAuth {
  // static final _auth = LocalAuthentication();

  // static Future<bool> authenticate() async {
  //   final canCheck = await _auth.canCheckBiometrics;
  //   if (!canCheck) return false;
  //   return await _auth.authenticate(
  //     localizedReason: 'Accede a tu diario Alma con biometría',
  //     options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
  //   );
  // }

  // Modo desarrollo: siempre autentica
  static Future<bool> authenticate() async {
    return true;
  }
}
