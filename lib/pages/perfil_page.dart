// perfil_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citas_app/models/user.dart';
import 'usuario_provider.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({Key? key}) : super(key: key);

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
    String? _tipoDocumentoSeleccionado = '1'; // valor por defecto

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombresController,
                decoration: const InputDecoration(labelText: 'Nombres'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _apellidosController,
                decoration: const InputDecoration(labelText: 'Apellidos'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _celularController,
                decoration: const InputDecoration(labelText: 'Celular'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(labelText: 'Correo'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
                DropdownButtonFormField<String>(
                  value: _tipoDocumentoSeleccionado,
                  decoration: const InputDecoration(labelText: 'Tipo de Documento'),
                  items: tiposDocumento.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key, // 1, 2, 3
                      child: Text(entry.value), // DNI, Carnet, Pasaporte
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _tipoDocumentoSeleccionado = value;
                    });
                  },
                  validator: (value) => value == null ? 'Seleccione un tipo de documento' : null,
                ),

              TextFormField(
                controller: _numeroDocumentoController,
                decoration: const InputDecoration(labelText: 'Número de Documento'),
                readOnly: true, // Hacer el campo no editable
                style: TextStyle(color: Colors.grey[600]), // Opcional: estilo para indicar que es readonly
              ),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
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
                     numeroDocumento: _numeroDocumento ?? '', // Usar el valor almacenado// solo debe mostrarse no se puede editar
                     roles:usuarioProvider.usuario?.roles ?? {}
                    );
                    try {
                      await Provider.of<UsuarioProvider>(context, listen: false)
                          .actualizarUsuario(_userId!, usuario);
                      // Actualizar datos en SharedPreferences
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
                child: const Text('Actualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}