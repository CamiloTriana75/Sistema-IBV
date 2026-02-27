<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '~/stores/auth'
import {
  supabaseNotificationService,
  type NotificationItem,
  type NotificationModule,
} from '~/services/supabaseNotificationService'
import { supabaseUserService, type SupabaseUser } from '~/services/supabaseUserService'
import { supabaseRoleService, type SupabaseRole } from '~/services/supabaseRoleService'

definePageMeta({ layout: 'admin', middleware: ['auth', 'admin'] })

const authStore = useAuthStore()

const loading = ref(false)
const saving = ref(false)
const error = ref('')
const notifications = ref<NotificationItem[]>([])
const users = ref<SupabaseUser[]>([])
const formError = ref('')
const adminUserId = ref<number | null>(null)
const roles = ref<SupabaseRole[]>([])

const searchQuery = ref('')
const filterModule = ref<NotificationModule | ''>('')
const filterUnread = ref(false)
const filterRole = ref('')
const filterUserId = ref('')

const SYSTEM_ROLES = computed(() =>
  roles.value.map((r) => ({ value: r.nombre.toLowerCase(), label: r.nombre }))
)

const moduleOptions: Array<{ value: NotificationModule; label: string }> = [
  { value: 'general', label: 'General' },
  { value: 'admin', label: 'Admin' },
  { value: 'recibidor', label: 'Recibidor' },
  { value: 'inventario', label: 'Inventario' },
  { value: 'despachador', label: 'Despachador' },
  { value: 'porteria', label: 'Porteria' },
]

const form = ref({
  titulo: '',
  mensaje: '',
  modulo: 'general' as NotificationModule,
  targetType: 'user',
  targetUserId: '',
  targetRole: 'recibidor',
  actionUrl: '',
})

const filteredNotifications = computed(() => {
  let list = [...notifications.value]
  if (filterRole.value) {
    const ids = new Set(users.value.filter((u) => u.rol === filterRole.value).map((u) => u.id))
    list = list.filter((n) => (n.recipient_user_id ? ids.has(n.recipient_user_id) : false))
  }
  return list
})

const getUserLabel = (userId: number | null) => {
  if (!userId) return '—'
  const user = users.value.find((u) => u.id === userId)
  if (!user) return `#${userId}`
  return `${user.nombres} ${user.apellidos}`.trim() || user.correo
}

const resolveAdminUserId = async () => {
  if (adminUserId.value) return adminUserId.value
  const email = authStore.user?.email
  if (!email) return null
  const profile = await supabaseUserService.getUserProfile(email)
  adminUserId.value = profile?.id ?? null
  return adminUserId.value
}

const loadRoles = async () => {
  try {
    const allRoles = await supabaseRoleService.getAllRolesWithUsers()
    roles.value = allRoles.map((r: any) => ({
      id: r.id,
      nombre: r.name,
      descripcion: r.description || '',
      activo: r.activo !== false,
      created_at: r.created_at,
    }))
    // Establecer el primer rol como default si es necesario
    if (roles.value.length > 0 && !roles.value.find((r) => r.nombre.toLowerCase() === form.value.targetRole)) {
      form.value.targetRole = roles.value[0].nombre.toLowerCase()
    }
  } catch (err) {
    console.error('Error cargando roles:', err)
  }
}

const loadUsers = async () => {
  users.value = await supabaseUserService.getAllUsers()
}

const loadNotifications = async () => {
  loading.value = true
  error.value = ''
  try {
    const list = await supabaseNotificationService.getNotifications({
      limit: 50,
      onlyUnread: filterUnread.value,
      module: filterModule.value || undefined,
      search: searchQuery.value || undefined,
      recipientUserId: filterUserId.value ? Number(filterUserId.value) : undefined,
    })
    notifications.value = list
  } catch (err: any) {
    error.value = err?.message || 'Error al cargar notificaciones'
  } finally {
    loading.value = false
  }
}

const markAsRead = async (item: NotificationItem) => {
  if (item.leida_en) return
  try {
    await supabaseNotificationService.markAsRead(item.id)
    notifications.value = notifications.value.map((n) =>
      n.id === item.id ? { ...n, leida_en: new Date().toISOString() } : n
    )
  } catch (err: any) {
    error.value = err?.message || 'Error al marcar notificacion'
  }
}

const createForUser = async (recipientUserId: number, createdByUserId: number, createdByRole: string) => {
  return supabaseNotificationService.createNotification({
    titulo: form.value.titulo.trim(),
    mensaje: form.value.mensaje.trim(),
    modulo: form.value.modulo,
    recipientUserId,
    createdByUserId,
    createdByRole,
    actionUrl: form.value.actionUrl?.trim() || null,
  })
}

const createNotifications = async () => {
  formError.value = ''

  if (!form.value.titulo.trim()) {
    formError.value = 'El titulo es requerido'
    return
  }
  if (!form.value.mensaje.trim()) {
    formError.value = 'El mensaje es requerido'
    return
  }

  const createdByUserId = await resolveAdminUserId()
  if (!createdByUserId) {
    formError.value = 'No se pudo resolver el usuario administrador'
    return
  }

  const createdByRole = authStore.user?.role || 'admin'

  saving.value = true
  try {
    if (form.value.targetType === 'user') {
      const target = Number(form.value.targetUserId)
      if (!target) {
        formError.value = 'Selecciona un usuario destino'
        return
      }
      await createForUser(target, createdByUserId, createdByRole)
    } else {
      const role = form.value.targetRole
      const roleUsers = users.value.filter((u) => u.rol === role && u.activo)
      if (!roleUsers.length) {
        formError.value = 'No hay usuarios activos con ese rol'
        return
      }
      for (const user of roleUsers) {
        await createForUser(user.id, createdByUserId, createdByRole)
      }
    }

    form.value.titulo = ''
    form.value.mensaje = ''
    form.value.actionUrl = ''
    await loadNotifications()
  } catch (err: any) {
    formError.value = err?.message || 'Error al crear notificaciones'
  } finally {
    saving.value = false
  }
}

const resetFilters = async () => {
  searchQuery.value = ''
  filterModule.value = ''
  filterUnread.value = false
  filterRole.value = ''
  filterUserId.value = ''
  await loadNotifications()
}

onMounted(async () => {
  await loadRoles()
  await loadUsers()
  await loadNotifications()
})
</script>

<template>
  <ClientOnly>
    <div class="space-y-6">
      <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Centro de Notificaciones</h1>
          <p class="text-gray-500 mt-1">Controla y envía notificaciones a usuarios y roles</p>
        </div>
        <button
          class="inline-flex items-center gap-2 px-4 py-2.5 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 disabled:opacity-50 disabled:cursor-not-allowed"
          type="button"
          @click="loadNotifications"
          :disabled="loading"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M4 4v5h.582m15.356 2A8 8 0 104.582 9"
            />
          </svg>
          Recargar
        </button>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div class="lg:col-span-1 bg-white rounded-xl shadow-sm border border-gray-100 p-5">
          <h2 class="text-lg font-semibold text-gray-900">Crear notificacion</h2>
          <p class="text-xs text-gray-500 mt-1">Envio directo por usuario o rol</p>

          <div class="mt-4 space-y-3">
            <div>
              <label class="text-sm font-medium text-gray-700">Titulo</label>
              <input
                v-model="form.titulo"
                class="mt-1 w-full px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="Titulo de la notificacion"
              />
            </div>
            <div>
              <label class="text-sm font-medium text-gray-700">Mensaje</label>
              <textarea
                v-model="form.mensaje"
                rows="3"
                class="mt-1 w-full px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="Detalle del mensaje"
              />
            </div>
            <div>
              <label class="text-sm font-medium text-gray-700">Modulo</label>
              <select
                v-model="form.modulo"
                class="mt-1 w-full px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option v-for="opt in moduleOptions" :key="opt.value" :value="opt.value">
                  {{ opt.label }}
                </option>
              </select>
            </div>
            <div>
              <label class="text-sm font-medium text-gray-700">Destino</label>
              <div class="mt-2 flex gap-3">
                <label class="flex items-center gap-2 text-sm text-gray-600">
                  <input v-model="form.targetType" type="radio" value="user" />
                  Usuario
                </label>
                <label class="flex items-center gap-2 text-sm text-gray-600">
                  <input v-model="form.targetType" type="radio" value="role" />
                  Rol
                </label>
              </div>
            </div>
            <div v-if="form.targetType === 'user'">
              <label class="text-sm font-medium text-gray-700">Usuario</label>
              <select
                v-model="form.targetUserId"
                class="mt-1 w-full px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="">Selecciona un usuario</option>
                <option v-for="user in users" :key="user.id" :value="String(user.id)">
                  {{ user.nombres }} {{ user.apellidos }} ({{ user.correo }})
                </option>
              </select>
            </div>
            <div v-else>
              <label class="text-sm font-medium text-gray-700">Rol</label>
              <select
                v-model="form.targetRole"
                class="mt-1 w-full px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option v-for="role in SYSTEM_ROLES" :key="role.value" :value="role.value">
                  {{ role.label }}
                </option>
              </select>
            </div>
            <div>
              <label class="text-sm font-medium text-gray-700">URL de accion (opcional)</label>
              <input
                v-model="form.actionUrl"
                class="mt-1 w-full px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="/admin/usuarios"
              />
            </div>

            <p v-if="formError" class="text-sm text-danger-600">{{ formError }}</p>

            <button
              class="w-full mt-2 inline-flex items-center justify-center gap-2 px-4 py-2.5 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-70"
              type="button"
              :disabled="saving"
              @click="createNotifications"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 4v16m8-8H4"
                />
              </svg>
              {{ saving ? 'Enviando...' : 'Enviar notificacion' }}
            </button>
          </div>
        </div>

        <div class="lg:col-span-2 space-y-4">
          <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-4">
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-3">
              <div class="lg:col-span-2">
                <label class="text-xs font-semibold text-gray-500">Buscar</label>
                <input
                  v-model="searchQuery"
                  class="mt-1 w-full px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                  placeholder="Titulo o mensaje"
                />
              </div>
              <div>
                <label class="text-xs font-semibold text-gray-500">Modulo</label>
                <select
                  v-model="filterModule"
                  class="mt-1 w-full px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                >
                  <option value="">Todos</option>
                  <option v-for="opt in moduleOptions" :key="opt.value" :value="opt.value">
                    {{ opt.label }}
                  </option>
                </select>
              </div>
              <div>
                <label class="text-xs font-semibold text-gray-500">Usuario</label>
                <select
                  v-model="filterUserId"
                  class="mt-1 w-full px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                >
                  <option value="">Todos</option>
                  <option v-for="user in users" :key="user.id" :value="String(user.id)">
                    {{ user.nombres }} {{ user.apellidos }}
                  </option>
                </select>
              </div>
              <div>
                <label class="text-xs font-semibold text-gray-500">Rol</label>
                <select
                  v-model="filterRole"
                  class="mt-1 w-full px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                >
                  <option value="">Todos</option>
                  <option v-for="role in SYSTEM_ROLES" :key="role.value" :value="role.value">
                    {{ role.label }}
                  </option>
                </select>
              </div>
            </div>
            <div class="flex items-center justify-between mt-3">
              <label class="flex items-center gap-2 text-sm text-gray-600 cursor-pointer">
                <input v-model="filterUnread" type="checkbox" class="w-4 h-4 rounded" />
                Solo no leidas
              </label>
              <div class="flex items-center gap-2">
                <button
                  class="px-3 py-2 text-sm rounded-lg border border-gray-200 hover:bg-gray-50"
                  type="button"
                  @click="resetFilters"
                >
                  Limpiar
                </button>
                <button
                  class="px-3 py-2 text-sm rounded-lg bg-primary-600 text-white hover:bg-primary-700"
                  type="button"
                  @click="loadNotifications"
                >
                  Aplicar
                </button>
              </div>
            </div>
          </div>

          <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
            <div class="px-4 py-3 border-b border-gray-100 flex items-center justify-between">
              <div>
                <p class="text-sm font-semibold text-gray-900">Listado</p>
                <p class="text-xs text-gray-500">{{ filteredNotifications.length }} registros</p>
              </div>
            </div>

            <div v-if="loading" class="px-4 py-6 text-sm text-gray-500">Cargando...</div>
            <div v-else-if="error" class="px-4 py-6 text-sm text-danger-600">{{ error }}</div>
            <div v-else-if="filteredNotifications.length === 0" class="px-4 py-6 text-sm text-gray-500">
              Sin notificaciones
            </div>

            <div v-else class="divide-y">
              <div v-for="item in filteredNotifications" :key="item.id" class="px-4 py-3">
                <div class="flex items-start justify-between gap-4">
                  <div>
                    <p class="text-sm font-semibold" :class="item.leida_en ? 'text-gray-600' : 'text-gray-900'">
                      {{ item.titulo }}
                    </p>
                    <p class="text-xs text-gray-500 mt-1">{{ item.mensaje }}</p>
                    <div class="flex flex-wrap items-center gap-3 text-[11px] text-gray-400 mt-2">
                      <span>Modulo: {{ item.modulo }}</span>
                      <span>Usuario: {{ getUserLabel(item.recipient_user_id) }}</span>
                      <span>Rol origen: {{ item.created_by_role }}</span>
                      <span>{{ item.created_at }}</span>
                    </div>
                  </div>
                  <div class="flex items-center gap-2">
                    <button
                      v-if="!item.leida_en"
                      class="text-xs text-primary-600 hover:text-primary-700"
                      type="button"
                      @click="markAsRead(item)"
                    >
                      Marcar leida
                    </button>
                    <span
                      class="text-[10px] px-2 py-1 rounded-full"
                      :class="item.leida_en ? 'bg-gray-100 text-gray-500' : 'bg-success-100 text-success-600'"
                    >
                      {{ item.leida_en ? 'Leida' : 'Nueva' }}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </ClientOnly>
</template>
