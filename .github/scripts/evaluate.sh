#!/bin/bash

# Directorios base
STUDENT_CODE_DIR="student_code/"
TEST_INPUT_BASE_DIR="test_cases/"
EXPECTED_OUTPUT_BASE_DIR="test_cases/"
ACTUAL_OUTPUT="student_code/output.txt"

# Verifica si se proporciona una actividad como argumento
if [ -z "$1" ]; then
    echo "Error: Debes especificar la actividad (por ejemplo, act1, act2)."
    exit 1
fi

ACTIVITY="$1"
STUDENT_ACTIVITY_DIR="${STUDENT_CODE_DIR}/${ACTIVITY}"
TEST_INPUT_DIR="${TEST_INPUT_BASE_DIR}/${ACTIVITY}"
EXPECTED_OUTPUT_DIR="${EXPECTED_OUTPUT_BASE_DIR}/${ACTIVITY}"

# Busca automáticamente el archivo cpp del estudiante
STUDENT_CODE=$(find $STUDENT_ACTIVITY_DIR -name "*.cpp" | head -n 1)

# Verifica que el archivo cpp del estudiante exista
if [ -z "$STUDENT_CODE" ]; then
    echo "Error: No se encontró un archivo .cpp en el directorio ${STUDENT_ACTIVITY_DIR}"
    exit 1
fi

# Compilar el código del estudiante
g++ "$STUDENT_CODE" -o "${STUDENT_ACTIVITY_DIR}/student_program"
if [ $? -ne 0 ]; then
    echo "Error: Fallo en la compilación."
    exit 1
fi

# Ejecutar el programa del estudiante con cada caso de prueba
for input_file in "$TEST_INPUT_DIR"/*.txt; do
    base_name=$(basename "$input_file" .txt)
    expected_output_file="${EXPECTED_OUTPUT_DIR}/output${base_name}.txt"
    
    # Ejecutar el programa y capturar la salida
    "${STUDENT_ACTIVITY_DIR}/student_program" < "$input_file" > "$ACTUAL_OUTPUT"
    
    # Comparar el resultado con el esperado
    if diff -q "$ACTUAL_OUTPUT" "$expected_output_file" > /dev/null; then
        echo "Test ${base_name}: OK"
    else
        echo "Test ${base_name}: Falló"
        diff "$ACTUAL_OUTPUT" "$expected_output_file"
    fi
done