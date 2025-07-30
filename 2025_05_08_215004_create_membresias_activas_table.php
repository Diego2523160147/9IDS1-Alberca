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
        Schema::create('membresias_activas', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('id_usuario');
            $table->unsignedBigInteger('membresia_id');
            $table->date('fecha_inicio');
            $table->date('fecha_fin')->nullable();
            $table->integer('clases_restantes')->nullable();
            $table->unsignedBigInteger('pago_id');
            $table->timestamps();

            $table->foreign('id_usuario')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('membresia_id')->references('id')->on('membresias')->onDelete('cascade');
            $table->foreign('pago_id')->references('id')->on('pagos')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('membresias_activas');
    }
};
