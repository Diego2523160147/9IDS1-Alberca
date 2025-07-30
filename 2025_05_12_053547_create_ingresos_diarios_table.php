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
        Schema::create('ingresos_diarios', function (Blueprint $table) {
            $table->date('fecha_pago');
            $table->unsignedBigInteger('id_usuario');
            $table->decimal('monto', 10, 2);
            $table->string('metodo_pago', 50)->nullable();
            $table->unsignedBigInteger('pago_id');
            $table->timestamps();

            $table->foreign('id_usuario')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('pago_id')->references('id')->on('pagos')->onDelete('cascade');
            $table->primary(['fecha_pago', 'id_usuario', 'pago_id']); 
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ingresos_diarios');
    }
};
