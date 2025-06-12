import 'package:citas_app/pages/citas_page.dart';
import 'package:citas_app/pages/dashboard_page.dart';
import 'package:citas_app/pages/doctores_page.dart';
import 'package:citas_app/pages/especialidades_page.dart';
import 'package:citas_app/pages/paciente_page.dart';
import 'package:citas_app/pages/perfil_page.dart';
import 'package:citas_app/pages/sede_provider.dart';
import 'package:citas_app/pages/sedes_page.dart';
import 'package:citas_app/pages/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/login_page.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UsuarioProvider()),
        ChangeNotifierProvider(create: (context) => SedeProvider()),
      ],
      child: MaterialApp(
        title: 'Medical App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/dashboard': (context) => const DashboardPage(),
          '/perfil': (context) => const PerfilPage(),
          '/especialidad': (context) => const EspecialidadesPage(),
          '/paciente': (context) => const PacientePage(),
          '/citas': (context) => const CitasPage(),
          '/doctores': (context) => const DoctoresPage(),
          '/sedes': (context) => const SedesPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}