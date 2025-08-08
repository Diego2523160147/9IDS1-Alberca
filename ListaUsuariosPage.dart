import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:quickalert/quickalert.dart';
import 'package:quickalert/models/quickalert_type.dart';

import '../models/Usuario.dart';
import 'EditarUsuarioPage.dart';

class ListaUsuariosPage extends StatefulWidget {
  const ListaUsuariosPage({super.key});

  @override
  State<ListaUsuariosPage> createState() => _ListaUsuariosPageState();
}

class _ListaUsuariosPageState extends State<ListaUsuariosPage> {
  List<Usuario> usuarios = [];
  bool _isLoading = false;

  String rolSeleccionado = 'clientes';

  final Color verdeSuave = const Color(0xFF4CAF50); // verde que mencionaste

  @override
  void initState() {
    super.initState();
    cargarUsuariosPorRol(rolSeleccionado);
  }

  Future<void> cargarUsuariosPorRol(String rol) async {
    setState(() {
      _isLoading = true;
      rolSeleccionado = rol;
    });
    try {
      final res = await http.get(Uri.parse('http://127.0.0.1:8001/api/$rol'));

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          usuarios = data.map((json) => Usuario.fromJson(json)).toList();
        });
      } else {
        final errorData = jsonDecode(res.body);
        String errorMessage = errorData['message'] ?? errorData['error'] ?? 'Error al cargar usuarios.';
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error de Carga',
          text: 'Error ${res.statusCode}: $errorMessage',
        );
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error de Conexión',
        text: 'No se pudo conectar al servidor para cargar usuarios. Detalles: $e',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> eliminarUsuario(int id) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: "¿Estás seguro?",
      text: "Esta acción eliminará el usuario de forma permanente.",
      confirmBtnText: "Sí, eliminar",
      cancelBtnText: "Cancelar",
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () async {
        Navigator.pop(context);
        setState(() {
          _isLoading = true;
        });
        try {
          final res = await http.delete(Uri.parse('http://127.0.0.1:8001/api/clientes/$id'));

          if (res.statusCode == 200) {
            final responseData = jsonDecode(res.body);
            String successMessage = responseData['message'] ?? 'Usuario eliminado con éxito.';
            await QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              title: '¡Éxito!',
              text: successMessage,
            );
            cargarUsuariosPorRol(rolSeleccionado);
          } else {
            final errorData = jsonDecode(res.body);
            String errorMessage = errorData['message'] ?? errorData['error'] ?? 'Hubo un error al eliminar el usuario.';
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'Error',
              text: 'Error ${res.statusCode}: $errorMessage',
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
          'Lista de Usuarios',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white, // ✅ Fondo blanco
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => cargarUsuariosPorRol('clientes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rolSeleccionado == 'clientes' ? Colors.teal : Colors.grey,
                  ),
                  child: const Text('Clientes'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => cargarUsuariosPorRol('profesores'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rolSeleccionado == 'profesores' ? Colors.teal : Colors.grey,
                  ),
                  child: const Text('Profesores'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => cargarUsuariosPorRol('administradores'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rolSeleccionado == 'administradores' ? Colors.teal : Colors.grey,
                  ),
                  child: const Text('Administradores'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: Colors.teal),
              )
                  : usuarios.isEmpty
                  ? const Center(
                child: Text(
                  'No hay usuarios registrados.',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                itemCount: usuarios.length,
                itemBuilder: (context, index) {
                  final u = usuarios[index];
                  return Card(
                    color: verdeSuave.withOpacity(0.2),
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      leading: CircleAvatar(
                        backgroundColor: verdeSuave,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        u.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        '${u.email}\nRol: ${u.rol}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.teal),
                            onPressed: () async {
                              final bool? edited = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditarUsuarioPage(usuario: u),
                                ),
                              );
                              if (edited == true) {
                                cargarUsuariosPorRol(rolSeleccionado);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => eliminarUsuario(u.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
