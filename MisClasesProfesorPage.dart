import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class Clase {
  final int? id;
  final String nombre;
  final String diaSemana;
  final String horaInicio;
  final String horaFin;
  final int lugaresOcupados;
  final int lugaresDisponibles;
  final int idUsuario;

  Clase({
    this.id,
    required this.nombre,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.lugaresOcupados,
    required this.lugaresDisponibles,
    required this.idUsuario,
  });

  factory Clase.fromJson(Map<String, dynamic> json) {
    return Clase(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      diaSemana: json['dia_semana'] ?? '',
      horaInicio: json['hora_inicio'] ?? '',
      horaFin: json['hora_fin'] ?? '',
      lugaresOcupados: json['lugares_ocupados'] ?? 0,
      lugaresDisponibles: json['lugares_disponibles'] ?? 0,
      idUsuario: json['id_usuario'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'dia_semana': diaSemana,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'lugares_ocupados': lugaresOcupados,
      'lugares_disponibles': lugaresDisponibles,
      'id_usuario': idUsuario,
    };
  }
}

class MisClasesProfesorPage extends StatefulWidget {
  final int profesorId;

  const MisClasesProfesorPage({super.key, required this.profesorId});

  @override
  State<MisClasesProfesorPage> createState() => _MisClasesProfesorPageState();
}

class _MisClasesProfesorPageState extends State<MisClasesProfesorPage> {
  List<Clase> clases = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchClases();
  }

  Future<void> fetchClases() async {
    try {
      final response = await http.get(
          Uri.parse('http://127.0.0.1:8001/api/clases/profesor/${widget.profesorId}')
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          clases = data.map((e) => Clase.fromJson(e)).toList();
          loading = false;
        });
      } else {
        print('Error al cargar clases. Código: ${response.statusCode}');
        setState(() => loading = false);
      }
    } catch (e) {
      print('Error al cargar clases: $e');
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Clases'),
        backgroundColor: const Color(0xFF0077B6),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : clases.isEmpty
          ? const Center(child: Text('No tienes clases asignadas.'))
          : ListView.builder(
        itemCount: clases.length,
        itemBuilder: (context, index) {
          final clase = clases[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.class_),
              title: Text(clase.nombre),
              subtitle: Text(
                'Día: ${clase.diaSemana}\n'
                    'Horario: ${clase.horaInicio} - ${clase.horaFin}\n'
                    'Ocupados: ${clase.lugaresOcupados}, Disponibles: ${clase.lugaresDisponibles}',
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
