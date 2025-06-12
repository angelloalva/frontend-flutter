// lib/pages/doctores_page.dart
import 'package:flutter/material.dart';

class DoctoresPage extends StatelessWidget {
  const DoctoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctores')),
      body: const Center(child: Text('Página de Doctores')),
    );
  }
}