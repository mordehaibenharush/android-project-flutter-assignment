import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/authentication.dart';
import 'package:provider/provider.dart';
import 'package:app/authiot.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    return Consumer<AuthRepository> (builder: (context, auth, child)
    {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Login',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          ),
          body: Column(
            children: [
              Container(
                height: 100.0,
                width: 320,
                padding: EdgeInsets.only(top: 30, left: 10),
                child: Text(
                  'Welcome to Startup Names Generator, please login below',
                  style: TextStyle(fontSize: 18,),),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'User Name',
                      hintText: 'Enter your user name'
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      hintText: 'Enter your password'
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Container(
                  height: 50,
                  width: 230,
                  decoration: BoxDecoration(
                      color: (auth.status == Status.Authenticating) ? null : Colors.deepPurple,
                      borderRadius: BorderRadius.circular(20)),
                  child: TextButton(
                    onPressed: () async {
                      bool isSingedIn = await auth.signIn(usernameController.text, passwordController.text);
                      if (isSingedIn) {
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('There was an error logging into the app'),));
                      }
                    },
                    child: (auth.status == Status.Authenticating) ? CircularProgressIndicator() :
                    Text(
                      'Login',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                ),
              )
            ],
          )
      );
    }
    );
  }
}
