<template>
  <div>
    <h1 class="text-4xl font-bold text-primary-600 mb-4">
      Bienvenido a Sistema IBV
    </h1>
    <p class="text-lg text-gray-700 mb-6">
      Sistema de Inventario y Despacho de Vehículos en Bodegas
    </p>
    
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <div class="bg-white p-6 rounded-lg shadow">
        <h2 class="text-xl font-semibold mb-2">🚗 Recepción</h2>
        <p class="text-gray-600">Registra vehículos al llegar del buque</p>
        <NuxtLink to="/recepcion" class="text-primary-600 hover:underline mt-2 inline-block">
          Ir a Recepción →
        </NuxtLink>
      </div>

      <div class="bg-white p-6 rounded-lg shadow">
        <h2 class="text-xl font-semibold mb-2">✅ Inventario</h2>
        <p class="text-gray-600">Verifica el equipamiento de los vehículos</p>
        <NuxtLink to="/inventario" class="text-primary-600 hover:underline mt-2 inline-block">
          Ir a Inventario →
        </NuxtLink>
      </div>

      <div class="bg-white p-6 rounded-lg shadow">
        <h2 class="text-xl font-semibold mb-2">📋 Impronta</h2>
        <p class="text-gray-600">Registra fotos e información de improntas</p>
        <NuxtLink to="/impronta" class="text-primary-600 hover:underline mt-2 inline-block">
          Ir a Impronta →
        </NuxtLink>
      </div>

      <div class="bg-white p-6 rounded-lg shadow">
        <h2 class="text-xl font-semibold mb-2">🚚 Despacho</h2>
        <p class="text-gray-600">Despacha vehículos ya validados</p>
        <NuxtLink to="/despacho" class="text-primary-600 hover:underline mt-2 inline-block">
          Ir a Despacho →
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Página de inicio
</script>
