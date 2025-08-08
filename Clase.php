<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Clase extends Model
{
    protected $table = 'clases';

    protected $fillable = [
        'nombre_clase',
        'instructor',
        'horario',
        'dias_semana',
        'hora_inicio',
        'hora_final',
        'cupo_maximo'
    ];
    

}
