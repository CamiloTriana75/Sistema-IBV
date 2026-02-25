<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useUserStore, SYSTEM_ROLES } from '~/stores/userStore'
import type { User } from '~/types/index'

definePageMeta({ layout: 'admin' })

const userStore = useUserStore()

// Filtros
const searchQuery = ref('')
const filterRole = ref('')
const filterStatus = ref('')

// Modal state
const showModal = ref(false)
const showDeleteModal = ref(false)
const editingUser = ref<User | null>(null)
const userToDelete = ref<User | null>(null)
const saving = ref(false)
const formError = ref('')
const showPassword = ref(false)

// Toast
const toast = ref({ show: false, message: '', type: 'success' as 'success' | 'error' })

const form = ref({
  name: '',
  email: '',
  password: '',
  role: 'recibidor' as User['role'],
  status: 'active' as User['status'],
})

// Computed
const filteredUsers = computed(() => {
  let result = [...userStore.users]
  if (searchQuery.value) {
    const q = searchQuery.value.toLowerCase()
    result = result.filter(
      (u) => u.name.toLowerCase().includes(q) || u.email.toLowerCase().includes(q)
    )
  }
  if (filterRole.value) {
    result = result.filter((u) => u.role === filterRole.value)
  }
  if (filterStatus.value) {
    result = result.filter((u) => u.status === filterStatus.value)
  }
  return result
})

// Helpers
const getInitials = (name: string) => {
  return name
    .split(' ')
    .map((w) => w[0])
    .join('')
    .substring(0, 2)
    .toUpperCase()
}

const getAvatarColor = (role: string) => {
  const colors: Record<string, string> = {
    admin: 'bg-primary-600',
    recibidor: 'bg-blue-500',
    inventario: 'bg-amber-500',
    despachador: 'bg-green-500',
    porteria: 'bg-purple-500',
  }
  return colors[role] || 'bg-gray-500'
}

const showToast = (message: string, type: 'success' | 'error' = 'success') => {
  toast.value = { show: true, message, type }
  setTimeout(() => {
    toast.value.show = false
  }, 3000)
}

// CRUD handlers
const openCreateModal = () => {
  editingUser.value = null
  formError.value = ''
  showPassword.value = false
  form.value = { name: '', email: '', password: '', role: 'recibidor', status: 'active' }
  showModal.value = true
}

const editUser = (user: User) => {
  editingUser.value = user
  formError.value = ''
  form.value = {
    name: user.name,
    email: user.email,
    password: '',
    role: user.role,
    status: user.status,
  }
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  editingUser.value = null
  formError.value = ''
}

const saveUser = async () => {
  formError.value = ''
  saving.value = true
  try {
    if (editingUser.value) {
      await userStore.updateUser(editingUser.value.id, {
        name: form.value.name,
        email: form.value.email,
        role: form.value.role,
        status: form.value.status,
      })
      showToast(`Usuario "${form.value.name}" actualizado`)
    } else {
      if (!form.value.password || form.value.password.length < 4) {
        formError.value = 'La contraseña debe tener al menos 4 caracteres'
        saving.value = false
        return
      }
      await userStore.createUser({
        name: form.value.name,
        email: form.value.email,
        role: form.value.role,
        status: form.value.status,
      })
      showToast(`Usuario "${form.value.name}" creado exitosamente`)
    }
    closeModal()
  } catch (err: unknown) {
    formError.value = (err as Error).message || 'Error al guardar'
  } finally {
    saving.value = false
  }
}

const openDeleteModal = (user: User) => {
  userToDelete.value = user
  showDeleteModal.value = true
}

const closeDeleteModal = () => {
  showDeleteModal.value = false
  userToDelete.value = null
}

const confirmDelete = async () => {
  if (!userToDelete.value) return
  saving.value = true
  try {
    const name = userToDelete.value.name
    await userStore.deleteUser(userToDelete.value.id)
    showToast(`Usuario "${name}" eliminado`)
    closeDeleteModal()
  } catch (err) {
    showToast('Error al eliminar usuario', 'error')
  } finally {
    saving.value = false
  }
}

const handleToggleStatus = async (user: User) => {
  try {
    await userStore.toggleStatus(user.id)
    showToast(`Estado de "${user.name}" actualizado`)
  } catch {
    showToast('Error al cambiar estado', 'error')
  }
}

onMounted(() => {
  userStore.fetchUsers()
})
</script>

<template>
  <div>
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
      <div>
        <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Gestión de Usuarios</h1>
        <p class="text-gray-500 mt-1">
          {{ userStore.activeUsers }} activos de {{ userStore.userCount }} usuarios
        </p>
      </div>
      <button
        class="inline-flex items-center gap-2 px-5 py-2.5 bg-primary-600 text-white font-semibold rounded-xl hover:bg-primary-700 transition shadow-sm"
        @click="openCreateModal"
      >
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M12 6v6m0 0v6m0-6h6m-6 0H6"
          />
        </svg>
        Nuevo Usuario
      </button>
    </div>

    <!-- Filtros y búsqueda -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-4 mb-6">
      <div class="flex flex-col sm:flex-row gap-3">
        <div class="flex-1 relative">
          <svg
            class="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
            />
          </svg>
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Buscar por nombre o email..."
            class="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-transparent"
          />
        </div>
        <select
          v-model="filterRole"
          class="px-4 py-2.5 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-transparent bg-white"
        >
          <option value="">Todos los roles</option>
          <option v-for="role in SYSTEM_ROLES" :key="role.value" :value="role.value">
            {{ role.label }}
          </option>
        </select>
        <select
          v-model="filterStatus"
          class="px-4 py-2.5 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-transparent bg-white"
        >
          <option value="">Todos los estados</option>
          <option value="active">Activos</option>
          <option value="inactive">Inactivos</option>
        </select>
      </div>
    </div>

    <!-- Toast de éxito -->
    <Transition
      enter-active-class="transition duration-300 ease-out"
      enter-from-class="translate-y-2 opacity-0"
      enter-to-class="translate-y-0 opacity-100"
      leave-active-class="transition duration-200 ease-in"
      leave-from-class="translate-y-0 opacity-100"
      leave-to-class="translate-y-2 opacity-0"
    >
      <div
        v-if="toast.show"
        :class="[
          'fixed bottom-6 right-6 z-50 flex items-center gap-3 px-5 py-3 rounded-xl shadow-lg text-white font-medium',
          toast.type === 'success' ? 'bg-green-600' : 'bg-red-600',
        ]"
      >
        <svg
          v-if="toast.type === 'success'"
          class="w-5 h-5"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M5 13l4 4L19 7"
          />
        </svg>
        <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M6 18L18 6M6 6l12 12"
          />
        </svg>
        {{ toast.message }}
      </div>
    </Transition>

    <!-- Tabla de usuarios -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
      <!-- Loading -->
      <div v-if="userStore.loading" class="p-12 text-center">
        <div
          class="animate-spin w-8 h-8 border-4 border-primary-200 border-t-primary-600 rounded-full mx-auto mb-3"
        />
        <p class="text-gray-500 text-sm">Cargando usuarios...</p>
      </div>

      <!-- Empty state -->
      <div v-else-if="filteredUsers.length === 0" class="p-12 text-center">
        <svg
          class="w-16 h-16 text-gray-300 mx-auto mb-4"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="1.5"
            d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"
          />
        </svg>
        <p class="text-gray-500 font-medium">No se encontraron usuarios</p>
        <p class="text-gray-400 text-sm mt-1">
          Intenta ajustar los filtros o crea un nuevo usuario
        </p>
      </div>

      <!-- Table -->
      <div v-else class="overflow-x-auto">
        <table class="w-full">
          <thead>
            <tr class="bg-gray-50 border-b border-gray-100">
              <th
                class="px-6 py-3.5 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Usuario
              </th>
              <th
                class="px-6 py-3.5 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Rol
              </th>
              <th
                class="px-6 py-3.5 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Estado
              </th>
              <th
                class="px-6 py-3.5 text-center text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Acciones
              </th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-50">
            <tr v-for="user in filteredUsers" :key="user.id" class="hover:bg-gray-50/50 transition">
              <!-- Usuario -->
              <td class="px-6 py-4">
                <div class="flex items-center gap-3">
                  <div
                    :class="[
                      'w-10 h-10 rounded-full flex items-center justify-center text-sm font-bold text-white shrink-0',
                      getAvatarColor(user.role),
                    ]"
                  >
                    {{ getInitials(user.name) }}
                  </div>
                  <div class="min-w-0">
                    <p class="text-sm font-semibold text-gray-900 truncate">{{ user.name }}</p>
                    <p class="text-xs text-gray-500 truncate">{{ user.email }}</p>
                  </div>
                </div>
              </td>
              <!-- Rol -->
              <td class="px-6 py-4">
                <span
                  :class="[
                    'inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold',
                    userStore.getRoleInfo(user.role).color,
                  ]"
                >
                  <span
                    :class="['w-1.5 h-1.5 rounded-full', userStore.getRoleInfo(user.role).dotColor]"
                  />
                  {{ userStore.getRoleInfo(user.role).label }}
                </span>
              </td>
              <!-- Estado -->
              <td class="px-6 py-4">
                <button
                  :class="[
                    'inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold cursor-pointer transition hover:opacity-80',
                    user.status === 'active'
                      ? 'bg-green-50 text-green-700'
                      : 'bg-red-50 text-red-600',
                  ]"
                  @click="handleToggleStatus(user)"
                >
                  <span
                    :class="[
                      'w-1.5 h-1.5 rounded-full',
                      user.status === 'active' ? 'bg-green-500' : 'bg-red-400',
                    ]"
                  />
                  {{ user.status === 'active' ? 'Activo' : 'Inactivo' }}
                </button>
              </td>
              <!-- Acciones -->
              <td class="px-6 py-4">
                <div class="flex items-center justify-center gap-2">
                  <button
                    class="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium text-primary-700 bg-primary-50 hover:bg-primary-100 rounded-lg transition"
                    @click="editUser(user)"
                  >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
                      />
                    </svg>
                    Editar
                  </button>
                  <button
                    class="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium text-red-700 bg-red-50 hover:bg-red-100 rounded-lg transition"
                    @click="openDeleteModal(user)"
                  >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                      />
                    </svg>
                    Eliminar
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Footer con conteo -->
      <div
        v-if="filteredUsers.length > 0"
        class="px-6 py-3 bg-gray-50 border-t border-gray-100 text-xs text-gray-500"
      >
        Mostrando {{ filteredUsers.length }} de {{ userStore.userCount }} usuarios
      </div>
    </div>

    <!-- ========== MODAL CREAR / EDITAR USUARIO ========== -->
    <Teleport to="body">
      <Transition
        enter-active-class="transition duration-200 ease-out"
        enter-from-class="opacity-0"
        enter-to-class="opacity-100"
        leave-active-class="transition duration-150 ease-in"
        leave-from-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <div v-if="showModal" class="fixed inset-0 z-50 flex items-center justify-center p-4">
          <!-- Overlay -->
          <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" @click="closeModal" />

          <!-- Modal -->
          <div
            class="relative bg-white rounded-2xl shadow-2xl w-full max-w-lg max-h-[90vh] overflow-y-auto"
          >
            <!-- Header -->
            <div class="flex items-center justify-between px-6 py-4 border-b border-gray-100">
              <div class="flex items-center gap-3">
                <div
                  :class="[
                    'w-10 h-10 rounded-xl flex items-center justify-center',
                    editingUser ? 'bg-amber-50' : 'bg-primary-50',
                  ]"
                >
                  <svg
                    v-if="!editingUser"
                    class="w-5 h-5 text-primary-600"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"
                    />
                  </svg>
                  <svg
                    v-else
                    class="w-5 h-5 text-amber-600"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
                    />
                  </svg>
                </div>
                <div>
                  <h2 class="text-lg font-bold text-gray-900">
                    {{ editingUser ? 'Editar Usuario' : 'Nuevo Usuario' }}
                  </h2>
                  <p class="text-xs text-gray-500">
                    {{
                      editingUser
                        ? 'Modifica los datos del usuario'
                        : 'Completa los datos para crear un usuario'
                    }}
                  </p>
                </div>
              </div>
              <button
                class="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-lg transition"
                @click="closeModal"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
              </button>
            </div>

            <!-- Form -->
            <form class="p-6 space-y-5" @submit.prevent="saveUser">
              <!-- Avatar preview -->
              <div class="flex justify-center">
                <div
                  :class="[
                    'w-16 h-16 rounded-full flex items-center justify-center text-xl font-bold text-white transition-all',
                    getAvatarColor(form.role),
                  ]"
                >
                  {{ form.name ? getInitials(form.name) : '?' }}
                </div>
              </div>

              <!-- Nombre completo -->
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1.5">
                  Nombre completo
                  <span class="text-red-500">*</span>
                </label>
                <input
                  v-model="form.name"
                  type="text"
                  required
                  placeholder="Ej: Carlos Pérez"
                  class="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-transparent transition placeholder:text-gray-400"
                />
              </div>

              <!-- Email -->
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1.5">
                  Correo electrónico
                  <span class="text-red-500">*</span>
                </label>
                <input
                  v-model="form.email"
                  type="email"
                  required
                  placeholder="Ej: carlos@ibv.com"
                  class="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-transparent transition placeholder:text-gray-400"
                />
              </div>

              <!-- Contraseña (solo al crear) -->
              <div v-if="!editingUser">
                <label class="block text-sm font-semibold text-gray-700 mb-1.5">
                  Contraseña
                  <span class="text-red-500">*</span>
                </label>
                <div class="relative">
                  <input
                    v-model="form.password"
                    :type="showPassword ? 'text' : 'password'"
                    required
                    placeholder="Mínimo 4 caracteres"
                    minlength="4"
                    class="w-full px-4 py-2.5 pr-12 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-transparent transition placeholder:text-gray-400"
                  />
                  <button
                    type="button"
                    class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                    @click="showPassword = !showPassword"
                  >
                    <svg
                      v-if="!showPassword"
                      class="w-5 h-5"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                      />
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"
                      />
                    </svg>
                    <svg
                      v-else
                      class="w-5 h-5"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"
                      />
                    </svg>
                  </button>
                </div>
              </div>

              <!-- Rol del sistema -->
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2.5">
                  Rol del sistema
                  <span class="text-red-500">*</span>
                </label>
                <div class="grid grid-cols-1 gap-2.5">
                  <label
                    v-for="role in SYSTEM_ROLES"
                    :key="role.value"
                    :class="[
                      'flex items-center gap-3 p-4 rounded-xl border-2 cursor-pointer transition-all',
                      form.role === role.value
                        ? 'border-primary-500 bg-primary-50 shadow-md'
                        : 'border-gray-200 hover:border-primary-300 hover:bg-gray-50',
                    ]"
                  >
                    <input v-model="form.role" type="radio" :value="role.value" class="sr-only" />
                    <div
                      :class="[
                        'w-10 h-10 rounded-xl flex items-center justify-center shrink-0 transition-all',
                        form.role === role.value ? role.color.replace('100', '100') : 'bg-gray-100',
                      ]"
                    >
                      <span
                        :class="[
                          'w-2.5 h-2.5 rounded-full',
                          form.role === role.value ? role.dotColor : 'bg-gray-400',
                        ]"
                      />
                    </div>
                    <div class="flex-1 min-w-0">
                      <p
                        :class="[
                          'text-sm font-bold',
                          form.role === role.value ? 'text-primary-700' : 'text-gray-900',
                        ]"
                      >
                        {{ role.label }}
                      </p>
                      <p class="text-xs text-gray-600 mt-0.5">{{ role.description }}</p>
                    </div>
                    <div class="shrink-0">
                      <div
                        v-if="form.role === role.value"
                        class="w-6 h-6 bg-primary-600 rounded-full flex items-center justify-center"
                      >
                        <svg class="w-4 h-4 text-white" fill="currentColor" viewBox="0 0 20 20">
                          <path
                            fill-rule="evenodd"
                            d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                            clip-rule="evenodd"
                          />
                        </svg>
                      </div>
                      <div v-else class="w-6 h-6 border-2 border-gray-300 rounded-full" />
                    </div>
                  </label>
                </div>
              </div>

              <!-- Estado -->
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1.5">Estado</label>
                <div class="flex gap-3">
                  <label
                    :class="[
                      'flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl border-2 cursor-pointer transition-all text-sm font-medium',
                      form.status === 'active'
                        ? 'border-green-500 bg-green-50 text-green-700'
                        : 'border-gray-100 text-gray-500 hover:border-gray-200',
                    ]"
                  >
                    <input v-model="form.status" type="radio" value="active" class="sr-only" />
                    <span class="w-2 h-2 rounded-full bg-green-500" />
                    Activo
                  </label>
                  <label
                    :class="[
                      'flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl border-2 cursor-pointer transition-all text-sm font-medium',
                      form.status === 'inactive'
                        ? 'border-red-400 bg-red-50 text-red-600'
                        : 'border-gray-100 text-gray-500 hover:border-gray-200',
                    ]"
                  >
                    <input v-model="form.status" type="radio" value="inactive" class="sr-only" />
                    <span class="w-2 h-2 rounded-full bg-red-400" />
                    Inactivo
                  </label>
                </div>
              </div>

              <!-- Error -->
              <div
                v-if="formError"
                class="flex items-center gap-2 p-3 bg-red-50 border border-red-200 rounded-xl text-sm text-red-700"
              >
                <svg class="w-5 h-5 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                  />
                </svg>
                {{ formError }}
              </div>

              <!-- Botones -->
              <div class="flex gap-3 pt-2">
                <button
                  type="button"
                  class="flex-1 px-5 py-2.5 bg-gray-100 text-gray-700 font-semibold rounded-xl hover:bg-gray-200 transition text-sm"
                  @click="closeModal"
                >
                  Cancelar
                </button>
                <button
                  type="submit"
                  :disabled="saving"
                  :class="[
                    'flex-1 px-5 py-2.5 font-semibold rounded-xl transition text-sm flex items-center justify-center gap-2',
                    saving
                      ? 'bg-gray-300 text-gray-500 cursor-not-allowed'
                      : editingUser
                        ? 'bg-amber-500 text-white hover:bg-amber-600 shadow-sm'
                        : 'bg-primary-600 text-white hover:bg-primary-700 shadow-sm',
                  ]"
                >
                  <div
                    v-if="saving"
                    class="animate-spin w-4 h-4 border-2 border-white/30 border-t-white rounded-full"
                  />
                  {{ saving ? 'Guardando...' : editingUser ? 'Actualizar' : 'Crear Usuario' }}
                </button>
              </div>
            </form>
          </div>
        </div>
      </Transition>
    </Teleport>

    <!-- ========== MODAL CONFIRMAR ELIMINACIÓN ========== -->
    <Teleport to="body">
      <Transition
        enter-active-class="transition duration-200 ease-out"
        enter-from-class="opacity-0"
        enter-to-class="opacity-100"
        leave-active-class="transition duration-150 ease-in"
        leave-from-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <div v-if="showDeleteModal" class="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" @click="closeDeleteModal" />
          <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-sm p-6 text-center">
            <div
              class="w-14 h-14 bg-red-50 rounded-full flex items-center justify-center mx-auto mb-4"
            >
              <svg
                class="w-7 h-7 text-red-600"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                />
              </svg>
            </div>
            <h3 class="text-lg font-bold text-gray-900 mb-1">Eliminar Usuario</h3>
            <p class="text-sm text-gray-500 mb-6">
              ¿Estás seguro de eliminar a
              <span class="font-semibold text-gray-700">{{ userToDelete?.name }}</span>
              ? Esta acción no se puede deshacer.
            </p>
            <div class="flex gap-3">
              <button
                class="flex-1 px-4 py-2.5 bg-gray-100 text-gray-700 font-semibold rounded-xl hover:bg-gray-200 transition text-sm"
                @click="closeDeleteModal"
              >
                Cancelar
              </button>
              <button
                :disabled="saving"
                class="flex-1 px-4 py-2.5 bg-red-600 text-white font-semibold rounded-xl hover:bg-red-700 transition text-sm"
                @click="confirmDelete"
              >
                {{ saving ? 'Eliminando...' : 'Eliminar' }}
              </button>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>
  </div>
</template>
