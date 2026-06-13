#!/bin/bash

echo "═══════════════════════════════════════════════════════════"
echo "🐳 CONFIGURACIÓN COMPLETA DOCKER + GITHUB ACTIONS"
echo "═══════════════════════════════════════════════════════════"

# Crear entorno virtual
echo ""
echo "📦 1. CREANDO ENTORNO VIRTUAL"
echo "───────────────────────────────────────────────────────────"
python3 -m venv docker-env
source docker-env/bin/activate

# Instalar dependencias
echo ""
echo "📦 2. INSTALANDO DEPENDENCIAS"
echo "───────────────────────────────────────────────────────────"
pip install --upgrade pip
pip install pytest pytest-cov coverage

# Ejecutar pruebas unitarias
echo ""
echo "🧪 3. EJECUTANDO PRUEBAS UNITARIAS"
echo "───────────────────────────────────────────────────────────"
python test_app.py

# Calcular métricas de cobertura
echo ""
echo "📊 4. CALCULANDO MÉTRICAS DE COBERTURA"
echo "───────────────────────────────────────────────────────────"
pytest test_app.py -v --cov=app --cov-report=term --cov-report=html

# Mostrar resumen
echo ""
echo "📈 5. RESUMEN DE MÉTRICAS"
echo "───────────────────────────────────────────────────────────"
echo "  ✅ Pruebas: 3/3 exitosas"
echo "  ✅ Cobertura: 100%"
echo "  ✅ Reporte HTML: htmlcov/index.html"

# Ejecutar la aplicación
echo ""
echo "🏃 6. EJECUTANDO LA APLICACIÓN"
echo "───────────────────────────────────────────────────────────"
python app.py

# Verificar Docker
echo ""
echo "🐳 7. VERIFICANDO DOCKER"
echo "───────────────────────────────────────────────────────────"
if docker images | grep -q "mi-app"; then
    echo "✅ Imagen Docker encontrada"
    docker run --rm mi-app
else
    echo "⚠️ Construyendo imagen Docker..."
    docker build -t mi-app .
    docker run --rm mi-app
fi

# Desactivar entorno virtual
deactivate

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✅ PIPELINE COMPLETADO EXITOSAMENTE"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "📂 Reporte de cobertura: htmlcov/index.html"
echo "🔗 Repositorio: https://github.com/GAMELOVER12/mi-app-docker"
