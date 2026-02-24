from django.contrib.auth.models import (
    AbstractBaseUser,
    BaseUserManager,
    PermissionsMixin,
)
from django.db import models
from django.utils import timezone

ROLE_CHOICES = [
    ("admin", "Administrador"),
    ("porteria", "Porteria"),
    ("recibidor", "Recibidor"),
    ("inventario", "Inventario"),
    ("despachador", "Despachador"),
    ("cliente", "Cliente"),
]

PERMISSION_CHOICES = [
    ("crear_usuario", "Crear usuario"),
    ("editar_usuario", "Editar usuario"),
    ("eliminar_usuario", "Eliminar usuario"),
    ("ver_usuario", "Ver usuario"),
    ("crear_buque", "Crear buque"),
    ("editar_buque", "Editar buque"),
    ("crear_vehiculo", "Crear vehículo"),
    ("escanear_vehiculo", "Escanear vehículo"),
]

VEHICLE_STATE_CHOICES = [
    ("ingresado", "Ingresado"),
    ("en_transito", "En tránsito"),
    ("en_porteria", "En portería"),
    ("en_inventario", "En inventario"),
    ("despachado", "Despachado"),
    ("recibido", "Recibido"),
]

DISPATCH_STATE_CHOICES = [
    ("pendiente", "Pendiente"),
    ("en_proceso", "En proceso"),
    ("completado", "Completado"),
    ("cancelado", "Cancelado"),
]

MOVEMENT_TYPE_CHOICES = [
    ("entrada", "Entrada"),
    ("salida", "Salida"),
    ("transferencia", "Transferencia"),
]

FINGERPRINT_STATE_CHOICES = [
    ("pendiente", "Pendiente"),
    ("completada", "Completada"),
    ("fallida", "Fallida"),
]


class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError("El email es obligatorio")
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        extra_fields.setdefault("is_active", True)

        if extra_fields.get("is_staff") is not True:
            raise ValueError("El superusuario debe tener is_staff=True")
        if extra_fields.get("is_superuser") is not True:
            raise ValueError("El superusuario debe tener is_superuser=True")

        return self.create_user(email, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    email = models.EmailField(unique=True)
    first_name = models.CharField(max_length=150, blank=True)
    last_name = models.CharField(max_length=150, blank=True)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default="cliente")
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    date_joined = models.DateTimeField(default=timezone.now)

    objects = UserManager()

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = []

    def __str__(self):
        return self.email

    class Meta:
        db_table = "users_user"
        verbose_name = "Usuario"
        verbose_name_plural = "Usuarios"


class Role(models.Model):
    """Modelo para gestionar roles y permisos"""

    nombre = models.CharField(max_length=100, unique=True)
    permisos = models.JSONField(
        default=list, blank=True, help_text="Lista de permisos asociados al rol"
    )
    descripcion = models.TextField(blank=True)
    creado_en = models.DateTimeField(auto_now_add=True)
    actualizado_en = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.nombre

    class Meta:
        db_table = "users_role"
        verbose_name = "Rol"
        verbose_name_plural = "Roles"


class Buque(models.Model):
    """Modelo para los buques que arriban al puerto"""

    identificacion = models.CharField(
        max_length=100,
        unique=True,
        help_text="Identificación única del buque (IMO, nombre, etc.)",
    )
    nombre = models.CharField(max_length=200)
    fecha_arribo = models.DateTimeField()
    procedencia = models.CharField(max_length=200, blank=True)
    destino = models.CharField(max_length=200, blank=True)
    cantidad_vehiculos = models.IntegerField(default=0)
    estado = models.CharField(
        max_length=20,
        choices=[
            ("activo", "Activo"),
            ("completado", "Completado"),
            ("cancelado", "Cancelado"),
        ],
        default="activo",
    )
    creado_en = models.DateTimeField(auto_now_add=True)
    actualizado_en = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.nombre} ({self.identificacion})"

    class Meta:
        db_table = "users_buque"
        verbose_name = "Buque"
        verbose_name_plural = "Buques"
        ordering = ["-fecha_arribo"]


class ModeloVehiculo(models.Model):
    """Modelo para los tipos/modelos de vehículos"""

    marca = models.CharField(max_length=100)
    modelo = models.CharField(max_length=100)
    año = models.IntegerField()
    tipo = models.CharField(
        max_length=50,
        choices=[
            ("auto", "Automóvil"),
            ("camioneta", "Camioneta"),
            ("camion", "Camión"),
            ("moto", "Motocicleta"),
        ],
    )
    creado_en = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.marca} {self.modelo} ({self.año})"

    class Meta:
        db_table = "users_modelovehiculo"
        verbose_name = "Modelo de Vehículo"
        verbose_name_plural = "Modelos de Vehículos"
        unique_together = ("marca", "modelo", "año")


class Vehiculo(models.Model):
    """Modelo para los vehículos registrados"""

    bin = models.CharField(max_length=50, unique=True, verbose_name="BIN")
    qr_code = models.CharField(max_length=255, unique=True, verbose_name="Código QR")
    buque = models.ForeignKey(Buque, on_delete=models.PROTECT, related_name="vehiculos")
    modelo = models.ForeignKey(
        ModeloVehiculo, on_delete=models.PROTECT, related_name="vehiculos"
    )
    color = models.CharField(max_length=50)
    estado = models.CharField(
        max_length=20, choices=VEHICLE_STATE_CHOICES, default="ingresado"
    )
    fecha_registro = models.DateTimeField(auto_now_add=True)
    actualizado_en = models.DateTimeField(auto_now=True)
    notas = models.TextField(blank=True)

    def __str__(self):
        return f"{self.bin} - {self.modelo}"

    class Meta:
        db_table = "users_vehiculo"
        verbose_name = "Vehículo"
        verbose_name_plural = "Vehículos"
        indexes = [
            models.Index(fields=["estado"]),
            models.Index(fields=["buque"]),
        ]


class Impronta(models.Model):
    """Modelo para las improntas (toma de fotos) de vehículos"""

    vehiculo = models.OneToOneField(
        Vehiculo, on_delete=models.CASCADE, related_name="impronta"
    )
    foto_url = models.URLField()
    datos = models.JSONField(
        default=dict, blank=True, help_text="Datos técnicos de la impronta"
    )
    usuario = models.ForeignKey(
        User, on_delete=models.PROTECT, related_name="improntas"
    )
    fecha = models.DateTimeField(auto_now_add=True)
    estado = models.CharField(
        max_length=20, choices=FINGERPRINT_STATE_CHOICES, default="pendiente"
    )
    observaciones = models.TextField(blank=True)

    def __str__(self):
        return f"Impronta - {self.vehiculo.bin}"

    class Meta:
        db_table = "users_impronta"
        verbose_name = "Impronta"
        verbose_name_plural = "Improntas"


class Inventario(models.Model):
    """Modelo para el inventario de vehículos"""

    vehiculo = models.OneToOneField(
        Vehiculo, on_delete=models.CASCADE, related_name="inventario"
    )
    checklist_json = models.JSONField(
        default=dict, help_text="JSON con los ítems del checklist y su estado"
    )
    completo = models.BooleanField(default=False)
    usuario = models.ForeignKey(
        User, on_delete=models.PROTECT, related_name="inventarios"
    )
    fecha = models.DateTimeField(auto_now_add=True)
    actualizado_en = models.DateTimeField(auto_now=True)
    observaciones = models.TextField(blank=True)

    def __str__(self):
        return f"Inventario - {self.vehiculo.bin}"

    class Meta:
        db_table = "users_inventario"
        verbose_name = "Inventario"
        verbose_name_plural = "Inventarios"


class Despacho(models.Model):
    """Modelo para los despachos de vehículos"""

    fecha = models.DateTimeField(auto_now_add=True)
    usuario = models.ForeignKey(
        User,
        on_delete=models.PROTECT,
        related_name="despachos",
        help_text="Usuario que realizó el despacho",
    )
    cantidad_vehiculos = models.IntegerField(default=0)
    estado = models.CharField(
        max_length=20, choices=DISPATCH_STATE_CHOICES, default="pendiente"
    )
    buque = models.ForeignKey(
        Buque, on_delete=models.PROTECT, null=True, blank=True, related_name="despachos"
    )
    observaciones = models.TextField(blank=True)

    def __str__(self):
        return f"Despacho {self.id} - {self.fecha.strftime('%Y-%m-%d %H:%M')}"

    class Meta:
        db_table = "users_despacho"
        verbose_name = "Despacho"
        verbose_name_plural = "Despachos"
        ordering = ["-fecha"]


class DespachoVehiculo(models.Model):
    """Modelo para la relación entre despachos y vehículos"""

    despacho = models.ForeignKey(
        Despacho, on_delete=models.CASCADE, related_name="vehiculos"
    )
    vehiculo = models.ForeignKey(
        Vehiculo, on_delete=models.PROTECT, related_name="despachos"
    )
    orden_escaneo = models.IntegerField(help_text="Orden en que se escaneó el vehículo")
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.despacho.id} - {self.vehiculo.bin}"

    class Meta:
        db_table = "users_despachovehi"
        verbose_name = "Vehículo en Despacho"
        verbose_name_plural = "Vehículos en Despacho"
        unique_together = ("despacho", "vehiculo")


class MovimientoPorteria(models.Model):
    """Modelo para registrar movimientos en portería"""

    tipo = models.CharField(max_length=20, choices=MOVEMENT_TYPE_CHOICES)
    vehiculo = models.ForeignKey(
        Vehiculo, on_delete=models.PROTECT, related_name="movimientos_porteria"
    )
    persona = models.CharField(
        max_length=200, help_text="Persona responsable del movimiento"
    )
    usuario = models.ForeignKey(
        User, on_delete=models.PROTECT, related_name="movimientos_porteria"
    )
    fecha = models.DateTimeField(auto_now_add=True)
    observaciones = models.TextField(blank=True)

    def __str__(self):
        return f"{self.tipo} - {self.vehiculo.bin} - {self.fecha.strftime('%Y-%m-%d %H:%M')}"

    class Meta:
        db_table = "users_movimientoporteria"
        verbose_name = "Movimiento Portería"
        verbose_name_plural = "Movimientos Portería"
        ordering = ["-fecha"]


class Recibo(models.Model):
    """Modelo para los recibos de entrega/recepción de vehículos"""

    vehiculo = models.ForeignKey(
        Vehiculo, on_delete=models.PROTECT, related_name="recibos"
    )
    despacho = models.ForeignKey(
        Despacho, on_delete=models.PROTECT, related_name="recibos"
    )
    datos_json = models.JSONField(
        default=dict, help_text="Datos del recibo (destino, cliente, etc.)"
    )
    fecha = models.DateTimeField(auto_now_add=True)
    usuario = models.ForeignKey(User, on_delete=models.PROTECT, related_name="recibos")
    estado = models.CharField(
        max_length=20,
        choices=[
            ("pendiente", "Pendiente"),
            ("recibido", "Recibido"),
            ("cancelado", "Cancelado"),
        ],
        default="pendiente",
    )
    observaciones = models.TextField(blank=True)

    def __str__(self):
        return f"Recibo {self.id} - {self.vehiculo.bin}"

    class Meta:
        db_table = "users_recibo"
        verbose_name = "Recibo"
        verbose_name_plural = "Recibos"
        ordering = ["-fecha"]
