<script setup lang="ts">
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useNotificationStore } from '~/stores/notificationStore'
import type { NotificationItem, NotificationModule } from '~/services/supabaseNotificationService'

const notificationStore = useNotificationStore()
const isOpen = ref(false)
const dropdownRef = ref<HTMLElement | null>(null)

const unreadCount = computed(() => notificationStore.unreadCount)
const isLoading = computed(() => notificationStore.loading)
const notifications = computed(() => notificationStore.notifications)

const moduleConfig: Record<NotificationModule, { label: string; dot: string }> = {
  admin: { label: 'Admin', dot: 'bg-primary-500' },
  recibidor: { label: 'Recibidor', dot: 'bg-success-500' },
  inventario: { label: 'Inventario', dot: 'bg-blue-500' },
  despachador: { label: 'Despachador', dot: 'bg-amber-500' },
  porteria: { label: 'Porteria', dot: 'bg-warning-500' },
  general: { label: 'General', dot: 'bg-gray-400' },
}

const formatDate = (value: string) => {
  try {
    const date = new Date(value)
    const ahora = new Date()
    const diffMs = ahora.getTime() - date.getTime()
    const diffMins = Math.floor(diffMs / 60000)
    const diffHours = Math.floor(diffMs / 3600000)
    const diffDays = Math.floor(diffMs / 86400000)
    
    // Si es hace menos de 1 hora
    if (diffMins < 60) {
      return diffMins <= 1 ? 'Ahora' : `${diffMins} min`
    }
    
    // Si es hace menos de 24 horas
    if (diffHours < 24) {
      return `${diffHours} h`
    }
    
    // Si es hace menos de 7 días
    if (diffDays < 7) {
      return `${diffDays} d`
    }
    
    // Formato corto para fechas antiguas
    return new Intl.DateTimeFormat('es-VE', {
      day: '2-digit',
      month: '2-digit',
    }).format(date)
  } catch {
    return value
  }
}

const toggleOpen = async () => {
  isOpen.value = !isOpen.value
  if (isOpen.value) {
    await notificationStore.fetchNotifications(12)
  }
}

const handleClickOutside = (event: MouseEvent) => {
  const target = event.target as Node
  if (dropdownRef.value && !dropdownRef.value.contains(target)) {
    isOpen.value = false
  }
}

const markAllAsRead = async () => {
  await notificationStore.markAllAsRead()
}

const markAsRead = async (item: NotificationItem) => {
  if (item.leida_en) return
  await notificationStore.markAsRead(item.id)
}

const openNotification = async (item: NotificationItem) => {
  await markAsRead(item)
  if (item.action_url) {
    navigateTo(item.action_url)
  }
}

onMounted(() => {
  notificationStore.fetchNotifications(12)
  document.addEventListener('click', handleClickOutside)
})

onBeforeUnmount(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

<template>
  <div ref="dropdownRef" class="relative">
    <button
      class="relative text-gray-400 hover:text-gray-600 transition"
      type="button"
      @click.stop="toggleOpen"
    >
      <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"
        />
      </svg>
      <span
        v-if="unreadCount > 0"
        class="absolute -top-1 -right-1 min-w-[16px] h-4 px-1 bg-danger-500 text-white text-[10px] font-bold rounded-full flex items-center justify-center"
      >
        {{ unreadCount > 9 ? '9+' : unreadCount }}
      </span>
    </button>

    <div
      v-if="isOpen"
      class="fixed sm:absolute right-0 sm:right-0 left-0 sm:left-auto mt-0 sm:mt-3 top-16 sm:top-auto w-full sm:w-[400px] sm:max-w-[90vw] bg-white border-t sm:border border-gray-200 sm:rounded-xl shadow-2xl sm:shadow-xl overflow-hidden z-50 max-h-[calc(100vh-4rem)] sm:max-h-[500px]"
      @click.stop
    >
      <div class="flex items-center justify-between px-4 sm:px-5 py-3 sm:py-3.5 border-b border-gray-100 bg-gray-50 sm:bg-white shrink-0">
        <div class="flex-1 min-w-0">
          <p class="text-sm sm:text-base font-semibold text-gray-900">Notificaciones</p>
          <p class="text-xs text-gray-500">{{ unreadCount }} sin leer</p>
        </div>
        <button
          class="text-xs sm:text-sm text-primary-600 hover:text-primary-700 font-semibold whitespace-nowrap ml-3"
          type="button"
          @click="markAllAsRead"
        >
          Marcar todas
        </button>
      </div>

      <div class="overflow-y-auto" style="max-height: calc(100vh - 8rem); height: auto;">
        <div v-if="isLoading" class="px-4 sm:px-5 py-8 text-sm text-center text-gray-500">
          Cargando...
        </div>

        <div v-else-if="notifications.length === 0" class="px-4 sm:px-5 py-8 text-sm text-center text-gray-500">
          <svg class="w-12 h-12 mx-auto mb-3 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"
            />
          </svg>
          <p class="font-medium">Sin notificaciones</p>
        </div>

        <button
          v-for="item in notifications"
          :key="item.id"
          class="w-full text-left px-4 sm:px-5 py-3 sm:py-3.5 border-b border-gray-100 hover:bg-gray-50 transition"
          :class="{ 'bg-primary-50/30': !item.leida_en }"
          type="button"
          @click="openNotification(item)"
        >
          <div class="flex items-start gap-3">
            <span
              class="mt-1 h-2 w-2 sm:h-2.5 sm:w-2.5 rounded-full shrink-0"
              :class="moduleConfig[item.modulo]?.dot || 'bg-gray-300'"
            />
            <div class="flex-1 min-w-0">
              <div class="flex items-start justify-between gap-2 mb-1">
                <p
                  class="text-sm sm:text-base font-semibold flex-1 min-w-0"
                  :class="item.leida_en ? 'text-gray-600' : 'text-gray-900'"
                  style="word-break: break-word;"
                >
                  {{ item.titulo }}
                </p>
                <span class="text-[10px] sm:text-[11px] text-gray-400 whitespace-nowrap shrink-0 mt-0.5">
                  {{ formatDate(item.created_at) }}
                </span>
              </div>
              <p class="text-xs sm:text-sm text-gray-500 mb-2 line-clamp-2">
                {{ item.mensaje }}
              </p>
              <div class="flex items-center justify-between gap-2">
                <span class="text-[10px] sm:text-[11px] px-2 py-0.5 rounded-full font-medium"
                  :class="`${moduleConfig[item.modulo]?.dot.replace('bg-', 'bg-opacity-10 bg-')} ${moduleConfig[item.modulo]?.dot.replace('bg-', 'text-')}`"
                >
                  {{ moduleConfig[item.modulo]?.label || 'General' }}
                </span>
                <button
                  v-if="!item.leida_en"
                  class="text-[10px] sm:text-[11px] text-primary-600 hover:text-primary-700 font-medium whitespace-nowrap"
                  type="button"
                  @click.stop="markAsRead(item)"
                >
                  Marcar leída
                </button>
              </div>
            </div>
          </div>
        </button>
      </div>
    </div>
  </div>
</template>
<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>