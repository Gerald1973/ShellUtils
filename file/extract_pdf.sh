#!/bin/bash
usage() {
    cat <<EOF
PDF Page Extractor Utility
--------------------------
Usage:
  $(basename "$0") <filename_or_pattern> <start_page> <end_page>

Arguments:
  filename_or_pattern  The name of the file or a pattern (e.g., "TANGO_FACTURE_*.pdf")
  start_page           The first page to extract (starting at 1)
  end_page             The last page to extract (inclusive)

Example:
  $(basename "$0") "TANGO_FACTURE_*.pdf" 1 3
  $(basename "$0") document.pdf 5 10

Note: Use quotes around patterns with '*' to avoid shell expansion issues.
EOF
    exit 1
}

# 1. Vérification des paramètres
if [ "$#" -ne 3 ]; then
    usage
fi

PATTERN=$1
START=$2
END=$3

if ! [[ "$START" =~ ^[0-9]+$ ]] || ! [[ "$END" =~ ^[0-9]+$ ]]; then
    echo "Error: Page numbers must be integers."
    exit 1
fi

# 3. Vérification de la présence de qpdf
if ! command -v qpdf &> /dev/null; then
    echo "Error: qpdf is not installed. Run 'sudo apt install qpdf'."
    exit 1
fi


found=false

for f in $PATTERN; do
    
    if [ -f "$f" ]; then
        found=true
        output_name="${f%.pdf}_p${START}-p${END}.pdf"
        
        echo "Processing: $f -> $output_name"
        
        qpdf "$f" --pages . "$START-$END" -- "$output_name"
        
        if [ $? -eq 0 ]; then
            echo "Successfully extracted pages $START to $END."
        else
            echo "Error processing $f (check if pages exist)."
        fi
        echo "---"
    fi
done

if [ "$found" = false ]; then
    echo "Error: No files found matching '$PATTERN'."
    exit 1
fi