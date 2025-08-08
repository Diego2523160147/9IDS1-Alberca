import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:quickalert/quickalert.dart';
import 'package:quickalert/models/quickalert_type.dart';

class RegistrarClasePage extends StatefulWidget {
  const RegistrarClasePage({super.key});

  @override
  State<RegistrarClasePage> createState() => _RegistrarClasePageState();
}

class _RegistrarClasePageState extends State<RegistrarClasePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreClaseController = TextEditingController();
  final TextEditingController _lugaresDisponiblesController = TextEditingController();

  String? _diaSemanaSeleccionado;
  String _horaInicio = '';
  String _horaFin = '';
  int? _idProfesorSeleccionado;
  bool _isLoading = false;

  List _profesores = [];
  final List<String> _dias = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
  ];

  @override
  void initState() {
    super.initState();
    _cargarProfesores();
  }

  @override
  void dispose() {
    _nombreClaseController.dispose();
    _lugaresDisponiblesController.dispose();
    super.dispose();
  }

  Future<void> _cargarProfesores() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/profesores'));
      if (response.statusCode == 200) {
        setState(() {
          _profesores = json.decode(response.body);
        });
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Error al cargar profesores: ${response.statusCode}',
        );
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error de Conexión',
        text: 'No se pudo conectar al servidor para cargar profesores. Detalles: $e',
      );
    }
  }

  Future<void> _seleccionarHora(bool esInicio) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.indigo, // Color de los botones y seleccionados
              onPrimary: Colors.white, // Color del texto en el color primario
              surface: Colors.white, // Color de fondo del diálogo
              onSurface: Colors.blueGrey, // Color del texto general
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.indigo, // Color del texto de los botones "CANCELAR" y "OK"
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final String formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
        if (esInicio) {
          _horaInicio = formattedTime;
        } else {
          _horaFin = formattedTime;
        }
      });
    }
  }

  Future<void> _registrarClase() async {
    if (!_formKey.currentState!.validate() || _idProfesorSeleccionado == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Campos Incompletos',
        text: 'Por favor, completa todos los campos requeridos y selecciona un profesor.',
      );
      return;
    }

    if (_horaInicio.isEmpty || _horaFin.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Horas Requeridas',
        text: 'Por favor, selecciona la hora de inicio y la hora de fin de la clase.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8001/api/clases/nuevo/1'), // Assuming '1' is a placeholder for a gym ID or similar
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'nombre': _nombreClaseController.text,
          'dia_semana': _diaSemanaSeleccionado,
          'hora_inicio': _horaInicio,
          'hora_fin': _horaFin,
          'lugares_disponibles': int.parse(_lugaresDisponiblesController.text),
          'id_profesor': _idProfesorSeleccionado,
        }),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        String successMessage = responseData['message'] ?? 'Clase registrada con éxito.';

        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: '¡Éxito!',
          text: successMessage,
        );
        Navigator.pop(context, true);
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = errorData['message'] ?? errorData['error'] ?? 'Hubo un error al registrar la clase.';

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
      print('Error al registrar clase: $e');
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
      case 'nombre':
        return 'Nombre de la Clase';
      case 'dia_semana':
        return 'Día de la Semana';
      case 'hora_inicio':
        return 'Hora de Inicio';
      case 'hora_fin':
        return 'Hora de Fin';
      case 'lugares_disponibles':
        return 'Lugares Disponibles';
      case 'id_profesor':
        return 'Profesor';
      default:
        return apiFieldName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Clase', style: TextStyle(color: Colors.white)),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Registrar Nueva Clase',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(blurRadius: 10.0, color: Colors.black38, offset: Offset(2.0, 2.0)),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(
                    controller: _nombreClaseController,
                    hintText: 'Ej. Yoga para Principiantes',
                    labelText: 'Nombre de la Clase',
                    icon: Icons.fitness_center,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor ingresa el nombre de la clase';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildDropdownField<String>(
                    value: _diaSemanaSeleccionado,
                    hintText: 'Selecciona un día',
                    labelText: 'Día de la Semana',
                    icon: Icons.calendar_today,
                    items: _dias.map((dia) {
                      return DropdownMenuItem(value: dia, child: Text(dia));
                    }).toList(),
                    onChanged: (value) => setState(() => _diaSemanaSeleccionado = value),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor selecciona el día de la semana';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimePickerField(
                          label: 'Hora de Inicio',
                          time: _horaInicio,
                          onTap: () => _seleccionarHora(true),
                          icon: Icons.access_time,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildTimePickerField(
                          label: 'Hora de Fin',
                          time: _horaFin,
                          onTap: () => _seleccionarHora(false),
                          icon: Icons.access_time_filled,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _lugaresDisponiblesController,
                    hintText: 'Ej. 20',
                    labelText: 'Lugares Disponibles',
                    icon: Icons.event_seat,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor ingresa los lugares disponibles';
                      if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Ingresa un número válido de lugares';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildDropdownField<int>(
                    value: _idProfesorSeleccionado,
                    hintText: 'Selecciona un profesor',
                    labelText: 'Profesor',
                    icon: Icons.person_outline,
                    items: _profesores.map<DropdownMenuItem<int>>((prof) {
                      return DropdownMenuItem<int>(
                        value: prof['id'],
                        child: Text(prof['name']),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _idProfesorSeleccionado = value),
                    validator: (value) {
                      if (value == null) return 'Por favor selecciona un profesor';
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : ElevatedButton(
                    onPressed: _registrarClase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 10,
                    ),
                    child: const Text(
                      'Registrar Clase',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          prefixIcon: Icon(icon, color: Colors.indigo),
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
          prefixIcon: Icon(icon, color: Colors.indigo),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
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

  Widget _buildTimePickerField({
    required String label,
    required String time,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
            ],
          ),
          child: TextFormField(
            controller: TextEditingController(text: time),
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Seleccionar hora',
              labelText: label,
              prefixIcon: Icon(icon, color: Colors.indigo),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              filled: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            ),
            validator: (value) {
              if (time.isEmpty) return 'Por favor, selecciona la hora';
              return null;
            },
          ),
        ),
      ),
    );
  }
}