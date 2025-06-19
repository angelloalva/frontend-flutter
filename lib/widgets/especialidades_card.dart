import 'package:citas_app/models/especialidad.dart';
import 'package:flutter/material.dart';

class EspecialidadCard extends StatelessWidget {
  final Especialidad especialidad;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EspecialidadCard({
    super.key,
    required this.especialidad,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.purple[100],
          child: Icon(
            Icons.medical_services,
            color: Colors.purple[600],
          ),
        ),
        title: Text(
          especialidad.nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            especialidad.descripcion,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ),
        trailing: (onEdit != null || onDelete != null)
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      if (onEdit != null) onEdit!();
                      break;
                    case 'delete':
                      if (onDelete != null) onDelete!();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (onEdit != null)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                  if (onDelete != null)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar'),
                        ],
                      ),
                    ),
                ],
              )
            : null,
      ),
    );
  }
}