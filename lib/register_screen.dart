import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _reenterPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _reenterPasswordController.dispose();
    super.dispose();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Account created.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Walidacja formularza powiodła się, wykonujemy żądanie HTTP
      const url =
          'https://asgr-deployment.onrender.com/account/register'; // Wprowadź właściwy endpoint

      final Map<String, String> data = {
        'email': _emailController.text,
        'password': _passwordController.text,
      };

      final String jsonData = jsonEncode(data);

      final response = await http.post(
        Uri.parse(url),
        body: jsonData,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        // Utworzenie konta zakończone sukcesem
        _showSuccessDialog();
      } else {
        // Błąd podczas tworzenia konta
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['detail'];

        final currentContext =
            context; // Przechowywanie referencji do BuildContext

        WidgetsBinding.instance!.addPostFrameCallback((_) {
          showDialog(
            context: currentContext, // Użycie przechowywanej referencji
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text('Error Creating Account'),
                content: Text('$errorMessage'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(dialogContext)
                          .pop(); // Używanie dialogContext
                    },
                  ),
                ],
              );
            },
          );
        });
      }
    }
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

  String? _validateReenterPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please re-enter your password.';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register New Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address'),
                validator: _validateEmail,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: _validatePassword,
              ),
              TextFormField(
                controller: _reenterPasswordController,
                decoration:
                    const InputDecoration(labelText: 'Re-enter Password'),
                obscureText: true,
                validator: _validateReenterPassword,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
