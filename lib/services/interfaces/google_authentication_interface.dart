import 'package:usper/core/classes/class_usper_user.dart';

abstract class GoogleAuthenticationInterface {
  Future<UsperUser?> performGoogleLogin();
}
