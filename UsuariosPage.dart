import 'package:flutter/material.dart';
import 'RegistrarUsuarioPage.dart';
import 'ListaUsuariosPage.dart';

class UsuariosPage extends StatelessWidget {
  const UsuariosPage({super.key});

  final Color backgroundColor = const Color(0xFF0D3311);
  final Color accentGreen = const Color(0xFF3B6B2D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Gestión de Usuarios',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 15,
            shadowColor: accentGreen.withOpacity(0.6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Administra tus Usuarios',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: backgroundColor,
                      shadows: [
                        Shadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Aquí puedes registrar nuevos usuarios o visualizar y gestionar la lista completa de usuarios existentes en tu sistema.',
                    style: TextStyle(
                      fontSize: 16,
                      color: backgroundColor.withOpacity(0.7),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Icon(
                    Icons.group,
                    size: 100,
                    color: accentGreen,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(3, 3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const RegistrarUsuarioPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: accentGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: accentGreen, width: 2),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        'Registrar Nuevo Usuario',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ListaUsuariosPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: accentGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: accentGreen, width: 2),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        'Ver Lista de Usuarios',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
}
