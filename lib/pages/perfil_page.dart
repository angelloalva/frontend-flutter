// perfil_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citas_app/models/user.dart';
import '../providers/usuario_provider.dart';

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
  late TextEditingController _numeroDocumentoController; // Nuevo controlador
  late String? _numeroDocumento; // Variable para almacenar numeroDocumento
  String? _userId;
  String? _tipoDocumentoSeleccionado = '1';
  @override
  void initState() {
    super.initState();
    _nombresController = TextEditingController();
    _apellidosController = TextEditingController();
    _celularController = TextEditingController();
    _correoController = TextEditingController();
    _direccionController = TextEditingController();
    _numeroDocumentoController = TextEditingController(); // Inicializar controlador
    _numeroDocumento = null; // Inicializar como null

    // Cargar userId y datos desde SharedPreferences
    _loadUserData();
  }
  @override
  void didUpdateWidget(covariant PerfilPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final usuario = Provider.of<UsuarioProvider>(context).usuario;
    if (usuario != null) {
      setState(() {
        _nombresController.text = usuario.nombres;
        _apellidosController.text = usuario.apellidos;
        _celularController.text = usuario.celular;
        _correoController.text = usuario.correo;
        _direccionController.text = usuario.direccion;
        _tipoDocumentoSeleccionado = usuario.tipoDocumento.toString();
        _numeroDocumento = usuario.numeroDocumento; // Actualizar numeroDocumento
        _numeroDocumentoController.text = usuario.numeroDocumento ?? ''; // Actualizar controlador
      });
    }
  }
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id');
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      final user = User.fromJson(userData);
      setState(() {
        _nombresController.text = user.nombres;
        _apellidosController.text = user.apellidos;
        _celularController.text = user.celular;
        _correoController.text = user.correo;
        _direccionController.text = user.direccion;
        _numeroDocumento = user.numeroDocumento; // Cargar numeroDocumento
        _numeroDocumentoController.text = user.numeroDocumento ?? ''; // Actualizar 
        _tipoDocumentoSeleccionado = user.tipoDocumento.toString();
      });
    }

    // Obtener datos frescos desde la API si hay userId
    if (_userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<UsuarioProvider>(context, listen: false).fetchUsuario(_userId!);
      });
    }
  }
  

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _celularController.dispose();
    _correoController.dispose();
    _direccionController.dispose();
    _numeroDocumentoController.dispose(); // Dispose del nuevo controlador

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(context);

    if (_userId == null) {
      return const Scaffold(
        body: Center(child: Text('Error: No se encontró el ID del usuario')),
      );
    }

    if (usuarioProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (usuarioProvider.error != null) {
      return Scaffold(
        body: Center(child: Text('Error: ${usuarioProvider.error}')),
      );
    }

    final usuario = usuarioProvider.usuario;
    if (usuario != null) {
      _nombresController.text = usuario.nombres;
      _apellidosController.text = usuario.apellidos;
      _celularController.text = usuario.celular;
      _correoController.text = usuario.correo;
      _direccionController.text = usuario.direccion;
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
                    // Avatar
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.blue[100],
                      child: const Icon(Icons.person, size: 60, color: Colors.blue),
                    ),
                    const SizedBox(height: 24),
                    // Nombres
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
                    // Apellidos
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
                    // Celular
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
                    // Correo
                    TextFormField(
                      controller: _correoController,
                      decoration: const InputDecoration(
                        labelText: 'Correo',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    // Tipo de documento
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
                    // Número de documento (solo lectura)
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
                    // Dirección
                    TextFormField(
                      controller: _direccionController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección',
                        prefixIcon: Icon(Icons.home),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Botón actualizar
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
                              numeroDocumento: _numeroDocumento ?? '',
                              roles: usuarioProvider.usuario?.roles ?? [],
                            );
                            try {
                              await Provider.of<UsuarioProvider>(context, listen: false)
                                  .actualizarUsuario(_userId!, usuario);
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setString('user_data', jsonEncode(usuario.toJson()));
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