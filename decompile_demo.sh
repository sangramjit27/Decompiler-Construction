#!/bin/bash

echo " [1] Writing sample C code to file..."
cat <<EOF > sample.c
#include <stdio.h>

int square(int x) {
    return x * x;
}

int main() {
    int result = square(5);
    printf("Result: %d\\n", result);
    return 0;
}
EOF

echo " [2] Compiling sample.c into executable..."
gcc -m32 -o sample sample.c

if [[ -f "sample" ]]; then
    echo " [3] Running the compiled executable..."
    ./sample > orig.txt
    cat orig.txt

    echo " [4] Decompiling using RetDec (EXE version)..."
    retdec_path="/c/Users/hp/Downloads/RetDec-v5.0-Windows-Release/bin/retdec-decompiler.exe"
    win_path_sample=$(cygpath -w sample)
    $retdec_path --output sample.c.decompiled.c "$win_path_sample"

    if [[ -f "sample.c.decompiled.c" ]]; then
        echo " [5] Cleaning decompiled code..."
        grep -Pzo "(?s)int square\(int x\).*?\}.*?int main\(.*?\{.*?\}" sample.c.decompiled.c | tr -d '\0' > sample_clean.c

        # Add missing includes
        sed -i '1i#include <stdio.h>' sample_clean.c

        echo " [6] Compiling cleaned decompiled code..."
        gcc -m32 -o sample_re sample_clean.c -Wl,--subsystem,console



        if [[ -f "sample_re" ]]; then
            echo " [7] Running recompiled version..."
            ./sample_re > decomp.txt

            echo " [8] Comparing original and decompiled outputs..."
            diff orig.txt decomp.txt || echo "❗ Outputs differ."
        
        fi
    else
        echo "❌ Decompiled file not found. Skipping recompilation."
    fi
else
    echo "❌ Compilation failed."
fi

echo "✅ Demo complete."


