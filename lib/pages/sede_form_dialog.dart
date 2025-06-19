import 'package:citas_app/models/sede.dart';
import 'package:citas_app/providers/sede_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SedeFormDialog extends StatefulWidget {
final Sede? sede; // Null para crear, no null para editar

  const SedeFormDialog({super.key, this.sede});

  @override
  _SedeFormDialogState createState() => _SedeFormDialogState();
}

class _SedeFormDialogState extends State<SedeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _direccionController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.sede?.nombre ?? '');
    _direccionController = TextEditingController(text: widget.sede?.direccion ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final sedeProvider = Provider.of<SedeProvider>(context, listen: false);
      try {
        if (widget.sede == null) {
          // Crear nueva sede
          await sedeProvider.crearSede(
            _nombreController.text,
            _direccionController.text,
            context,
          );
        } else {
          // Actualizar sede existente
          await sedeProvider.actualizarSede(
            widget.sede!.id,
            _nombreController.text,
            _direccionController.text,
            context,
          );
        }
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar esta sede?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final sedeProvider = Provider.of<SedeProvider>(context, listen: false);
      try {
        await sedeProvider.eliminarSede(widget.sede!.id, context);
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.sede != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Sede' : 'Crear Sede'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'El nombre es obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'La dirección es obligatoria' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (isEditing)
          TextButton(
            onPressed: _delete,
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Actualizar' : 'Crear'),
        ),
      ],
    );
  }
}