import 'package:citas_app/models/sede.dart';
import 'package:citas_app/pages/sede_form_dialog.dart';
import 'package:citas_app/pages/sede_provider.dart';
import 'package:citas_app/pages/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SedesPage extends StatefulWidget {
  const SedesPage({super.key});

  @override
  _SedesPageState createState() => _SedesPageState();
}

class _SedesPageState extends State<SedesPage> {
  @override
  void initState() {
    super.initState();
    // Cargar sedes al montar la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SedeProvider>(context, listen: false).fetchSedes(context);
    });
  }

  void _showSedeFormDialog([Sede? sede]) {
    showDialog(
      context: context,
      builder: (context) => SedeFormDialog(sede: sede),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sedeProvider = Provider.of<SedeProvider>(context);
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    final isAdmin = usuarioProvider.isAdmin ?? false; // Verifica si el usuario es admin

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Sedes'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: Colors.blue[600],
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () => _showSedeFormDialog(),
            )
          : null,
      body: sedeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : sedeProvider.error != null
              ? Center(child: Text('Error: ${sedeProvider.error}'))
              : sedeProvider.sedes.isEmpty
                  ? const Center(child: Text('No hay sedes disponibles'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: sedeProvider.sedes.length,
                      itemBuilder: (context, index) {
                        final sede = sedeProvider.sedes[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 30,
                              ),
                            ),
                            title: Text(
                              sede.nombre,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              sede.direccion,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            trailing: isAdmin
                                ? IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showSedeFormDialog(sede),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
    );
  }
}