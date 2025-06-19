import 'package:citas_app/pages/usuarios_page.dart';
import 'package:citas_app/providers/usuario_provider.dart';
import 'package:citas_app/providers/especialidad_provider.dart';
import 'package:citas_app/providers/sede_provider.dart';
import 'package:flutter/material.dart';
import 'package:citas_app/widgets/dashboard_card.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citas_app/pages/misturnos_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
      Provider.of<EspecialidadProvider>(context, listen: false).fetchEspecialidades(context);
      Provider.of<SedeProvider>(context, listen: false).fetchSedes(context);
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId != null) {
      await Provider.of<UsuarioProvider>(context, listen: false).fetchUsuario(userId);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_id');
    await prefs.remove('user_data');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {


    return Consumer<UsuarioProvider>(
      builder: (context, usuarioProvider, child) {
        String userFullName = 'Usuario';
        if (usuarioProvider.usuario != null) {
          userFullName = '${usuarioProvider.usuario!.nombres} ${usuarioProvider.usuario!.apellidos}'.trim();
        }

        final roles = usuarioProvider.usuario?.roles ?? [];
        final esDoctor = roles.contains('DOCTOR');
        final esAdmin = roles.contains('ADMIN');
        final puedeVerTurnos = roles.contains('ADMIN') || esDoctor;

        // Obtén las listas de especialidades y sedes
        final especialidades = Provider.of<EspecialidadProvider>(context).especialidades;
        final sedes = Provider.of<SedeProvider>(context).sedes;

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: const Text('Dashboard'),
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _logout(context),
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Text(
                    'Menú',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Mi Perfil'),
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final userId = prefs.getString('user_id');
                    if (userId != null) {
                      Navigator.pushNamed(context, '/perfil');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error: No se encontró el ID del usuario')),
                      );
                    }
                  },
                ),
                if (esAdmin || esDoctor)
                  ListTile(
                    leading: const Icon(Icons.medical_services),
                    title: const Text('Paciente'),
                    onTap: () {
                      Navigator.pushNamed(context, '/paciente');
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.medical_services),
                  title: const Text('Especialidades'),
                  onTap: () {
                    Navigator.pushNamed(context, '/especialidad');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Citas'),
                  onTap: () {
                    Navigator.pushNamed(context, '/citas');
                  },
                ),
                // ----------- OPCIÓN MIS TURNOS SOLO PARA DOCTOR -----------
                if (esAdmin)
                  
                  ListTile(
                    leading: const Icon(Icons.person_pin),
                    title: const Text('Doctores'),
                    onTap: () {
                      Navigator.pushNamed(context, '/doctores');
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Sedes'),
                  onTap: () {
                    Navigator.pushNamed(context, '/sedes');
                  },
                ),
                // ----------- OPCIÓN MIS TURNOS SOLO PARA DOCTOR -----------
                if (esDoctor)
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('Mis Turnos'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MisTurnosPage(
                            especialidades: especialidades,
                            sedes: sedes,
                          ),
                        ),
                      );
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Cerrar Sesión'),
                  onTap: () => _logout(context),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[600]!, Colors.blue[400]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue[200]!,
                        offset: const Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¡Bienvenido!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userFullName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  children: [
                    /*if (esAdmin)
                      DashboardCard(
                        title: 'Usuarios',
                        icon: Icons.people,
                        color: Colors.purple,
                        subtitle: 'Gestiona los usuarios del sistema',
                        onTap: () {
                          Navigator.pushNamed(context, '/usuarios');
                        },
                      ),*/
                    if (esAdmin || esDoctor )  
                      DashboardCard(
                        title: 'Paciente',
                        icon: Icons.medical_services,
                        color: Colors.blue,
                        subtitle: 'Consulta información de pacientes',
                        onTap: () {
                          Navigator.pushNamed(context, '/paciente');
                        },
                      ),
                    DashboardCard(
                      title: 'Citas',
                      icon: Icons.calendar_today,
                      color: Colors.green,
                      subtitle: 'Gestiona tus citas médicas',
                      onTap: () {
                        Navigator.pushNamed(context, '/citas');
                      },
                    ),
                    DashboardCard(
                      title: 'Especialidades',
                      icon: Icons.calendar_today,
                      color: Colors.deepPurple,
                      subtitle: 'Gestiona tus especialidades',
                      onTap: () {
                        Navigator.pushNamed(context, '/especialidad');
                      },
                    ),
                    if (esAdmin)
                      DashboardCard(
                        title: 'Doctores',
                        icon: Icons.person_pin,
                        color: Colors.orange,
                        subtitle: 'Encuentra información de doctores',
                        onTap: () {
                          Navigator.pushNamed(context, '/doctores');
                        },
                      ),
                    if (esAdmin)
                      DashboardCard(
                        title: 'Sedes',
                        icon: Icons.location_on,
                        color: Colors.red,
                        subtitle: 'Consulta las sedes disponibles',
                        onTap: () {
                          Navigator.pushNamed(context, '/sedes');
                        },
                      ),
                    // ----------- TARJETA MIS TURNOS SOLO PARA DOCTOR -----------
                    if (esDoctor)
                      DashboardCard(
                        title: 'Mis Turnos',
                        icon: Icons.schedule,
                        color: Colors.teal,
                        subtitle: 'Visualiza tus turnos',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MisTurnosPage(
                                especialidades: especialidades,
                                sedes: sedes,
                              ),
                            ),
                          );
                        },
                      ),
                        // ----------- TARJETA CREAR USUARIO SOLO PARA ADMIN -----------
                    if (esAdmin)
                      DashboardCard(
                        title: 'Crear Usuario',
                        icon: Icons.person_add,
                        color: Colors.indigo,
                        subtitle: 'Registrar un nuevo usuario',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CrearUsuarioPage(),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}