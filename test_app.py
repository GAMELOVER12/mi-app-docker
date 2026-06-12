import unittest
from app import calcular_metricas

class TestMetricas(unittest.TestCase):
    
    def test_suma(self):
        resultado = calcular_metricas([1,2,3])
        self.assertEqual(resultado["suma"], 6)
    
    def test_promedio(self):
        resultado = calcular_metricas([10,20,30])
        self.assertEqual(resultado["promedio"], 20)
    
    def test_lista_vacia(self):
        resultado = calcular_metricas([])
        self.assertIn("error", resultado)

if __name__ == "__main__":
    unittest.main()
