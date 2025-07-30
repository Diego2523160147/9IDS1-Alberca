<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Membresia extends Model
{
    protected $table = 'membresias';

    protected $fillable = [
        'nombre',
        'tipo',
        'precio',
        'fecha_inicio',
        'fecha_fin',
        'clases_incluidas',
        'descripcion',
        'estado',
        'id_usuario'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

}
