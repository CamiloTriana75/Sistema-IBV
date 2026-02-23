<script setup lang="ts">
import { ref, reactive } from 'vue'

definePageMeta({
  layout: 'admin',
  middleware: ['auth', 'admin'],
})

const showModal = ref(false)
const editingRole = ref<any>(null)

const roleForm = reactive({
  name: '',
  description: '',
  permissions: [] as string[],
})

const roleNames = ['Admin', 'Portería', 'Recibidor', 'Inventario', 'Despachador', 'Cliente']

const roles = ref([
  {
    id: 1,
    name: 'Administrador',
    usersCount: 2,
    headerBg: 'border-primary-100 bg-primary-50/30',
    iconBg: 'bg-primary-100 text-primary-600',
    icon: '<svg fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" /></svg>',
    permissions: [
      { key: 'users.manage', label: 'Gestionar usuarios', allowed: true },
      { key: 'roles.manage', label: 'Gestionar roles', allowed: true },
      { key: 'vehicles.manage', label: 'Gestionar vehículos', allowed: true },
      { key: 'reports.view', label: 'Ver reportes', allowed: true },
      { key: 'settings.manage', label: 'Configuración', allowed: true },
    ],
  },
  {
    id: 2,
    name: 'Portería',
    usersCount: 2,
    headerBg: 'border-warning-100 bg-warning-50/30',
    iconBg: 'bg-warning-500/10 text-warning-600',
    icon: '<svg fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z" /></svg>',
    permissions: [
      { key: 'gate.scan', label: 'Escanear QR', allowed: true },
      { key: 'gate.log', label: 'Ver registro', allowed: true },
      { key: 'vehicles.view', label: 'Ver vehículos', allowed: true },
      { key: 'reports.view', label: 'Ver reportes', allowed: false },
      { key: 'settings.manage', label: 'Configuración', allowed: false },
    ],
  },
  {
    id: 3,
    name: 'Recibidor',
    usersCount: 3,
    headerBg: 'border-success-100 bg-success-50/30',
    iconBg: 'bg-success-500/10 text-success-600',
    icon: '<svg fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path d="M12 4v16m8-8H4" /></svg>',
    permissions: [
      { key: 'vehicles.receive', label: 'Recibir vehículos', allowed: true },
      { key: 'vehicles.view', label: 'Ver vehículos', allowed: true },
      { key: 'imprint.create', label: 'Crear improntas', allowed: true },
      { key: 'reports.view', label: 'Ver reportes', allowed: false },
      { key: 'settings.manage', label: 'Configuración', allowed: false },
    ],
  },
  {
    id: 4,
    name: 'Inventario',
    usersCount: 2,
    headerBg: 'border-blue-100 bg-blue-50/30',
    iconBg: 'bg-blue-100 text-blue-600',
    icon: '<svg fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" /></svg>',
    permissions: [
      { key: 'inventory.inspect', label: 'Inspeccionar', allowed: true },
      { key: 'inventory.checklist', label: 'Completar checklist', allowed: true },
      { key: 'vehicles.view', label: 'Ver vehículos', allowed: true },
      { key: 'reports.view', label: 'Ver reportes', allowed: true },
      { key: 'settings.manage', label: 'Configuración', allowed: false },
    ],
  },
  {
    id: 5,
    name: 'Despachador',
    usersCount: 2,
    headerBg: 'border-purple-100 bg-purple-50/30',
    iconBg: 'bg-purple-100 text-purple-600',
    icon: '<svg fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path d="M13 7l5 5m0 0l-5 5m5-5H6" /></svg>',
    permissions: [
      { key: 'dispatch.create', label: 'Crear despachos', allowed: true },
      { key: 'dispatch.manage', label: 'Gestionar lotes', allowed: true },
      { key: 'vehicles.view', label: 'Ver vehículos', allowed: true },
      { key: 'reports.view', label: 'Ver reportes', allowed: true },
      { key: 'settings.manage', label: 'Configuración', allowed: false },
    ],
  },
  {
    id: 6,
    name: 'Cliente',
    usersCount: 1,
    headerBg: 'border-gray-100 bg-gray-50/30',
    iconBg: 'bg-gray-100 text-gray-600',
    icon: '<svg fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" /></svg>',
    permissions: [
      { key: 'vehicles.view.own', label: 'Ver sus vehículos', allowed: true },
      { key: 'dispatch.track', label: 'Rastrear despacho', allowed: true },
      { key: 'profile.edit', label: 'Editar perfil', allowed: true },
      { key: 'reports.view', label: 'Ver reportes', allowed: false },
      { key: 'settings.manage', label: 'Configuración', allowed: false },
    ],
  },
])

const permissionGroups = {
  Usuarios: [
    { key: 'users.view', label: 'Ver usuarios', roles: ['Admin'] },
    { key: 'users.create', label: 'Crear usuarios', roles: ['Admin'] },
    { key: 'users.edit', label: 'Editar usuarios', roles: ['Admin'] },
    { key: 'users.delete', label: 'Eliminar usuarios', roles: ['Admin'] },
  ],
  Vehículos: [
    {
      key: 'vehicles.view',
      label: 'Ver vehículos',
      roles: ['Admin', 'Portería', 'Recibidor', 'Inventario', 'Despachador'],
    },
    { key: 'vehicles.receive', label: 'Recibir vehículos', roles: ['Admin', 'Recibidor'] },
    { key: 'vehicles.imprint', label: 'Crear improntas', roles: ['Admin', 'Recibidor'] },
    { key: 'vehicles.inspect', label: 'Inspeccionar', roles: ['Admin', 'Inventario'] },
  ],
  Despacho: [
    { key: 'dispatch.create', label: 'Crear despachos', roles: ['Admin', 'Despachador'] },
    { key: 'dispatch.manage', label: 'Gestionar lotes', roles: ['Admin', 'Despachador'] },
    {
      key: 'dispatch.track',
      label: 'Rastrear despacho',
      roles: ['Admin', 'Despachador', 'Cliente'],
    },
  ],
  Portería: [
    { key: 'gate.scan', label: 'Escanear QR', roles: ['Admin', 'Portería'] },
    { key: 'gate.log', label: 'Ver registro de movimientos', roles: ['Admin', 'Portería'] },
    { key: 'gate.authorize', label: 'Autorizar salida', roles: ['Admin', 'Portería'] },
  ],
  Sistema: [
    { key: 'reports.view', label: 'Ver reportes', roles: ['Admin', 'Inventario', 'Despachador'] },
    { key: 'reports.export', label: 'Exportar reportes', roles: ['Admin'] },
    { key: 'settings.manage', label: 'Configuración del sistema', roles: ['Admin'] },
    { key: 'audit.view', label: 'Ver auditoría', roles: ['Admin'] },
  ],
}

const editablePermissions = {
  Usuarios: [
    { key: 'users.view', label: 'Ver' },
    { key: 'users.create', label: 'Crear' },
    { key: 'users.edit', label: 'Editar' },
    { key: 'users.delete', label: 'Eliminar' },
  ],
  Vehículos: [
    { key: 'vehicles.view', label: 'Ver' },
    { key: 'vehicles.receive', label: 'Recibir' },
    { key: 'vehicles.imprint', label: 'Improntar' },
    { key: 'vehicles.inspect', label: 'Inspeccionar' },
  ],
  Despacho: [
    { key: 'dispatch.create', label: 'Crear' },
    { key: 'dispatch.manage', label: 'Gestionar' },
    { key: 'dispatch.track', label: 'Rastrear' },
  ],
  Portería: [
    { key: 'gate.scan', label: 'Escanear QR' },
    { key: 'gate.log', label: 'Ver registro' },
    { key: 'gate.authorize', label: 'Autorizar' },
  ],
  Sistema: [
    { key: 'reports.view', label: 'Ver reportes' },
    { key: 'reports.export', label: 'Exportar' },
    { key: 'settings.manage', label: 'Configuración' },
    { key: 'audit.view', label: 'Auditoría' },
  ],
}

const openCreateRole = () => {
  editingRole.value = null
  roleForm.name = ''
  roleForm.description = ''
  roleForm.permissions = []
  showModal.value = true
}

const editRole = (role: any) => {
  editingRole.value = role
  roleForm.name = role.name
  roleForm.description = ''
  roleForm.permissions = role.permissions.filter((p: any) => p.allowed).map((p: any) => p.key)
  showModal.value = true
}

const toggleModule = (module: string, event: Event) => {
  const checked = (event.target as HTMLInputElement).checked
  const perms = (editablePermissions as any)[module]
  if (checked) {
    perms.forEach((p: any) => {
      if (!roleForm.permissions.includes(p.key)) roleForm.permissions.push(p.key)
    })
  } else {
    roleForm.permissions = roleForm.permissions.filter(
      (k: string) => !perms.some((p: any) => p.key === k)
    )
  }
}

const saveRole = () => {
  console.log('Saving role:', roleForm)
  showModal.value = false
}
</script>

<template>
  <div>
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
      <div>
        <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Roles y Permisos</h1>
        <p class="text-gray-500 mt-1">Configura los niveles de acceso para cada rol del sistema</p>
      </div>
      <button
        class="inline-flex items-center gap-2 px-5 py-2.5 bg-primary-600 text-white text-sm font-semibold rounded-xl hover:bg-primary-700 transition-all shadow-lg shadow-primary-500/25"
        @click="openCreateRole"
      >
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M12 4v16m8-8H4"
          />
        </svg>
        Nuevo Rol
      </button>
    </div>

    <!-- Roles Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6 mb-8">
      <div
        v-for="role in roles"
        :key="role.id"
        class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden hover:shadow-md transition-shadow"
      >
        <!-- Role Header -->
        <div :class="['px-6 py-4 border-b', role.headerBg]">
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-3">
              <div :class="['w-10 h-10 rounded-lg flex items-center justify-center', role.iconBg]">
                <span class="w-5 h-5" v-html="role.icon" />
              </div>
              <div>
                <h3 class="font-bold text-gray-900">{{ role.name }}</h3>
                <p class="text-xs text-gray-500">{{ role.usersCount }} usuarios</p>
              </div>
            </div>
            <div class="flex gap-1">
              <button
                class="p-1.5 text-gray-400 hover:text-primary-600 hover:bg-primary-50 rounded-lg transition"
                @click="editRole(role)"
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
            </div>
          </div>
        </div>

        <!-- Permisos -->
        <div class="px-6 py-4">
          <p class="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-3">Permisos</p>
          <div class="space-y-2.5">
            <div
              v-for="perm in role.permissions"
              :key="perm.key"
              class="flex items-center justify-between"
            >
              <div class="flex items-center gap-2">
                <svg
                  v-if="perm.allowed"
                  class="w-4 h-4 text-success-500"
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
                <svg
                  v-else
                  class="w-4 h-4 text-gray-300"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
                <span :class="['text-sm', perm.allowed ? 'text-gray-700' : 'text-gray-400']">
                  {{ perm.label }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla de permisos detallada -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
      <div class="px-6 py-4 border-b border-gray-100">
        <h3 class="font-semibold text-gray-900">Matriz de Permisos</h3>
        <p class="text-sm text-gray-500 mt-0.5">Vista detallada de todos los permisos por rol</p>
      </div>
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 border-b border-gray-100">
            <tr>
              <th
                class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider min-w-[200px]"
              >
                Permiso
              </th>
              <th
                v-for="role in roleNames"
                :key="role"
                class="px-4 py-3 text-center text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                {{ role }}
              </th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-50">
            <template v-for="(group, groupName) in permissionGroups" :key="groupName">
              <!-- Group Header -->
              <tr class="bg-gray-50/50">
                <td :colspan="roleNames.length + 1" class="px-6 py-2">
                  <span class="text-xs font-bold text-gray-500 uppercase tracking-wider">
                    {{ groupName }}
                  </span>
                </td>
              </tr>
              <!-- Permissions -->
              <tr v-for="perm in group" :key="perm.key" class="hover:bg-gray-50 transition">
                <td class="px-6 py-3 text-sm text-gray-700">{{ perm.label }}</td>
                <td v-for="role in roleNames" :key="role" class="px-4 py-3 text-center">
                  <div class="flex justify-center">
                    <span
                      v-if="perm.roles.includes(role)"
                      class="w-6 h-6 bg-success-500/10 text-success-500 rounded-full flex items-center justify-center"
                    >
                      <svg
                        class="w-3.5 h-3.5"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="3"
                          d="M5 13l4 4L19 7"
                        />
                      </svg>
                    </span>
                    <span
                      v-else
                      class="w-6 h-6 bg-gray-100 text-gray-300 rounded-full flex items-center justify-center"
                    >
                      <svg
                        class="w-3.5 h-3.5"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="3"
                          d="M20 12H4"
                        />
                      </svg>
                    </span>
                  </div>
                </td>
              </tr>
            </template>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal Crear/Editar Rol -->
    <div
      v-if="showModal"
      class="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4"
    >
      <div
        class="bg-white rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-hidden flex flex-col"
      >
        <!-- Header -->
        <div class="flex items-center justify-between px-6 py-4 border-b border-gray-100">
          <div>
            <h2 class="text-lg font-bold text-gray-900">
              {{ editingRole ? 'Editar Rol' : 'Crear Nuevo Rol' }}
            </h2>
            <p class="text-sm text-gray-500 mt-0.5">Configura el nombre y los permisos del rol</p>
          </div>
          <button
            class="text-gray-400 hover:text-gray-600 transition p-1"
            @click="showModal = false"
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

        <!-- Body -->
        <div class="flex-1 overflow-y-auto px-6 py-5 space-y-6">
          <!-- Nombre del rol -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-1.5">Nombre del rol</label>
            <input
              v-model="roleForm.name"
              type="text"
              required
              placeholder="Ej: Supervisor"
              class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition text-sm"
            />
          </div>

          <!-- Descripción -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-1.5">Descripción</label>
            <textarea
              v-model="roleForm.description"
              rows="2"
              placeholder="Describe las responsabilidades de este rol"
              class="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition text-sm resize-none"
            />
          </div>

          <!-- Permisos por módulo -->
          <div>
            <p class="text-sm font-semibold text-gray-700 mb-3">Permisos</p>
            <div class="space-y-4">
              <div
                v-for="(perms, module) in editablePermissions"
                :key="module"
                class="border border-gray-200 rounded-xl overflow-hidden"
              >
                <div class="bg-gray-50 px-4 py-2.5 border-b border-gray-200">
                  <div class="flex items-center justify-between">
                    <span class="text-sm font-semibold text-gray-700">{{ module }}</span>
                    <label class="flex items-center gap-2 cursor-pointer">
                      <input
                        type="checkbox"
                        class="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
                        @change="toggleModule(module, $event)"
                      />
                      <span class="text-xs text-gray-500">Todos</span>
                    </label>
                  </div>
                </div>
                <div class="px-4 py-3 grid grid-cols-2 gap-2">
                  <label
                    v-for="perm in perms"
                    :key="perm.key"
                    class="flex items-center gap-2 cursor-pointer py-1"
                  >
                    <input
                      v-model="roleForm.permissions"
                      :value="perm.key"
                      type="checkbox"
                      class="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
                    />
                    <span class="text-sm text-gray-600">{{ perm.label }}</span>
                  </label>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Footer -->
        <div class="px-6 py-4 border-t border-gray-100 flex gap-3">
          <button
            class="flex-1 py-2.5 bg-primary-600 text-white font-semibold rounded-xl hover:bg-primary-700 transition text-sm"
            @click="saveRole"
          >
            {{ editingRole ? 'Guardar Cambios' : 'Crear Rol' }}
          </button>
          <button
            class="px-6 py-2.5 bg-gray-100 text-gray-700 font-semibold rounded-xl hover:bg-gray-200 transition text-sm"
            @click="showModal = false"
          >
            Cancelar
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
