import 'dart:convert';

import 'package:citas_app/models/especialidad.dart';
import 'package:citas_app/services/especialidad_service.dart';
import 'package:flutter/material.dart';
import 'package:citas_app/widgets/especialidades_card.dart';

class EspecialidadesPage extends StatefulWidget {
  const EspecialidadesPage({Key? key}) : super(key: key);

  @override
  State<EspecialidadesPage> createState() => _EspecialidadesPageState();
}

class _EspecialidadesPageState extends State<EspecialidadesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Especialidad> especialidades = [];
  List<Especialidad> especialidadesFiltradas = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchEspecialidades();
    _searchController.addListener(_filterEspecialidades);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchEspecialidades() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final fetchedEspecialidades = await EspecialidadService().getEspecialidades(context);
      setState(() {
        especialidades = fetchedEspecialidades;
        especialidadesFiltradas = List.from(especialidades);
      });
    } catch (e) {
      _handleApiError(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterEspecialidades() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      especialidadesFiltradas = especialidades.where((especialidad) {
        return especialidad.nombre.toLowerCase().contains(query) ||
               especialidad.descripcion.toLowerCase().contains(query);
      }).toList();
    });
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
          ElevatedButton(
            onPressed: () async {
              if (nombreController.text.isNotEmpty) {
                setState(() {
                  _isLoading = true;
                });
                try {
                  final nuevaEspecialidad = await EspecialidadService().createEspecialidad(
                    
                    nombre: nombreController.text,
                    descripcion: descripcionController.text,context: context
                  );
                  setState(() {
                    especialidades.add(nuevaEspecialidad);
                    _filterEspecialidades();
                  });
                  Navigator.pop(context);
                  _showMessage('Especialidad creada exitosamente', isError: false);
                } catch (e) {
                  _handleApiError(e);
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
            child: const Text('Guardar'),
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
          ElevatedButton(
            onPressed: () async {
              if (nombreController.text.isNotEmpty) {
                setState(() {
                  _isLoading = true;
                });
                try {
                  // Using POST for editing as a temporary workaround
                  final updatedEspecialidad = await EspecialidadService().updateEspecialidad(
                    id: especialidad.id,
                    nombre: nombreController.text,
                    descripcion: descripcionController.text,
                    context:context,
                  );
                  setState(() {
                    int index = especialidades.indexWhere((e) => e.id == especialidad.id);
                    if (index != -1) {
                      especialidades[index] = updatedEspecialidad;
                      _filterEspecialidades();
                    }
                  });
                  Navigator.pop(context);
                  _showMessage('Especialidad actualizada exitosamente', isError: false);
                } catch (e) {
                  _handleApiError(e);
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
            child: const Text('Actualizar'),
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
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              try {
                await EspecialidadService().deleteEspecialidad(especialidad.id, context);
                setState(() {
                  especialidades.removeWhere((e) => e.id == especialidad.id);
                  _filterEspecialidades();
                });
                Navigator.pop(context);
                _showMessage('Especialidad eliminada exitosamente', isError: false);
              } catch (e) {
                _handleApiError(e);
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
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
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _showCreateDialog(),
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : especialidadesFiltradas.isEmpty
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
                        itemCount: especialidadesFiltradas.length,
                        itemBuilder: (context, index) {
                          final especialidad = especialidadesFiltradas[index];
                          return EspecialidadCard(
                            especialidad: especialidad,
                            onEdit: () => _showEditDialog(especialidad),
                            onDelete: () => _showDeleteDialog(especialidad),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}