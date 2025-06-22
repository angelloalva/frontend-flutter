// lib/pages/doctores_page.dart
import 'package:citas_app/providers/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/doctor_provider.dart';
import '../providers/especialidad_provider.dart';
import '../providers/sede_provider.dart';
import '../providers/usuario_provider.dart';
import 'usuarios_page.dart';

class DoctoresPage extends StatefulWidget {
  const DoctoresPage({Key? key}) : super(key: key);

  @override
  State<DoctoresPage> createState() => _DoctoresPageState();
}

class _DoctoresPageState extends State<DoctoresPage> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DoctorProvider>(context, listen: false).fetchDoctores();
      Provider.of<UsuarioProvider>(context, listen: false).fetchUsuarios();
    });
  }

  @override
  Widget build(BuildContext context) {

    final usuarioProvider = Provider.of<AuthProvider>(context);
      final roles = usuarioProvider.perfil!.roles ?? [];

      // 🔒 Restricción de acceso
      if (!roles.contains('ADMIN')) {
        return Scaffold(
          appBar: AppBar(title: const Text('Acceso Denegado')),
          body: const Center(child: Text('No tienes permiso para ver esta página.')),
        );
      }


    final especialidades = Provider.of<EspecialidadProvider>(context).especialidades;
    final sedes = Provider.of<SedeProvider>(context).sedes;
    final usuarios = Provider.of<UsuarioProvider>(context).usuarios;
    final especialidadNombres = {for (var e in especialidades) e.id: e.nombre};
    final sedeNombres = {for (var s in sedes) s.id: s.nombre};
    final usuarioNombres = {for (var u in usuarios) u.id: '${u.nombres} ${u.apellidos}'};

    return Consumer<DoctorProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Doctores')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (provider.error != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Doctores')),
            body: Center(child: Text('Error: ${provider.error}')),
          );
        }
        for (var doctor in provider.doctores) {
            if (!usuarioNombres.containsKey(doctor.usuarioId)) {
              print('ADVERTENCIA: No se encontró usuario para usuarioId: ${doctor.usuarioId} (doctor id: ${doctor.id})');
            }
          }
            print('Doctores cargados (${provider.doctores.length}):');
            for (var d in provider.doctores) {
              print('Doctor: id=${d.id}, usuarioId=${d.usuarioId}, cmp=${d.cmp}');
            }
                  final doctores = provider.doctores.where((doctor) {
              final usuarioId = doctor.usuarioId;
              final nombreCompleto = usuarioNombres[usuarioId]?.toLowerCase() ?? '';
              final query = _search.toLowerCase();
              return doctor.cmp.toLowerCase().contains(query) ||
                    nombreCompleto.contains(query);
            }).toList();

        print('Doctores cargados (${provider.doctores.length}):');
        for (var d in provider.doctores) {
          print('Doctor: id=${d.id}, usuarioId=${d.usuarioId}, cmp=${d.cmp}');
        }
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Doctores'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add),
                tooltip: 'Crear Usuario',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CrearUsuarioPage( defaultRole: 'DOCTOR',)),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Buscar doctor por nombre o CMP',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _search = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: doctores.isEmpty
                    ? const Center(child: Text('No hay doctores registrados.'))
                    : ListView.builder(
                        itemCount: doctores.length,
                        itemBuilder: (context, index) {
                          final doctor = doctores[index];
                          final nombreCompleto = usuarioNombres[doctor.usuarioId] ?? 'Sin nombre';
                          return ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(nombreCompleto),
                            subtitle: Text(
                              'CMP: ${doctor.cmp}\n'
                              'Especialidad: ${especialidadNombres[doctor.especialidadId] ?? doctor.especialidadId}\n'
                              'Sedes: ${doctor.sedeIds.map((id) => sedeNombres[id] ?? id).join(', ')}',
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}