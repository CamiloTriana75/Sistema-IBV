from django.test import TestCase
from django.utils import timezone
from django.contrib.auth import get_user_model
from django.db import IntegrityError

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

CustomUser = get_user_model()


class UserModelTestCase(TestCase):
    """Tests para el modelo User"""

    def setUp(self):
        self.user = User.objects.create_user(
            email="test@example.com",
            password="testpass123",
            first_name="Test",
            last_name="User",
            role="admin",
        )

    def test_user_creation(self):
        """Validar que se crea un usuario correctamente"""
        user = User.objects.get(email="test@example.com")
        self.assertEqual(user.first_name, "Test")
        self.assertEqual(user.last_name, "User")
        self.assertEqual(user.role, "admin")
        self.assertTrue(user.check_password("testpass123"))

    def test_user_str(self):
        """Validar representación en string del usuario"""
        self.assertEqual(str(self.user), "test@example.com")

    def test_superuser_creation(self):
        """Validar creación de superusuario"""
        admin = User.objects.create_superuser(
            email="admin@example.com", password="adminpass123"
        )
        self.assertTrue(admin.is_staff)
        self.assertTrue(admin.is_superuser)
        self.assertTrue(admin.is_active)


class RoleModelTestCase(TestCase):
    """Tests para el modelo Role"""

    def setUp(self):
        self.role = Role.objects.create(
            nombre="Editor",
            descripcion="Rol para editores del sistema",
            permisos=["crear_usuario", "editar_usuario"],
        )

    def test_role_creation(self):
        """Validar creación de rol"""
        role = Role.objects.get(nombre="Editor")
        self.assertEqual(role.descripcion, "Rol para editores del sistema")
        self.assertIn("crear_usuario", role.permisos)

    def test_role_str(self):
        """Validar representación en string del rol"""
        self.assertEqual(str(self.role), "Editor")


class BuqueModelTestCase(TestCase):
    """Tests para el modelo Buque"""

    def setUp(self):
        self.buque = Buque.objects.create(
            identificacion="SHIP001",
            nombre="MV Pacific",
            fecha_arribo=timezone.now(),
            procedencia="Shanghai",
            destino="Los Angeles",
            cantidad_vehiculos=150,
        )

    def test_buque_creation(self):
        """Validar creación de buque"""
        buque = Buque.objects.get(identificacion="SHIP001")
        self.assertEqual(buque.nombre, "MV Pacific")
        self.assertEqual(buque.cantidad_vehiculos, 150)
        self.assertEqual(buque.estado, "activo")

    def test_buque_str(self):
        """Validar representación en string del buque"""
        self.assertIn("MV Pacific", str(self.buque))
        self.assertIn("SHIP001", str(self.buque))


class ModeloVehiculoTestCase(TestCase):
    """Tests para el modelo ModeloVehiculo"""

    def setUp(self):
        self.modelo = ModeloVehiculo.objects.create(
            marca="Toyota", modelo="Corolla", año=2024, tipo="auto"
        )

    def test_modelo_creation(self):
        """Validar creación de modelo de vehículo"""
        modelo = ModeloVehiculo.objects.get(marca="Toyota")
        self.assertEqual(modelo.modelo, "Corolla")
        self.assertEqual(modelo.año, 2024)
        self.assertEqual(modelo.tipo, "auto")

    def test_modelo_str(self):
        """Validar representación en string"""
        self.assertEqual(str(self.modelo), "Toyota Corolla (2024)")

    def test_modelo_unique_together(self):
        """Validar que no se pueden crear duplicados"""
        with self.assertRaises(IntegrityError):
            ModeloVehiculo.objects.create(
                marca="Toyota", modelo="Corolla", año=2024, tipo="auto"
            )


class VehiculoTestCase(TestCase):
    """Tests para el modelo Vehiculo"""

    def setUp(self):
        self.buque = Buque.objects.create(
            identificacion="SHIP001", nombre="MV Pacific", fecha_arribo=timezone.now()
        )
        self.modelo = ModeloVehiculo.objects.create(
            marca="Honda", modelo="Civic", año=2023, tipo="auto"
        )
        self.vehiculo = Vehiculo.objects.create(
            bin="BIN12345",
            qr_code="QR-001",
            buque=self.buque,
            modelo=self.modelo,
            color="Rojo",
        )

    def test_vehiculo_creation(self):
        """Validar creación de vehículo"""
        vehiculo = Vehiculo.objects.get(bin="BIN12345")
        self.assertEqual(vehiculo.qr_code, "QR-001")
        self.assertEqual(vehiculo.color, "Rojo")
        self.assertEqual(vehiculo.estado, "ingresado")
        self.assertEqual(vehiculo.buque, self.buque)

    def test_vehiculo_str(self):
        """Validar representación en string"""
        self.assertIn("BIN12345", str(self.vehiculo))

    def test_vehiculo_estado_choices(self):
        """Validar estados disponibles del vehículo"""
        self.vehiculo.estado = "en_transito"
        self.vehiculo.save()
        self.assertEqual(self.vehiculo.estado, "en_transito")


class ImprontaTestCase(TestCase):
    """Tests para el modelo Impronta"""

    def setUp(self):
        self.user = User.objects.create_user(
            email="recibidor@example.com", password="pass123", role="recibidor"
        )
        self.buque = Buque.objects.create(
            identificacion="SHIP001", nombre="MV Pacific", fecha_arribo=timezone.now()
        )
        self.modelo = ModeloVehiculo.objects.create(
            marca="Ford", modelo="Focus", año=2023, tipo="auto"
        )
        self.vehiculo = Vehiculo.objects.create(
            bin="BIN54321",
            qr_code="QR-002",
            buque=self.buque,
            modelo=self.modelo,
            color="Azul",
        )
        self.impronta = Impronta.objects.create(
            vehiculo=self.vehiculo,
            foto_url="https://example.com/foto.jpg",
            usuario=self.user,
            datos={"fotogrametria": "completada"},
        )

    def test_impronta_creation(self):
        """Validar creación de impronta"""
        impronta = Impronta.objects.get(id=self.impronta.id)
        self.assertEqual(impronta.vehiculo, self.vehiculo)
        self.assertIn("fotogrametria", impronta.datos)
        self.assertEqual(impronta.estado, "pendiente")

    def test_impronta_str(self):
        """Validar representación en string"""
        self.assertIn("BIN54321", str(self.impronta))


class InventarioTestCase(TestCase):
    """Tests para el modelo Inventario"""

    def setUp(self):
        self.user = User.objects.create_user(
            email="inventario@example.com", password="pass123", role="inventario"
        )
        self.buque = Buque.objects.create(
            identificacion="SHIP001", nombre="MV Pacific", fecha_arribo=timezone.now()
        )
        self.modelo = ModeloVehiculo.objects.create(
            marca="Nissan", modelo="Altima", año=2023, tipo="auto"
        )
        self.vehiculo = Vehiculo.objects.create(
            bin="BIN99999",
            qr_code="QR-003",
            buque=self.buque,
            modelo=self.modelo,
            color="Negro",
        )
        self.inventario = Inventario.objects.create(
            vehiculo=self.vehiculo,
            usuario=self.user,
            checklist_json={"llantas": True, "bateria": True},
        )

    def test_inventario_creation(self):
        """Validar creación de inventario"""
        inventario = Inventario.objects.get(vehiculo=self.vehiculo)
        self.assertFalse(inventario.completo)
        self.assertIn("llantas", inventario.checklist_json)

    def test_inventario_update_completo(self):
        """Validar actualización del estado completo"""
        self.inventario.completo = True
        self.inventario.save()
        self.assertTrue(self.inventario.completo)


class DespachoTestCase(TestCase):
    """Tests para el modelo Despacho"""

    def setUp(self):
        self.user = User.objects.create_user(
            email="despachador@example.com", password="pass123", role="despachador"
        )
        self.buque = Buque.objects.create(
            identificacion="SHIP001", nombre="MV Pacific", fecha_arribo=timezone.now()
        )
        self.despacho = Despacho.objects.create(
            usuario=self.user, buque=self.buque, cantidad_vehiculos=10
        )

    def test_despacho_creation(self):
        """Validar creación de despacho"""
        despacho = Despacho.objects.get(id=self.despacho.id)
        self.assertEqual(despacho.usuario, self.user)
        self.assertEqual(despacho.cantidad_vehiculos, 10)
        self.assertEqual(despacho.estado, "pendiente")

    def test_despacho_estado_changes(self):
        """Validar cambios de estado"""
        self.despacho.estado = "en_proceso"
        self.despacho.save()
        self.assertEqual(self.despacho.estado, "en_proceso")


class DespachoVehiculoTestCase(TestCase):
    """Tests para el modelo DespachoVehiculo"""

    def setUp(self):
        self.user = User.objects.create_user(
            email="despachador2@example.com", password="pass123", role="despachador"
        )
        self.buque = Buque.objects.create(
            identificacion="SHIP002", nombre="MV Atlantic", fecha_arribo=timezone.now()
        )
        self.modelo = ModeloVehiculo.objects.create(
            marca="BMW", modelo="X5", año=2024, tipo="auto"
        )
        self.vehiculo = Vehiculo.objects.create(
            bin="BIN88888",
            qr_code="QR-004",
            buque=self.buque,
            modelo=self.modelo,
            color="Blanco",
        )
        self.despacho = Despacho.objects.create(usuario=self.user, buque=self.buque)
        self.despacho_vehiculo = DespachoVehiculo.objects.create(
            despacho=self.despacho, vehiculo=self.vehiculo, orden_escaneo=1
        )

    def test_despacho_vehiculo_creation(self):
        """Validar creación de relación"""
        dv = DespachoVehiculo.objects.get(id=self.despacho_vehiculo.id)
        self.assertEqual(dv.despacho, self.despacho)
        self.assertEqual(dv.vehiculo, self.vehiculo)
        self.assertEqual(dv.orden_escaneo, 1)


class MovimientoPorteriaTestCase(TestCase):
    """Tests para el modelo MovimientoPorteria"""

    def setUp(self):
        self.user = User.objects.create_user(
            email="porteria@example.com", password="pass123", role="porteria"
        )
        self.buque = Buque.objects.create(
            identificacion="SHIP003", nombre="MV Oceanic", fecha_arribo=timezone.now()
        )
        self.modelo = ModeloVehiculo.objects.create(
            marca="Tesla", modelo="Model S", año=2024, tipo="auto"
        )
        self.vehiculo = Vehiculo.objects.create(
            bin="BIN77777",
            qr_code="QR-005",
            buque=self.buque,
            modelo=self.modelo,
            color="Gris",
        )
        self.movimiento = MovimientoPorteria.objects.create(
            tipo="entrada",
            vehiculo=self.vehiculo,
            persona="Juan Pérez",
            usuario=self.user,
        )

    def test_movimiento_creation(self):
        """Validar creación de movimiento"""
        mov = MovimientoPorteria.objects.get(id=self.movimiento.id)
        self.assertEqual(mov.tipo, "entrada")
        self.assertEqual(mov.persona, "Juan Pérez")
        self.assertEqual(mov.vehiculo, self.vehiculo)


class ReciboTestCase(TestCase):
    """Tests para el modelo Recibo"""

    def setUp(self):
        self.user = User.objects.create_user(
            email="recibidor2@example.com", password="pass123", role="recibidor"
        )
        self.buque = Buque.objects.create(
            identificacion="SHIP004", nombre="MV Concordia", fecha_arribo=timezone.now()
        )
        self.modelo = ModeloVehiculo.objects.create(
            marca="Mercedes", modelo="C-Class", año=2024, tipo="auto"
        )
        self.vehiculo = Vehiculo.objects.create(
            bin="BIN66666",
            qr_code="QR-006",
            buque=self.buque,
            modelo=self.modelo,
            color="Plateado",
        )
        self.despacho = Despacho.objects.create(usuario=self.user, buque=self.buque)
        self.recibo = Recibo.objects.create(
            vehiculo=self.vehiculo,
            despacho=self.despacho,
            usuario=self.user,
            datos_json={"destino": "Miami", "cliente": "Cliente XYZ"},
        )

    def test_recibo_creation(self):
        """Validar creación de recibo"""
        recibo = Recibo.objects.get(id=self.recibo.id)
        self.assertEqual(recibo.vehiculo, self.vehiculo)
        self.assertEqual(recibo.estado, "pendiente")
        self.assertIn("destino", recibo.datos_json)

    def test_recibo_estado_update(self):
        """Validar actualización del estado de recibo"""
        self.recibo.estado = "recibido"
        self.recibo.save()
        self.assertEqual(self.recibo.estado, "recibido")
