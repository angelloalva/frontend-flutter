import 'dart:convert';

import 'package:citas_app/models/user.dart';
import 'package:citas_app/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:citas_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var logger = Logger();
  final _formKey = GlobalKey<FormState>();
  final _documentController = TextEditingController();
  final _passwordController = TextEditingController();
  
  int _selectedDocumentType = 1;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final List<Map<String, dynamic>> _documentTypes = [
    {'value': 1, 'label': 'DNI'},
    {'value': 2, 'label': 'CARNET'},
    {'value': 3, 'label': 'PASAPORTE'},
  ];

  @override
  void dispose() {
    _documentController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  Future<void> _saveUserData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final responseData = await ApiService().login(
        tipoDocumento: _selectedDocumentType,
        numeroDocumento: _documentController.text.trim(),
        password: _passwordController.text,
      );
      final user = User.fromJson(responseData['user'] ?? {});
      final token = responseData['jwt'] ?? '';

      // Guardar token y datos del usuario en SharedPreferences
      await _saveUserData(token, user);
      _showMessage('Login exitoso', isError: false);
      
      // Navegar al dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(),
        ),
      );
    } catch (e, stacktrace) {
      String message;
      if (e.toString().contains('401')) {
        message = 'Credenciales incorrectas';
      } else if (e.toString().contains('XMLHttpRequest')) {
        message = 'Error CORS: Verifica la configuración del servidor';
      } else if (e.toString().contains('Connection refused')) {
        message = 'Error: El servidor no está disponible';
      } else {
         logger.e('Ocurrió un error', error: e, stackTrace: stacktrace);
        message = 'Error de conexión: ${e.toString()}';
      }
      _showMessage(message);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.medical_services,
                        size: 80,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sistema Médico',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),

                      DropdownButtonFormField<int>(
                        value: _selectedDocumentType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Documento',
                          prefixIcon: Icon(Icons.assignment_ind),
                          border: OutlineInputBorder(),
                        ),
                        items: _documentTypes.map((doc) {
                          return DropdownMenuItem<int>(
                            value: doc['value'],
                            child: Text(doc['label']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDocumentType = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Selecciona un tipo de documento';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _documentController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: 'Número de Documento',
                          prefixIcon: Icon(Icons.credit_card),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa tu número de documento';
                          }
                          if (value.trim().length < 8) {
                            return 'El número debe tener al menos 8 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa tu contraseña';
                          }
                          if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}