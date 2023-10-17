import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'register_screen.dart'; // Import RegisterScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Perform login API call
    setState(() {
      _isLoading = true;
    });

    // Construct the login request JSON
    final loginData = {
      'username': _usernameController.text,
      'password': _passwordController.text,
    };

    // Send the login request to the endpoint
    final response = await postLoginRequest(loginData);

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      // User logged in successfully, navigate to main_screen
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      // Show login error message
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Login Error'),
              content:
                  const Text('Invalid email or password. Please try again.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      });
    }
  }

  void _navigateToRegisterScreen() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required.';
    }
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,}$')
        .hasMatch(value)) {
      return 'Invalid email format.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _usernameController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      validator: _validatePassword,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: _login,
                      child: const Text('Login'),
                    ),
                    const SizedBox(height: 16.0),
                    TextButton(
                      onPressed: _navigateToRegisterScreen,
                      child: const Text('Create an account'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // Dodanie słuchacza zdarzenia cofania się
      final route = ModalRoute.of(context);
      if (route != null) {
        route.addScopedWillPopCallback(() async {
          // Zablokowanie cofania się
          return false;
        });
      }
    });
  }
}

// Sample function for sending login request to the endpoint
Future<http.Response> postLoginRequest(Map<String, String> loginData) {
  final body = Uri(queryParameters: loginData).query;
  return http.post(
    Uri.parse('https://asgr-deployment.onrender.com/account/login'),
    body: body,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
  );
}
