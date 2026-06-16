import 'package:flutter/material.dart';
import 'main_navigation_screen.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final apiService = ApiService();

    final success = await apiService.login(
      username,
      password,
    );

    if (success) {
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(),
        ),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Invalid credentials'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 350,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Image.asset(
                'assets/images/logo_app.png',
                width: 220,
                height: 220,
              ),
              const SizedBox(height: 24),



              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: login,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
      ),
      ),
    );
  }
}