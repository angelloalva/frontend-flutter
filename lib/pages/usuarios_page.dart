import 'package:citas_app/models/registro.dart';
import 'package:citas_app/providers/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/usuario_service.dart';
import '../providers/usuario_provider.dart';
import '../providers/especialidad_provider.dart';
import '../providers/sede_provider.dart';
import '../models/especialidad.dart';
import '../models/sede.dart';
class CrearUsuarioPage extends StatefulWidget {
  final bool isFromLogin;
  final String? defaultRole; // Nuevo parámetro
  
  const CrearUsuarioPage({
    Key? key, 
    this.isFromLogin = false,
    this.defaultRole, // Rol por defecto opcional
  }) : super(key: key);

  @override
  State<CrearUsuarioPage> createState() => _CrearUsuarioPageState();
}

class _CrearUsuarioPageState extends State<CrearUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _correoController = TextEditingController();
  final _celularController = TextEditingController();
  final _direccionController = TextEditingController();
  final _documentoNumeroController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  int _documentoTipo = 1;
  List<String> _roles = [];
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // Doctor fields
  final _cmpController = TextEditingController();
  String? _especialidadId;
  List<String> _sedeIds = [];

  bool get isDoctor => _roles.contains('DOCTOR');
  bool get isFromLogin => widget.isFromLogin;
  bool get hasDefaultRole => widget.defaultRole != null;

  @override
  void initState() {
    super.initState();
    // Si viene desde login, automáticamente selecciona PACIENTE
    if (isFromLogin) {
      _roles = ['PACIENTE'];
    } 
    // Si tiene un rol por defecto, establecerlo
    else if (widget.defaultRole != null) {
      _roles = [widget.defaultRole!];
    }
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _celularController.dispose();
    _direccionController.dispose();
    _documentoNumeroController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cmpController.dispose();
    super.dispose();
  }

  Future<void> _crearUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    final usuario = {
      'documentoTipo': _documentoTipo,
      'documentoNumero': _documentoNumeroController.text,
      'nombres': _nombresController.text,
      'apellidos': _apellidosController.text,
      'correo': _correoController.text,
      'celular': _celularController.text,
      'direccion': _direccionController.text,
      'roles': _roles,
      if (isFromLogin) 'password': _passwordController.text,
    };

    Map<String, dynamic>? doctor;
    if (isDoctor) {
      doctor = {
        'cmp': _cmpController.text,
        'especialidadId': _especialidadId,
        'sedeIds': _sedeIds,
        'fotoUrl': null,
      };
    }

    try {
      if (isFromLogin) {
         final registro = Registro(
              documentoTipo: _documentoTipo,
              documentoNumero: _documentoNumeroController.text,
              nombres: _nombresController.text,
              apellidos: _apellidosController.text,
              correo: _correoController.text,
              celular: _celularController.text,
              direccion: _direccionController.text,
              roles: _roles,
              password: _passwordController.text,
            );
        // Si viene desde login, usar AuthProvider
        await Provider.of<AuthProvider>(context, listen: false).crearUsuario(
         registro,
        );
      } else {
        // Si es creación administrativa, usar UsuarioProvider
        await Provider.of<UsuarioProvider>(context, listen: false).crearUsuario(
          usuario: usuario,
          doctor: doctor ?? {},
        );
      }
      
      String message = isFromLogin 
          ? 'Cuenta creada exitosamente. Ya puedes iniciar sesión.'
          : 'Usuario creado exitosamente';
          
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _selectSedesDialog(List<Sede> sedes) async {
    final selected = Set<String>.from(_sedeIds);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecciona las sedes'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: sedes.map((sede) {
                return CheckboxListTile(
                  value: selected.contains(sede.id),
                  title: Text(sede.nombre),
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        selected.add(sede.id);
                      } else {
                        selected.remove(sede.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _sedeIds = selected.toList();
                });
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  String _getTitulo() {
    if (isFromLogin) return 'Crear Cuenta';
    if (widget.defaultRole == 'DOCTOR') return 'Crear Doctor';
    return 'Crear Usuario';
  }

  @override
  Widget build(BuildContext context) {
    final especialidades = Provider.of<EspecialidadProvider>(context).especialidades;
    final sedes = Provider.of<SedeProvider>(context).sedes;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitulo()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<int>(
                value: _documentoTipo,
                decoration: const InputDecoration(labelText: 'Tipo de Documento'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('DNI')),
                  DropdownMenuItem(value: 2, child: Text('Carnet de Extranjería')),
                ],
                onChanged: (v) => setState(() => _documentoTipo = v!),
              ),
              TextFormField(
                controller: _documentoNumeroController,
                decoration: const InputDecoration(labelText: 'Número de Documento'),
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _nombresController,
                decoration: const InputDecoration(labelText: 'Nombres'),
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _apellidosController,
                decoration: const InputDecoration(labelText: 'Apellidos'),
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(labelText: 'Correo'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo requerido';
                  if (!v.contains('@')) return 'Ingresa un correo válido';
                  return null;
                },
              ),
              TextFormField(
                controller: _celularController,
                decoration: const InputDecoration(labelText: 'Celular'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              
              // Campos de contraseña solo si viene desde login
              if (isFromLogin) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Campo requerido';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Campo requerido';
                    if (v != _passwordController.text) return 'Las contraseñas no coinciden';
                    return null;
                  },
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Roles - Solo mostrar si NO viene desde login Y NO tiene rol por defecto
              if (!isFromLogin && !hasDefaultRole) ...[
                const Text('Roles:', style: TextStyle(fontWeight: FontWeight.bold)),
                CheckboxListTile(
                  title: const Text('ADMIN'),
                  value: _roles.contains('ADMIN'),
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _roles.add('ADMIN');
                      } else {
                        _roles.remove('ADMIN');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('DOCTOR'),
                  value: _roles.contains('DOCTOR'),
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _roles.add('DOCTOR');
                      } else {
                        _roles.remove('DOCTOR');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('PACIENTE'),
                  value: _roles.contains('PACIENTE'),
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _roles.add('PACIENTE');
                      } else {
                        _roles.remove('PACIENTE');
                      }
                    });
                  },
                ),
              ] else ...[
                // Si viene desde login, tiene rol por defecto, mostrar rol fijo
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          widget.defaultRole == 'DOCTOR' 
                              ? Icons.medical_services 
                              : Icons.person, 
                          color: Colors.blue[700]
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isFromLogin 
                              ? 'Registrándose como: PACIENTE'
                              : 'Creando usuario como: ${widget.defaultRole}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              // Si es doctor, pide datos de doctor
              if (isDoctor) ...[
                const Divider(),
                const Text(
                  'Información del Doctor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _cmpController,
                  decoration: const InputDecoration(labelText: 'CMP'),
                  validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _especialidadId,
                  decoration: const InputDecoration(labelText: 'Especialidad'),
                  items: especialidades.map((e) => DropdownMenuItem(
                    value: e.id,
                    child: Text(e.nombre),
                  )).toList(),
                  onChanged: (v) => setState(() => _especialidadId = v),
                  validator: (v) => v == null || v.isEmpty ? 'Selecciona una especialidad' : null,
                ),
                ListTile(
                  title: const Text('Sedes'),
                  subtitle: Text(
                    _sedeIds.isEmpty
                        ? 'Selecciona una o más sedes'
                        : sedes
                            .where((s) => _sedeIds.contains(s.id))
                            .map((s) => s.nombre)
                            .join(', '),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _selectSedesDialog(sedes),
                    child: const Text('Seleccionar'),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _crearUsuario,
                child: Text(_getTitulo()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}