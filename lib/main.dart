import 'package:citas_app/pages/citas_page.dart';
import 'package:citas_app/pages/dashboard_page.dart';
import 'package:citas_app/pages/doctores_page.dart';
import 'package:citas_app/pages/especialidades_page.dart';
import 'package:citas_app/pages/miscitas_page.dart';
import 'package:citas_app/pages/paciente_page.dart';
import 'package:citas_app/pages/perfil_page.dart';
import 'package:citas_app/providers/api_provider.dart';
import 'package:citas_app/providers/cita_provider.dart';
import 'package:citas_app/providers/doctor_provider.dart';
import 'package:citas_app/providers/especialidad_provider.dart';
import 'package:citas_app/providers/paciente_provider.dart';
import 'package:citas_app/providers/sede_provider.dart';
import 'package:citas_app/pages/sedes_page.dart';
import 'package:citas_app/providers/usuario_provider.dart';
import 'package:citas_app/providers/turno_provider.dart';
import 'package:citas_app/pages/turno_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'pages/login_page.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UsuarioProvider()),
        ChangeNotifierProvider(create: (_) => EspecialidadProvider()),
        ChangeNotifierProvider(create: (_) => SedeProvider()),
        ChangeNotifierProvider(create: (_) => TurnoProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
        ChangeNotifierProvider(create: (_) => PacienteProvider()),
        ChangeNotifierProvider(create: (_) => CitaProvider()),
      ],
      child: MaterialApp(
        title: 'Medical App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es'), // Español
          Locale('en'), // Inglés
          // Agrega más si necesitas otros idiomas
        ],

        initialRoute: '/login',
        onGenerateRoute: (settings) {
          if (settings.name == '/crear-turno') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => CrearTurnoPage(
                especialidades: args['especialidades'],
                sedes: args['sedes'],
                doctorId: args['doctorId'],
              ),
            );
          }    // ...otras rutas...
          return null;
        },
        routes: {
          '/login': (context) => const LoginPage(),
          '/dashboard': (context) => const DashboardPage(),
          '/perfil': (context) => const PerfilPage(),
          '/especialidad': (context) => const EspecialidadesPage(),
          '/paciente': (context) => const PacientePage(),
          '/citas': (context) => const MisCitasPage(),
          '/doctores': (context) => const DoctoresPage(),
          '/sedes': (context) => const SedesPage(),

        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}