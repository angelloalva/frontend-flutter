import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/paciente_provider.dart';
import '../providers/doctor_provider.dart';
import '../providers/usuario_provider.dart';
import '../models/user.dart';

class PacientePage extends StatefulWidget {
  const PacientePage({Key? key}) : super(key: key);

  @override
  State<PacientePage> createState() => _PacientePageState();
}

class _PacientePageState extends State<PacientePage> {
  int _currentPage = 0;
  final int _pageSize = 10;
  String _search = '';

  // Mapa para mostrar el nombre del tipo de documento
  final Map<String, String> tipoDocumentoNombres = {
    '1': 'DNI',
    '2': 'CARNET DE EXTRANJERIA',
    '3': 'PASAPORTE',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final usuarioProvider = Provider.of<UsuarioProvider>(context, listen: false);
      final esAdmin = usuarioProvider.usuario?.roles.contains('ADMIN');
      final esDoctor = usuarioProvider.usuario?.roles.contains('DOCTOR');
      if (esAdmin == true) {
        Provider.of<PacienteProvider>(context, listen: false).fetchPacientes();
      } else if (esDoctor == true) {
        Provider.of<DoctorProvider>(context, listen: false).fetchMisPacientes();
      }
    });
  }

  void _showPacienteDetalles(User paciente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(child: Text('${paciente.nombres} ${paciente.apellidos}')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.badge),
              title: const Text('Tipo de documento'),
              subtitle: Text(tipoDocumentoNombres[paciente.tipoDocumento] ?? paciente.tipoDocumento),
            ),
            ListTile(
              leading: const Icon(Icons.confirmation_number),
              title: const Text('Número de documento'),
              subtitle: Text(paciente.numeroDocumento),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Celular'),
              subtitle: Text(paciente.celular),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Correo'),
              subtitle: Text(paciente.correo),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Dirección'),
              subtitle: Text(paciente.direccion),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    final esAdmin = usuarioProvider.usuario?.roles.contains('ADMIN');
    final esDoctor = usuarioProvider.usuario?.roles.contains('DOCTOR');

    if (esAdmin == true) {
      return Consumer<PacienteProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Scaffold(
              appBar: AppBar(title: const Text('Pacientes')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          if (provider.error != null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Pacientes')),
              body: Center(child: Text('Error: ${provider.error}')),
            );
          }

          final pacientes = provider.pacientes.where((p) {
            final query = _search.toLowerCase();
            return p.nombres.toLowerCase().contains(query) ||
                   p.apellidos.toLowerCase().contains(query) ||
                   p.numeroDocumento.toLowerCase().contains(query);
          }).toList();

          final totalPages = (pacientes.length / _pageSize).ceil();
          final start = _currentPage * _pageSize;
          final end = (start + _pageSize) > pacientes.length ? pacientes.length : (start + _pageSize);
          final pacientesPagina = pacientes.sublist(start, end);

          return Scaffold(
            appBar: AppBar(title: const Text('Pacientes')),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Buscar paciente',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _search = value;
                        _currentPage = 0;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: pacientesPagina.isEmpty
                      ? const Center(child: Text('No hay pacientes registrados.'))
                      : ListView.separated(
                          itemCount: pacientesPagina.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final paciente = pacientesPagina[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(horizontal: 12),
                              child: ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.person)),
                                title: Text('${paciente.nombres} ${paciente.apellidos}'),
                                subtitle: Text('Documento: ${paciente.numeroDocumento}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.info_outline, color: Colors.blue),
                                  onPressed: () => _showPacienteDetalles(paciente),
                                  tooltip: 'Ver detalles',
                                ),
                                onTap: () => _showPacienteDetalles(paciente),
                              ),
                            );
                          },
                        ),
                ),
                if (totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: _currentPage > 0
                              ? () => setState(() => _currentPage--)
                              : null,
                        ),
                        Text('Página ${_currentPage + 1} de $totalPages'),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: _currentPage < totalPages - 1
                              ? () => setState(() => _currentPage++)
                              : null,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      );
    } else if (esDoctor == true) {
      return Consumer<DoctorProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingPacientes) {
            return Scaffold(
              appBar: AppBar(title: const Text('Mis Pacientes')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          if (provider.errorPacientes != null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Mis Pacientes')),
              body: Center(child: Text('Error: ${provider.errorPacientes}')),
            );
          }
          final pacientes = provider.misPacientes.where((p) {
            final query = _search.toLowerCase();
            return p.nombres.toLowerCase().contains(query) ||
                   p.apellidos.toLowerCase().contains(query) ||
                   p.numeroDocumento.toLowerCase().contains(query);
          }).toList();

          final totalPages = (pacientes.length / _pageSize).ceil();
          final start = _currentPage * _pageSize;
          final end = (start + _pageSize) > pacientes.length ? pacientes.length : (start + _pageSize);
          final pacientesPagina = pacientes.sublist(start, end);

          return Scaffold(
            appBar: AppBar(title: const Text('Mis Pacientes')),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Buscar paciente',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _search = value;
                        _currentPage = 0;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: pacientesPagina.isEmpty
                      ? const Center(child: Text('No tienes pacientes asignados.'))
                      : ListView.separated(
                          itemCount: pacientesPagina.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final paciente = pacientesPagina[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(horizontal: 12),
                              child: ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.person)),
                                title: Text('${paciente.nombres} ${paciente.apellidos}'),
                                subtitle: Text('Documento: ${paciente.numeroDocumento}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.info_outline, color: Colors.blue),
                                  onPressed: () => _showPacienteDetalles(paciente),
                                  tooltip: 'Ver detalles',
                                ),
                                onTap: () => _showPacienteDetalles(paciente),
                              ),
                            );
                          },
                        ),
                ),
                if (totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: _currentPage > 0
                              ? () => setState(() => _currentPage--)
                              : null,
                        ),
                        Text('Página ${_currentPage + 1} de $totalPages'),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: _currentPage < totalPages - 1
                              ? () => setState(() => _currentPage++)
                              : null,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      );
    } else {
      return const Scaffold(
        body: Center(child: Text('No tienes permisos para ver pacientes.')),
      );
    }
  }
}