import 'package:citas_app/providers/doctor_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/turno_provider.dart';
import '../providers/usuario_provider.dart';
import '../models/especialidad.dart';
import '../models/sede.dart';

class MisTurnosPage extends StatefulWidget {
  final List<Especialidad> especialidades;
  final List<Sede> sedes;

  const MisTurnosPage({
    super.key,
    required this.especialidades,
    required this.sedes,
  });

  @override
  State<MisTurnosPage> createState() => _MisTurnosPageState();
}

class _MisTurnosPageState extends State<MisTurnosPage> {
  late Map<String, String> especialidadNombres;
  late Map<String, String> sedeNombres;

  @override
  void initState() {
    super.initState();
    print('Especialidades recibidas:');
    for (var e in widget.especialidades) {
      print('ID: ${e.id}, Nombre: ${e.nombre}');
    }
    especialidadNombres = {for (var e in widget.especialidades) e.id: e.nombre};
    sedeNombres = {for (var s in widget.sedes) s.id: s.nombre};

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final usuarioProvider = Provider.of<UsuarioProvider>(context, listen: false);
          final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);

    // 🔥 Esta es la llamada que te falta 🔥
    await doctorProvider.fetchDoctores();
      final doctorId = usuarioProvider.usuario?.id ?? '';
      await Provider.of<TurnoProvider>(context, listen: false)
          .fetchTurnosPorDoctor(doctorId, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    final roles = usuarioProvider.usuario?.roles ?? [];
    final puedeCrearTurno = roles.contains('DOCTOR');
    final doctorId = usuarioProvider.usuario?.id ?? '';

    return Consumer<TurnoProvider>(
      builder: (context, turnoProvider, _) {
        if (turnoProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Mis Turnos')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (turnoProvider.error != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Mis Turnos')),
            body: Center(child: Text('Error: ${turnoProvider.error}')),
          );
        }
        final turnos = turnoProvider.turnos;
        return Scaffold(
          appBar: AppBar(title: const Text('Mis Turnos')),
          body: turnos.isEmpty
              ? const Center(child: Text('No tienes turnos registrados.'))
              : ListView.builder(
                  itemCount: turnos.length,
                  itemBuilder: (context, index) {
                    final turno = turnos[index];
                    return Card(
                      margin: const EdgeInsets.all(12),
                      child: ExpansionTile(
                        title: Text('Turno #${index + 1}'),
                        subtitle: Text(
                          'Especialidad: ${especialidadNombres[turno.especialidadId] ?? 'Desconocida'}\n'
                          'Sede: ${sedeNombres[turno.sedeId] ?? 'Desconocida'}',
                        ),
                        children: turno.diasDisponibles.map((dia) => ListTile(
                          title: Text('${dia.dia} ${dia.fecha}'),
                          subtitle: Text('${dia.horaInicio} - ${dia.horaFin}'),
                        )).toList(),
                      ),
                    );
                  },
                ),
          floatingActionButton: puedeCrearTurno
            ? FloatingActionButton.extended(
                heroTag: 'crear_turno_fab',
                icon: const Icon(Icons.add),
                label: const Text('Crear Turno'),
                onPressed: () async { // 🔥 Agrega async aquí
                  final result = await Navigator.pushNamed(
                    context,
                    '/crear-turno',
                    arguments: {
                      'especialidades': widget.especialidades,
                      'sedes': widget.sedes,
                      'doctorId': doctorId,
                    },
                  );

                  if (result == true) { // 🔥 Verifica si se creó un turno
                    final turnoProvider = Provider.of<TurnoProvider>(context, listen: false);
                    await turnoProvider.fetchTurnosPorDoctor(doctorId, context);
                  } }
              )
            : null,

        );
      },
    );
  }
}