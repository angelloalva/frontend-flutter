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

class _MisCitasPageState extends State<MisCitasPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final usuarioProvider = Provider.of<UsuarioProvider>(context, listen: false);
      final pacienteId = usuarioProvider.usuario?.id ?? '';
      await Provider.of<CitaProvider>(context, listen: false)
          .fetchCitasPorPaciente(pacienteId, context);
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CitaProvider>(
      builder: (context, citaProvider, _) {
        if (citaProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Mis Citas')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (citaProvider.error != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Mis Citas')),
            body: Center(child: Text('Error: ${citaProvider.error}')),
          );
        }

        final now = DateTime.now();
        final proximas = citaProvider.citas.where((cita) {
          return cita.fechaHora.isAfter(now) || 
              (cita.fechaHora.day == now.day &&
               cita.fechaHora.month == now.month &&
               cita.fechaHora.year == now.year &&
               cita.estado == 'PENDIENTE');
        }).toList();
        final historial = citaProvider.citas.where((cita) {
          return cita.fechaHora.isBefore(now) || 
              cita.estado == 'COMPLETADA' || 
              cita.estado == 'CANCELADA';
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mis Citas'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Próximas'),
                Tab(text: 'Historial'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Pestaña Próximas
              proximas.isEmpty
                  ? const Center(child: Text('No tienes citas próximas.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: proximas.length,
                      itemBuilder: (context, index) {
                        final cita = proximas[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 20, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Fecha: ${cita.fechaHora.day}/${cita.fechaHora.month}/${cita.fechaHora.year} ${cita.fechaHora.hour}:${cita.fechaHora.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.medical_services, size: 20, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text('Especialidad: ${cita.especialidadNombre ?? 'No especificada'}'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 20, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text('Doctor: ${cita.doctorNombres} ${cita.doctorApellidos}'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 20, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text('Sede: ${cita.sedeNombre ?? 'No especificada'}'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.info, size: 20, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text('Estado: ${cita.estado}'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              // Pestaña Historial
              historial.isEmpty
                  ? const Center(child: Text('No tienes citas en el historial.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: historial.length,
                      itemBuilder: (context, index) {
                        final cita = historial[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 20, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Fecha: ${cita.fechaHora.day}/${cita.fechaHora.month}/${cita.fechaHora.year} ${cita.fechaHora.hour}:${cita.fechaHora.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.medical_services, size: 20, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text('Especialidad: ${cita.especialidadNombre ?? 'No especificada'}'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 20, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text('Doctor: ${cita.doctorNombres} ${cita.doctorApellidos}'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 20, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text('Sede: ${cita.sedeNombre ?? 'No especificada'}'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.info, size: 20, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text('Estado: ${cita.estado}'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'misheroTag_citas_fab',
            icon: const Icon(Icons.add),
            label: const Text('Crear Cita'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CrearCitaPage()),
              ).then((result) {
                if (result == true) {
                  // Recarga las citas
                  final usuarioProvider = Provider.of<UsuarioProvider>(context, listen: false);
                  final pacienteId = usuarioProvider.usuario?.id ?? '';
                  Provider.of<CitaProvider>(context, listen: false)
                      .fetchCitasPorPaciente(pacienteId, context);
                }
              });
            },
          ),
        );
      },
    );
  }
}