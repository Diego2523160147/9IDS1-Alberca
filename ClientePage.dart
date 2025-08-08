import 'package:flutter/material.dart';
import 'package:alberca_9ids1/loginPage.dart';
import '../models/Usuario.dart';
import 'ClasesDisponiblesPage.dart';
import 'MembresiasClientePage.dart';

class ClientePage extends StatelessWidget {
  final Usuario usuario;

  const ClientePage({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    const Color fondoClaro = Color(0xFFE6F0FA); // azul cielo claro
    const Color azulBoton = Color(0xFF0077B6); // azul profundo
    const Color azulTexto = Color(0xFF023E8A); // azul oscuro

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista Cliente'),
        backgroundColor: azulBoton,
        elevation: 0,
      ),
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0077B6), Color(0xFF90E0EF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0077B6), Color(0xFF48CAE4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Menú',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const loginPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: fondoClaro,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Bienvenido, ${usuario.name}!',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: azulTexto,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Desde aquí puedes inscribirte a una clase y revisar tus clases disponibles que te quedan.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildMenuCard(
                    icon: Icons.card_membership,
                    label: 'Clases Restantes',
                    color: azulBoton,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MembresiasClientePage(usuarioId: usuario.id),
                        ),
                      );
                    },
                  ),

                  _buildMenuCard(
                    icon: Icons.schedule,
                    label: 'Inscribirse A Clases ',
                    color: azulBoton,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClasesDisponiblesPage(clienteId: usuario.id),
                        ),
                      );
                    },
                  ),


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: color),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
