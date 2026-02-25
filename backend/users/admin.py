from django.contrib import admin
from django.contrib.auth.admin import UserAdmin

from .models import (
    User,
    Role,
    Buque,
    ModeloVehiculo,
    Vehiculo,
    Impronta,
    Inventario,
    Despacho,
    DespachoVehiculo,
    MovimientoPorteria,
    Recibo,
)


@admin.register(User)
class CustomUserAdmin(UserAdmin):
    model = User
    ordering = ("email",)
    list_display = ("email", "first_name", "last_name", "role", "is_staff", "is_active")
    search_fields = ("email", "first_name", "last_name")
    filter_horizontal = ()
    fieldsets = (
        (None, {"fields": ("email", "password")}),
        ("Personal info", {"fields": ("first_name", "last_name", "role")}),
        (
            "Permissions",
            {
                "fields": (
                    "is_active",
                    "is_staff",
                    "is_superuser",
                )
            },
        ),
        ("Important dates", {"fields": ("last_login",)}),
    )
    add_fieldsets = (
        (
            None,
            {
                "classes": ("wide",),
                "fields": (
                    "email",
                    "password1",
                    "password2",
                    "role",
                    "is_staff",
                    "is_active",
                ),
            },
        ),
    )


@admin.register(Role)
class RoleAdmin(admin.ModelAdmin):
    list_display = ("nombre", "descripcion", "creado_en")
    search_fields = ("nombre",)
    readonly_fields = ("creado_en", "actualizado_en")
    fieldsets = (
        ("Información básica", {"fields": ("nombre", "descripcion")}),
        ("Permisos", {"fields": ("permisos",)}),
        ("Auditoría", {"fields": ("creado_en", "actualizado_en")}),
    )


@admin.register(Buque)
class BuqueAdmin(admin.ModelAdmin):
    list_display = (
        "nombre",
        "identificacion",
        "fecha_arribo",
        "cantidad_vehiculos",
        "estado",
    )
    search_fields = ("nombre", "identificacion")
    list_filter = ("estado", "fecha_arribo")
    readonly_fields = ("creado_en", "actualizado_en")
    fieldsets = (
        ("Información básica", {"fields": ("nombre", "identificacion")}),
        ("Detalles del viaje", {"fields": ("fecha_arribo", "procedencia", "destino")}),
        ("Estado", {"fields": ("estado", "cantidad_vehiculos")}),
        ("Auditoría", {"fields": ("creado_en", "actualizado_en")}),
    )


@admin.register(ModeloVehiculo)
class ModeloVehiculoAdmin(admin.ModelAdmin):
    list_display = ("marca", "modelo", "año", "tipo")
    search_fields = ("marca", "modelo")
    list_filter = ("tipo", "año")
    readonly_fields = ("creado_en",)


@admin.register(Vehiculo)
class VehiculoAdmin(admin.ModelAdmin):
    list_display = ("bin", "qr_code", "modelo", "buque", "estado", "fecha_registro")
    search_fields = ("bin", "qr_code")
    list_filter = ("estado", "buque", "fecha_registro")
    readonly_fields = ("fecha_registro", "actualizado_en")
    fieldsets = (
        ("Identificación", {"fields": ("bin", "qr_code")}),
        ("Detalles del vehículo", {"fields": ("modelo", "color")}),
        ("Ubicación", {"fields": ("buque",)}),
        ("Estado", {"fields": ("estado",)}),
        ("Observaciones", {"fields": ("notas",)}),
        ("Auditoría", {"fields": ("fecha_registro", "actualizado_en")}),
    )


@admin.register(Impronta)
class ImprontaAdmin(admin.ModelAdmin):
    list_display = ("vehiculo", "usuario", "fecha", "estado")
    search_fields = ("vehiculo__bin",)
    list_filter = ("estado", "fecha")
    readonly_fields = ("fecha",)
    fieldsets = (
        ("Información del vehículo", {"fields": ("vehiculo",)}),
        ("Foto y datos", {"fields": ("foto_url", "datos")}),
        ("Usuario", {"fields": ("usuario",)}),
        ("Estado", {"fields": ("estado",)}),
        ("Observaciones", {"fields": ("observaciones",)}),
        ("Auditoría", {"fields": ("fecha",)}),
    )


@admin.register(Inventario)
class InventarioAdmin(admin.ModelAdmin):
    list_display = ("vehiculo", "usuario", "completo", "fecha")
    search_fields = ("vehiculo__bin",)
    list_filter = ("completo", "fecha")
    readonly_fields = ("fecha", "actualizado_en")
    fieldsets = (
        ("Vehículo", {"fields": ("vehiculo",)}),
        ("Checklist", {"fields": ("checklist_json", "completo")}),
        ("Usuario", {"fields": ("usuario",)}),
        ("Observaciones", {"fields": ("observaciones",)}),
        ("Auditoría", {"fields": ("fecha", "actualizado_en")}),
    )


@admin.register(Despacho)
class DespachoAdmin(admin.ModelAdmin):
    list_display = ("id", "fecha", "usuario", "cantidad_vehiculos", "estado")
    list_filter = ("estado", "fecha", "buque")
    search_fields = ("usuario__email",)
    readonly_fields = ("fecha",)
    fieldsets = (
        ("Información del despacho", {"fields": ("fecha", "usuario", "buque")}),
        ("Estado", {"fields": ("estado", "cantidad_vehiculos")}),
        ("Observaciones", {"fields": ("observaciones",)}),
    )


class DespachoVehiculoInline(admin.TabularInline):
    model = DespachoVehiculo
    extra = 1
    readonly_fields = ("timestamp",)


@admin.register(DespachoVehiculo)
class DespachoVehiculoAdmin(admin.ModelAdmin):
    list_display = ("despacho", "vehiculo", "orden_escaneo")
    search_fields = ("vehiculo__bin", "despacho__id")
    list_filter = ("despacho__fecha",)
    readonly_fields = ("timestamp",)


@admin.register(MovimientoPorteria)
class MovimientoPorteriaAdmin(admin.ModelAdmin):
    list_display = ("tipo", "vehiculo", "persona", "usuario", "fecha")
    search_fields = ("vehiculo__bin", "persona")
    list_filter = ("tipo", "fecha")
    readonly_fields = ("fecha",)
    fieldsets = (
        ("Movimiento", {"fields": ("tipo", "vehiculo")}),
        ("Responsables", {"fields": ("persona", "usuario")}),
        ("Observaciones", {"fields": ("observaciones",)}),
        ("Auditoría", {"fields": ("fecha",)}),
    )


@admin.register(Recibo)
class ReciboAdmin(admin.ModelAdmin):
    list_display = ("id", "vehiculo", "fecha", "estado", "usuario")
    search_fields = ("vehiculo__bin",)
    list_filter = ("estado", "fecha")
    readonly_fields = ("fecha",)
    fieldsets = (
        ("Información", {"fields": ("vehiculo", "despacho", "usuario")}),
        ("Datos del recibo", {"fields": ("datos_json",)}),
        ("Estado", {"fields": ("estado",)}),
        ("Observaciones", {"fields": ("observaciones",)}),
        ("Auditoría", {"fields": ("fecha",)}),
    )
