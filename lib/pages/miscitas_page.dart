import 'package:citas_app/models/user.dart';
import 'package:citas_app/pages/citas_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cita_provider.dart';
import '../providers/usuario_provider.dart';


class MisCitasPage extends StatefulWidget {
  const MisCitasPage({super.key});

  @override
  State<MisCitasPage> createState() => _MisCitasPageState();
}
class _MisCitasPageState extends State<MisCitasPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final usuarioProvider = Provider.of<UsuarioProvider>(context, listen: false);
      final pacienteId = usuarioProvider.usuario?.id ?? '';
      await Future.wait([
        Provider.of<CitaProvider>(context, listen: false).fetchCitasPorPaciente(pacienteId, context),
       
      ]);
    });
  }

  String getDoctorName(String doctorId, List<User> users) {
    final user = users.firstWhere(
      (u) => u.id == doctorId,
      orElse: () => User(
        id: '',
        nombres: 'Desconocido',
        apellidos: '',
        celular: '',
        correo: '',
        direccion: '',
        tipoDocumento: '',
        numeroDocumento: '',
        roles: [],
      ), // Devuelve un User por defecto
    );
    return user.nombres == 'Desconocido' ? 'Desconocido' : '${user.nombres} ${user.apellidos}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CitaProvider>(
      builder: (context, citaProvider, _) {
        if (citaProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Mis citas')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (citaProvider.error != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Mis Citas')),
            body: Center(child: Text('Error: ${citaProvider.error}')),
          );
        }

        final citas = citaProvider.citas;
        

       return Scaffold(
          appBar: AppBar(title: const Text('Mis Citas')),
          body: citas.isEmpty
              ? const Center(child: Text('No tienes citas registradas.'))
              : ListView.builder(
                  itemCount: citas.length,
                  itemBuilder: (context, index) {
                    final cita = citas[index];
                    final doctorNombreCompleto = '${cita.doctorNombres} ${cita.doctorApellidos}';

                    return ListTile(
                      leading: const Icon(Icons.event_note),
                      title: Text('Cita con Doctor: $doctorNombreCompleto'),
                      subtitle: Text('Fecha: ${cita.fechaHora}\nEstado: ${cita.estado}'),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text('Crear Cita'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CrearCitaPage()),
              );
            },
          ),
        );
      },
    );
  }
}