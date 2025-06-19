import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> handleSessionExpired(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('jwt_token');
  await prefs.remove('user_id');
  await prefs.remove('user_data');

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Sesión expirada. Por favor, inicia sesión de nuevo.')),
  );
  await Future.delayed(const Duration(milliseconds: 500));
  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
}