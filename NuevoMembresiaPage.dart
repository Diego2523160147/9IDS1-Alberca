// lib/NuevoMembresiaPage.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:alberca_9ids1/models/Membresia.dart';
import 'package:alberca_9ids1/models/Usuario.dart';

class NuevoMembresiaPage extends StatefulWidget {
  const NuevoMembresiaPage({super.key});

  @override
  State<NuevoMembresiaPage> createState() => _NuevoMembresiaPageState();
}

class _NuevoMembresiaPageState extends State<NuevoMembresiaPage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _duracionDiasController = TextEditingController();
  final TextEditingController _clasesIncluidasController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  // Nuevas variables para la selección de usuario
  List<Usuario> _usuarios = []; // Lista de usuarios disponibles
  Usuario? _usuarioSeleccionado; // Usuario seleccionado en el Dropdown

  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchUsuarios(); // Cargar usuarios al iniciar la página
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _tipoController.dispose();
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
    });
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/clientes'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _usuarios = data.map((json) => Usuario.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al cargar usuarios: $e');
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'No se pudieron cargar los usuarios. Detalles: $e',
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _guardarMembresia() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_usuarioSeleccionado == null) {
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
      final Membresia nuevaMembresia = Membresia(
        id: 0, // El ID será generado por la API
        nombre: _nombreController.text,
        tipo: _tipoController.text,
        precio: double.parse(_precioController.text),
        duracionDias: int.parse(_duracionDiasController.text),
        clasesIncluidas: int.parse(_clasesIncluidasController.text),
        idUsuario: _usuarioSeleccionado!.id, // Usar el ID del usuario seleccionado
        nombreUsuario: _usuarioSeleccionado!.name, // Usar el nombre del usuario seleccionado (opcional, solo para el modelo local)
        descripcion: _descripcionController.text.isEmpty ? null : _descripcionController.text,
      );

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8001/api/membresias/nuevo'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(nuevaMembresia.toJson()),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        String successMessage = responseData['message'] ?? 'Membresía guardada con éxito.';

        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: '¡Éxito!',
          text: successMessage,
        );
        Navigator.pop(context, true);

      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = errorData['message'] ?? errorData['error'] ?? 'Hubo un error al guardar la membresía.';

        if (errorData['errors'] != null && errorData['errors'] is Map) {
          Map<String, dynamic> validationErrors = errorData['errors'];
          validationErrors.forEach((field, errors) {
            errorMessage += "\n${_getFieldName(field)}: ${(errors as List).join(', ')}"; // Usa _getFieldName
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
      print('Error al guardar membresía: $e');
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

  // Helper para traducir nombres de campos de API a nombres más amigables (para errores de validación)
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
          'Nueva Membresía',
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
          child: _isLoading && _usuarios.isEmpty // Muestra un spinner mientras carga usuarios
              ? const CircularProgressIndicator(color: Colors.white)
              : SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Registrar Nueva Membresía',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black38,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  // Dropdown para seleccionar Usuario
                  _buildDropdownField<Usuario>(
                    value: _usuarioSeleccionado,
                    hintText: 'Selecciona un usuario',
                    labelText: 'Usuario',
                    icon: Icons.person_add,
                    items: _usuarios.map((user) {
                      return DropdownMenuItem<Usuario>(
                        value: user,
                        child: Text('${user.name}'),
                      );
                    }).toList(),
                    onChanged: (Usuario? newValue) {
                      setState(() {
                        _usuarioSeleccionado = newValue;
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
                    hintText: 'Ej. Membresía Mensual',
                    labelText: 'Nombre de Membresía',
                    icon: Icons.card_membership,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor ingresa el nombre';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Dropdown para Tipo de Membresía
                  _buildDropdownField<String>(
                    value: _tipoController.text.isEmpty ? null : _tipoController.text,
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
                        _tipoController.text = newValue ?? '';
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
                    hintText: 'Ej. 500.00',
                    labelText: 'Precio',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor ingresa el precio';
                      if (double.tryParse(value) == null) return 'Ingresa un número válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _duracionDiasController,
                    hintText: 'Ej. 30',
                    labelText: 'Duración en Días',
                    icon: Icons.calendar_today,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor ingresa la duración';
                      if (int.tryParse(value) == null) return 'Ingresa un número entero válido';
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
                      if (value == null || value.isEmpty) return 'Por favor ingresa el número de clases';
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
                    onPressed: _guardarMembresia,
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
                      'Guardar Membresía',
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