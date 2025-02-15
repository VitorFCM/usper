import 'package:flutter/material.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GoogleLoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  GoogleLoginButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          backgroundColor: Colors.black),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FontAwesomeIcons.google,
            color: white,
            size: 24.0,
          ),
          SizedBox(width: 12),
          Text(
            'Sign in with Google',
            style: TextStyle(
              fontSize: 16,
              color: white,
            ),
          ),
        ],
      ),
    );
  }
}
