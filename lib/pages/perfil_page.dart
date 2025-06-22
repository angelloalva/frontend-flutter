// perfil_page.dart
import 'dart:convert';
import 'package:citas_app/providers/api_provider.dart';
import 'package:citas_app/providers/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citas_app/models/user.dart';
class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombresController;
  late TextEditingController _apellidosController;
  late TextEditingController _celularController;
  late TextEditingController _correoController;
  late TextEditingController _direccionController;
  late TextEditingController _numeroDocumentoController;
  String? _userId;
  String? _tipoDocumentoSeleccionado;

  @override
  void initState() {
    super.initState();
    _nombresController = TextEditingController();
    _apellidosController = TextEditingController();
    _celularController = TextEditingController();
    _correoController = TextEditingController();
    _direccionController = TextEditingController();
    _numeroDocumentoController = TextEditingController();
    _tipoDocumentoSeleccionado = '1';

    // Cargar datos iniciales
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id');

    if (_userId != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.perfil == null) {
        await authProvider.fetchUserProfile();
      }
      if (authProvider.perfil != null) {
        _updateControllers(authProvider.perfil!);
      }
    }
  }

  void _updateControllers(User user) {
    setState(() {
      _nombresController.text = user.nombres;
      _apellidosController.text = user.apellidos;
      _celularController.text = user.celular;
      _correoController.text = user.correo;
      _direccionController.text = user.direccion;
      _numeroDocumentoController.text = user.numeroDocumento;
      _tipoDocumentoSeleccionado = user.tipoDocumento;
    });
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _celularController.dispose();
    _correoController.dispose();
    _direccionController.dispose();
    _numeroDocumentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (_userId == null) {
      return const Scaffold(
        body: Center(child: Text('Error: No se encontró el ID del usuario')),
      );
    }

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${authProvider.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await authProvider.fetchUserProfile();
                },
                child: const Text('Intentar de nuevo'),
              ),
            ],
          ),
        ),
      );
    }

    if (authProvider.perfil == null) {
      return const Scaffold(
        body: Center(child: Text('No se pudieron cargar los datos del perfil')),
      );
    }

    final Map<String, String> tiposDocumento = {
      '1': 'DNI',
      '2': 'Carnet',
      '3': 'Pasaporte',
    };

return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.blue[100],
                      child: const Icon(Icons.person, size: 60, color: Colors.blue),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nombresController,
                      decoration: const InputDecoration(
                        labelText: 'Nombres',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _apellidosController,
                      decoration: const InputDecoration(
                        labelText: 'Apellidos',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _celularController,
                      decoration: const InputDecoration(
                        labelText: 'Celular',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _correoController,
                      decoration: const InputDecoration(
                        labelText: 'Correo',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return 'Campo requerido';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Correo inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _tipoDocumentoSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Documento',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                      ),
                      items: tiposDocumento.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _tipoDocumentoSeleccionado = value;
                        });
                      },
                      validator: (value) => value == null ? 'Seleccione un tipo de documento' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _numeroDocumentoController,
                      decoration: const InputDecoration(
                        labelText: 'Número de Documento',
                        prefixIcon: Icon(Icons.numbers),
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _direccionController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección',
                        prefixIcon: Icon(Icons.home),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Actualizar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final usuario = User(
                              id: _userId!,
                              nombres: _nombresController.text,
                              apellidos: _apellidosController.text,
                              celular: _celularController.text,
                              correo: _correoController.text,
                              direccion: _direccionController.text,
                              tipoDocumento: _tipoDocumentoSeleccionado!,
                              numeroDocumento: _numeroDocumentoController.text,
                              roles: authProvider.perfil?.roles ?? [],
                            );
                            try {
                              // Usar UsuarioProvider para actualizar el usuario
                              final usuarioProvider = Provider.of<UsuarioProvider>(context, listen: false);
                              await usuarioProvider.actualizarUsuario(_userId!, usuario);

                              // Actualizar AuthProvider.perfil y cachear
                              authProvider.setPerfil(usuario);
                              await authProvider.cacheUserProfile(usuario);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Perfil actualizado correctamente')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error al actualizar: $e')),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}