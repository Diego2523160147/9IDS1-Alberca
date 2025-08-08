// lib/EditarMembresiaPage.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:alberca_9ids1/models/Membresia.dart';
import 'package:alberca_9ids1/models/Usuario.dart';

class EditarMembresiaPage extends StatefulWidget {
  final Membresia membresia;

  const EditarMembresiaPage({super.key, required this.membresia});

  @override
  State<EditarMembresiaPage> createState() => _EditarMembresiaPageState();
}

class _EditarMembresiaPageState extends State<EditarMembresiaPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late TextEditingController _duracionDiasController;
  late TextEditingController _clasesIncluidasController;
  late TextEditingController _descripcionController;

  String? _selectedTipo; // Variable para el tipo de membresía seleccionada
  List<Usuario> _usuarios = []; // Lista de usuarios disponibles
  Usuario? _selectedUsuario; // Usuario seleccionado en el Dropdown

  bool _isLoading = false;
  String? _fetchError; // Para errores al cargar usuarios

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.membresia.nombre);
    _selectedTipo = widget.membresia.tipo;
    _precioController = TextEditingController(text: widget.membresia.precio.toString());
    _duracionDiasController = TextEditingController(text: widget.membresia.duracionDias.toString());
    _clasesIncluidasController = TextEditingController(text: widget.membresia.clasesIncluidas.toString());
    _descripcionController = TextEditingController(text: widget.membresia.descripcion ?? '');

    _fetchUsuarios(); // Cargar usuarios al iniciar la página
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _duracionDiasController.dispose();
    _clasesIncluidasController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  // Método para obtener la lista de usuarios desde la API
  Future<void> _fetchUsuarios() async {
    setState(() {
      _isLoading = true;
      _fetchError = null;
    });
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/clientes')); // Endpoint de tu ClienteController@index
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _usuarios = data.map((json) => Usuario.fromJson(json)).toList();

          // Encontrar y seleccionar el usuario actual de la membresía
          if (widget.membresia.idUsuario != 0) { // Check if idUsuario is valid
            _selectedUsuario = _usuarios.firstWhere(
                  (user) => user.id == widget.membresia.idUsuario,
              orElse: () => _usuarios.first, // Fallback to first user if not found, or handle null
            );
          } else if (_usuarios.isNotEmpty) {
            _selectedUsuario = _usuarios.first; // If no user assigned, default to first available
          }
        });
      } else {
        _fetchError = 'Failed to load users: ${response.statusCode}';
        throw Exception(_fetchError);
      }
    } catch (e) {
      print('Error al cargar usuarios para edición: $e');
      setState(() {
        _fetchError = 'No se pudieron cargar los usuarios. Detalles: $e';
      });
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'No se pudieron cargar los usuarios para editar. Detalles: $e',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTipo == null || _selectedTipo!.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Advertencia',
        text: 'Por favor, selecciona un tipo de membresía.',
      );
      return;
    }

    if (_selectedUsuario == null) { // Nueva validación para el usuario
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Advertencia',
        text: 'Por favor, selecciona un usuario para la membresía.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Membresia membresiaActualizada = Membresia(
        id: widget.membresia.id,
        nombre: _nombreController.text,
        tipo: _selectedTipo!,
        precio: double.parse(_precioController.text),
        duracionDias: int.parse(_duracionDiasController.text),
        clasesIncluidas: int.parse(_clasesIncluidasController.text),
        idUsuario: _selectedUsuario!.id, // ¡AQUÍ SE USA EL NUEVO ID DEL USUARIO SELECCIONADO!
        nombreUsuario: _selectedUsuario!.name, // Se actualiza también el nombre (para consistencia local)
        descripcion: _descripcionController.text.isEmpty ? null : _descripcionController.text,
      );

      final response = await http.put(
        Uri.parse('http://127.0.0.1:8001/api/membresias/${membresiaActualizada.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(membresiaActualizada.toJson()),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        String successMessage = responseData['message'] ?? 'Membresía actualizada con éxito.';

        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: '¡Éxito!',
          text: successMessage,
        );
        Navigator.pop(context, true); // Regresar y refrescar la lista
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = errorData['message'] ?? errorData['error'] ?? 'Hubo un error al actualizar la membresía.';

        if (errorData['errors'] != null && errorData['errors'] is Map) {
          Map<String, dynamic> validationErrors = errorData['errors'];
          validationErrors.forEach((field, errors) {
            errorMessage += "\n${_getFieldName(field)}: ${(errors as List).join(', ')}";
          });
        }

        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Error ${response.statusCode}: $errorMessage',
        );
      }
    } catch (e) {
      print('Error al guardar cambios: $e');
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error de Conexión',
        text: 'No se pudo conectar al servidor. Intenta de nuevo. Detalles: $e',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getFieldName(String apiFieldName) {
    switch (apiFieldName) {
      case 'nombre': return 'Nombre de Membresía';
      case 'tipo': return 'Tipo de Membresía';
      case 'precio': return 'Precio';
      case 'duracion_dias': return 'Duración en Días';
      case 'clases_incluidas': return 'Clases Incluidas';
      case 'descripcion': return 'Descripción';
      case 'id_usuario': return 'Usuario';
      default: return apiFieldName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Membresía',
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
        child: Center(
          child: _isLoading && _usuarios.isEmpty && _fetchError == null // Muestra spinner solo si carga y no hay error
              ? const CircularProgressIndicator(color: Colors.white)
              : _fetchError != null
              ? Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                _fetchError!,
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
              : SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Editando: ${widget.membresia.nombre}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(blurRadius: 10.0, color: Colors.black38, offset: Offset(2.0, 2.0)),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  // Dropdown para seleccionar Usuario (AHORA EDITABLE)
                  _buildDropdownField<Usuario>(
                    value: _selectedUsuario,
                    hintText: 'Selecciona un usuario',
                    labelText: 'Usuario Asignado',
                    icon: Icons.person_add,
                    items: _usuarios.map((user) {
                      return DropdownMenuItem<Usuario>(
                        value: user,
                        child: Text('${user.name}'),
                      );
                    }).toList(),
                    onChanged: (Usuario? newValue) {
                      setState(() {
                        _selectedUsuario = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) return 'Por favor selecciona un usuario';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _nombreController,
                    hintText: 'Nombre de Membresía',
                    labelText: 'Nombre',
                    icon: Icons.card_membership,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ingresa el nombre';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Dropdown para Tipo de Membresía
                  _buildDropdownField<String>(
                    value: _selectedTipo,
                    hintText: 'Selecciona un tipo',
                    labelText: 'Tipo de Membresía',
                    icon: Icons.category,
                    items: const [
                      DropdownMenuItem(value: 'mensual', child: Text('Mensual')),
                      DropdownMenuItem(value: 'por_clase', child: Text('Por Clase')),
                      DropdownMenuItem(value: 'trimestral', child: Text('Trimestral')),
                      DropdownMenuItem(value: 'anual', child: Text('Anual')),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTipo = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor selecciona el tipo';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _precioController,
                    hintText: 'Precio',
                    labelText: 'Precio',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ingresa el precio';
                      if (double.tryParse(value) == null) return 'Ingresa un número válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _duracionDiasController,
                    hintText: 'Duración en Días',
                    labelText: 'Días',
                    icon: Icons.calendar_today,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ingresa la duración';
                      if (int.tryParse(value) == null) return 'Ingresa un número entero';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _clasesIncluidasController,
                    hintText: 'Ej. 10 (número de clases)',
                    labelText: 'Clases Incluidas (número)',
                    icon: Icons.fitness_center,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ingresa el número de clases';
                      if (int.tryParse(value) == null) return 'Ingresa un número entero válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _descripcionController,
                    hintText: 'Ej. Membresía premium con acceso ilimitado',
                    labelText: 'Descripción (Opcional)',
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 40),
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : ElevatedButton(
                    onPressed: _guardarCambios,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 10,
                    ),
                    child: const Text(
                      'Guardar Cambios',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(color: Colors.blueGrey[800]),
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          prefixIcon: Icon(icon, color: Colors.indigo),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required T? value,
    required String hintText,
    required String labelText,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? Function(T?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          prefixIcon: Icon(icon, color: Colors.indigo),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        style: TextStyle(color: Colors.blueGrey[800]),
        dropdownColor: Colors.white,
        iconEnabledColor: Colors.indigo,
        items: items,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}