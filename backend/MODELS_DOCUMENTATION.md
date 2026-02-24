# Documentación de Modelos Django - Sistema IBV

## Descripción General
Este documento describe los modelos de datos del Sistema de Gestión de Importación de Vehículos (IBV). Los modelos están diseñados para gestionar el flujo completo de vehículos desde su arribo en buques hasta su despacho final.

---

## Modelos de Usuarios

### User
**Tabla:** `users_user`

Modelo de usuario personalizado basado en `AbstractBaseUser`.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| email | EmailField | Email único del usuario (USERNAME_FIELD) |
| first_name | CharField | Nombre del usuario |
| last_name | CharField | Apellido del usuario |
| role | CharField | Rol del usuario (admin, porteria, recibidor, inventario, despachador, cliente) |
| is_active | BooleanField | Indica si el usuario está activo |
| is_staff | BooleanField | Indica si el usuario puede acceder al admin |
| is_superuser | BooleanField | Indica si el usuario es superusuario |
| date_joined | DateTimeField | Fecha y hora de creación |

**Métodos destacados:**
- `create_user()` - Crear usuario regular
- `create_superuser()` - Crear usuario administrador

---

### Role
**Tabla:** `users_role`

Gestión de roles y permisos del sistema.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| nombre | CharField | Nombre único del rol |
| permisos | JSONField | Lista de permisos asociados (ej: ["crear_usuario", "editar_usuario"]) |
| descripcion | TextField | Descripción del rol |
| creado_en | DateTimeField | Fecha de creación (automática) |
| actualizado_en | DateTimeField | Fecha de última actualización (automática) |

---

## Modelos de Buques y Vehículos

### Buque
**Tabla:** `users_buque`

Registro de los buques que arriban al puerto.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| identificacion | CharField | ID única del buque (IMO, nombre, etc.) |
| nombre | CharField | Nombre del buque |
| fecha_arribo | DateTimeField | Fecha y hora de arribo |
| procedencia | CharField | Puerto de origen |
| destino | CharField | Puerto de destino |
| cantidad_vehiculos | IntegerField | Cantidad de vehículos transportados |
| estado | CharField | Estado (activo, completado, cancelado) |
| creado_en | DateTimeField | Fecha de creación |
| actualizado_en | DateTimeField | Fecha de última actualización |

**Relaciones:** 
- Tiene muchos `Vehiculo`
- Tiene muchos `Despacho`

---

### ModeloVehiculo
**Tabla:** `users_modelovehiculo`

Tipos y modelos de vehículos.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| marca | CharField | Marca del vehículo (Toyota, Honda, BMW, etc.) |
| modelo | CharField | Modelo del vehículo (Corolla, Civic, X5, etc.) |
| año | IntegerField | Año de fabricación |
| tipo | CharField | Tipo (auto, camioneta, camión, moto) |
| creado_en | DateTimeField | Fecha de creación |

**Restricción única:** `(marca, modelo, año)` - No puede haber duplicados

**Relaciones:**
- Tiene muchos `Vehiculo`

---

### Vehiculo
**Tabla:** `users_vehiculo`

Registro de vehículos individuales.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| bin | CharField | Número BIN único del vehículo |
| qr_code | CharField | Código QR único para identificación rápida |
| buque | ForeignKey | Referencia al buque que lo transporta |
| modelo | ForeignKey | Referencia al modelo del vehículo |
| color | CharField | Color del vehículo |
| estado | CharField | Estado (ingresado, en_transito, en_porteria, en_inventario, despachado, recibido) |
| notas | TextField | Notas adicionales sobre el vehículo |
| fecha_registro | DateTimeField | Fecha de registro (automática) |
| actualizado_en | DateTimeField | Fecha de última actualización |

**Índices para optimización:**
- Estado
- Buque

**Relaciones:**
- Tiene una `Impronta`
- Tiene un `Inventario`
- Tiene muchos `Despacho` (a través de `DespachoVehiculo`)
- Tiene muchos `MovimientoPorteria`
- Tiene muchos `Recibo`

---

## Modelos de Procesos

### Impronta
**Tabla:** `users_impronta`

Registro de la toma de fotos/datos técnicos de vehículos (1:1 con Vehiculo).

| Campo | Tipo | Descripción |
|-------|------|-------------|
| vehiculo | OneToOneField | Referencia única al vehículo |
| foto_url | URLField | URL de la foto del vehículo |
| datos | JSONField | Datos técnicos de la fotogrametría (flexible) |
| usuario | ForeignKey | Usuario que realizó la impronta |
| estado | CharField | Estado (pendiente, completada, fallida) |
| observaciones | TextField | Observaciones del proceso |
| fecha | DateTimeField | Fecha de creación (automática) |

---

### Inventario
**Tabla:** `users_inventario`

Registro de inventario/checklist de vehículos (1:1 con Vehiculo).

| Campo | Tipo | Descripción |
|-------|------|-------------|
| vehiculo | OneToOneField | Referencia única al vehículo |
| checklist_json | JSONField | JSON con ítems del checklist y su estado |
| completo | BooleanField | Indica si el inventario está completo |
| usuario | ForeignKey | Usuario que realizó el inventario |
| observaciones | TextField | Observaciones adicionales |
| fecha | DateTimeField | Fecha de creación (automática) |
| actualizado_en | DateTimeField | Fecha de última actualización |

---

### Despacho
**Tabla:** `users_despacho`

Registro de despachos de vehículos.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| fecha | DateTimeField | Fecha de creación del despacho (automática) |
| usuario | ForeignKey | Usuario que realizó el despacho |
| buque | ForeignKey | Buque asociado (opcional) |
| cantidad_vehiculos | IntegerField | Cantidad de vehículos despachados |
| estado | CharField | Estado (pendiente, en_proceso, completado, cancelado) |
| observaciones | TextField | Observaciones del despacho |

**Relaciones:**
- Tiene muchos `DespachoVehiculo`
- Tiene muchos `Recibo`

---

### DespachoVehiculo
**Tabla:** `users_despachovehi`

Relación M2M entre Despacho y Vehiculo con orden de escaneo.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| despacho | ForeignKey | Referencia al despacho |
| vehiculo | ForeignKey | Referencia al vehículo |
| orden_escaneo | IntegerField | Orden en que se escaneó el vehículo |
| timestamp | DateTimeField | Timestamp del registro (automático) |

**Restricción única:** `(despacho, vehiculo)` - No puede repetirse el mismo vehículo en un despacho

---

### MovimientoPorteria
**Tabla:** `users_movimientoporteria`

Registro de movimientos de vehículos en portería.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| tipo | CharField | Tipo de movimiento (entrada, salida, transferencia) |
| vehiculo | ForeignKey | Referencia al vehículo |
| persona | CharField | Nombre de la persona responsable |
| usuario | ForeignKey | Usuario que registró el movimiento |
| observaciones | TextField | Observaciones del movimiento |
| fecha | DateTimeField | Fecha de creación (automática) |

---

### Recibo
**Tabla:** `users_recibo`

Registro de recibos de entrega/recepción de vehículos.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| vehiculo | ForeignKey | Referencia al vehículo |
| despacho | ForeignKey | Referencia al despacho |
| datos_json | JSONField | Datos del recibo (destino, cliente, etc.) |
| usuario | ForeignKey | Usuario que generó el recibo |
| estado | CharField | Estado (pendiente, recibido, cancelado) |
| observaciones | TextField | Observaciones del recibo |
| fecha | DateTimeField | Fecha de creación (automática) |

---

## Flujo de datos típico

```
1. Buque arriba al puerto
   ↓
2. Vehículos se registran en el sistema (Vehiculo)
   ↓
3. Impronta: Se toman fotos/datos del vehículo
   ↓
4. Inventario: Se realiza checklist del vehículo
   ↓
5. MovimientoPorteria: Se registran movimientos entrada/salida
   ↓
6. Despacho: Se crea despacho y se asignan vehículos
   ↓
7. DespachoVehiculo: Se registra orden de escaneo
   ↓
8. Recibo: Se genera comprobante de entrega/recepción
```

---

## Acceso a los datos

### Crear un registro
```python
from users.models import Vehiculo, Buque, ModeloVehiculo

# Crear vehículo
vehiculo = Vehiculo.objects.create(
    bin="BIN12345",
    qr_code="QR-001",
    buque=buque_instance,
    modelo=modelo_instance,
    color="Rojo"
)
```

### Consultar datos
```python
# Filtrar vehículos por estado
veh_ingresados = Vehiculo.objects.filter(estado="ingresado")

# Acceder a datos relacionados
buque = vehiculo.buque
modelo = vehiculo.modelo
```

### Actualizar datos
```python
vehiculo.estado = "despachado"
vehiculo.save()
```

---

## Admin Django
Todos los modelos están registrados en Django Admin en `/admin/` con interfaces personalizadas para facilitar la gestión de datos.

**Usuarios con acceso:** Usuarios con `is_staff=True`

---

Última actualización: 2026-02-24
