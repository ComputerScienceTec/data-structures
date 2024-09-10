#!/bin/bash

# Directorios base
STUDENT_CODE_DIR="../student_code/"
TEST_INPUT_BASE_DIR="../test_cases/"
EXPECTED_OUTPUT_BASE_DIR="../test_cases/"
ACTUAL_OUTPUT="../student_code/output.txt"
RESULTS_FILE="../results.md"

# Inicializar el archivo de resultados
echo "# Resultados de Evaluación" > $RESULTS_FILE
echo "" >> $RESULTS_FILE

# Recorre todas las actividades detectadas en el directorio student_code
for activity_dir in $(find $STUDENT_CODE_DIR -mindepth 1 -maxdepth 1 -type d); do
    activity=$(basename $activity_dir)
    echo "Evaluando actividad: $activity"

    STUDENT_ACTIVITY_DIR="${STUDENT_CODE_DIR}/${activity}"
    TEST_INPUT_DIR="${TEST_INPUT_BASE_DIR}/${activity}/input"
    EXPECTED_OUTPUT_DIR="${EXPECTED_OUTPUT_BASE_DIR}/${activity}/output"

    # Busca automáticamente el archivo cpp del estudiante
    STUDENT_CODE=$(find $STUDENT_ACTIVITY_DIR -name "*.cpp" | head -n 1)

    # Verifica que el archivo cpp del estudiante exista
    if [ -z "$STUDENT_CODE" ]; then
        echo "Error: No se encontró un archivo .cpp en el directorio ${STUDENT_ACTIVITY_DIR}"
        continue
    fi

    # Compilar el código del estudiante
    g++ "$STUDENT_CODE" -o "${STUDENT_ACTIVITY_DIR}/student_program.o"
    if [ $? -ne 0 ]; then
        echo "Error: Fallo en la compilación de $activity."
        echo "## Actividad: $activity" >> $RESULTS_FILE
        echo "Compilación fallida" >> $RESULTS_FILE
        echo "" >> $RESULTS_FILE
        continue
    fi

    # Inicializar conteo de pruebas pasadas
    total_tests=0
    passed_tests=0

    # Ejecutar el programa del estudiante con cada caso de prueba
    for input_file in "$TEST_INPUT_DIR"/*.txt; do
        base_name=$(basename "$input_file" .txt)
        expected_output_file="${EXPECTED_OUTPUT_DIR}/output_${base_name}.txt"
        
        # Ejecutar el programa y capturar la salida
        "${STUDENT_ACTIVITY_DIR}/student_program.o" < "$input_file" > "$ACTUAL_OUTPUT"
        
        # Comparar el resultado con el esperado
        if diff -q "$ACTUAL_OUTPUT" "$expected_output_file" > /dev/null; then
            echo "Test ${base_name}: OK"
            passed_tests=$((passed_tests + 1))
        else
            echo "Test ${base_name}: Falló"
            diff "$ACTUAL_OUTPUT" "$expected_output_file"
        fi

        total_tests=$((total_tests + 1))
    done

    # Guardar los resultados en results.md
    echo "## Actividad: $activity" >> $RESULTS_FILE
    echo "Total de pruebas: $total_tests" >> $RESULTS_FILE
    echo "Pruebas pasadas: $passed_tests" >> $RESULTS_FILE
    echo "Promedio: $(( (passed_tests * 100) / total_tests ))%" >> $RESULTS_FILE
    echo "" >> $RESULTS_FILE
done
