<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('tarjetas_acceso', function (Blueprint $table) {
            $table->id();
            $table->timestamps();   
            $table->unsignedBigInteger('id_usuario');
            $table->string('codigo_tarjeta', 50)->unique();
            $table->date('fecha_activacion');
            $table->date('fecha_expiracion')->nullable();
            $table->boolean('activa')->default(true);
            

            $table->foreign('id_usuario')->references('id')->on('users')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('tarjetas_acceso');
    }
};
