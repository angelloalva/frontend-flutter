import 'package:flutter/material.dart';

class PacientePage extends StatelessWidget {
  const PacientePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paciente')),
      body: const Center(child: Text('Página de Pacientes')),
    );
  }
}