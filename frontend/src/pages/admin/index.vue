<template>
  <div>
    <h1 class="text-3xl font-bold mb-8">Panel Administrativo</h1>
    
    <!-- Grid de paneles -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <!-- Usuarios -->
      <NuxtLink to="/admin/usuarios" class="bg-white p-6 rounded-lg shadow hover:shadow-lg transition cursor-pointer">
        <h2 class="text-2xl mb-2">👥</h2>
        <h3 class="text-xl font-semibold mb-1">Usuarios</h3>
        <p class="text-gray-600 text-sm">Gestionar usuarios y roles</p>
      </NuxtLink>

      <!-- Roles -->
      <div class="bg-white p-6 rounded-lg shadow hover:shadow-lg transition">
        <h2 class="text-2xl mb-2">🔑</h2>
        <h3 class="text-xl font-semibold mb-1">Roles</h3>
        <p class="text-gray-600 text-sm">Configurar permisos (próximamente)</p>
      </div>

      <!-- Estadísticas -->
      <div class="bg-white p-6 rounded-lg shadow hover:shadow-lg transition">
        <h2 class="text-2xl mb-2">📊</h2>
        <h3 class="text-xl font-semibold mb-1">Estadísticas</h3>
        <p class="text-gray-600 text-sm">Ver reportes del sistema</p>
      </div>

      <!-- Auditoría -->
      <div class="bg-white p-6 rounded-lg shadow hover:shadow-lg transition">
        <h2 class="text-2xl mb-2">📝</h2>
        <h3 class="text-xl font-semibold mb-1">Auditoría</h3>
        <p class="text-gray-600 text-sm">Registro de cambios (próximamente)</p>
      </div>

      <!-- Configuración -->
      <div class="bg-white p-6 rounded-lg shadow hover:shadow-lg transition">
        <h2 class="text-2xl mb-2">⚙️</h2>
        <h3 class="text-xl font-semibold mb-1">Configuración</h3>
        <p class="text-gray-600 text-sm">Ajustes del sistema</p>
      </div>

      <!-- Backup -->
      <div class="bg-white p-6 rounded-lg shadow hover:shadow-lg transition">
        <h2 class="text-2xl mb-2">💾</h2>
        <h3 class="text-xl font-semibold mb-1">Backup</h3>
        <p class="text-gray-600 text-sm">Respaldar datos (próximamente)</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Admin Dashboard
</script>
