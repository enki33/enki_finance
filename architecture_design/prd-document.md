# Product Requirements Document
## Sistema de Finanzas Personales con Metodología de 6 Jarras

### 1. Descripción General

#### 1.1 Propósito
Este sistema está diseñado para gestionar finanzas personales implementando la metodología de las 6 jarras de T. Harv Eker, permitiendo un control detallado de ingresos, gastos y la distribución del dinero según los porcentajes establecidos.

#### 1.2 Alcance
- Aplicación multiplataforma (Android y Web) desarrollada con Flutter
- Funcionamiento offline-first con sincronización
- Gestión completa de transacciones y transferencias
- Sistema de jarras con porcentajes predefinidos
- Reportes y análisis de cumplimiento

### 2. Arquitectura y Tecnologías

#### 2.1 Stack Tecnológico
- **Frontend**: Flutter
- **State Management**: Riverpod
- **Navegación**: Go Router
- **Backend**: Supabase
- **Sincronización Offline**: Powersync
- **Arquitectura**: Clean Architecture con enfoque Feature First

#### 2.2 Estructura del Proyecto
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

### 3. Requerimientos Funcionales

#### 3.1 Sistema de Jarras
- **Distribución de Ingresos**
  - NECESIDADES: 55%
  - INVERSION_LP: 10%
  - AHORRO: 10%
  - EDUCACION: 10%
  - OCIO: 10%
  - DONACIONES: 5%

- **Características**
  - Distribución automática de ingresos
  - Transferencias entre jarras permitidas
  - Registro histórico de transferencias
  - Análisis de cumplimiento de porcentajes

#### 3.2 Gestión de Transacciones
- Registro de ingresos y gastos
- Categorización por tipo y subcategoría
- Soporte para múltiples monedas (base: MXN)
- Manejo de tipos de cambio manual
- Validaciones de saldo disponible

#### 3.3 Transacciones Recurrentes
- Configuración de periodicidad (semanal, mensual, anual)
- Notificaciones configurables (default: 1 día antes)
- Confirmación requerida para ejecución
- Validación de saldo disponible

#### 3.4 Gestión de Períodos
- Períodos mensuales y anuales
- Cierre automático de períodos
- Apertura manual para ajustes
- Transferencia automática de saldos no utilizados

#### 3.5 Reportes y Análisis
- Dashboard principal con balances
- Análisis de cumplimiento de metodología
- Seguimiento de metas financieras
- Comparativas entre períodos
- Exportación de datos a Excel

### 4. Requerimientos Técnicos

#### 4.1 Sincronización
- Sincronización inmediata al recuperar conexión
- Indicadores visuales de estado de sincronización
- Manejo de conflictos priorizando Supabase
- Notificaciones de errores de sincronización

#### 4.2 Seguridad
- Autenticación mediante Supabase
- Estructura modular para futuras capas de seguridad
- Validaciones de integridad de datos
- Manejo seguro de datos offline

#### 4.3 Performance
- Optimización de consultas
- Manejo eficiente de memoria
- Caché de datos frecuentes
- Paginación donde sea necesario

### 5. Interfaz de Usuario

#### 5.1 Navegación
- Combinación de bottom navigation y drawer
- Acceso rápido a funciones principales
- Botón flotante para nuevas transacciones
- Dashboard como pantalla principal

#### 5.2 Componentes Principales
- Balance de cuentas y jarras
- Lista de transacciones pendientes
- Indicadores de cumplimiento
- Notificaciones y alertas

#### 5.3 Responsive Design
- Interfaces adaptativas
- Layouts optimizados por plataforma
- Reutilización máxima de componentes
- Validaciones específicas por plataforma

### 6. Notificaciones

#### 6.1 Sistema de Notificaciones
- Push notifications para eventos críticos
- Sección de historial de notificaciones
- Diferentes niveles de urgencia
- Configuración de preferencias

#### 6.2 Eventos a Notificar
- Transacciones recurrentes próximas
- Errores en transacciones
- Desviaciones significativas en jarras
- Problemas de sincronización

### 7. Gestión de Datos

#### 7.1 Persistencia
- Almacenamiento local con Powersync
- Sincronización con Supabase
- Exportación de datos en formato Excel
- Backup automático en la nube

#### 7.2 Migración y Actualizaciones
- Sistema de versiones de base de datos
- Migraciones automáticas
- Mantenimiento de integridad de datos
- Actualización de catálogos

### 8. Métricas y Análisis

#### 8.1 KPIs Principales
- Adherencia a porcentajes de jarras
- Cumplimiento de metas financieras
- Eficiencia en sincronización
- Uso de funcionalidades

#### 8.2 Reportes
- Estado de cuentas y jarras
- Histórico de transacciones
- Análisis de tendencias
- Proyecciones financieras

### 9. Mantenibilidad

#### 9.1 Código
- Documentación inline
- Tests unitarios y de integración
- Convenciones de código Flutter
- Separación clara de responsabilidades

#### 9.2 Configuración
- Variables de entorno
- Configuraciones por ambiente
- Toggles de características
- Parámetros de sistema

### 10. Roadmap de Implementación

#### Fase 1: Fundamentos
- Configuración del proyecto
- Implementación de autenticación
- Estructura base de datos
- UI/UX básica

#### Fase 2: Funcionalidades Core
- Sistema de jarras
- Gestión de transacciones
- Categorías y subcategorías
- Sincronización básica

#### Fase 3: Funcionalidades Avanzadas
- Transacciones recurrentes
- Reportes y análisis
- Notificaciones
- Exportación de datos

#### Fase 4: Optimización
- Performance
- UX avanzada
- Pruebas exhaustivas
- Preparación para producción
