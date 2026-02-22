<template>
  <div>
    <!-- Header/Navbar -->
    <header class="bg-white shadow">
      <nav class="container mx-auto px-4 py-4 flex justify-between items-center">
        <div class="text-2xl font-bold text-primary-600">
          <NuxtLink to="/">IBV</NuxtLink>
        </div>
        <ul class="flex gap-6">
          <li><NuxtLink to="/" class="hover:text-primary-600">Inicio</NuxtLink></li>
          <li><NuxtLink to="/login" class="hover:text-primary-600">Login</NuxtLink></li>
        </ul>
      </nav>
    </header>

    <!-- Main Content -->
    <main class="container mx-auto px-4 py-8">
      <slot />
    </main>

    <!-- Footer -->
    <footer class="bg-gray-800 text-white mt-12 py-6">
      <div class="container mx-auto px-4 text-center">
        <p>&copy; 2026 Sistema IBV. Todos los derechos reservados.</p>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
// Layout principal
</script>
