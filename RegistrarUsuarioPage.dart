import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:quickalert/quickalert.dart';
import 'package:quickalert/models/quickalert_type.dart';

class RegistrarUsuarioPage extends StatefulWidget {
  const RegistrarUsuarioPage({super.key});

  @override
  State<RegistrarUsuarioPage> createState() => _RegistrarUsuarioPageState();
}

class _RegistrarUsuarioPageState extends State<RegistrarUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _curpController = TextEditingController();
  final TextEditingController _fechaNacimientoController = TextEditingController();

  String? _generoSeleccionado;
  String? _rolSeleccionado;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _curpController.dispose();
    _fechaNacimientoController.dispose();
    super.dispose();
  }

  Future<void> _registrarUsuario() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8001/api/clientes/nuevo'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'name': _nombreController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'curp': _curpController.text.isEmpty ? null : _curpController.text,
          'fecha_nacimiento': _fechaNacimientoController.text.isEmpty ? null : _fechaNacimientoController.text,
          'genero': _generoSeleccionado,
          'rol': _rolSeleccionado,
        }),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        String successMessage = responseData['message'] ?? 'Usuario registrado con éxito.';

        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: '¡Éxito!',
          text: successMessage,
        );
        Navigator.pop(context, true);
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = errorData['message'] ?? errorData['error'] ?? 'Hubo un error al registrar el usuario.';

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
      print('Error al registrar usuario: $e');
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
      case 'name':
        return 'Nombre';
      case 'email':
        return 'Email';
      case 'password':
        return 'Contraseña';
      case 'curp':
        return 'CURP';
      case 'fecha_nacimiento':
        return 'Fecha de Nacimiento';
      case 'genero':
        return 'Género';
      case 'rol':
        return 'Rol';
      default:
        return apiFieldName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Usuario', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white, // Fondo blanco general
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              shadowColor: Colors.teal.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Registrar Nuevo Usuario',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                          shadows: [
                            Shadow(blurRadius: 10.0, color: Colors.black26, offset: Offset(2.0, 2.0)),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      _buildTextField(
                        controller: _nombreController,
                        hintText: 'Ej. Juan Pérez',
                        labelText: 'Nombre',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Por favor ingresa el nombre';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'Ej. correo@example.com',
                        labelText: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Por favor ingresa el email';
                          if (!value.contains('@')) return 'Ingresa un email válido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: 'Mínimo 6 caracteres',
                        labelText: 'Contraseña',
                        icon: Icons.lock,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Por favor ingresa la contraseña';
                          if (value.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _curpController,
                        hintText: 'Ej. ABCD123456GHIJKL01',
                        labelText: 'CURP (Opcional)',
                        icon: Icons.credit_card,
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            locale: const Locale('es', 'ES'),
                          );
                          if (pickedDate != null) {
                            String formattedDate = pickedDate.toIso8601String().split('T')[0];
                            setState(() {
                              _fechaNacimientoController.text = formattedDate;
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: _buildTextField(
                            controller: _fechaNacimientoController,
                            hintText: 'YYYY-MM-DD',
                            labelText: 'Fecha de Nacimiento (Opcional)',
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
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Por favor selecciona el género';
                          return null;
                        },
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
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Por favor selecciona el rol';
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.teal)
                          : ElevatedButton(
                        onPressed: _registrarUsuario,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 10,
                        ),
                        child: const Text(
                          'Registrar Usuario',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
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
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
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
          prefixIcon: Icon(icon, color: Colors.teal),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
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
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          prefixIcon: Icon(icon, color: Colors.teal),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        style: TextStyle(color: Colors.blueGrey[800]),
        dropdownColor: Colors.white,
        iconEnabledColor: Colors.teal,
        items: items,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
