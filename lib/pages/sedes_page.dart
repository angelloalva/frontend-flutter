import 'package:citas_app/models/sede.dart';
import 'package:citas_app/pages/sede_form_dialog.dart';
import 'package:citas_app/providers/sede_provider.dart';
import 'package:citas_app/providers/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SedesPage extends StatefulWidget {
  const SedesPage({super.key});

  @override
  _SedesPageState createState() => _SedesPageState();
}

class _SedesPageState extends State<SedesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SedeProvider>(context, listen: false).fetchSedes(context);
    });
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    final isAdmin = usuarioProvider.isAdmin ?? false;

    // Filtrar sedes según el texto de búsqueda
    final sedesFiltradas = sedeProvider.sedes.where((sede) {
      return sede.nombre.toLowerCase().contains(_searchText) ||
             sede.direccion.toLowerCase().contains(_searchText);
    }).toList();

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
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar sede...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: sedesFiltradas.isEmpty
                          ? const Center(child: Text('No hay sedes disponibles'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(0),
                              itemCount: sedesFiltradas.length,
                              itemBuilder: (context, index) {
                                final sede = sedesFiltradas[index];
                                return Card(
                                  elevation: 4,
                                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                    ),
                  ],
                ),
    );
  }
}