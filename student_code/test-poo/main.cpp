#include <iostream>
#include "rectangulo.h"

int main() {
    double largo, ancho;
    
    // Leer los valores de largo y ancho desde la entrada estándar
    std::cin >> largo >> ancho;

    // Crear un objeto de tipo Rectangulo
    Rectangulo rect(largo, ancho);

    // Calcular el área y el perímetro
    double area = rect.calcularArea();
    double perimetro = rect.calcularPerimetro();

    // Imprimir los resultados
    std::cout << "Área: " << area << std::endl;
    std::cout << "Perímetro: " << perimetro << std::endl;

    return 0;
}
