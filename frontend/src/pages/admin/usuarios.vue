<template>
  <div>
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-3xl font-bold">Gestión de Usuarios</h1>
      <button
        @click="openCreateModal"
        class="px-4 py-2 bg-success-500 text-white rounded-lg hover:bg-success-600 transition"
      >
        ➕ Nuevo usuario
      </button>
    </div>

    <!-- Tabla de usuarios -->
    <div class="bg-white rounded-lg shadow overflow-hidden">
      <table class="w-full">
        <thead class="bg-gray-100 border-b">
          <tr>
            <th class="px-6 py-3 text-left text-sm font-semibold text-gray-700">Nombre</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-gray-700">Email</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-gray-700">Rol</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-gray-700">Estado</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-gray-700">Acciones</th>
          </tr>
        </thead>
        <tbody class="divide-y">
          <tr v-for="user in users" :key="user.id" class="hover:bg-gray-50">
            <td class="px-6 py-4 text-sm text-gray-800">{{ user.name }}</td>
            <td class="px-6 py-4 text-sm text-gray-600">{{ user.email }}</td>
            <td class="px-6 py-4 text-sm">
              <span class="px-2 py-1 bg-blue-100 text-blue-800 rounded text-xs font-semibold">
                {{ user.role }}
              </span>
            </td>
            <td class="px-6 py-4 text-sm">
              <span
                :class="[
                  'px-2 py-1 rounded text-xs font-semibold',
                  user.status === 'active'
                    ? 'bg-green-100 text-green-800'
                    : 'bg-red-100 text-red-800'
                ]"
              >
                {{ user.status }}
              </span>
            </td>
            <td class="px-6 py-4 text-sm">
              <button
                @click="editUser(user)"
                class="text-blue-600 hover:text-blue-800 mr-3"
              >
                ✏️ Editar
              </button>
              <button
                @click="openDeleteModal(user)"
                class="text-red-600 hover:text-red-800"
              >
                🗑️ Eliminar
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Modal crear/editar usuario -->
    <div v-if="showModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h2 class="text-2xl font-bold mb-4">
          {{ editingUser ? 'Editar usuario' : 'Nuevo usuario' }}
        </h2>

        <form @submit.prevent="saveUser" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Nombre</label>
            <input
              v-model="form.name"
              type="text"
              required
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
            <input
              v-model="form.email"
              type="email"
              required
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Rol</label>
            <select
              v-model="form.role"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            >
              <option value="admin">Admin</option>
              <option value="porteria">Portería</option>
              <option value="recibidor">Recibidor</option>
              <option value="inventario">Inventario</option>
              <option value="despachador">Despachador</option>
              <option value="cliente">Cliente</option>
            </select>
          </div>

          <div>
            <label class="flex items-center">
              <input
                v-model="form.status"
                type="checkbox"
                value="active"
                class="rounded"
              />
              <span class="ml-2 text-sm text-gray-700">Activo</span>
            </label>
          </div>

          <div class="flex gap-2">
            <button
              type="submit"
              class="flex-1 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition"
            >
              Guardar
            </button>
            <button
              @click="closeModal"
              type="button"
              class="flex-1 px-4 py-2 bg-gray-300 text-gray-800 rounded-lg hover:bg-gray-400 transition"
            >
              Cancelar
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal confirmar eliminación -->
    <div v-if="showDeleteModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h2 class="text-2xl font-bold mb-4 text-danger-600">Confirmar eliminación</h2>
        <p class="text-gray-700 mb-6">
          ¿Estás seguro de que quieres eliminar a {{ userToDelete?.name }}?
        </p>
        <div class="flex gap-2">
          <button
            @click="confirmDelete"
            class="flex-1 px-4 py-2 bg-danger-600 text-white rounded-lg hover:bg-danger-700 transition"
          >
            Eliminar
          </button>
          <button
            @click="closeDeleteModal"
            class="flex-1 px-4 py-2 bg-gray-300 text-gray-800 rounded-lg hover:bg-gray-400 transition"
          >
            Cancelar
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useUserStore } from '~/stores/userStore'

const userStore = useUserStore()
const users = ref([])
const showModal = ref(false)
const showDeleteModal = ref(false)
const editingUser = ref(null)
const userToDelete = ref(null)
const form = ref({
  name: '',
  email: '',
  role: 'cliente',
  status: 'active'
})

onMounted(async () => {
  // Cargar usuarios
  await userStore.fetchUsers()
  users.value = userStore.users || []
})

const openCreateModal = () => {
  editingUser.value = null
  form.value = { name: '', email: '', role: 'cliente', status: 'active' }
  showModal.value = true
}

const editUser = (user: any) => {
  editingUser.value = user
  form.value = { ...user }
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  editingUser.value = null
}

const saveUser = async () => {
  try {
    if (editingUser.value) {
      await userStore.updateUser(editingUser.value.id, form.value)
    } else {
      await userStore.createUser(form.value)
    }
    users.value = userStore.users || []
    closeModal()
  } catch (error) {
    console.error('Error saving user:', error)
  }
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
  try {
    await userStore.deleteUser(userToDelete.value.id)
    users.value = userStore.users || []
    closeDeleteModal()
  } catch (error) {
    console.error('Error deleting user:', error)
  }
}
</script>
