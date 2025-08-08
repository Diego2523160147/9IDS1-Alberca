import 'package:flutter/material.dart';

class AvisoPrivacidadPage extends StatelessWidget {
  const AvisoPrivacidadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D3311), // Fondo verde militar oscuro
      appBar: AppBar(
        title: const Text('Aviso de Privacidad'),
        backgroundColor: const Color(0xFF2E8B57), // Verde oliva (igual que botón)
        elevation: 10,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
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
                const Text(
                  'Alberca XYZ - Gestión de Clases y Usuarios',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D3311), // Verde oscuro para título
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  '''En Sistema para control de Alberca, valoramos y respetamos la privacidad de todos nuestros usuarios, incluyendo clientes, profesores y administradores. Por ello, informamos que la información personal que recopilamos se utiliza exclusivamente para brindar un mejor servicio y gestionar adecuadamente las clases, profesores y usuarios dentro de nuestra plataforma.

Información que recopilamos

- Datos personales básicos: nombre, correo electrónico, fecha de nacimiento, género y datos de contacto.
- Información de usuario: rol asignado (cliente, profesor o administrador).
- Datos de uso: selección y registro de clases, horarios, historial de asistencia y preferencias.
- Información técnica: datos del dispositivo y ubicación aproximada para mejorar la experiencia en la aplicación.

Finalidad del tratamiento de datos

- Gestionar las inscripciones y clases asignadas a cada cliente.
- Facilitar la comunicación entre profesores y clientes.
- Administrar los permisos y accesos según el rol del usuario.
- Mejorar la calidad del servicio y personalizar la experiencia del usuario.
- Cumplir con obligaciones legales y administrativas.

Derechos del usuario

Los usuarios tienen derecho a:

- Acceder a sus datos personales.
- Rectificar información incorrecta o incompleta.
- Solicitar la cancelación o eliminación de sus datos cuando sea legalmente procedente.
- Oponerse al tratamiento de sus datos para fines específicos.

Para ejercer estos derechos, puede contactarnos a través de nuestro correo electrónico: contacto@albercaxyz.com.

Seguridad y confidencialidad

Implementamos medidas técnicas y organizativas para proteger sus datos personales contra accesos no autorizados, pérdida, alteración o divulgación indebida.
Cambios en el aviso de privacidad
Este aviso puede actualizarse periódicamente. Cualquier cambio será informado oportunamente a través de la aplicación o medios oficiales.
Al utilizar esta aplicación, usted acepta y consiente el tratamiento de sus datos conforme a este aviso de privacidad.
''',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF0D3311), // Texto en verde oscuro
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E8B57), // Verde oliva
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                  ),
                  child: const Text(
                    'Leído',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
