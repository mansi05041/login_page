import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_page/screens/Login_page.dart';
import 'package:login_page/screens/Profile_page.dart';
import '../authentication/fire_auth.dart';
import '../authentication/google_signIn.dart';
import '../utility/validator.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // setting global values
  final _registerkey = GlobalKey<FormState>();
  final _nameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _focusName = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();
  bool _isProcessing = false;
  bool _isSignInGoogle = false;
  bool passwordVisible = true;
  var error;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        _focusName.unfocus(),
        _focusEmail.unfocus(),
        _focusPassword.unfocus()
      },
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Get Register!!'),
            automaticallyImplyLeading: false,
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () async {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const RegisterPage()),
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
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // form to take email and password for sign In
                  Form(
                    key: _registerkey,
                    child: Column(
                      children: <Widget>[
                        // user name
                        TextFormField(
                          controller: _nameTextController,
                          focusNode: _focusName,
                          validator: (value) => Validator.validateName(
                            name: _nameTextController.text,
                          ),
                          decoration: InputDecoration(
                            hintText: "Name",
                            errorBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
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
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        setState(() {
                                          _isProcessing = true;
                                        });
                                        if (_registerkey.currentState!
                                            .validate()) {
                                          User? user = await FireAuth
                                              .registerUsingEmailPassword(
                                                  name:
                                                      _nameTextController.text,
                                                  email:
                                                      _emailTextController.text,
                                                  password:
                                                      _passwordTextController
                                                          .text,
                                                  context: context);
                                          setState(() {
                                            _isProcessing = false;
                                          });
                                          if (user != null) {
                                            Navigator.of(context)
                                                .pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfilePage(user: user),
                                              ),
                                              ModalRoute.withName('/'),
                                            );
                                          } else {
                                            error =
                                                "Account already in use or Password is too weak, try again!";
                                            _showAlertDialog(error);
                                          }
                                        }
                                      },
                                      child: const Text(
                                        'Sign up',
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
                                                const LoginPage(),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Already have Account?',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 24),
                        const Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 10),
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
                                    error =
                                        "Error in Google SignIn, Try again!!";
                                    _showAlertDialog(error);
                                  }
                                },
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const <Widget>[
                                      Image(
                                        image: AssetImage("assets/google.png"),
                                        height: 35,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(
                                          'Register with Google',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ]),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  _showAlertDialog(error) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Register Failed',
              style: TextStyle(color: Colors.redAccent),
            ),
            content: Text(error),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () async {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            const RegisterPage()),
                  );
                },
              )
            ],
          );
        });
  }
}
