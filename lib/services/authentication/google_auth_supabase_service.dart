import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/services/authentication/google_authentication_exceptions.dart';
import 'package:usper/services/authentication/google_authentication_interface.dart';
import 'package:usper/utils/check_email_domain.dart';

class GoogleAuthSupabaseService implements GoogleAuthenticationInterface {
  final supabase = Supabase.instance.client;

  @override
  Future<UsperUser?> performGoogleLogin() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: dotenv.env['IOS_CLIENT_ID']!,
      serverClientId: dotenv.env['WEB_CLIENT_ID']!,
    );

    await googleSignIn.signOut(); //Debug purpose only, remove for production

    final googleUser = await googleSignIn.signIn();

    //Following lines are commented for debug purpose only, remove for production
    //if (!checkEmailDomain(googleUser!.email, "usp.br")) {
    //  await googleSignIn.signOut();
    //  throw NotAUniversityEmail();
    //}

    final googleAuth = await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw 'No Access Token found.';
    }
    if (idToken == null) {
      throw 'No ID Token found.';
    }

    AuthResponse r = await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    final List<String> names = _splitName(r.user!.userMetadata!['full_name']);
    return UsperUser(r.user!.userMetadata!['email'], names[0], names[1],
        "course", r.user!.userMetadata!['avatar_url']);
  }

  List<String> _splitName(final fullName) {
    List<String> splitText = fullName.split(" ");
    splitText = [splitText[0], splitText.sublist(1).join(' ')];
    return splitText;
  }
}
