<template>
  <button
    :class="[
      'px-4 py-2 rounded-lg font-semibold transition-all duration-200',
      'focus:outline-none focus:ring-2 focus:ring-offset-2',
      variantClasses
    ]"
    :disabled="disabled"
  >
    <slot />
  </button>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  variant?: 'primary' | 'secondary' | 'success' | 'danger'
  disabled?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
  disabled: false
})

const variantClasses = computed(() => {
  const variants = {
    primary: 'bg-primary-600 text-white hover:bg-primary-700 focus:ring-primary-500',
    secondary: 'bg-gray-200 text-gray-900 hover:bg-gray-300 focus:ring-gray-500',
    success: 'bg-success-600 text-white hover:bg-success-700 focus:ring-success-500',
    danger: 'bg-danger-600 text-white hover:bg-danger-700 focus:ring-danger-500'
  }
  return variants[props.variant]
})
</script>
