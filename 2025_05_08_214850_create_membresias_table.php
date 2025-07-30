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
        Schema::create('membresias', function (Blueprint $table) {
            $table->id();
            $table->string('nombre', 100);
            $table->enum('tipo', ['mensual', 'por_clase', 'trimestral', 'anual']);
            $table->decimal('precio', 10, 2);
            $table->integer('duracion_dias')->nullable();
            $table->integer('clases_incluidas')->nullable();
            $table->text('descripcion')->nullable();
            $table->timestamps();
            $table->bigInteger("id_usuario");
            
            $table->foreign('id_usuario')->references('id')->on('users')->onDelete('cascade');
            
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('membresias');
    }
};
