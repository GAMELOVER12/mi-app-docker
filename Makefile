# Reemplazar el Makefile con la versión correcta
cat > Makefile << 'MAKEFILE'
.PHONY: help test build run clean all

help:
	@echo "Comandos disponibles:"
	@echo "  make test  - Ejecutar pruebas"
	@echo "  make build - Construir imagen Docker"
	@echo "  make run   - Ejecutar contenedor"
	@echo "  make clean - Limpiar recursos Docker"
	@echo "  make all   - Ejecutar todo el pipeline"

test:
	python3 test_app.py

build:
	docker build -t metricas-app .

run: build
	docker run --rm metricas-app

clean:
	docker system prune -f

all: test build run
	@echo "✅ Pipeline completado!"
MAKEFILE
