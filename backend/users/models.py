from django.contrib.auth.models import (
    AbstractBaseUser,
    BaseUserManager,
    Group,
    Permission,
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
    password = models.CharField(
        "password",
        max_length=128,
        db_column="contrasena",
    )
    last_login = models.DateTimeField(
        blank=True,
        null=True,
        verbose_name="last login",
        db_column="ultimo_ingreso",
    )
    is_superuser = models.BooleanField(
        default=False,
        help_text=(
            "Designates that this user has all permissions without "
            "explicitly assigning them."
        ),
        verbose_name="superuser status",
        db_column="es_superusuario",
    )
    email = models.EmailField(unique=True, db_column="correo")
    first_name = models.CharField(max_length=150, blank=True, db_column="nombres")
    last_name = models.CharField(max_length=150, blank=True, db_column="apellidos")
    role = models.CharField(
        max_length=20,
        choices=ROLE_CHOICES,
        default="cliente",
        db_column="rol",
    )
    is_active = models.BooleanField(default=True, db_column="activo")
    is_staff = models.BooleanField(default=False, db_column="es_personal")
    date_joined = models.DateTimeField(
        default=timezone.now,
        db_column="fecha_registro",
    )

    groups = models.ManyToManyField(
        Group,
        blank=True,
        help_text=(
            "The groups this user belongs to. A user will get all permissions "
            "granted to each of their groups."
        ),
        related_name="user_set",
        related_query_name="user",
        verbose_name="groups",
        db_table="usuarios_grupos",
    )
    user_permissions = models.ManyToManyField(
        Permission,
        blank=True,
        help_text="Specific permissions for this user.",
        related_name="user_set",
        related_query_name="user",
        verbose_name="user permissions",
        db_table="usuarios_permisos",
    )

    objects = UserManager()

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = []

    class Meta:
        db_table = "usuarios"

    def __str__(self):
        return self.email
