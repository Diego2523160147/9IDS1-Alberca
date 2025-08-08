import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:alberca_9ids1/HomePage.dart';
import 'package:alberca_9ids1/clientePage.dart';
import 'package:alberca_9ids1/profesorPage.dart';

import 'package:alberca_9ids1/models/LoginResponse.dart';
import 'package:alberca_9ids1/models/Usuario.dart';

import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:quickalert/models/quickalert_type.dart';

// Importa la página del aviso de privacidad
import 'avisoPrivacidadPage.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  final TextEditingController _txtUser = TextEditingController();
  final TextEditingController _txtPassword = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D3311), // Verde militar oscuro
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  'https://cdn-icons-png.flaticon.com/512/3001/3001758.png', // Imagen militar
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Acceso al Sistema',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D3311), // Título en verde oscuro
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Por favor, autentícate para continuar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),
                _buildTextField(
                  controller: _txtUser,
                  hintText: 'ejemplo@correo.com',
                  labelText: 'Correo electrónico',
                  icon: Icons.person,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _txtPassword,
                  hintText: 'Tu contraseña',
                  labelText: 'Contraseña',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 20),

                // Texto clickeable para el aviso de privacidad
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AvisoPrivacidadPage()),
                    );
                  },
                  child: const Text(
                    'Aviso de Privacidad',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Color(0xFF2E8B57),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                _isLoading
                    ? const CircularProgressIndicator(color: Color(0xFF2E8B57))
                    : ElevatedButton(
                  onPressed: _showPrivacyDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E8B57), // Botón verde oliva
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                  ),
                  child: const Text(
                    'Ingresar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8001/api/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'email': _txtUser.text,
          'password': _txtPassword.text,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(json);

        if (loginResponse.acceso == "Ok") {
          final rol = json['rol'] ?? '';

          final usuario = Usuario(
            id: json['idUsuario'] ?? 0,
            name: json['nombreUsuario'] ?? '',
            email: json['email'] ?? '',
            curp: '',
            fechaNacimiento: '',
            genero: '',
            rol: rol,
          );

          Widget nextPage;
          switch (rol) {
            case 'administrador':
              nextPage = const HomePage();
              break;
            case 'cliente':
              nextPage = ClientePage(usuario: usuario);
              break;
            case 'profesor':
              nextPage = ProfesorPage(usuario: usuario);
              break;
            default:
              await QuickAlert.show(
                context: context,
                type: QuickAlertType.error,
                title: 'Rol desconocido',
                text: 'El rol recibido es: "$rol"',
              );
              return;
          }

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => nextPage));
        } else {
          await QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Acceso denegado',
            text: loginResponse.error,
          );
        }
      } else {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error de Conexión',
          text: 'Código HTTP: ${response.statusCode}',
        );
      }
    } catch (e) {
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'Ocurrió un error inesperado: $e',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showPrivacyDialog() async {
    final acepto = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aviso de Privacidad'),
        content: const Text(
          '¿Has leído y aceptas el aviso de privacidad para continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sí, acepto'),
          ),
        ],
      ),
    );

    if (acepto == true) {
      _login();
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: Icon(icon, color: const Color(0xFF2E8B57)), // Icono verde oliva
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
