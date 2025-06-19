import 'package:citas_app/models/especialidad.dart';
import 'package:citas_app/models/sede.dart';
import 'package:citas_app/providers/turno_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CrearTurnoPage extends StatefulWidget {
  final String doctorId;
  final List<Especialidad> especialidades;
  final List<Sede> sedes;

  const CrearTurnoPage({
    super.key,
    required this.doctorId,
    required this.especialidades,
    required this.sedes,
  });

  @override
  State<CrearTurnoPage> createState() => _CrearTurnoPageState();
}

class _CrearTurnoPageState extends State<CrearTurnoPage> {
  String? _especialidadId;
  String? _sedeId;
  DateTime? _fecha;
  String? _diaSemana;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFin;

  final diasSemana = [
    'LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO', 'DOMINGO'
  ];

  final _formKey = GlobalKey<FormState>();

  Future<void> _seleccionarHoraInicio() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) setState(() => _horaInicio = picked);
  }

  Future<void> _seleccionarHoraFin() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _horaFin = picked);
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'), // <-- Esto lo muestra en español

    );
    if (picked != null) setState(() => _fecha = picked);
  }

  void _crearTurno() async {
    if (_formKey.currentState!.validate()) {
      final turno = {
        "especialidadId": _especialidadId,
        "sedeId": _sedeId,
        "doctorId": widget.doctorId,
        "diasDisponibles": [
          {
            "fecha": _fecha?.toIso8601String().split('T').first,
            "dia": diasSemana[_fecha!.weekday - 1], // Calculado automáticamente
            "horaInicio": '${_horaInicio!.hour.toString().padLeft(2, '0')}:${_horaInicio!.minute.toString().padLeft(2, '0')}:00',
            "horaFin": '${_horaFin!.hour.toString().padLeft(2, '0')}:${_horaFin!.minute.toString().padLeft(2, '0')}:00',
            "slots": []
          }
        ]
      };

      final turnoProvider = Provider.of<TurnoProvider>(context, listen: false);
      await turnoProvider.crearTurno(turno,context);

      if (turnoProvider.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Turno creado exitosamente')),
        );
        Navigator.pop(context,true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear turno: ${turnoProvider.error}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final turnoProvider = Provider.of<TurnoProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Turno')),
      body: turnoProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _especialidadId,
                      items: widget.especialidades
                          .map((e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.nombre),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _especialidadId = v),
                      decoration: const InputDecoration(labelText: 'Especialidad'),
                      validator: (v) => v == null ? 'Seleccione una especialidad' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _sedeId,
                      items: widget.sedes
                          .map((s) => DropdownMenuItem(
                                value: s.id,
                                child: Text(s.nombre),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _sedeId = v),
                      decoration: const InputDecoration(labelText: 'Sede'),
                      validator: (v) => v == null ? 'Seleccione una sede' : null,
                    ),
                   /* const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _diaSemana,
                      items: diasSemana
                          .map((d) => DropdownMenuItem(
                                value: d,
                                child: Text(d),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _diaSemana = v),
                      decoration: const InputDecoration(labelText: 'Día de la semana'),
                      validator: (v) => v == null ? 'Seleccione un día' : null,
                    ),*/
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(_fecha == null
                          ? 'Seleccione una fecha'
                          : 'Fecha: ${_fecha!.toLocal().toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _seleccionarFecha,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text(_horaInicio == null
                                ? 'Hora inicio'
                                : 'Inicio: ${_horaInicio!.format(context)}'),
                            trailing: const Icon(Icons.access_time),
                            onTap: _seleccionarHoraInicio,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ListTile(
                            title: Text(_horaFin == null
                                ? 'Hora fin'
                                : 'Fin: ${_horaFin!.format(context)}'),
                            trailing: const Icon(Icons.access_time),
                            onTap: _seleccionarHoraFin,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Crear Turno'),
                      onPressed: turnoProvider.isLoading ? null : _crearTurno,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 7, 6, 7),
                        foregroundColor: Colors.white, 
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}