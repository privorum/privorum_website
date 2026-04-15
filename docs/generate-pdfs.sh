#!/usr/bin/env bash

#
# generate-pdfs.sh
#
# Converts all Markdown files in this directory to PDF using pandoc.
# Supports Mermaid diagrams - converts them to PNG images before PDF generation.
# If a PDF already exists, it is renamed with a timestamp before generating the new one.
#
# Requirements:
#   - pandoc (https://pandoc.org/installing.html)
#   - pdflatex (texlive-latex-base)
#   - mermaid-cli (npm install -g @mermaid-js/mermaid-cli) - optional, for diagrams
#
# Usage:
#   ./generate-pdfs.sh           # Convert all .md files
#   ./generate-pdfs.sh file.md   # Convert a specific file
#   ./generate-pdfs.sh --no-diagrams file.md  # Skip mermaid conversion
#

# Change to the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$SCRIPT_DIR"

# Timestamp for renaming duplicates
timestamp=$(date +"%Y%m%d_%H%M%S")

# Counters
converted=0
failed=0
diagrams_converted=0

# Options
SKIP_DIAGRAMS=false

# Check if pandoc is installed
if ! command -v pandoc &> /dev/null; then
    echo "Error: pandoc is not installed."
    echo "Install with: brew install pandoc (macOS) or apt-get install pandoc (Ubuntu)"
    exit 1
fi

# Check if mermaid-cli is installed
MMDC_AVAILABLE=false
if command -v mmdc &> /dev/null; then
    MMDC_AVAILABLE=true
fi

# Create temp directory for diagram processing
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Replace Unicode characters that pdflatex cannot render (box-drawing, emoji, etc.)
sanitize_unicode() {
    local input_file="$1"
    local output_file="$2"
    sed \
        -e 's/│/|/g' \
        -e 's/┌/+/g' -e 's/┐/+/g' -e 's/└/+/g' -e 's/┘/+/g' \
        -e 's/├/+/g' -e 's/┤/+/g' -e 's/┬/+/g' -e 's/┴/+/g' -e 's/┼/+/g' \
        -e 's/─/-/g' -e 's/═/=/g' \
        -e 's/▼/v/g' -e 's/▲/^/g' -e 's/▶/>/g' -e 's/►/>/g' -e 's/◀/</g' -e 's/◄/</g' \
        -e 's/•/*/g' -e 's/·/./g' \
        -e 's/✅/[x]/g' -e 's/✓/[x]/g' -e 's/✗/[ ]/g' -e 's/❌/[!]/g' \
        -e 's/→/->/g' -e 's/←/<-/g' -e 's/↑/^/g' -e 's/↓/v/g' -e 's/↔/<->/g' \
        -e 's/⚠️/[!]/g' -e 's/⚠/[!]/g' \
        -e 's/—/--/g' -e 's/–/-/g' \
        -e 's/≤/<=/g' -e 's/≥/>=/g' -e 's/±/+\/-/g' -e 's/×/x/g' \
        -e 's/█/#/g' -e 's/░/./g' \
        -e 's/μ/u/g' -e 's/µ/u/g' \
        -e 's/🧠/(brain)/g' -e 's/📝/(note)/g' -e 's/⏱/(timer)/g' \
        -e 's/🔒/(lock)/g' -e 's/🔑/(key)/g' \
        -e 's/📊/(chart)/g' -e 's/📈/(up)/g' -e 's/📉/(down)/g' \
        -e 's/🚀/(rocket)/g' -e 's/💡/(tip)/g' -e 's/⭐/(*)/g' \
        -e 's/🔄/(sync)/g' -e 's/🛑/(stop)/g' \
        "$input_file" > "$output_file"
}

# Check if file contains mermaid diagrams
has_mermaid_diagrams() {
    local file="$1"
    grep -q '```mermaid' "$file" 2>/dev/null
}

# Convert mermaid code block to PNG
convert_mermaid_block() {
    local mermaid_code="$1"
    local output_png="$2"

    local temp_mmd="$TEMP_DIR/temp_$$.mmd"
    echo "$mermaid_code" > "$temp_mmd"

    # Puppeteer config to allow running without sandbox (containers, CI, etc.)
    local puppeteer_cfg="$TEMP_DIR/puppeteer_$$.json"
    cat > "$puppeteer_cfg" << 'PCFG'
{"args": ["--no-sandbox", "--disable-setuid-sandbox"]}
PCFG

    if mmdc -i "$temp_mmd" -o "$output_png" -b transparent -s 2 -p "$puppeteer_cfg" &>/dev/null; then
        rm -f "$temp_mmd" "$puppeteer_cfg"
        return 0
    else
        rm -f "$temp_mmd" "$puppeteer_cfg"
        return 1
    fi
}

# Process markdown file, converting mermaid blocks to images
process_mermaid_diagrams() {
    local input_file="$1"
    local output_file="$2"
    local diagram_dir="$3"

    local content
    content=$(cat "$input_file")

    local diagram_num=0
    local in_mermaid=false
    local mermaid_code=""
    local processed_content=""

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^\`\`\`mermaid ]]; then
            in_mermaid=true
            mermaid_code=""
            continue
        fi

        if $in_mermaid; then
            if [[ "$line" =~ ^\`\`\` ]]; then
                in_mermaid=false
                diagram_num=$((diagram_num + 1))
                local png_file="$diagram_dir/diagram_${diagram_num}.png"

                if convert_mermaid_block "$mermaid_code" "$png_file"; then
                    processed_content+="![Diagram ${diagram_num}](${png_file})"$'\n'
                    diagrams_converted=$((diagrams_converted + 1))
                else
                    # Keep original code block if conversion fails
                    processed_content+='```mermaid'$'\n'
                    processed_content+="$mermaid_code"$'\n'
                    processed_content+='```'$'\n'
                    echo "  Warning: Failed to convert diagram $diagram_num"
                fi
            else
                mermaid_code+="$line"$'\n'
            fi
        else
            processed_content+="$line"$'\n'
        fi
    done < "$input_file"

    echo "$processed_content" > "$output_file"
    return $diagram_num
}

# Convert a single markdown file to PDF
convert_to_pdf() {
    local md_file="$1"
    local md_dir
    md_dir="$(dirname "$md_file")"
    local md_basename
    md_basename="$(basename "$md_file" .md)"
    local pdf_dir="${md_dir}/pdf"
    local pdf_file="${pdf_dir}/${md_basename}.pdf"

    # Skip non-markdown files
    if [[ "$md_file" != *.md ]]; then
        echo "Skipping non-markdown file: $md_file"
        return 0
    fi

    # Check if markdown file exists
    if [[ ! -f "$md_file" ]]; then
        echo "Error: File not found: $md_file"
        failed=$((failed + 1))
        return 0
    fi

    # Ensure pdf output directory exists
    mkdir -p "$pdf_dir"

    # Handle existing PDF - rename with timestamp
    if [[ -f "$pdf_file" ]]; then
        local backup_name="${pdf_dir}/${md_basename}_backup_${timestamp}.pdf"
        echo "PDF already exists, renaming to: $backup_name"
        mv "$pdf_file" "$backup_name"
    fi

    echo "Converting: $md_file -> $pdf_file"

    # Check for mermaid diagrams
    local processed_md="$md_file"
    local diagram_dir="$TEMP_DIR/diagrams_$$"
    mkdir -p "$diagram_dir"

    if ! $SKIP_DIAGRAMS && $MMDC_AVAILABLE && has_mermaid_diagrams "$md_file"; then
        echo "  Processing Mermaid diagrams..."
        processed_md="$TEMP_DIR/processed_$$.md"
        process_mermaid_diagrams "$md_file" "$processed_md" "$diagram_dir"
        local num_diagrams=$?
        if [[ $num_diagrams -gt 0 ]]; then
            echo "  Converted $num_diagrams diagram(s)"
        fi
    elif ! $SKIP_DIAGRAMS && ! $MMDC_AVAILABLE && has_mermaid_diagrams "$md_file"; then
        echo "  Warning: File contains Mermaid diagrams but mmdc is not installed"
        echo "  Install with: npm install -g @mermaid-js/mermaid-cli"
    fi

    # Sanitize Unicode characters that pdflatex cannot handle
    local sanitized_md="$TEMP_DIR/sanitized_$$.md"
    sanitize_unicode "$processed_md" "$sanitized_md"

    # Build a LaTeX header that fixes table overflow
    local header_file="$TEMP_DIR/header_$$.tex"
    cat > "$header_file" << 'LATEX_HEADER'
\usepackage{array}
\usepackage{longtable}
\usepackage{booktabs}
\usepackage{etoolbox}

% Shrink font inside all longtable environments (pandoc uses longtable)
\AtBeginEnvironment{longtable}{\small}

% Allow line breaks inside monospace text
\makeatletter
\renewcommand{\texttt}[1]{%
  {\ttfamily\hyphenchar\font=`\-\relax #1}%
}
\makeatother
LATEX_HEADER

    # Convert markdown to PDF
    if pandoc "$sanitized_md" -o "$pdf_file" \
        --pdf-engine=pdflatex \
        -V geometry:margin=0.75in \
        -V fontsize=11pt \
        -V colorlinks=true \
        -V tables=true \
        --columns=80 \
        -H "$header_file" \
        --resource-path="$diagram_dir:$SCRIPT_DIR"; then
        echo "  Created: $pdf_file"
        converted=$((converted + 1))
    else
        echo "  Failed to convert: $md_file"
        failed=$((failed + 1))
    fi

    # Cleanup temp files for this conversion
    rm -f "$TEMP_DIR/processed_$$.md"
    rm -f "$TEMP_DIR/sanitized_$$.md"
    rm -f "$TEMP_DIR/header_$$.tex"
    rm -rf "$diagram_dir"

    return 0
}

# Main execution
echo "Markdown to PDF Converter (with Mermaid support)"
echo "================================================="
echo ""

if $MMDC_AVAILABLE; then
    echo "Mermaid CLI: Available (diagrams will be converted)"
else
    echo "Mermaid CLI: Not installed (diagrams will be skipped)"
    echo "  Install with: npm install -g @mermaid-js/mermaid-cli"
fi
echo ""

# Parse arguments
files_to_convert=()
for arg in "$@"; do
    case "$arg" in
        --no-diagrams)
            SKIP_DIAGRAMS=true
            echo "Option: Skipping Mermaid diagram conversion"
            ;;
        *)
            files_to_convert+=("$arg")
            ;;
    esac
done

# Determine which files to process
if [[ ${#files_to_convert[@]} -gt 0 ]]; then
    # Specific files provided as arguments
    for md_file in "${files_to_convert[@]}"; do
        convert_to_pdf "$md_file"
        echo ""
    done
else
    # Find all markdown files in current directory
    for md_file in *.md; do
        if [[ -f "$md_file" ]]; then
            convert_to_pdf "$md_file"
            echo ""
        fi
    done
fi

# Summary
echo "================================================="
echo "Converted: $converted file(s)"
if [[ $diagrams_converted -gt 0 ]]; then
    echo "Diagrams:  $diagrams_converted converted to PNG"
fi
if [[ $failed -gt 0 ]]; then
    echo "Failed:    $failed"
fi
