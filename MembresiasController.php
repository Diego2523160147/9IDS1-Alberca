<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Membresias; // Asegúrate de que el nombre de tu modelo sea 'Membresias' y no 'Membresia'
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\Log; 


class MembresiasController extends Controller
{
    // Método para CREAR una nueva membresía
    public function store(Request $request)
    {
        try {
            $validatedData = $request->validate([
                'nombre' => 'required|string|max:100',
                'tipo' => ['required', Rule::in(['mensual', 'por_clase', 'trimestral', 'anual'])],
                'precio' => 'required|numeric|min:0',
                'duracion_dias' => 'nullable|integer|min:0', // nullable si no siempre se envía
                'clases_incluidas' => 'nullable|integer|min:0', // nullable si no siempre se envía
                'descripcion' => 'nullable|string|max:500', // Añadido max para descripción
                'id_usuario' => 'required|exists:users,id',
            ]);

            $membresia = new Membresias();
            $membresia->nombre = $validatedData['nombre'];
            $membresia->tipo = $validatedData['tipo'];
            $membresia->precio = $validatedData['precio'];
            $membresia->duracion_dias = $validatedData['duracion_dias'];
            $membresia->clases_incluidas = $validatedData['clases_incluidas'];
            $membresia->descripcion = $validatedData['descripcion'];
            $membresia->id_usuario = $validatedData['id_usuario'];

            $membresia->save();

            return response()->json(['message' => 'Membresía creada con éxito', 'membresia' => $membresia], 201);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json(['message' => 'Error de validación', 'errors' => $e->errors()], 422);
        } catch (\Throwable $e) {
            // Log the error for debugging
            Log::error('Error al crear membresía: ' . $e->getMessage() . ' en ' . $e->getFile() . ' línea ' . $e->getLine());
            return response()->json(['error' => 'Error interno del servidor al crear la membresía.', 'details' => $e->getMessage()], 500);
        }
    }

    // Método para ACTUALIZAR una membresía
    public function update(Request $request, $id) // <--- Recibe el ID de la URL
    {
        try {
            // Depuración:
            Log::info('Datos recibidos para actualizar membresía con ID: ' . $id . ' - ' . json_encode($request->all()));

            // Validar los datos
            $validatedData = $request->validate([
                'nombre' => 'required|string|max:100',
                'tipo' => ['required', Rule::in(['mensual', 'por_clase', 'trimestral', 'anual'])],
                'precio' => 'required|numeric|min:0',
                'duracion_dias' => 'nullable|integer|min:0',
                'clases_incluidas' => 'nullable|integer|min:0',
                'descripcion' => 'nullable|string|max:500', // Añadido max para descripción
                'id_usuario' => 'required|exists:users,id',
            ]);

            // Encuentra la membresía por el ID recibido en la URL
            $membresia = Membresias::findOrFail($id); // Si no existe, Laravel devuelve un 404 automáticamente

            // Actualiza los campos
            $membresia->nombre = $validatedData['nombre'];
            $membresia->tipo = $validatedData['tipo'];
            $membresia->precio = $validatedData['precio'];
            $membresia->duracion_dias = $validatedData['duracion_dias'];
            $membresia->clases_incluidas = $validatedData['clases_incluidas'];
            $membresia->descripcion = $validatedData['descripcion'];
            $membresia->id_usuario = $validatedData['id_usuario'];

            $membresia->save();

            return response()->json(['message' => 'Membresía actualizada correctamente', 'membresia' => $membresia], 200);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'message' => 'Los datos proporcionados no son válidos.',
                'errors' => $e->errors()
            ], 422);
        } catch (\Throwable $e) {
            // Log the error for debugging
            Log::error('Error al actualizar membresía (ID: ' . $id . '): ' . $e->getMessage() . ' en ' . $e->getFile() . ' línea ' . $e->getLine());
            return response()->json(['error' => 'Error interno del servidor al actualizar la membresía.', 'details' => $e->getMessage()], 500);
        }
    }

    // Método para obtener todas las membresías (ya lo tenías bien)
    public function list()
    {
        $membresias = Membresias::join('users as u', 'u.id', '=', 'membresias.id_usuario')
            ->select(
                'membresias.*',
                'u.name as nombre_usuario'
            )
            ->get();

        return response()->json($membresias);
    }

    
    public function delete(Request $request)
    {
        // 1. Loguear la solicitud entrante
        Log::info('Solicitud de eliminación de membresía recibida.');
        Log::info('ID recibido para eliminar: ' . ($request->has('id') ? $request->input('id') : 'ID no presente en la solicitud.'));

        try {
            // Validar que el ID esté presente y sea un entero
            $request->validate([
                'id' => 'required|integer|exists:membresias,id', // Validar que el ID exista en la tabla
            ]);

            $membresia = Membresias::find($request->id);

            if ($membresia) {
                // 2. Loguear que la membresía fue encontrada
                Log::info('Membresía encontrada para eliminar: ID ' . $membresia->id . ', Nombre: ' . $membresia->nombre);

                // 3. Intenta eliminar la membresía
                $membresia->delete();

                // 4. Loguear éxito
                Log::info('Membresía eliminada correctamente: ID ' . $membresia->id);
                return response()->json(['message' => 'Membresía eliminada correctamente'], 200);
            } else {
                // 5. Loguear si la membresía no fue encontrada (aunque exists:membresias,id lo haría antes)
                Log::warning('Intento de eliminar membresía no encontrada: ID ' . $request->id);
                return response()->json(['message' => 'Membresía no encontrada'], 404);
            }
        } catch (\Illuminate\Validation\ValidationException $e) {
            // Logear errores de validación
            Log::error('Error de validación al eliminar membresía: ' . json_encode($e->errors()));
            return response()->json(['message' => 'Error de validación al eliminar', 'errors' => $e->errors()], 422);
        } catch (\Throwable $e) {
            // Logear cualquier otra excepción inesperada
            Log::error('Error inesperado al eliminar membresía: ' . $e->getMessage() . ' en ' . $e->getFile() . ' línea ' . $e->getLine());
            return response()->json(['error' => 'Error interno del servidor al eliminar la membresía.', 'details' => $e->getMessage()], 500);
        }
    }


    
    public function show($id) 
    {
        $membresia = Membresias::find($id);

        if (!$membresia) {
            return response()->json(['error' => 'Membresía no encontrada'], 404);
        }

        return response()->json($membresia);
    }
}