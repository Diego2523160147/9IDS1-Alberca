<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Membresias; 
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\Log; 


class MembresiasController extends Controller
{
    
    public function store(Request $request)
    {
        try {
            $validatedData = $request->validate([
                'nombre' => 'required|string|max:100',
                'tipo' => ['required', Rule::in(['mensual', 'por_clase', 'trimestral', 'anual'])],
                'precio' => 'required|numeric|min:0',
                'duracion_dias' => 'nullable|integer|min:0',
                'clases_incluidas' => 'nullable|integer|min:0',
                'descripcion' => 'nullable|string|max:500', 
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
            
            Log::error('Error al crear membresía: ' . $e->getMessage() . ' en ' . $e->getFile() . ' línea ' . $e->getLine());
            return response()->json(['error' => 'Error interno del servidor al crear la membresía.', 'details' => $e->getMessage()], 500);
        }
    }

    
    public function update(Request $request, $id) 
    {
        try {
            
            Log::info('Datos recibidos para actualizar membresía con ID: ' . $id . ' - ' . json_encode($request->all()));

            
            $validatedData = $request->validate([
                'nombre' => 'required|string|max:100',
                'tipo' => ['required', Rule::in(['mensual', 'por_clase', 'trimestral', 'anual'])],
                'precio' => 'required|numeric|min:0',
                'duracion_dias' => 'nullable|integer|min:0',
                'clases_incluidas' => 'nullable|integer|min:0',
                'descripcion' => 'nullable|string|max:500', 
                'id_usuario' => 'required|exists:users,id',
            ]);

            
            $membresia = Membresias::findOrFail($id); 

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
            
            Log::error('Error al actualizar membresía (ID: ' . $id . '): ' . $e->getMessage() . ' en ' . $e->getFile() . ' línea ' . $e->getLine());
            return response()->json(['error' => 'Error interno del servidor al actualizar la membresía.', 'details' => $e->getMessage()], 500);
        }
    }

    
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
        
        Log::info('Solicitud de eliminación de membresía recibida.');
        Log::info('ID recibido para eliminar: ' . ($request->has('id') ? $request->input('id') : 'ID no presente en la solicitud.'));

        try {
            
            $request->validate([
                'id' => 'required|integer|exists:membresias,id', 
            ]);

            $membresia = Membresias::find($request->id);

            if ($membresia) {
                
                Log::info('Membresía encontrada para eliminar: ID ' . $membresia->id . ', Nombre: ' . $membresia->nombre);

                
                $membresia->delete();

                
                Log::info('Membresía eliminada correctamente: ID ' . $membresia->id);
                return response()->json(['message' => 'Membresía eliminada correctamente'], 200);
            } else {
                
                Log::warning('Intento de eliminar membresía no encontrada: ID ' . $request->id);
                return response()->json(['message' => 'Membresía no encontrada'], 404);
            }
        } catch (\Illuminate\Validation\ValidationException $e) {
            
            Log::error('Error de validación al eliminar membresía: ' . json_encode($e->errors()));
            return response()->json(['message' => 'Error de validación al eliminar', 'errors' => $e->errors()], 422);
        } catch (\Throwable $e) {
            
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
