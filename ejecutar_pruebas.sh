#!/bin/bash

echo "════════════════════════════════════════"
echo "🧪 EJECUTANDO PRUEBAS Y MÉTRICAS"
echo "════════════════════════════════════════"

# Verificar que pytest está instalado
if ! python3 -c "import pytest" 2>/dev/null; then
    echo "❌ pytest no está instalado. Instalando..."
    pip3 install pytest pytest-cov --user
fi

# 1. Ejecutar pruebas básicas
echo ""
echo "📝 1. PRUEBAS UNITARIAS"
echo "────────────────────────────────────────"
python3 -m pytest test_app.py -v

# 2. Calcular cobertura
echo ""
echo "📊 2. MÉTRICAS DE COBERTURA"
echo "────────────────────────────────────────"
python3 -m pytest test_app.py --cov=app --cov-report=term

# 3. Ver detalles de líneas no cubiertas
echo ""
echo "🔍 3. DETALLE DE COBERTURA"
echo "────────────────────────────────────────"
python3 -m pytest test_app.py --cov=app --cov-report=term-missing 2>/dev/null | grep -A 50 "TOTAL"

# 4. Generar reporte HTML
echo ""
echo "🌐 4. GENERANDO REPORTE HTML"
echo "────────────────────────────────────────"
python3 -m pytest test_app.py --cov=app --cov-report=html

echo ""
echo "✅ Reporte generado en: htmlcov/index.html"
echo "════════════════════════════════════════"
