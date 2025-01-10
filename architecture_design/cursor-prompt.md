# Prompt para Generación de Código en Cursor

Necesito crear una aplicación Flutter usando Clean Architecture y el enfoque Feature First para un sistema de finanzas personales. La aplicación implementará la metodología de 6 jarras de T. Harv Eker.

## Tecnologías y Dependencias

- Flutter última versión estable
- Riverpod para state management
- Go Router para navegación
- Supabase para backend
- Powersync para sincronización offline
- Clean Architecture
- Feature First approach

## Estructura del Proyecto

La aplicación debe seguir una estructura Feature First con Clean Architecture:

```
lib/
├── core/
│   ├── errors/
│   ├── routing/
│   └── utils/
├── features/
│   ├── auth/
│   ├── accounts/
│   ├── jars/
│   ├── transactions/
│   └── reports/
└── shared/
    ├── data/
    ├── domain/
    └── presentation/
```

## Requerimientos Específicos

1. La aplicación debe implementar offline-first usando Powersync
2. Usar Supabase para autenticación y base de datos
3. Implementar sistema de jarras con porcentajes predefinidos
4. Soportar múltiples monedas con MXN como base
5. Manejar transacciones recurrentes
6. Incluir sistema de notificaciones
7. Permitir exportación de datos a Excel
8. Implementar análisis y reportes
9. Diseño responsive para web y móvil

## Detalles de Implementación

### Porcentajes de Jarras
- NECESIDADES: 55%
- INVERSION_LP: 10%
- AHORRO: 10%
- EDUCACION: 10%
- OCIO: 10%
- DONACIONES: 5%

### Funcionalidades Principales
1. Registro de ingresos con distribución automática
2. Registro de gastos con validación de saldo
3. Transferencias entre jarras y cuentas
4. Manejo de transacciones recurrentes
5. Sistema de notificaciones push
6. Reportes y análisis de cumplimiento
7. Exportación de datos

### UI/UX
1. Combinar bottom navigation bar y drawer
2. Dashboard principal con balances
3. Botón flotante para acciones rápidas
4. Indicadores de sincronización
5. Diseño adaptativo multiplataforma

## Instrucciones de Generación

1. Configurar proyecto Flutter con las dependencias necesarias
2. Implementar estructura base siguiendo Clean Architecture
3. Configurar conexión con Supabase y Powersync
4. Implementar features en orden de prioridad:
   - Auth
   - Accounts/Jars
   - Transactions
   - Reports

## Consideraciones Importantes

- Priorizar la simplicidad manteniendo buenas prácticas
- Asegurar código modular y reutilizable
- Implementar manejo adecuado de errores
- Incluir documentación inline
- Seguir principios SOLID
- Mantener separación clara de responsabilidades

## Flujos de Datos

### Registro de Ingreso
1. Usuario ingresa monto y categoría
2. Sistema valida datos
3. Distribuye automáticamente en jarras
4. Sincroniza cuando hay conexión

### Registro de Gasto
1. Usuario selecciona categoría y monto
2. Sistema valida saldo en jarra
3. Registra transacción si hay fondos
4. Actualiza balances
5. Sincroniza cuando hay conexión

### Transferencias
1. Usuario selecciona origen y destino
2. Sistema valida saldo
3. Ejecuta transferencia
4. Registra movimiento
5. Sincroniza cuando hay conexión

## Testing

Incluir tests para:
1. Lógica de negocio
2. Casos de uso
3. Providers
4. Widgets principales
5. Integración con Supabase/Powersync

## Documentación

Incluir documentación para:
1. Configuración del proyecto
2. Estructura de archivos
3. Patrones implementados
4. Flujos principales
5. Manejo de estado

## Prioridades de Implementación

1. Estructura base y configuración
2. Autenticación y perfil
3. Gestión de jarras y cuentas
4. Transacciones básicas
5. Sincronización offline
6. Reportes y análisis
7. Funcionalidades adicionales

## Validaciones Importantes

1. Saldos suficientes
2. Datos requeridos
3. Formatos correctos
4. Estados de sincronización
5. Permisos de usuario

## Manejo de Errores

1. Errores de red
2. Errores de validación
3. Errores de sincronización
4. Errores de autenticación
5. Errores de permisos

Por favor, genera el código siguiendo estas especificaciones, priorizando la calidad y mantenibilidad del código.
