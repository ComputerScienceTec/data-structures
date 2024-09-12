#include "rectangulo.h"

// Constructor de la clase
Rectangulo::Rectangulo(double l, double a) : largo(l), ancho(a) {}

// Método para calcular el área
double Rectangulo::calcularArea() {
    return largo * ancho;
}

// Método para calcular el perímetro
double Rectangulo::calcularPerimetro() {
    return 2 * (largo + ancho);
}
