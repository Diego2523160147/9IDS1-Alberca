import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:quickalert/quickalert.dart'; // Import QuickAlert

import 'EditarClasePage.dart'; // importa la página de editar clase

class ListaClasesPage extends StatefulWidget {
  const ListaClasesPage({super.key});

  @override
  State<ListaClasesPage> createState() => _ListaClasesPageState();
}

class _ListaClasesPageState extends State<ListaClasesPage> {
  List clases = [];
  bool _isLoading = false; // Add loading state

  @override
  void initState() {
    super.initState();
    cargarClases();
  }

  Future<void> cargarClases() async {
    setState(() {
      _isLoading = true; // Set loading to true
    });
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/verClases'));
      if (response.statusCode == 200) {
        setState(() {
          clases = json.decode(response.body);
        });
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Error al cargar clases: ${response.statusCode}',
        );
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error de Conexión',
        text: 'No se pudo conectar al servidor para cargar clases. Detalles: $e',
      );
    } finally {
      setState(() {
        _isLoading = false; // Set loading to false
      });
    }
  }

  Future<void> eliminarClase(int id) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Confirmar Eliminación',
      text: '¿Estás seguro de que quieres eliminar esta clase?',
      confirmBtnText: 'Sí',
      cancelBtnText: 'No',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () async {
        Navigator.pop(context); // Close the confirmation alert
        setState(() {
          _isLoading = true; // Show loading
        });
        try {
          final response = await http.delete(Uri.parse('http://127.0.0.1:8001/api/clases/$id'));
          if (response.statusCode == 200) {
            await QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              title: '¡Éxito!',
              text: 'Clase eliminada con éxito.',
            );
            cargarClases(); // Reload classes after successful deletion
          } else {
            final errorData = jsonDecode(response.body);
            String errorMessage = errorData['message'] ?? errorData['error'] ?? 'Hubo un error al eliminar la clase.';
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'Error',
              text: 'Error ${response.statusCode}: $errorMessage',
            );
          }
        } catch (e) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Error de Conexión',
            text: 'No se pudo conectar al servidor para eliminar la clase. Detalles: $e',
          );
        } finally {
          setState(() {
            _isLoading = false; // Hide loading
          });
        }
      },
      onCancelBtnTap: () {
        Navigator.pop(context); // Close the confirmation alert
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Clases', style: TextStyle(color: Colors.white)),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : clases.isEmpty
            ? const Center(
          child: Text(
            'No hay clases registradas aún.',
            style: TextStyle(fontSize: 18, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        )
            : ListView.builder(
          itemCount: clases.length,
          itemBuilder: (context, index) {
            final clase = clases[index];
            // Format time to HH:MM if it includes seconds
            String horaInicioDisplay = clase['hora_inicio']?.split(':').take(2).join(':') ?? '';
            String horaFinDisplay = clase['hora_fin']?.split(':').take(2).join(':') ?? '';

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
                        clase['nombre'] ?? 'Nombre no disponible',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Día: ${clase['dia_semana'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey[700]),
                      ),
                      Text(
                        'Hora: $horaInicioDisplay - $horaFinDisplay',
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey[700]),
                      ),
                      Text(
                        'Lugares: ${clase['lugares_ocupados'] ?? 0}/${clase['lugares_disponibles'] ?? 0}',
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey[700]),
                      ),
                      if (clase['profesor_nombre'] != null) // Display professor if available
                        Text(
                          'Profesor: ${clase['profesor_nombre']}',
                          style: TextStyle(fontSize: 16, color: Colors.blueGrey[700]),
                        ),
                      const Divider(height: 20, thickness: 1, color: Colors.black12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.indigo[600], size: 28),
                            tooltip: 'Editar Clase',
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditarClasePage(clase: clase),
                                ),
                              );
                              if (result == true) {
                                cargarClases(); // Reload classes if edited successfully
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red[600], size: 28),
                            tooltip: 'Eliminar Clase',
                            onPressed: () => eliminarClase(clase['id']),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}