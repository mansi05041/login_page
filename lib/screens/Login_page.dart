import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:login_page/authentication/fire_auth.dart';
import 'package:login_page/authentication/google_signIn.dart';
import 'package:login_page/screens/Profile_page.dart';
import 'package:login_page/screens/Register_page.dart';
import 'package:login_page/utility/validator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // setting global values
  final _formkey = GlobalKey<FormState>();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();
  bool _isProcessing = false;
  bool _isSignInGoogle = false;
  bool passwordVisible = true;
  var error;

  // Initialize Firebase App
  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            user: user,
          ),
        ),
      );
    }
    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {_focusEmail.unfocus(), _focusPassword.unfocus()},
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Login Here'),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () async {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (BuildContext context) => const LoginPage()),
                  );
                },
                child: const Icon(
                  Icons.refresh,
                  size: 26.0,
                ),
              ),
            ),
          ],
        ),
        body: FutureBuilder(
          future: _initializeFirebase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Image.asset(
                        "assets/login_here.gif",
                        height: 200,
                        scale: 2.5,
                      ),
                    ),
                    // form to take email and password for sign In
                    Form(
                      key: _formkey,
                      child: Column(
                        children: <Widget>[
                          // Email
                          TextFormField(
                            controller: _emailTextController,
                            focusNode: _focusEmail,
                            validator: (value) => Validator.validateEmail(
                              email: _emailTextController.text,
                            ),
                            decoration: InputDecoration(
                              hintText: "Email",
                              errorBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // password
                          TextFormField(
                            controller: _passwordTextController,
                            focusNode: _focusPassword,
                            validator: (value) => Validator.validatePassword(
                              password: _passwordTextController.text,
                            ),
                            obscureText: passwordVisible,
                            decoration: InputDecoration(
                              hintText: "Password",
                              suffixIcon: IconButton(
                                icon: Icon(passwordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () {
                                  setState(() {
                                    passwordVisible = !passwordVisible;
                                  });
                                },
                              ),
                              alignLabelWithHint: false,
                              errorBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _isProcessing
                              ? const CircularProgressIndicator(value: 0.2)
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          _focusEmail.unfocus();
                                          _focusPassword.unfocus();
                                          if (_formkey.currentState!
                                              .validate()) {
                                            setState(() {
                                              _isProcessing = true;
                                            });
                                            User? user = await FireAuth
                                                .signInUsingEmailPassword(
                                                    email: _emailTextController
                                                        .text,
                                                    password:
                                                        _passwordTextController
                                                            .text,
                                                    context: context);
                                            setState(() {
                                              _isProcessing = false;
                                            });
                                            if (user != null) {
                                              Navigator.of(context)
                                                  .pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfilePage(user: user),
                                                ),
                                              );
                                            } else {
                                              error =
                                                  "Wrong Password or Email, Try Again!!";
                                              _showAlertDialog(error);
                                            }
                                          }
                                        },
                                        child: const Text(
                                          'Sign In',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const RegisterPage(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'New Account?',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          const SizedBox(height: 24),
                          _isSignInGoogle
                              ? const CircularProgressIndicator(value: 0.2)
                              : OutlinedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      _isSignInGoogle = true;
                                    });
                                    User? user =
                                        await AuthenticationWithGoogleSignIn
                                            .signInWithGoogle(
                                                BuildContext: BuildContext);
                                    setState(() {
                                      _isSignInGoogle = false;
                                    });
                                    if (user != null) {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => ProfilePage(
                                            user: user,
                                          ),
                                        ),
                                      );
                                    } else {
                                      error = "Not able to signIn using Google";
                                      _showAlertDialog(error);
                                    }
                                  },
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const <Widget>[
                                        Image(
                                          image:
                                              AssetImage("assets/google.png"),
                                          height: 35,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Text(
                                            'Sign in with Google',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ]),
                                )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  _showAlertDialog(error) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Login Failed',
              style: TextStyle(color: Colors.redAccent),
            ),
            content: Text(error),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () async {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (BuildContext context) => const LoginPage()),
                  );
                },
              )
            ],
          );
        });
  }
}
