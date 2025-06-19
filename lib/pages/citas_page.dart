import 'package:citas_app/models/TurnoResponse.dart';
import 'package:citas_app/models/cita.dart';
import 'package:citas_app/models/doctor.dart';
import 'package:citas_app/models/sede.dart';
import 'package:citas_app/models/turno.dart';
import 'package:citas_app/providers/cita_provider.dart';
import 'package:citas_app/providers/doctor_provider.dart';
import 'package:citas_app/providers/paciente_provider.dart';
import 'package:citas_app/providers/sede_provider.dart';
import 'package:citas_app/providers/turno_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CrearCitaPage extends StatefulWidget {
  const CrearCitaPage({super.key});

  @override
  State<CrearCitaPage> createState() => _CrearCitaPageState();
}

class _CrearCitaPageState extends State<CrearCitaPage> {
  final _formKey = GlobalKey<FormState>();
  late String pacienteId;
  String? doctorId;
  String? sedeId;
  DateTime? fechaSeleccionada;
  DateTime? slotSeleccionado;

  List<TurnoResponse> turnosDisponibles = [];
  List<DateTime> diasDisponibles = [];
  List<DateTime> slotsDisponibles = [];

  bool cargandoTurnos = true; // Inicializado como true
  bool pacienteIdCargado = false; // Nueva variable para controlar la carga del paciente

  @override
  void initState() {
    super.initState();
    _inicializarDatos();
  }

  Future<void> _inicializarDatos() async {
    print('Iniciando inicialización de datos...');
    
    try {
      // Cargar paciente ID primero
      print('Cargando paciente ID...');
      await _loadPacienteId();
      print('Paciente ID cargado: $pacienteId');
      
      // Luego cargar turnos
      print('Cargando turnos...');
      await _cargarTurnos();
      print('Turnos cargados exitosamente');
      
    } catch (e) {
      print('Error al inicializar datos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    } finally {
      print('Finalizando carga, estableciendo cargandoTurnos = false');
      if (mounted) {
        setState(() {
          cargandoTurnos = false;
        });
      }
    }
  }

  Future<void> _cargarTurnos() async {
    if (!mounted) return;
    
    print('Iniciando carga de turnos...');
    
    try {
      final turnoProvider = Provider.of<TurnoProvider>(context, listen: false);
      
      print('Provider obtenido, llamando fetchTodosLosTurnos...');
      await turnoProvider.fetchTodosLosTurnos(context);
      
      print('Fetch completado, turnos en provider: ${turnoProvider.todosLosTurnos.length}');
      
      if (mounted) {
        setState(() {
          turnosDisponibles = turnoProvider.todosLosTurnos;
        });
        print('Total de turnos cargados en estado local: ${turnosDisponibles.length}');
        
        // Debug adicional - mostrar algunos turnos si existen
        if (turnosDisponibles.isNotEmpty) {
          print('Primer turno: Doctor ID: ${turnosDisponibles.first.doctorId}, Doctor: ${turnosDisponibles.first.doctorNombres} ${turnosDisponibles.first.doctorApellidos}');
        } else {
          print('ADVERTENCIA: turnosDisponibles está vacío después de la asignación');
        }
      }
    } catch (e, stackTrace) {
      print('Error al cargar turnos: $e');
      print('Stack trace: $stackTrace');
      rethrow; // Re-lanzar el error para que lo maneje _inicializarDatos
    }
  }

  Future<void> _loadPacienteId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId != null && userId.isNotEmpty) {
      if (mounted) {
        setState(() {
          pacienteId = userId;
          pacienteIdCargado = true;
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No se encontró el usuario autenticado')),
        );
      }
    }
  }

  void _cargarDiasDisponibles() {
    final dias = turnosDisponibles
        .where((turno) => turno.doctorId == doctorId && turno.sedeId == sedeId)
        .expand((turno) => turno.diasDisponibles)
        .where((dia) => dia.slots.any((slot) => !slot.ocupado))
        .map((dia) => dia.fecha)
        .toSet()
        .toList();

    setState(() {
      diasDisponibles = dias;
      fechaSeleccionada = null;
      slotSeleccionado = null;
      slotsDisponibles = [];
    });
  }

  void _cargarSlotsDisponibles(DateTime fechaSeleccionada) {
    final slots = turnosDisponibles
        .where((turno) => turno.doctorId == doctorId && turno.sedeId == sedeId)
        .expand((turno) => turno.diasDisponibles)
        .where((dia) => dia.fecha.toLocal().toString().split(' ')[0] == fechaSeleccionada.toLocal().toString().split(' ')[0])
        .expand((dia) => dia.slots.where((slot) => !slot.ocupado))
        .map((slot) => slot.fechaHoraCompleta)
        .toList();

    setState(() {
      slotsDisponibles = slots;
      slotSeleccionado = null;
    });
  }

  void _crearCita() async {
    if (_formKey.currentState!.validate() && slotSeleccionado != null && doctorId != null && sedeId != null) {
      final citaProvider = Provider.of<CitaProvider>(context, listen: false);

      final turnoSeleccionado = turnosDisponibles.firstWhere(
        (turno) => turno.doctorId == doctorId && turno.sedeId == sedeId,
        orElse: () => turnosDisponibles.first,
      );

      final cita = Cita(
        pacienteId: pacienteId,
        doctorId: doctorId!,
        doctorNombres: turnoSeleccionado.doctorNombres,
        doctorApellidos: turnoSeleccionado.doctorApellidos,
        sedeId: sedeId!,
        fechaHora: slotSeleccionado!,
        turnoId: turnoSeleccionado.id,
        estado: 'PENDIENTE',
        observaciones: '',
      );

      try {
        await citaProvider.crearCita(cita, context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cita creada exitosamente'))
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear cita: $e'))
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete todos los campos'))
      );
    }
  }

  // Función para obtener doctores únicos
  List<DropdownMenuItem<String>> _getDoctorItems() {
    final doctoresUnicos = <String, TurnoResponse>{};
    
    for (final turno in turnosDisponibles) {
      if (!doctoresUnicos.containsKey(turno.doctorId)) {
        doctoresUnicos[turno.doctorId] = turno;
      }
    }
    
    return doctoresUnicos.values.map((turno) => DropdownMenuItem(
      value: turno.doctorId,
      child: Text('${turno.doctorNombres} ${turno.doctorApellidos} - ${turno.especialidadNombre}'),
    )).toList();
  }

  // Función para obtener sedes únicas para el doctor seleccionado
  List<DropdownMenuItem<String>> _getSedeItems() {
    final sedesUnicas = <String, TurnoResponse>{};
    
    for (final turno in turnosDisponibles.where((t) => t.doctorId == doctorId)) {
      if (!sedesUnicas.containsKey(turno.sedeId)) {
        sedesUnicas[turno.sedeId] = turno;
      }
    }
    
    return sedesUnicas.values.map((turno) => DropdownMenuItem(
      value: turno.sedeId,
      child: Text(turno.sedeNombre),
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cita')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: cargandoTurnos || !pacienteIdCargado
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando información...'),
                  ],
                ),
              )
            : turnosDisponibles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No hay turnos disponibles en este momento'),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              cargandoTurnos = true;
                            });
                            _cargarTurnos().then((_) {
                              if (mounted) {
                                setState(() {
                                  cargandoTurnos = false;
                                });
                              }
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Recargar'),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Debug: Provider tiene ${Provider.of<TurnoProvider>(context, listen: false).todosLosTurnos.length} turnos',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        DropdownButtonFormField<String>(
                          value: doctorId,
                          items: _getDoctorItems(),
                          onChanged: (v) {
                            setState(() {
                              doctorId = v;
                              sedeId = null;
                              fechaSeleccionada = null;
                              slotSeleccionado = null;
                              diasDisponibles = [];
                              slotsDisponibles = [];
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Seleccione Doctor',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null ? 'Seleccione un doctor' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        DropdownButtonFormField<String>(
                          value: sedeId,
                          items: doctorId != null ? _getSedeItems() : [],
                          onChanged: doctorId != null ? (v) {
                            setState(() {
                              sedeId = v;
                              fechaSeleccionada = null;
                              slotSeleccionado = null;
                            });
                            if (v != null) {
                              _cargarDiasDisponibles();
                            }
                          } : null,
                          decoration: const InputDecoration(
                            labelText: 'Seleccione Sede',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null ? 'Seleccione una sede' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        diasDisponibles.isEmpty && doctorId != null && sedeId != null
                            ? const Card(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'No hay fechas disponibles para esta combinación',
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                ),
                              )
                            : diasDisponibles.isNotEmpty
                                ? DropdownButtonFormField<DateTime>(
                                    value: fechaSeleccionada,
                                    items: diasDisponibles.map((fecha) => DropdownMenuItem(
                                      value: fecha,
                                      child: Text('${fecha.day}/${fecha.month}/${fecha.year}'),
                                    )).toList(),
                                    onChanged: (v) {
                                      setState(() => fechaSeleccionada = v);
                                      if (v != null) {
                                        _cargarSlotsDisponibles(v);
                                      }
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Seleccione Fecha',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (v) => v == null ? 'Seleccione una fecha' : null,
                                  )
                                : const Card(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text('Seleccione un doctor y una sede para ver disponibilidad'),
                                    ),
                                  ),
                        const SizedBox(height: 16),
                        
                        slotsDisponibles.isEmpty && fechaSeleccionada != null
                            ? const Card(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'No hay horarios disponibles para esta fecha',
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                ),
                              )
                            : slotsDisponibles.isNotEmpty
                                ? DropdownButtonFormField<DateTime>(
                                    value: slotSeleccionado,
                                    items: slotsDisponibles.map((slot) => DropdownMenuItem(
                                      value: slot,
                                      child: Text('${slot.hour}:${slot.minute.toString().padLeft(2, '0')}'),
                                    )).toList(),
                                    onChanged: (v) => setState(() => slotSeleccionado = v),
                                    decoration: const InputDecoration(
                                      labelText: 'Seleccione Horario',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (v) => v == null ? 'Seleccione un horario' : null,
                                  )
                                : fechaSeleccionada != null
                                    ? const Card(
                                        child: Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Text('Seleccione una fecha para ver horarios'),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                        
                        const SizedBox(height: 24),
                        
                        ElevatedButton.icon(
                          onPressed: _crearCita,
                          icon: const Icon(Icons.save),
                          label: const Text('Crear Cita'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}