import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:quickalert/quickalert.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:intl/intl.dart';
import '../models/Usuario.dart';

class EditarUsuarioPage extends StatefulWidget {
  final Usuario usuario;

  const EditarUsuarioPage({super.key, required this.usuario});

  @override
  State<EditarUsuarioPage> createState() => _EditarUsuarioPageState();
}

class _EditarUsuarioPageState extends State<EditarUsuarioPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _curpController;
  late TextEditingController _fechaNacimientoController;

  DateTime? _fechaSeleccionada;
  String? _generoSeleccionado;
  String? _rolSeleccionado;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.usuario.name);
    _emailController = TextEditingController(text: widget.usuario.email);
    _curpController = TextEditingController(text: widget.usuario.curp);
    _fechaSeleccionada = widget.usuario.fechaNacimiento != null && widget.usuario.fechaNacimiento.isNotEmpty
        ? DateTime.tryParse(widget.usuario.fechaNacimiento)
        : null;
    _fechaNacimientoController = TextEditingController(
      text: _fechaSeleccionada != null ? DateFormat('yyyy-MM-dd').format(_fechaSeleccionada!) : '',
    );

    _generoSeleccionado = widget.usuario.genero.isEmpty ? null : widget.usuario.genero;
    _rolSeleccionado = widget.usuario.rol.isEmpty ? null : widget.usuario.rol;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _curpController.dispose();
    _fechaNacimientoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale("es", "ES"),
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
        _fechaNacimientoController.text = DateFormat('yyyy-MM-dd').format(fecha);
      });
    }
  }

  Future<void> actualizarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final res = await http.put(
        Uri.parse('http://127.0.0.1:8001/api/clientes/${widget.usuario.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'email': _emailController.text,
          'curp': _curpController.text.isEmpty ? null : _curpController.text,
          'fecha_nacimiento': _fechaNacimientoController.text.isEmpty ? null : _fechaNacimientoController.text,
          'genero': _generoSeleccionado,
          'rol': _rolSeleccionado,
        }),
      );

      if (res.statusCode == 200) {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: '¡Éxito!',
          text: 'Usuario actualizado correctamente.',
        );
        Navigator.pop(context, true);
      } else {
        final errorData = jsonDecode(res.body);
        String errorMessage = errorData['message'] ?? errorData['error'] ?? 'Error al actualizar.';
        if (errorData['errors'] is Map) {
          (errorData['errors'] as Map).forEach((field, errors) {
            errorMessage += "\n${_getFieldName(field)}: ${(errors as List).join(', ')}";
          });
        }
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Error ${res.statusCode}: $errorMessage',
        );
      }
    } catch (e) {
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error de Conexión',
        text: 'No se pudo conectar al servidor. Detalles: $e',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getFieldName(String apiFieldName) {
    switch (apiFieldName) {
      case 'name': return 'Nombre';
      case 'email': return 'Email';
      case 'curp': return 'CURP';
      case 'fecha_nacimiento': return 'Fecha de Nacimiento';
      case 'genero': return 'Género';
      case 'rol': return 'Rol';
      default: return apiFieldName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Usuario', style: TextStyle(color: Colors.white)),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Modificar Datos del Usuario',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(controller: _nameController, hintText: 'Ej. Juan Pérez', labelText: 'Nombre', icon: Icons.person),
                  const SizedBox(height: 20),
                  _buildTextField(controller: _emailController, hintText: 'correo@example.com', labelText: 'Email', icon: Icons.email, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 20),
                  _buildTextField(controller: _curpController, hintText: 'CURP (opcional)', labelText: 'CURP', icon: Icons.credit_card),
                  const SizedBox(height: 20),

                  // Fecha con DatePicker
                  GestureDetector(
                    onTap: _seleccionarFecha,
                    child: AbsorbPointer(
                      child: _buildTextField(
                        controller: _fechaNacimientoController,
                        hintText: 'YYYY-MM-DD',
                        labelText: 'Fecha Nacimiento',
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.datetime,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  _buildDropdownField<String>(
                    value: _generoSeleccionado,
                    hintText: 'Selecciona un género',
                    labelText: 'Género',
                    icon: Icons.people,
                    items: const [
                      DropdownMenuItem(value: 'M', child: Text('Masculino')),
                      DropdownMenuItem(value: 'F', child: Text('Femenino')),
                      DropdownMenuItem(value: 'O', child: Text('Otro')),
                    ],
                    onChanged: (value) => setState(() => _generoSeleccionado = value),
                    validator: (value) => (value == null || value.isEmpty) ? 'Selecciona el género' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildDropdownField<String>(
                    value: _rolSeleccionado,
                    hintText: 'Selecciona un rol',
                    labelText: 'Rol',
                    icon: Icons.assignment_ind,
                    items: const [
                      DropdownMenuItem(value: 'cliente', child: Text('Cliente')),
                      DropdownMenuItem(value: 'profesor', child: Text('Profesor')),
                      DropdownMenuItem(value: 'administrador', child: Text('Administrador')),
                    ],
                    onChanged: (value) => setState(() => _rolSeleccionado = value),
                    validator: (value) => (value == null || value.isEmpty) ? 'Selecciona el rol' : null,
                  ),
                  const SizedBox(height: 40),
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : ElevatedButton(
                    onPressed: actualizarUsuario,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Actualizar Usuario', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(color: Colors.blueGrey[800]),
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          prefixIcon: Icon(icon, color: Colors.indigo),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
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
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          prefixIcon: Icon(icon, color: Colors.indigo),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        items: items,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
