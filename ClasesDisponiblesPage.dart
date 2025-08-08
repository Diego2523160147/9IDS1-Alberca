import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:quickalert/quickalert.dart'; // Importa QuickAlert
import 'package:quickalert/models/quickalert_type.dart';

class ClasesDisponiblesPage extends StatefulWidget {
  final int clienteId;

  const ClasesDisponiblesPage({super.key, required this.clienteId});

  @override
  State<ClasesDisponiblesPage> createState() => _ClasesDisponiblesPageState();
}

class _ClasesDisponiblesPageState extends State<ClasesDisponiblesPage> {
  late Future<List<dynamic>> _clasesFuture;
  bool _isFetchingClases = false; // Añadimos un estado de carga para la obtención de clases

  @override
  void initState() {
    super.initState();
    _clasesFuture = _fetchClases();
  }

  Future<List<dynamic>> _fetchClases() async {
    setState(() {
      _isFetchingClases = true; // Establece el estado de carga a true antes de obtener los datos
    });
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/verClases'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar las clases: ${response.statusCode}');
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error de Conexión',
        text: 'No se pudo conectar al servidor para cargar las clases. Detalles: $e',
      );
      throw Exception('Error de conexión: $e'); // Se vuelve a lanzar para que lo capture FutureBuilder
    } finally {
      setState(() {
        _isFetchingClases = false; // Establece el estado de carga a false después de obtener los datos
      });
    }
  }

  Future<void> _inscribirClase(int claseId) async {
    setState(() {
      _isFetchingClases = true; // Muestra el indicador de carga al inscribirse
    });
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8001/api/clases/asistir/${widget.clienteId}/$claseId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Status code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: '¡Éxito!',
          text: data['message'] ?? 'Inscripción exitosa.',
        );
        setState(() {
          _clasesFuture = _fetchClases(); // Actualiza la lista después de la inscripción
        });
      } else {
        final data = json.decode(response.body);
        String errorMessage = data['error'] ?? data['message'] ?? 'Error al inscribirse a la clase.';
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error de Inscripción',
          text: errorMessage,
        );
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error de Conexión',
        text: 'No se pudo conectar al servidor para inscribirse. Detalles: $e',
      );
    } finally {
      setState(() {
        _isFetchingClases = false; // Oculta el indicador de carga
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clases Disponibles', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.blueGrey],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<List<dynamic>>(
          future: _clasesFuture,
          builder: (context, snapshot) {
            if (_isFetchingClases) { // Usamos nuestro estado de carga personalizado
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Error: ${snapshot.error}. Por favor, inténtalo de nuevo más tarde.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              );
            }
            final clases = snapshot.data ?? [];

            if (clases.isEmpty) {
              return const Center(
                child: Text(
                  'No hay clases disponibles en este momento.',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView.builder(
              itemCount: clases.length,
              itemBuilder: (context, index) {
                final clase = clases[index];
                final nombre = clase['nombre'] ?? 'Clase sin nombre';
                final diaSemana = clase['dia_semana'] ?? 'N/A';
                // Aseguramos que la hora se formatee a HH:MM si incluye segundos
                final horaInicioDisplay = clase['hora_inicio']?.split(':').take(2).join(':') ?? 'N/A';
                final horaFinDisplay = clase['hora_fin']?.split(':').take(2).join(':') ?? 'N/A';
                final lugaresDisponibles = clase['lugares_disponibles'];
                final lugaresOcupados = clase['lugares_ocupados'] ?? 0; // Valor predeterminado a 0 si es nulo
                final profesorNombre = clase['profesor_nombre'] ?? 'Sin asignar'; // Asumiendo que la API devuelve 'profesor_nombre'

                final cuposRestantes = (lugaresDisponibles != null)
                    ? (lugaresDisponibles - lugaresOcupados)
                    : -1; // -1 puede significar ilimitado o no especificado

                final bool isFull = (cuposRestantes != -1 && cuposRestantes <= 0);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    color: Colors.white.withOpacity(0.95),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombre,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Día: $diaSemana | Hora: $horaInicioDisplay - $horaFinDisplay',
                            style: TextStyle(fontSize: 16, color: Colors.blueGrey[700]),
                          ),

                          Text(
                            (cuposRestantes == -1)
                                ? 'Cupos: Ilimitados'
                                : 'Cupos: $cuposRestantes / $lugaresDisponibles',
                            style: TextStyle(
                              fontSize: 16,
                              color: isFull ? Colors.red : Colors.blueGrey[700],
                              fontWeight: isFull ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          const Divider(height: 20, thickness: 1, color: Colors.black12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: isFull ? null : () => _inscribirClase(clase['id']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFull ? Colors.grey : Colors.indigo,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: 5,
                              ),
                              icon: const Icon(Icons.add_task),
                              label: Text(isFull ? 'Cupo Lleno' : 'Inscribirse'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}