import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vandad_flutter_project/constants/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  VerifyEmailViewState createState() => VerifyEmailViewState();
}

class VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Center(
          child: Column(
        children: [
          const Text(
              "We've sent you an email verification.Please open it to verify your account"),
          const Padding(
            padding: EdgeInsets.only(top: 50,bottom: 50),
            child: Text(
                "If you haven't received a verification email yet, press the button below"),
          ),
          TextButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
              },
              child: const Text('Send email verification')),
          TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(registerRoute, (route) => false);
                }
              },
              child: const Text('Restart')),
        ],
      )),
    );
  }
}
