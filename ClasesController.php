<?php

namespace App\Http\Controllers;

use App\Models\Asistencia;
use App\Models\Clase;
use App\Models\Membresia;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ClasesController extends Controller
{
    
     // Ver clases disponibles para usuarios
    public function index()
    {
        $clases = Clase::all();
        return response()->json(['clases' => $clases], 200);
    }

    /**
     * Crear una nueva clase (solo admin).
     */
    public function store(Request $request)
    {
        $user = Auth::user();
        

    if (!$user || $user->rol !== 'Administrador') {
        return response()->json(['error' => 'No autorizado'], 403);
        
    }

        $request->validate([
            'nombre_clase' => 'required|string',
            'instructor' => 'required|string',
            'horario' => 'required',
            'dias_semana' => 'required|string',
            'hora_inicio' => 'required',
            'hora_final' => 'required',
            'cupo_maximo' => 'required|integer|min:1',
        ]);
        

        try {
        $clase = Clase::create($request->all());
        return response()->json(['message' => 'Clase creada con éxito', 'clase' => $clase], 201);
    } catch (\Exception $e) {
        return response()->json(['error' => 'No se pudo crear la clase', 'detalle' => $e->getMessage()], 500);
    }

   
    }

    // Usuario marca asistencia
   public function asistir($id_clase)
{
    try {
        $user = Auth::user();

        if (!$user) {
            return response()->json(['mensaje' => 'Usuario no autenticado'], 401);
        }

        $membresia = Membresia::where('id_usuario', $user->id)
            ->where('estado', 'activa')
            ->where('clases_incluidas', '>', 0)
            ->first();

        if (!$membresia) {
            return response()->json(['mensaje' => 'No tienes membresía activa o sin clases disponibles'], 403);
        }

        $clase = Clase::find($id_clase);
        if (!$clase) {
            return response()->json(['mensaje' => 'Clase no encontrada'], 404);
        }

        Asistencia::create([
            'user_id' => $user->id,
            'clase_id' => $clase->id,
            'fecha' => now()->toDateString(),
            'hora' => now()->format('H:i:s'),
        ]);

        $membresia->clases_incluidas -= 1;
        $membresia->save();

        return response()->json(['mensaje' => 'Asistencia registrada y clase descontada'], 200);
    } catch (\Exception $e) {
        return response()->json([
            'mensaje' => 'Error interno al registrar asistencia',
             'detalle' => $e->getMessage(), // solo en debug
        ], 500);
    }
}



    /**
     * Mostrar detalles de una clase por ID.
     */
    public function show(string $id)
    {
        $clase = Clase::find($id);
        if (!$clase) {
            return response()->json(['error' => 'Clase no encontrada'], 404);
        }
        return response()->json(['clase' => $clase], 200);
    }

    /**
     * Actualizar una clase (solo admin).
     */
    public function update(Request $request, string $id)
    {
        if (Auth::user()->rol !== 'Administrador') {
            return response()->json(['error' => 'No autorizado'], 403);
        }

        $clase = Clase::findOrFail($id);

        $request->validate([
            'nombre_clase' => 'sometimes|required|string',
            'instructor' => 'sometimes|required|string',
            'horario' => 'sometimes|required',
            'dias_semana' => 'sometimes|required|string',
            'hora_inicio' => 'sometimes|required',
            'hora_final' => 'sometimes|required',
            'cupo_maximo' => 'sometimes|required|integer|min:1',
        ]);

        $clase->update($request->all());

        return response()->json(['message' => 'Clase actualizada', 'clase' => $clase]);
    }

    /**
     * Eliminar una clase (solo admin).
     */
    public function destroy(string $id)
{
    $user = Auth::user();

    if (!$user || $user->rol !== 'Administrador') {
        return response()->json(['error' => 'No autorizado'], 403);
    }

    $clase = Clase::find($id);
    if (!$clase) {
        return response()->json(['error' => 'Clase no encontrada'], 404);
    }

    $clase->delete();
    return response()->json(['message' => 'Clase eliminada correctamente']);
}
}
