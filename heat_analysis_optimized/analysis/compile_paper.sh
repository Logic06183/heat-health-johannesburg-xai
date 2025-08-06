#!/bin/bash

# LaTeX Paper Compilation Script
# ==============================

echo "🚀 COMPILING HEAT-HEALTH PAPER"
echo "==============================="

# Change to the analysis directory
cd /Users/craig/Downloads/publication/heat_analysis_optimized/analysis

# Check if required files exist
if [[ ! -f "heat_health_paper.tex" ]]; then
    echo "❌ Error: heat_health_paper.tex not found!"
    exit 1
fi

if [[ ! -f "references.bib" ]]; then
    echo "❌ Error: references.bib not found!"
    exit 1
fi

echo "📋 Found required files:"
echo "   ✓ heat_health_paper.tex"
echo "   ✓ references.bib"

# Check for figures
echo "🖼️  Checking figures..."
required_figures=(
    "Figure1_ModelPerformance.png"
    "Figure2_TemporalPatterns_Fixed.png"
    "Figure3_SHAPImportance_Fixed.png"
    "Figure4_VulnerabilityDistribution.png"
    "Figure5_GenderDifferences_Fixed.png"
    "ConceptualFramework.png"
)

for figure in "${required_figures[@]}"; do
    if [[ -f "$figure" ]]; then
        echo "   ✓ $figure"
    else
        echo "   ⚠️  $figure (optional)"
    fi
done

# Compilation steps
echo ""
echo "🔨 Starting LaTeX compilation..."

# First pass - LaTeX
echo "📖 Pass 1: LaTeX compilation..."
pdflatex -interaction=nonstopmode heat_health_paper.tex > compile_log.txt 2>&1

if [[ $? -eq 0 ]]; then
    echo "   ✓ LaTeX compilation successful"
else
    echo "   ❌ LaTeX compilation failed. Check compile_log.txt for details."
    echo "Last 10 lines of compile_log.txt:"
    tail -10 compile_log.txt
    exit 1
fi

# Second pass - BibTeX
echo "📚 Pass 2: BibTeX for references..."
bibtex heat_health_paper > bibtex_log.txt 2>&1

if [[ $? -eq 0 ]]; then
    echo "   ✓ BibTeX compilation successful"
else
    echo "   ⚠️  BibTeX compilation had issues. Check bibtex_log.txt"
    echo "Last 5 lines of bibtex_log.txt:"
    tail -5 bibtex_log.txt
fi

# Third pass - LaTeX again
echo "📖 Pass 3: LaTeX compilation (with references)..."
pdflatex -interaction=nonstopmode heat_health_paper.tex >> compile_log.txt 2>&1

if [[ $? -eq 0 ]]; then
    echo "   ✓ LaTeX compilation successful"
else
    echo "   ❌ LaTeX compilation failed. Check compile_log.txt for details."
    exit 1
fi

# Fourth pass - Final LaTeX
echo "📖 Pass 4: Final LaTeX compilation..."
pdflatex -interaction=nonstopmode heat_health_paper.tex >> compile_log.txt 2>&1

if [[ $? -eq 0 ]]; then
    echo "   ✓ Final LaTeX compilation successful"
else
    echo "   ❌ Final LaTeX compilation failed. Check compile_log.txt for details."
    exit 1
fi

# Check if PDF was created
if [[ -f "heat_health_paper.pdf" ]]; then
    echo ""
    echo "🎉 SUCCESS! PDF created successfully!"
    echo "📄 Output: heat_health_paper.pdf"
    
    # Get file size
    file_size=$(du -h "heat_health_paper.pdf" | cut -f1)
    echo "📊 File size: $file_size"
    
    # Count pages
    page_count=$(pdfinfo heat_health_paper.pdf 2>/dev/null | grep "Pages:" | awk '{print $2}')
    if [[ -n "$page_count" ]]; then
        echo "📑 Pages: $page_count"
    fi
    
else
    echo ""
    echo "❌ FAILED! PDF was not created."
    echo "Check compile_log.txt for detailed error information."
    exit 1
fi

# Clean up auxiliary files
echo ""
echo "🧹 Cleaning up auxiliary files..."
rm -f *.aux *.log *.bbl *.blg *.toc *.out *.lof *.lot *.fls *.fdb_latexmk *.synctex.gz

echo "✅ Compilation complete!"
echo ""
echo "📁 Output files:"
echo "   • heat_health_paper.pdf (main output)"
echo "   • compile_log.txt (compilation log)"
echo "   • bibtex_log.txt (bibliography log)"