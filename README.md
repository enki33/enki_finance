# Enki Finance

Sistema de finanzas personales que implementa la metodología de 6 jarras de T. Harv Eker.

## Características

- Implementación de la metodología de 6 jarras
- Soporte para múltiples monedas
- Transacciones recurrentes
- Sistema de notificaciones
- Reportes y análisis
- Exportación de datos

## Tecnologías

- Flutter
- Riverpod para state management
- Go Router para navegación
- Supabase para backend
- Clean Architecture
- Feature First approach

## Requisitos

- Flutter SDK (última versión estable)
- Dart SDK (última versión estable)
- Cuenta en Supabase

## Configuración

1. Clonar el repositorio:
```bash
git clone https://github.com/tu-usuario/enki_finance.git
cd enki_finance
```

2. Crear archivo `.env` en la raíz del proyecto:
```env
SUPABASE_URL=tu_url_de_supabase
SUPABASE_ANON_KEY=tu_clave_anonima_de_supabase
```

3. Instalar dependencias y generar código:
```bash
./setup.ps1  # Windows
./setup.sh   # Linux/Mac
```

4. Ejecutar la aplicación:
```bash
flutter run
```

## Estructura del Proyecto

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

## Distribución de Jarras

- NECESIDADES: 55%
- INVERSION_LP: 10%
- AHORRO: 10%
- EDUCACION: 10%
- OCIO: 10%
- DONACIONES: 5%

## Contribuir

1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

## Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## Contacto

Tu Nombre - [@tu_twitter](https://twitter.com/tu_twitter) - email@example.com

Link del Proyecto: [https://github.com/tu-usuario/enki_finance](https://github.com/tu-usuario/enki_finance)
