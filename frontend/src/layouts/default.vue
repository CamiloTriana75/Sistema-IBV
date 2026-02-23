<template>
  <div>
    <!-- Header/Navbar -->
    <header class="bg-white shadow sticky top-0 z-40">
      <nav class="container mx-auto px-4 py-4 flex justify-between items-center">
        <div class="text-2xl font-bold text-primary-600">
          <NuxtLink to="/">🚗 IBV</NuxtLink>
        </div>
        <ul class="hidden md:flex gap-6">
          <li><NuxtLink to="/" class="text-gray-700 hover:text-primary-600 transition">Inicio</NuxtLink></li>
          <li><NuxtLink to="/login" class="text-gray-700 hover:text-primary-600 transition">Login</NuxtLink></li>
        </ul>
        <button class="md:hidden">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </button>
      </nav>
    </header>

    <!-- Main Content -->
    <main class="container mx-auto px-4 py-8 min-h-[calc(100vh-200px)]">
      <slot />
    </main>

    <!-- Footer -->
    <footer class="bg-gray-800 text-white mt-12 py-6 border-t">
      <div class="container mx-auto px-4 text-center">
        <p>&copy; 2026 Sistema IBV. Todos los derechos reservados.</p>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
// Layout principal aplicado a todas las páginas
</script>
