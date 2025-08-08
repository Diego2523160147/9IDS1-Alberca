import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:alberca_9ids1/models/Membresia.dart';
import 'package:alberca_9ids1/EditarMembresiaPage.dart';
import 'package:alberca_9ids1/NuevoMembresiaPage.dart';

class MembresiasListaPage extends StatefulWidget {
  const MembresiasListaPage({super.key});

  @override
  State<MembresiasListaPage> createState() => _MembresiasListaPageState();
}

class _MembresiasListaPageState extends State<MembresiasListaPage> {
  List<Membresia> _membresias = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMembresias();
  }

  Future<void> _fetchMembresias() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/membresias'));

      if (response.statusCode == 200) {
        List<dynamic> membresiasJson = jsonDecode(response.body);
        setState(() {
          _membresias = membresiasJson
              .map((json) => Membresia.fromJson(json as Map<String, dynamic>))
              .toList();
        });
      } else {
        setState(() {
          _errorMessage = 'Error al cargar las membresías: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudo conectar al servidor. Verifica tu conexión. Detalles: $e';
      });
      print('Error fetching memberships: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _eliminarMembresia(int id) async {
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: '¿Eliminar Membresía?',
      text: '¿Estás seguro de que deseas eliminar esta membresía?',
      confirmBtnText: 'Sí',
      cancelBtnText: 'Cancelar',
      showCancelBtn: true,
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () async {
        Navigator.of(context, rootNavigator: true).pop(); // cerrar el diálogo manualmente
        setState(() {
          _isLoading = true;
        });

        try {
          final response = await http.post(
            Uri.parse('http://127.0.0.1:8001/api/membresias/eliminar'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({'id': id}),
          );

          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);
            String successMessage = responseData['message'] ?? 'Membresía eliminada con éxito.';

            await QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              title: '¡Éxito!',
              text: successMessage,
            );
            _fetchMembresias();
          } else {
            final errorData = jsonDecode(response.body);
            String errorMessage = errorData['message'] ?? errorData['error'] ?? 'Hubo un error al eliminar la membresía.';
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
            text: 'No se pudo conectar al servidor para eliminar. Detalles: $e',
          );
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Listado de Membresías',
          style: TextStyle(color: Colors.white),
        ),
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
            : _errorMessage != null
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 5.0, color: Colors.black)],
              ),
            ),
          ),
        )
            : _membresias.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 80, color: Colors.white70),
              const SizedBox(height: 20),
              const Text(
                'No hay membresías registradas aún.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  shadows: [Shadow(blurRadius: 5.0, color: Colors.black)],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchMembresias,
                icon: const Icon(Icons.refresh),
                label: const Text('Recargar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        )
            : RefreshIndicator(
          onRefresh: _fetchMembresias,
          color: Colors.indigo,
          backgroundColor: Colors.white,
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _membresias.length,
            itemBuilder: (context, index) {
              final membresia = _membresias[index];
              return Card(
                elevation: 8,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.white.withOpacity(0.95),
                child: InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditarMembresiaPage(membresia: membresia),
                      ),
                    );
                    if (result == true) {
                      _fetchMembresias();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          membresia.nombre,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // MOSTRANDO EL NOMBRE DEL USUARIO
                        Text(
                          'Usuario: ${membresia.nombreUsuario ?? 'N/A'}', // Muestra el nombre del usuario
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.deepPurple[700], // Un color diferente para destacarlo
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8), // Espacio después del usuario
                        Text('Tipo: ${membresia.tipo}',
                            style: TextStyle(fontSize: 16, color: Colors.blueGrey[700])),
                        const SizedBox(height: 4),
                        Text(
                          'Precio: \$${membresia.precio.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Duración: ${membresia.duracionDias} días',
                            style: TextStyle(fontSize: 16, color: Colors.blueGrey[700])),
                        const SizedBox(height: 8),
                        Text('Clases Incluidas: ${membresia.clasesIncluidas.toString()}',
                            style: const TextStyle(fontSize: 16, color: Colors.black87)),
                        if (membresia.descripcion != null && membresia.descripcion!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text('Descripción: ${membresia.descripcion}',
                                style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                          ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Eliminar Membresía',
                                onPressed: () {
                                  _eliminarMembresia(membresia.id);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                tooltip: 'Editar Membresía',
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditarMembresiaPage(membresia: membresia),
                                    ),
                                  );
                                  if (result == true) {
                                    _fetchMembresias();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NuevoMembresiaPage()),
          );
          if (result == true) {
            _fetchMembresias();
          }
        },
        label: const Text('Agregar Membresía'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}