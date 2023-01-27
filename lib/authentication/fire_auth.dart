import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FireAuth {
  // to register the new user using email and password
  static Future<User?> registerUsingEmailPassword({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      user = userCredential.user;
      await user!.updateProfile(displayName: name);
      await user.reload();
      user = auth.currentUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        const AlertDialog(
          backgroundColor: Colors.tealAccent,
          title: Center(
            child: Text(
              'Password is too weak',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        const AlertDialog(
          backgroundColor: Colors.tealAccent,
          title: Center(
            child: Text(
              'Account Already in use',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
        ;
      }
    } catch (e) {
      print(e);
    }
    return user;
  }

  // to sign in a user who has already registered in our app using email and password
  static Future<User?> signInUsingEmailPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        const AlertDialog(
          backgroundColor: Colors.tealAccent,
          title: Center(
            child: Text(
              'User Not Found',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      } else if (e.code == 'wrong-password') {
        const AlertDialog(
          backgroundColor: Colors.tealAccent,
          title: Center(
            child: Text(
              'Wrong Password',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
    return user;
  }

  // refreshing the user
  static Future<User?> refreshUser(User user) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await user.reload();
    User? refreshedUser = auth.currentUser;
    return refreshedUser;
  }

  // reset the password
  static Future<void> resetPassword({required String email}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.sendPasswordResetEmail(email: email);
  }
}
