#ifndef RECTANGULO_H
#define RECTANGULO_H

class Rectangulo {
private:
    double largo;
    double ancho;

public:
    Rectangulo(double l, double a);  // Constructor
    double calcularArea();           // Método para calcular el área
    double calcularPerimetro();      // Método para calcular el perímetro
};

#endif
