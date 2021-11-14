import 'package:app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/authentication.dart';
import 'package:provider/provider.dart';
import 'package:app/firestore.dart';

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
          body: SingleChildScrollView(
            child: Column(
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
                        hintText: 'Enter your user name',
                        labelStyle: TextStyle(color: Colors.deepPurple),
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
                        hintText: 'Enter your password',
                        labelStyle: TextStyle(color: Colors.deepPurple),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Container(
                    height: 50,
                    width: 350,
                    decoration: BoxDecoration(
                        color: (auth.status == Status.Authenticating) ? null : Colors.deepPurple,
                        borderRadius: BorderRadius.circular(20)),
                    child: TextButton(
                      onPressed: () async {
                        bool isSignedIn = await auth.signIn(usernameController.text, passwordController.text);
                        /*if (res == 1) {
                          UserCredential? uc = await auth.signUp(usernameController.text, passwordController.text);
                          if (uc != null)
                            FirestoreRepository(userId: auth.user?.uid).createUserDoc();
                        }*/
                        if (isSignedIn) {
                          List saved = await FirestoreRepository(userId: auth.user?.uid).getSavedWordPairs();
                          Navigator.of(context).pop(saved);
                        }
                        else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('There was an error logging into the app'),));
                        }
                      },
                      child: (auth.status == Status.Authenticating) ? CircularProgressIndicator() :
                      Text('Login', style: TextStyle(color: Colors.white, fontSize: 25),),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Container(
                    height: 50,
                    width: 350,
                    decoration: BoxDecoration(
                        color: (auth.status == Status.Authenticating) ? null : Colors.blue,
                        borderRadius: BorderRadius.circular(20)),
                    child: TextButton(
                        onPressed: () async {
                          final TextEditingController confirmPasswordController = TextEditingController();
                          return showModalBottomSheet(context: context, builder: (context) {
                            return Container(
                              height: 250,
                              child:
                                Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text("Please confirm your password below:"),
                                    ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15, right: 10, left: 10),
                                  child: TextField(
                                    controller: confirmPasswordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Password',
                                        hintText: 'Re-enter your password',
                                        labelStyle: TextStyle(color: Colors.deepPurple),
                                        errorText: (confirmPasswordController.text == passwordController.text) ? null :'Passwords must match',
                                        errorStyle: TextStyle(color: Colors.deepPurple),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: ElevatedButton(onPressed: () async {
                                    if (confirmPasswordController.text == passwordController.text) {
                                      UserCredential? userCredential = await auth
                                          .signUp(usernameController.text,
                                          passwordController.text);
                                      if (userCredential != null) {
                                        List saved = await FirestoreRepository(
                                            userId: auth.user?.uid)
                                            .getSavedWordPairs();
                                        Navigator.pop(context);
                                        Navigator.of(context).pop(saved);
                                      }
                                      else {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                            SnackBar(
                                              content: Text('There was an error registering into the app'),));
                                      }
                                    }
                                  },
                                      child: Text("Confirm", style: TextStyle(),),
                                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple))
                                  ),),
                                ],)
                            );
                          });},
                        child: Text('New user? Click to sign up', style: TextStyle(color: Colors.white, fontSize: 20),),
                      ),
                    ),
                  ),
              ],
            ),
          )
      );
    }
    );
  }
}
