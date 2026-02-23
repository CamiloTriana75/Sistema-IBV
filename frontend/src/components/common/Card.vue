<template>
  <div class="rounded-lg border border-gray-200 bg-white shadow-md overflow-hidden">
    <!-- Card Header -->
    <div v-if="title" class="border-b border-gray-200 px-6 py-4">
      <h3 class="text-lg font-semibold text-gray-900">{{ title }}</h3>
    </div>

    <!-- Card Body -->
    <div class="px-6 py-4">
      <slot />
    </div>

    <!-- Card Footer -->
    <div v-if="$slots.footer" class="border-t border-gray-200 px-6 py-4 bg-gray-50">
      <slot name="footer" />
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  title?: string
}

withDefaults(defineProps<Props>(), {
  title: ''
})
</script>

<style scoped>
/* Hover effect */
:deep(.hover-lift) {
  @apply transition-all duration-200 hover:shadow-lg hover:-translate-y-1;
}
</style>
