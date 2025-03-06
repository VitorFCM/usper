import 'package:usper/core/classes/class_usper_user.dart';

abstract interface class GoogleAuthenticationInterface {
  Future<UsperUser?> performGoogleLogin();
}
