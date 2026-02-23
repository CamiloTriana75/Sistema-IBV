<template>
  <div>
    <h1 class="text-4xl font-bold text-primary-600 mb-4">
      Bienvenido a Sistema IBV
    </h1>
    <p class="text-lg text-gray-700 mb-8">
      Sistema de Inventario y Despacho de Vehículos en Bodegas
    </p>
    
    <!-- Grid de módulos principales -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <div class="bg-white p-6 rounded-lg shadow hover:shadow-lg transition">
        <h2 class="text-xl font-semibold mb-2 text-blue-600">🚢 Recepción</h2>
        <p class="text-gray-600 text-sm">Registra vehículos al llegar del buque</p>
      </div>

      <div class="bg-white p-6 rounded-lg shadow hover:shadow-lg transition">
        <h2 class="text-xl font-semibold mb-2 text-purple-600">📋 Impronta</h2>
        <p class="text-gray-600 text-sm">Registra fotos de las improntas</p>
      </div>

      <div class="bg-white p-6 rounded-lg shadow hover:shadow-lg transition">
        <h2 class="text-xl font-semibold mb-2 text-green-600">✅ Inventario</h2>
        <p class="text-gray-600 text-sm">Verifica equipamiento</p>
      </div>

      <div class="bg-white p-6 rounded-lg shadow hover:shadow-lg transition">
        <h2 class="text-xl font-semibold mb-2 text-orange-600">🚚 Despacho</h2>
        <p class="text-gray-600 text-sm">Despacha vehículos validados</p>
      </div>
    </div>

    <!-- Estadísticas -->
    <div class="mt-12 bg-white p-6 rounded-lg shadow">
      <h2 class="text-2xl font-bold mb-4">📊 Resumen del Sistema</h2>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div class="text-center">
          <p class="text-4xl font-bold text-primary-600">0</p>
          <p class="text-gray-600">Vehículos hoy</p>
        </div>
        <div class="text-center">
          <p class="text-4xl font-bold text-green-600">0</p>
          <p class="text-gray-600">Despachados</p>
        </div>
        <div class="text-center">
          <p class="text-4xl font-bold text-orange-600">0</p>
          <p class="text-gray-600">Pendientes</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Página de inicio
</script>
