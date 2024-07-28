import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/screens/home_page.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  var pass1 = true;
  var pass2 = true;

  void signUp() async {
    if (_formKey.currentState!.validate()) {
      var url = Uri.http('10.0.2.2:1337', 'api/auth/local/register');
      try {
        final response = await http.post(url, body: {
          'username': usernameController.text,
          'email': emailController.text,
          'password': passwordController.text,
        });
        if (response.statusCode == 200) {
          print('User created');
          final jwt = jsonDecode(response.body);
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('jwt', jwt['jwt']);
          prefs.setString('username', jwt['user']['username']);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User created successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          }
        } else if (response.statusCode == 400) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User already exists'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          print(
              'Failed to create user with status code: ${response.statusCode}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Failed to create user: ${response.reasonPhrase}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'username is required';
                  }
                  if (value.length < 3) {
                    return 'username must be at least 3 characters';
                  }
                  return null;
                },
                controller: usernameController,
                textInputAction: TextInputAction.next,
                key: const Key('username'),
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.text,
              ),
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
                controller: emailController,
                textInputAction: TextInputAction.next,
                key: const Key('email'),
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
                key: const Key('password'),
                controller: passwordController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Password',
                  helperText: 'No less than 8 characters',
                  prefixIcon: const Icon(Icons.password),
                  suffix: IconButton(
                    onPressed: () {
                      setState(() {
                        pass1 = !pass1;
                      });
                    },
                    icon: Icon(pass1 ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
                obscureText: pass1,
                keyboardType: TextInputType.text,
              ),
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Confirm Password is required';
                  }
                  if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                key: const Key('confirmPassword'),
                controller: confirmPasswordController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.password),
                    suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            pass2 = !pass2;
                          });
                        },
                        icon: Icon(
                            pass2 ? Icons.visibility : Icons.visibility_off))),
                obscureText: pass2,
                keyboardType: TextInputType.text,
              ),
              FilledButton(
                onPressed: () {
                  signUp();
                },
                child: const Text('Sign Up'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
