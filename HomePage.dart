import 'package:flutter/material.dart';
import 'package:alberca_9ids1/NuevoMembresiaPage.dart';
import 'package:alberca_9ids1/MembresiasListaPage.dart';
import 'package:alberca_9ids1/UsuariosPage.dart';
import 'package:alberca_9ids1/MembresiasPage.dart';
import 'package:alberca_9ids1/RegistrarClasePage.dart';
import 'package:alberca_9ids1/ListaClasesPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color primaryColor = const Color(0xFF0D3311);
  final Color lightPrimary = const Color(0xFF3B6B2D); // Verde claro suave para textos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text(
          'Alberca Natación',
          style: TextStyle(color: Color(0xFF3B6B2D)),
        ),
        backgroundColor: primaryColor,
        elevation: 2,
        centerTitle: true,
      ),
      drawer: _buildDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: ListView(
          children: [
            _smallCard(
              icon: Icons.pool,
              title: 'Niños',
              description: 'Seguridad y juegos para los pequeños',
              color: Colors.teal,
            ),
            const SizedBox(height: 15),
            _smallCard(
              icon: Icons.accessibility_new,
              title: 'Principiantes',
              description: 'Aprende las bases con confianza',
              color: Colors.orange,
            ),
            const SizedBox(height: 15),
            _smallCard(
              icon: Icons.fitness_center,
              title: 'Perfeccionamiento',
              description: 'Mejora técnica y resistencia',
              color: Colors.green,
            ),
            const SizedBox(height: 15),
            _smallCard(
              icon: Icons.self_improvement,
              title: 'Adultos Mayores',
              description: 'Ejercicios suaves y bienestar',
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: primaryColor,
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              accountName: const Text(
                "Edgar Leonel",
                style: TextStyle(color: Colors.white),
              ),
              accountEmail: const Text(
                "Administrador",
                style: TextStyle(color: Colors.white70),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage("assets/login_icon.png"),
              ),
            ),
            _drawerItem("Inicio", Icons.dashboard, () {
              Navigator.pop(context);
            }),
            _drawerItem("Usuarios", Icons.people, () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const UsuariosPage()));
            }),
            _drawerItem("Membresías", Icons.card_membership, () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const Membresiaspage()));
            }),
            _drawerItem("Registrar Clase", Icons.edit_calendar, () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const RegistrarClasePage()));
            }),
            _drawerItem("Lista de Clases", Icons.list_alt, () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const ListaClasesPage()));
            }),
            const Divider(color: Colors.white70),
            _drawerItem("Cerrar Sesión", Icons.logout, () {
              Navigator.pushReplacementNamed(context, '/');
            }),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Widget _smallCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Ícono a la izquierda
            CircleAvatar(
              backgroundColor: color.withOpacity(0.8),
              radius: 25,
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            // Texto a la derecha, alineado a la derecha
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,  // texto alineado a la derecha
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      color: lightPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
