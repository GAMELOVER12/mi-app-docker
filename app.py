def calcular_metricas(numeros):
    """Calcula métricas básicas"""
    if not numeros:
        return {"error": "Lista vacía"}
    
    return {
        "suma": sum(numeros),
        "promedio": sum(numeros) / len(numeros),
        "maximo": max(numeros),
        "minimo": min(numeros),
        "total": len(numeros)
    }

if __name__ == "__main__":
    datos = [10, 20, 30, 40, 50]
    resultado = calcular_metricas(datos)
    print("\n📊 RESULTADOS:")
    for k, v in resultado.items():
        print(f"  {k}: {v}")
