import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:quickalert/quickalert.dart'; // Importa QuickAlert
import 'package:quickalert/models/quickalert_type.dart'; // Importa QuickAlertType
import '../models/Membresia.dart'; // Asegúrate de que esta ruta sea correcta

class MembresiasClientePage extends StatefulWidget {
  final int usuarioId;

  const MembresiasClientePage({super.key, required this.usuarioId});

  @override
  State<MembresiasClientePage> createState() => _MembresiasClientePageState();
}

class _MembresiasClientePageState extends State<MembresiasClientePage> {
  late Future<List<Membresia>> _membresiasFuture;
  bool _isLoading = false; // Estado para el indicador de carga

  // Colores consistentes con ClientePage
  static const Color azulBoton = Color(0xFF0077B6); // azul profundo
  static const Color azulTexto = Color(0xFF023E8A); // azul oscuro
  static const Color fondoClaro = Color(0xFFE6F0FA); // azul cielo claro

  @override
  void initState() {
    super.initState();
    _membresiasFuture = _fetchMembresias();
  }

  Future<List<Membresia>> _fetchMembresias() async {
    setState(() {
      _isLoading = true; // Activa el indicador de carga
    });
    try {
      final url = Uri.parse('http://127.0.0.1:8001/api/membresias/usuario?usuario_id=${widget.usuarioId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Membresia.fromJson(json)).toList();
      } else {
        // Manejo de errores más detallado
        String errorMessage = 'Error al cargar las membresías';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (_) {
          // Si el cuerpo de la respuesta no es JSON válido
        }
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: '$errorMessage (Código: ${response.statusCode})',
        );
        throw Exception(errorMessage); // Re-lanzar para que FutureBuilder lo maneje
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error de Conexión',
        text: 'No se pudo conectar al servidor para obtener las membresías. Detalles: $e',
      );
      throw Exception('Error de conexión: $e'); // Re-lanzar
    } finally {
      setState(() {
        _isLoading = false; // Desactiva el indicador de carga
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Membresías', style: TextStyle(color: Colors.white)),
        backgroundColor: azulBoton,
        foregroundColor: Colors.white,
        elevation: 0, // Sin sombra para un look moderno
      ),
      body: Container(
        // Fondo degradado o color sólido consistente con ClientePage
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.blueGrey], // Usando el degradado de las otras páginas de admin
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<List<Membresia>>(
          future: _membresiasFuture,
          builder: (context, snapshot) {
            if (_isLoading) { // Usamos el estado de carga que creamos
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Error al cargar las membresías: ${snapshot.error}. Por favor, inténtalo de nuevo.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              );
            }
            final membresias = snapshot.data ?? [];

            if (membresias.isEmpty) {
              return const Center(
                child: Text(
                  'No tienes membresías activas en este momento.',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: membresias.length,
              itemBuilder: (context, index) {
                final memb = membresias[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    color: Colors.white.withOpacity(0.95), // Tarjetas ligeramente transparentes
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            memb.tipo,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: azulTexto, // Usar el color de texto de ClientePage
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Clases incluidas: ${memb.clasesIncluidas}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blueGrey[700], // Color de texto similar
                            ),
                          ),
                          if (memb.descripcion != null && memb.descripcion!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                memb.descripcion!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.blueGrey[500],
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          // Aquí puedes añadir más detalles si la API los proporciona, por ejemplo, fecha de inicio/fin
                          // Ejemplo:
                          // Text(
                          //   'Activa hasta: ${memb.fechaFin?.toLocal().toString().split(' ')[0] ?? 'N/A'}',
                          //   style: TextStyle(fontSize: 14, color: Colors.blueGrey[600]),
                          // ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Tooltip(
                              message: memb.descripcion ?? 'Sin descripción',
                              child: Icon(Icons.info_outline, color: azulBoton),
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