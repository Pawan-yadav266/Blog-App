import 'package:blogapp/screen/ForgotPassword.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../components/round_button.dart';
import 'Home.dart';
import 'Signin.dart';
import 'option_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;

  bool showSpinner = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String email = "", password = "";
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: WillPopScope(
        onWillPop: ()async{
          Navigator.push(context, MaterialPageRoute(builder: (context)=>OptionScreen()));
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Login"),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Login',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Form(
                      key: _formkey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                  hintText: 'Email',
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email)),
                              onChanged: (String value) {
                                email = value;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'enter email';
                                }
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: TextFormField(
                                controller: passwordController,
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: true,
                                decoration: const InputDecoration(
                                    hintText: 'Password',
                                    labelText: 'Password',
                                    prefixIcon: Icon(Icons.password)),
                                onChanged: (String value) {
                                  password = value;
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'enter password';
                                  }
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10,bottom: 30),
                              child: InkWell(
                                onTap: (){
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
                                },
                                child: const Align(
                                  alignment: Alignment.centerRight,
                                    child: Text('Forgot Password?')
                                ),
                              ),
                            ),
                            RoundButton(
                                title: 'Login',
                                onPressed: () async {
                                  if (_formkey.currentState!.validate()) {
                                    setState(() {
                                      showSpinner = true;
                                    });

                                    try {
                                      final user =
                                          await _auth.signInWithEmailAndPassword(
                                              email: email.toString().trim(),
                                              password: password.toString().trim());

                                      if (user != null) {
                                        print('success');
                                        toastMessage('Login Succesfull');
                                        setState(() {
                                          showSpinner = false;
                                        });
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Home()));
                                      }
                                    } catch (e) {
                                      print(e.toString());
                                      toastMessage(e.toString());
                                      setState(() {
                                        showSpinner = false;
                                      });
                                    }
                                  }
                                })
                          ],
                        ),
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void toastMessage(String message) {
    Fluttertoast.showToast(
        msg: message.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }
}
