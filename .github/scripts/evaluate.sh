#!/bin/bash

# Directorios base
STUDENT_CODE_DIR="../student_code/"
TEST_INPUT_BASE_DIR="../test_cases/"
EXPECTED_OUTPUT_BASE_DIR="../test_cases/"
ACTUAL_OUTPUT="../student_code/output.txt"
RESULTS_FILE="../results.md"

HIDDEN_TEST_INPUT_BASE_DIR="/home/ubuntu/hidden_test_cases/"
HIDDEN_EXPECTED_OUTPUT_BASE_DIR="/home/ubuntu/hidden_test_cases/"

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

    HIDDEN_TEST_INPUT_DIR="${HIDDEN_TEST_INPUT_BASE_DIR}/${activity}/input"
    HIDDEN_EXPECTED_OUTPUT_DIR="${HIDDEN_EXPECTED_OUTPUT_BASE_DIR}/${activity}/output"

    # Busca automáticamente todos los archivos cpp y headers .h del estudiante
    STUDENT_CPP_FILES=$(find "$STUDENT_ACTIVITY_DIR" -name "*.cpp")

    # Verifica que existan archivos cpp
    if [ -z "$STUDENT_CPP_FILES" ]; then
        echo "Error: No se encontraron archivos .cpp en el directorio ${STUDENT_ACTIVITY_DIR}"
        echo "## Actividad: $activity" >> $RESULTS_FILE
        echo "Compilación fallida: No se encontraron archivos .cpp" >> $RESULTS_FILE
        echo "Total de pruebas: 0" >> $RESULTS_FILE
        echo "Pruebas pasadas: 0" >> $RESULTS_FILE
        echo "Promedio: 0%" >> $RESULTS_FILE
        echo "" >> $RESULTS_FILE
        continue
    fi

    # Compilar todos los archivos cpp del estudiante
    g++ $STUDENT_CPP_FILES -o "${STUDENT_ACTIVITY_DIR}/student_program.o"
    if [ $? -ne 0 ]; then
        echo "Error: Fallo en la compilación de $activity."
        echo "## Actividad: $activity" >> $RESULTS_FILE
        echo "Compilación fallida" >> $RESULTS_FILE
        echo "Total de pruebas: 0" >> $RESULTS_FILE
        echo "Pruebas pasadas: 0" >> $RESULTS_FILE
        echo "Promedio: 0%" >> $RESULTS_FILE
        echo "" >> $RESULTS_FILE
        continue
    fi

    # Inicializar conteo de pruebas pasadas
    total_tests=0
    passed_tests=0

    # Verifica que el directorio de pruebas visibles exista
    if [ -d "$TEST_INPUT_DIR" ]; then
        # Ejecutar el programa del estudiante con cada caso de prueba visible
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
    else
        echo "No se encontraron pruebas visibles para la actividad: $activity"
    fi

    # Verifica que el directorio de pruebas ocultas exista
    if [ -d "$HIDDEN_TEST_INPUT_DIR" ]; then
        # Ejecutar el programa del estudiante con cada caso de prueba oculto
        for hidden_input_file in "$HIDDEN_TEST_INPUT_DIR"/*.txt; do
            base_name=$(basename "$hidden_input_file" .txt)
            expected_output_file="${HIDDEN_EXPECTED_OUTPUT_DIR}/output_${base_name}.txt"
            
            # Ejecutar el programa y capturar la salida
            "${STUDENT_ACTIVITY_DIR}/student_program.o" < "$hidden_input_file" > "$ACTUAL_OUTPUT"
            
            # Comparar el resultado con el esperado
            if diff -q "$ACTUAL_OUTPUT" "$expected_output_file" > /dev/null; then
                echo "Hidden Test ${base_name}: OK"
                passed_tests=$((passed_tests + 1))
            else
                echo "Hidden Test ${base_name}: Falló"
                diff "$ACTUAL_OUTPUT" "$expected_output_file"
            fi

            total_tests=$((total_tests + 1))
        done
    else
        echo "No se encontraron pruebas ocultas para la actividad: $activity"
    fi

    # Guardar los resultados en results.md
    echo "## Actividad: $activity" >> $RESULTS_FILE
    echo "Total de pruebas: $total_tests" >> $RESULTS_FILE
    echo "Pruebas pasadas: $passed_tests" >> $RESULTS_FILE
    echo "Promedio: $(( (passed_tests * 100) / total_tests ))%" >> $RESULTS_FILE
    echo "" >> $RESULTS_FILE
done
