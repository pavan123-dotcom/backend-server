import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> isDeviceSupported() async {
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    return canAuthenticateWithBiometrics || await auth.isDeviceSupported();
  }

  Future<bool> authenticate() async {
    try {
      final bool isSupported = await isDeviceSupported();

      if (!isSupported) {
        print("Device not supported for biometrics");
        return false; // Secure: Fail if not supported
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to view the Ballot',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
         // Handle unavailable
         return false;
      }
      print("Authentication Error: ${e.message}");
      return false;
    }
  }
}
