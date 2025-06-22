import 'dart:convert';

import 'package:citas_app/models/especialidad.dart';
import 'package:citas_app/providers/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:citas_app/widgets/especialidades_card.dart';
import 'package:provider/provider.dart';
import 'package:citas_app/providers/usuario_provider.dart';
import 'package:citas_app/providers/especialidad_provider.dart';

class EspecialidadesPage extends StatefulWidget {
  const EspecialidadesPage({super.key});

  @override
  State<EspecialidadesPage> createState() => _EspecialidadesPageState();
}

class _EspecialidadesPageState extends State<EspecialidadesPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EspecialidadProvider>(context, listen: false).fetchEspecialidades(context);
    });
    _searchController.addListener(() {
      setState(() {}); // Para actualizar la búsqueda
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateDialog() {
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Especialidad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          Consumer<EspecialidadProvider>(
            builder: (context, provider, _) => ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      if (nombreController.text.isNotEmpty) {
                        try {
                          await provider.createEspecialidad(
                            context: context,
                            nombre: nombreController.text,
                            descripcion: descripcionController.text,
                          );
                          Navigator.pop(context);
                          _showMessage('Especialidad creada exitosamente', isError: false);
                        } catch (e) {
                          _handleApiError(e);
                        }
                      }
                    },
              child: provider.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Especialidad especialidad) {
    final nombreController = TextEditingController(text: especialidad.nombre);
    final descripcionController = TextEditingController(text: especialidad.descripcion);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Especialidad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          Consumer<EspecialidadProvider>(
            builder: (context, provider, _) => ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      if (nombreController.text.isNotEmpty) {
                        try {
                          await provider.updateEspecialidad(
                            context: context,
                            id: especialidad.id,
                            nombre: nombreController.text,
                            descripcion: descripcionController.text,
                          );
                          Navigator.pop(context);
                          _showMessage('Especialidad actualizada exitosamente', isError: false);
                        } catch (e) {
                          _handleApiError(e);
                        }
                      }
                    },
              child: provider.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Actualizar'),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Especialidad especialidad) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Especialidad'),
        content: Text('¿Estás seguro de eliminar "${especialidad.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          Consumer<EspecialidadProvider>(
            builder: (context, provider, _) => ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      try {
                        await provider.deleteEspecialidad(
                          context: context,
                          id: especialidad.id,
                        );
                        Navigator.pop(context);
                        _showMessage('Especialidad eliminada exitosamente', isError: false);
                      } catch (e) {
                        _handleApiError(e);
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: provider.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Eliminar'),
            ),
          ),
        ],
      ),
    );
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

  void _handleApiError(dynamic e) {
    print('Error capturado: $e');
    String message = 'Error desconocido';
    if (e is Exception) {
      String errorString = e.toString();
      try {
        final errorJson = json.decode(errorString.split(': ').last);
        if (errorString.contains('404')) {
          message = errorJson['message'] ?? 'Especialidad no encontrada';
        } else if (errorString.contains('400')) {
          final details = errorJson['details'] as Map<String, dynamic>;
          message = details.entries.map((e) => '${e.key}: ${e.value}').join(', ');
        } else if (errorString.contains('403')) {
          message = 'No tienes permiso para realizar esta acción';
        } else if (errorString.contains('401')) {
          message = 'Sesión expirada. Por favor, inicia sesión nuevamente';
        } else {
          message = errorJson['message'] ?? 'Error inesperado';
        }
      } catch (_) {
        message = errorString;
      }
    }
    _showMessage(message, isError: true);
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = usuarioProvider.perfil!.roles.contains("ADMIN") ?? false;

    return Consumer<EspecialidadProvider>(
      builder: (context, provider, _) {
        final query = _searchController.text.toLowerCase();
        final listaMostrar = query.isEmpty
            ? provider.especialidades
            : provider.especialidades.where((especialidad) {
                return especialidad.nombre.toLowerCase().contains(query) ||
                    especialidad.descripcion.toLowerCase().contains(query);
              }).toList();

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Especialidades'),
            backgroundColor: Colors.purple[600],
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Column(
            children: [
              // Header con búsqueda
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.purple[600],
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar especialidades...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isAdmin)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: provider.isLoading ? null : () => _showCreateDialog(),
                              icon: const Icon(Icons.add),
                              label: const Text('Nueva Especialidad'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.purple[600],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Lista de especialidades
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : listaMostrar.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No se encontraron especialidades',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: listaMostrar.length,
                            itemBuilder: (context, index) {
                              final especialidad = listaMostrar[index];
                              return EspecialidadCard(
                                especialidad: especialidad,
                                onEdit: isAdmin ? () => _showEditDialog(especialidad) : null,
                                onDelete: isAdmin ? () => _showDeleteDialog(especialidad) : null,
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