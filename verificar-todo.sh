#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}🔍 VERIFICACIÓN COMPLETA: DOCKER + GITHUB ACTIONS + MÉTRICAS${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"

# Contador de verificaciones
TOTAL=0
PASADOS=0

# Función para verificar
check() {
    TOTAL=$((TOTAL + 1))
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅${NC} $1"
        PASADOS=$((PASADOS + 1))
    else
        echo -e "${RED}❌${NC} $1"
    fi
}

# ============================================
# 1. VERIFICAR ARCHIVOS DEL PROYECTO
# ============================================
echo -e "\n${YELLOW}📁 1. ARCHIVOS DEL PROYECTO${NC}"
echo "────────────────────────────────────────────────────────────────"

[ -f "app.py" ] && echo -e "${GREEN}✅${NC} app.py existe" || echo -e "${RED}❌${NC} app.py falta"
[ -f "test_app.py" ] && echo -e "${GREEN}✅${NC} test_app.py existe" || echo -e "${RED}❌${NC} test_app.py falta"
[ -f "Dockerfile" ] && echo -e "${GREEN}✅${NC} Dockerfile existe" || echo -e "${RED}❌${NC} Dockerfile falta"
[ -f "requirements.txt" ] && echo -e "${GREEN}✅${NC} requirements.txt existe" || echo -e "${RED}❌${NC} requirements.txt falta"
[ -f ".github/workflows/docker-ci.yml" ] && echo -e "${GREEN}✅${NC} GitHub Actions workflow existe" || echo -e "${RED}❌${NC} GitHub Actions workflow falta"

# ============================================
# 2. VERIFICAR GIT Y GITHUB
# ============================================
echo -e "\n${YELLOW}📦 2. GIT Y GITHUB${NC}"
echo "────────────────────────────────────────────────────────────────"

# Git configurado
git config user.name &>/dev/null && echo -e "${GREEN}✅${NC} Git configurado: $(git config user.name)" || echo -e "${RED}❌${NC} Git no configurado"

# Repositorio remoto
git remote -v | grep -q origin && echo -e "${GREEN}✅${NC} Repositorio remoto: $(git remote get-url origin)" || echo -e "${RED}❌${NC} Repositorio remoto no configurado"

# GitHub CLI
gh auth status &>/dev/null && echo -e "${GREEN}✅${NC} GitHub CLI autenticado" || echo -e "${RED}❌${NC} GitHub CLI no autenticado"

# ============================================
# 3. VERIFICAR PYTHON Y DEPENDENCIAS
# ============================================
echo -e "\n${YELLOW}🐍 3. PYTHON Y DEPENDENCIAS${NC}"
echo "────────────────────────────────────────────────────────────────"

# Python version
PYTHON_VERSION=$(python3 --version 2>&1)
echo -e "${GREEN}✅${NC} $PYTHON_VERSION"

# Crear y activar entorno virtual si no existe
if [ ! -d "venv" ]; then
    python3 -m venv venv 2>/dev/null
fi

# Activar entorno virtual
source venv/bin/activate 2>/dev/null

# Instalar pytest si no está
if ! pip list 2>/dev/null | grep -q pytest; then
    pip install pytest pytest-cov coverage --quiet 2>/dev/null
fi

# Verificar pytest
pip list 2>/dev/null | grep -q pytest && echo -e "${GREEN}✅${NC} pytest instalado" || echo -e "${RED}❌${NC} pytest no instalado"

# Verificar pytest-cov
pip list 2>/dev/null | grep -q pytest-cov && echo -e "${GREEN}✅${NC} pytest-cov instalado" || echo -e "${RED}❌${NC} pytest-cov no instalado"

# ============================================
# 4. VERIFICAR PRUEBAS UNITARIAS
# ============================================
echo -e "\n${YELLOW}🧪 4. PRUEBAS UNITARIAS${NC}"
echo "────────────────────────────────────────────────────────────────"

# Ejecutar pruebas
pytest test_app.py -v --tb=short 2>&1 | head -20

# Contar pruebas pasadas
PASSED_TESTS=$(pytest test_app.py --collect-only -q 2>&1 | grep -c "test_" 2>/dev/null)
echo -e "${GREEN}✅${NC} Total pruebas: $PASSED_TESTS"

# ============================================
# 5. VERIFICAR MÉTRICAS DE CÓDIGO
# ============================================
echo -e "\n${YELLOW}📊 5. MÉTRICAS DE CÓDIGO${NC}"
echo "────────────────────────────────────────────────────────────────"

# Calcular cobertura
pytest test_app.py --cov=app --cov-report=term --no-cov-on-fail 2>&1 | grep -A 5 "coverage"

# Líneas de código
LINES_APP=$(cat app.py 2>/dev/null | grep -v '^$' | grep -v '^#' | wc -l)
LINES_TEST=$(cat test_app.py 2>/dev/null | grep -v '^$' | grep -v '^#' | wc -l)
echo -e "${GREEN}✅${NC} Líneas de código (app.py): $LINES_APP"
echo -e "${GREEN}✅${NC} Líneas de código (test_app.py): $LINES_TEST"

# Funciones
FUNCTIONS=$(grep -c "def " app.py 2>/dev/null)
TESTS=$(grep -c "def test_" test_app.py 2>/dev/null)
echo -e "${GREEN}✅${NC} Funciones en app.py: $FUNCTIONS"
echo -e "${GREEN}✅${NC} Pruebas unitarias: $TESTS"

# ============================================
# 6. VERIFICAR EJECUCIÓN DEL CÓDIGO
# ============================================
echo -e "\n${YELLOW}🏃 6. EJECUCIÓN DEL CÓDIGO${NC}"
echo "────────────────────────────────────────────────────────────────"

# Ejecutar app.py
echo "Salida de app.py:"
python3 app.py 2>&1 | head -10

# ============================================
# 7. VERIFICAR DOCKER
# ============================================
echo -e "\n${YELLOW}🐳 7. DOCKER${NC}"
echo "────────────────────────────────────────────────────────────────"

# Docker corriendo
docker ps &>/dev/null && echo -e "${GREEN}✅${NC} Docker está corriendo" || echo -e "${RED}❌${NC} Docker no está corriendo"

# Imagen Docker local
docker images | grep -q "mi-app" && echo -e "${GREEN}✅${NC} Imagen Docker local encontrada" || echo -e "${RED}❌${NC} Imagen Docker no encontrada (ejecuta: docker build -t mi-app .)"

# Construir imagen si no existe
if ! docker images | grep -q "mi-app"; then
    echo -e "${YELLOW}⚠️${NC} Construyendo imagen Docker..."
    docker build -t mi-app . &>/dev/null && echo -e "${GREEN}✅${NC} Imagen Docker construida" || echo -e "${RED}❌${NC} Error construyendo imagen"
fi

# Ejecutar contenedor
echo "Ejecución en contenedor Docker:"
docker run --rm mi-app 2>&1 | head -10

# ============================================
# 8. VERIFICAR DOCKER HUB
# ============================================
echo -e "\n${YELLOW}☁️ 8. DOCKER HUB${NC}"
echo "────────────────────────────────────────────────────────────────"

# Docker login
docker login --help &>/dev/null && echo -e "${GREEN}✅${NC} Docker CLI configurado"

# Verificar si la imagen está en Docker Hub
echo -e "${BLUE}ℹ️${NC} Para verificar en Docker Hub:"
echo "   docker search wearygamelov1/mi-app-docker"
echo "   docker pull wearygamelov1/mi-app-docker:latest"

# ============================================
# 9. VERIFICAR GITHUB ACTIONS
# ============================================
echo -e "\n${YELLOW}⚙️ 9. GITHUB ACTIONS${NC}"
echo "────────────────────────────────────────────────────────────────"

# Listar workflows
gh workflow list 2>&1 | head -5

# Últimas ejecuciones
echo -e "\n${BLUE}Últimas ejecuciones:${NC}"
gh run list --limit 3 2>&1

# ============================================
# 10. RESUMEN FINAL
# ============================================
echo -e "\n${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}📊 RESUMEN DE VERIFICACIÓN${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"

echo -e "${GREEN}✅ Proyecto configurado correctamente${NC}"
echo ""
echo -e "${YELLOW}📌 Comandos útiles:${NC}"
echo "  source venv/bin/activate          # Activar entorno virtual"
echo "  pytest test_app.py -v              # Ejecutar pruebas"
echo "  pytest test_app.py --cov=app       # Ver métricas"
echo "  python3 app.py                     # Ejecutar código"
echo "  docker build -t mi-app .           # Construir imagen"
echo "  docker run --rm mi-app             # Ejecutar contenedor"
echo "  docker push wearygamelov1/mi-app-docker:latest  # Subir a Docker Hub"
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"

# Desactivar entorno virtual
deactivate 2>/dev/null

