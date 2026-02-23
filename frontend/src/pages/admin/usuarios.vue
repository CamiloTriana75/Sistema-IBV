<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useUserStore } from '~/stores/userStore'

definePageMeta({
  layout: 'admin',
  middleware: ['auth', 'admin'],
})

// Filtros
const filters = ref({
  search: '',
  role: '',
  status: '',
})

const userStore = useUserStore()
const users = computed(() => userStore.users)

// Paginación
const currentPage = ref(1)
const perPage = 8

onMounted(async () => {
  await userStore.fetchUsers()
})

// Filtrar usuarios
const filteredUsers = computed(() => {
  return users.value.filter((u) => {
    const matchSearch =
      !filters.value.search ||
      u.name.toLowerCase().includes(filters.value.search.toLowerCase()) ||
      u.email.toLowerCase().includes(filters.value.search.toLowerCase())
    const matchRole = !filters.value.role || u.role === filters.value.role
    const matchStatus = !filters.value.status || u.status === filters.value.status
    return matchSearch && matchRole && matchStatus
  })
})

const totalPages = computed(() => Math.ceil(filteredUsers.value.length / perPage))
const paginationStart = computed(() => (currentPage.value - 1) * perPage + 1)
const paginationEnd = computed(() =>
  Math.min(currentPage.value * perPage, filteredUsers.value.length)
)

// Helpers de estilo
const getAvatarColor = (role: string) => {
  const colors: Record<string, string> = {
    admin: 'bg-primary-600',
    porteria: 'bg-warning-600',
    recibidor: 'bg-success-600',
    inventario: 'bg-blue-600',
    despachador: 'bg-purple-600',
    cliente: 'bg-gray-500',
  }
  return colors[role] || 'bg-gray-500'
}

const getRoleBadge = (role: string) => {
  const badges: Record<string, string> = {
    admin: 'bg-primary-100 text-primary-700',
    porteria: 'bg-warning-500/10 text-warning-700',
    recibidor: 'bg-success-500/10 text-success-700',
    inventario: 'bg-blue-100 text-blue-700',
    despachador: 'bg-purple-100 text-purple-700',
    cliente: 'bg-gray-100 text-gray-700',
  }
  return badges[role] || 'bg-gray-100 text-gray-700'
}

const getRoleName = (role: string) => {
  const names: Record<string, string> = {
    admin: 'Administrador',
    porteria: 'Portería',
    recibidor: 'Recibidor',
    inventario: 'Inventario',
    despachador: 'Despachador',
    cliente: 'Cliente',
  }
  return names[role] || role
}

// Modal CRUD
const showModal = ref(false)
const showDeleteModal = ref(false)
const editingUser = ref<any>(null)
const userToDelete = ref<any>(null)
const form = ref({
  name: '',
  email: '',
  password: '',
  role: 'cliente',
  status: 'active',
})

const openCreateModal = () => {
  editingUser.value = null
  form.value = { name: '', email: '', password: '', role: 'cliente', status: 'active' }
  showModal.value = true
}

const editUser = (user: any) => {
  editingUser.value = user
  form.value = { ...user, password: '' }
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  editingUser.value = null
}

const saveUser = async () => {
  if (editingUser.value) {
    await userStore.updateUser(editingUser.value.id, form.value)
  } else {
    await userStore.createUser(form.value)
  }
  closeModal()
}

const openDeleteModal = (user: any) => {
  userToDelete.value = user
  showDeleteModal.value = true
}

const closeDeleteModal = () => {
  showDeleteModal.value = false
  userToDelete.value = null
}

const confirmDelete = async () => {
  if (userToDelete.value?.id) {
    await userStore.deleteUser(userToDelete.value.id)
  }
  closeDeleteModal()
}
</script>

<template>
  <div>
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
      <div>
        <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Gestión de Usuarios</h1>
        <p class="text-gray-500 mt-1">Administra los usuarios y sus roles en el sistema</p>
      </div>
      <button
        class="inline-flex items-center gap-2 px-5 py-2.5 bg-primary-600 text-white text-sm font-semibold rounded-xl hover:bg-primary-700 active:bg-primary-800 transition-all shadow-lg shadow-primary-500/25"
        @click="openCreateModal"
      >
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M12 4v16m8-8H4"
          />
        </svg>
        Nuevo Usuario
      </button>
    </div>

    <!-- Filtros -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-4 mb-6">
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <!-- Búsqueda -->
        <div class="relative lg:col-span-2">
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
            v-model="filters.search"
            type="text"
            placeholder="Buscar por nombre o email…"
            class="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition text-sm"
          />
        </div>

        <!-- Filtro Rol -->
        <select
          v-model="filters.role"
          class="w-full px-4 py-2.5 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition text-sm text-gray-700"
        >
          <option value="">Todos los roles</option>
          <option value="admin">Admin</option>
          <option value="porteria">Portería</option>
          <option value="recibidor">Recibidor</option>
          <option value="inventario">Inventario</option>
          <option value="despachador">Despachador</option>
          <option value="cliente">Cliente</option>
        </select>

        <!-- Filtro Estado -->
        <select
          v-model="filters.status"
          class="w-full px-4 py-2.5 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition text-sm text-gray-700"
        >
          <option value="">Todos los estados</option>
          <option value="active">Activo</option>
          <option value="inactive">Inactivo</option>
        </select>
      </div>
    </div>

    <!-- Tabla de usuarios -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 border-b border-gray-100">
            <tr>
              <th
                class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Usuario
              </th>
              <th
                class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Rol
              </th>
              <th
                class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Estado
              </th>
              <th
                class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Creado
              </th>
              <th
                class="px-6 py-3 text-right text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Acciones
              </th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-50">
            <tr v-for="user in filteredUsers" :key="user.id" class="hover:bg-gray-50 transition">
              <!-- Usuario -->
              <td class="px-6 py-4">
                <div class="flex items-center gap-3">
                  <div
                    class="w-10 h-10 rounded-full flex items-center justify-center text-sm font-bold text-white"
                    :class="getAvatarColor(user.role)"
                  >
                    {{ user.name.charAt(0) }}{{ user.name.split(' ')[1]?.charAt(0) || '' }}
                  </div>
                  <div>
                    <p class="text-sm font-medium text-gray-900">{{ user.name }}</p>
                    <p class="text-xs text-gray-500">{{ user.email }}</p>
                  </div>
                </div>
              </td>
              <!-- Rol -->
              <td class="px-6 py-4">
                <span
                  :class="[
                    'inline-flex px-2.5 py-1 text-xs font-semibold rounded-full',
                    getRoleBadge(user.role),
                  ]"
                >
                  {{ getRoleName(user.role) }}
                </span>
              </td>
              <!-- Estado -->
              <td class="px-6 py-4">
                <div class="flex items-center gap-2">
                  <span
                    :class="[
                      'w-2 h-2 rounded-full',
                      user.status === 'active' ? 'bg-success-500' : 'bg-gray-300',
                    ]"
                  />
                  <span
                    :class="[
                      'text-xs font-medium',
                      user.status === 'active' ? 'text-success-600' : 'text-gray-500',
                    ]"
                  >
                    {{ user.status === 'active' ? 'Activo' : 'Inactivo' }}
                  </span>
                </div>
              </td>
              <!-- Creado -->
              <td class="px-6 py-4 text-sm text-gray-500">{{ user.createdAt || '—' }}</td>
              <!-- Acciones -->
              <td class="px-6 py-4">
                <div class="flex items-center justify-end gap-1">
                  <button
                    class="p-2 text-gray-400 hover:text-primary-600 hover:bg-primary-50 rounded-lg transition"
                    title="Editar"
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
                  </button>
                  <button
                    class="p-2 text-gray-400 hover:text-danger-600 hover:bg-danger-50 rounded-lg transition"
                    title="Eliminar"
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
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Paginación -->
      <div
        class="px-6 py-4 border-t border-gray-100 flex flex-col sm:flex-row items-center justify-between gap-4"
      >
        <p class="text-sm text-gray-500">
          Mostrando
          <span class="font-medium text-gray-700">{{ paginationStart }}</span>
          a
          <span class="font-medium text-gray-700">{{ paginationEnd }}</span>
          de
          <span class="font-medium text-gray-700">{{ filteredUsers.length }}</span>
          resultados
        </p>
        <div class="flex items-center gap-1">
          <button
            :disabled="currentPage === 1"
            class="px-3 py-1.5 text-sm border border-gray-200 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition"
            @click="currentPage = Math.max(1, currentPage - 1)"
          >
            Anterior
          </button>
          <button
            v-for="page in totalPages"
            :key="page"
            :class="[
              'w-9 h-9 text-sm rounded-lg transition font-medium',
              currentPage === page
                ? 'bg-primary-600 text-white shadow-sm'
                : 'text-gray-600 hover:bg-gray-50',
            ]"
            @click="currentPage = page"
          >
            {{ page }}
          </button>
          <button
            :disabled="currentPage === totalPages"
            class="px-3 py-1.5 text-sm border border-gray-200 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition"
            @click="currentPage = Math.min(totalPages, currentPage + 1)"
          >
            Siguiente
          </button>
        </div>
      </div>
    </div>

    <!-- Modal Crear/Editar -->
    <div
      v-if="showModal"
      class="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4"
    >
      <div class="bg-white rounded-2xl shadow-2xl w-full max-w-lg transform transition-all">
        <!-- Modal Header -->
        <div class="flex items-center justify-between px-6 py-4 border-b border-gray-100">
          <div>
            <h2 class="text-lg font-bold text-gray-900">
              {{ editingUser ? 'Editar Usuario' : 'Crear Nuevo Usuario' }}
            </h2>
            <p class="text-sm text-gray-500 mt-0.5">
              {{
                editingUser
                  ? 'Modifica la información del usuario'
                  : 'Completa los datos para crear un usuario'
              }}
            </p>
          </div>
          <button class="text-gray-400 hover:text-gray-600 transition p-1" @click="closeModal">
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

        <!-- Modal Body -->
        <form class="px-6 py-5 space-y-4" @submit.prevent="saveUser">
          <!-- Nombre -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-1.5">Nombre completo</label>
            <input
              v-model="form.name"
              type="text"
              required
              placeholder="Juan Pérez"
              class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition text-sm"
            />
          </div>

          <!-- Email -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-1.5">
              Correo electrónico
            </label>
            <input
              v-model="form.email"
              type="email"
              required
              placeholder="juan@empresa.com"
              class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition text-sm"
            />
          </div>

          <!-- Contraseña (solo al crear) -->
          <div v-if="!editingUser">
            <label class="block text-sm font-semibold text-gray-700 mb-1.5">Contraseña</label>
            <input
              v-model="form.password"
              type="password"
              required
              placeholder="Mínimo 8 caracteres"
              class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition text-sm"
            />
          </div>

          <!-- Rol y Estado -->
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-1.5">Rol</label>
              <select
                v-model="form.role"
                class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition text-sm"
              >
                <option value="admin">Administrador</option>
                <option value="porteria">Portería</option>
                <option value="recibidor">Recibidor</option>
                <option value="inventario">Inventario</option>
                <option value="despachador">Despachador</option>
                <option value="cliente">Cliente</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-1.5">Estado</label>
              <select
                v-model="form.status"
                class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition text-sm"
              >
                <option value="active">Activo</option>
                <option value="inactive">Inactivo</option>
              </select>
            </div>
          </div>

          <!-- Footer Buttons -->
          <div class="flex gap-3 pt-2">
            <button
              type="submit"
              class="flex-1 py-2.5 bg-primary-600 text-white font-semibold rounded-xl hover:bg-primary-700 transition text-sm"
            >
              {{ editingUser ? 'Guardar Cambios' : 'Crear Usuario' }}
            </button>
            <button
              type="button"
              class="px-6 py-2.5 bg-gray-100 text-gray-700 font-semibold rounded-xl hover:bg-gray-200 transition text-sm"
              @click="closeModal"
            >
              Cancelar
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal Eliminar -->
    <div
      v-if="showDeleteModal"
      class="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4"
    >
      <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md p-6 transform transition-all">
        <div class="flex flex-col items-center text-center">
          <div
            class="w-14 h-14 bg-danger-500/10 rounded-full flex items-center justify-center mb-4"
          >
            <svg
              class="w-7 h-7 text-danger-500"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z"
              />
            </svg>
          </div>
          <h3 class="text-lg font-bold text-gray-900 mb-2">Eliminar Usuario</h3>
          <p class="text-sm text-gray-500 mb-6">
            ¿Estás seguro que deseas eliminar a
            <span class="font-semibold text-gray-700">{{ userToDelete?.name }}</span>
            ? Esta acción no se puede deshacer.
          </p>
          <div class="flex gap-3 w-full">
            <button
              class="flex-1 py-2.5 bg-danger-600 text-white font-semibold rounded-xl hover:bg-danger-700 transition text-sm"
              @click="confirmDelete"
            >
              Sí, Eliminar
            </button>
            <button
              class="flex-1 py-2.5 bg-gray-100 text-gray-700 font-semibold rounded-xl hover:bg-gray-200 transition text-sm"
              @click="closeDeleteModal"
            >
              Cancelar
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
