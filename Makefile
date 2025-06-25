# Makefile for The Blue Print book
BOOKNAME = The_Blue_Print
TITLE = title.txt
BUILD = build

# Chapter files for React book
CHAPTERS = chapters/01-introduction-and-fundamentals.md \
    chapters/02-component-thinking.md \
    chapters/03-state-and-props.md \
    chapters/04-hooks-and-lifecycle.md \
    chapters/05-1-compound-components.md \
    chapters/05-2-render-props.md \
    chapters/05-3-higher-order-components.md \
    chapters/05-4-context-patterns.md \
    chapters/05-5-advanced-hooks.md \
    chapters/05-6-provider-patterns.md \
    chapters/05-7-error-boundaries.md \
    chapters/05-8-advanced-composition.md \
    chapters/05-9-performance-optimization.md \
    chapters/05-10-testing-patterns.md \
    chapters/05-11-exercises.md \
    chapters/06-performance-optimization.md \
    chapters/07-testing-react-components.md \
    chapters/08-state-management.md \
    chapters/09-production-deployment.md \
    chapters/10-the-journey-continues.md

# Docker options
EXTRA_OPTS = 

# Main targets
.PHONY: all clean eisvogel eisvogel-separate add_cover merge-pdfs

all: eisvogel add_cover

clean:
	rm -rf $(BUILD)

# Try Eisvogel PDF generation with increased memory first
eisvogel: $(BUILD)/eisvogel/$(BOOKNAME).pdf add_cover

# Eisvogel PDF generation with increased LaTeX memory
$(BUILD)/eisvogel/$(BOOKNAME).pdf: $(TITLE) $(CHAPTERS)
	mkdir -p $(BUILD)/eisvogel 
	@echo "Attempting PDF generation with increased LaTeX memory..."
	@docker run --rm $(EXTRA_OPTS)\
		--volume `pwd`:/data pandoc/extra\
		--pdf-engine=xelatex \
		--pdf-engine-opt=--interaction=nonstopmode \
		--pdf-engine-opt=--max-print-line=1000 \
		--pdf-engine-opt=--main-memory=12000000 \
		-V toc-title="Content" -V lang=en-GB \
		--include-in-header=clean-table-styling.tex \
		-o /data/$@ $^  --from markdown --template eisvogel --listings --filter pandoc-latex-environment --top-level-division=chapter || \
		$(MAKE) eisvogel-separate

# Fallback: Compile chapters separately and merge
eisvogel-separate:
	@echo "Standard compilation failed, trying separate chapter compilation..."
	mkdir -p $(BUILD)/eisvogel/chapters
	
	# Step 1: Create title page and TOC
	@echo "Creating title page and table of contents..."
	@echo '---' > $(BUILD)/toc-only.md
	@echo 'title: The Blue Print' >> $(BUILD)/toc-only.md
	@echo 'subtitle: A Journey Into Web Application Development with React' >> $(BUILD)/toc-only.md
	@echo 'author: Thomas Ochman' >> $(BUILD)/toc-only.md
	@echo 'affiliation: Agile Ventures' >> $(BUILD)/toc-only.md
	@echo 'titlepage: true' >> $(BUILD)/toc-only.md
	@echo 'titlepage-rule-height: 0' >> $(BUILD)/toc-only.md
	@echo 'language: en-US' >> $(BUILD)/toc-only.md
	@echo 'toc: true' >> $(BUILD)/toc-only.md
	@echo 'book: true' >> $(BUILD)/toc-only.md
	@echo 'listings-disable-line-numbers: true' >> $(BUILD)/toc-only.md
	@echo 'disable-header-and-footer: true' >> $(BUILD)/toc-only.md
	@echo 'code-block-font-size: \small' >> $(BUILD)/toc-only.md
	@echo 'footer-left: "\ "' >> $(BUILD)/toc-only.md
	@echo 'fontsize: 13pt' >> $(BUILD)/toc-only.md
	@echo 'colorlinks: true' >> $(BUILD)/toc-only.md
	@echo 'urlcolor: blue' >> $(BUILD)/toc-only.md
	@tail -n +20 $(TITLE) >> $(BUILD)/toc-only.md
	@echo '---' >> $(BUILD)/toc-only.md
	@echo '' >> $(BUILD)/toc-only.md
	@echo '# Table of Contents' >> $(BUILD)/toc-only.md
	@echo '' >> $(BUILD)/toc-only.md
	@for chapter in $(CHAPTERS); do \
		chapter_name=$$(basename $$chapter .md | sed 's/^[0-9]*-//'); \
		chapter_num=$$(basename $$chapter .md | sed 's/-.*//' | sed 's/^0*//'); \
		chapter_title=$$(head -1 $$chapter | sed 's/^# //'); \
		echo "$$chapter_num. $$chapter_title" >> $(BUILD)/toc-only.md; \
	done
	
	@docker run --rm $(EXTRA_OPTS) \
		--volume `pwd`:/data pandoc/extra \
		--pdf-engine=xelatex \
		--pdf-engine-opt=--interaction=nonstopmode \
		--include-in-header=clean-table-styling.tex \
		-o /data/$(BUILD)/eisvogel/title-and-toc.pdf \
		/data/$(BUILD)/toc-only.md \
		--from markdown --template eisvogel --listings --filter pandoc-latex-environment
	
	# Step 2: Create chapter header template for individual chapters
	@echo '---' > $(BUILD)/chapter-header.md
	@echo 'listings-disable-line-numbers: true' >> $(BUILD)/chapter-header.md
	@echo 'disable-header-and-footer: true' >> $(BUILD)/chapter-header.md
	@echo 'code-block-font-size: \small' >> $(BUILD)/chapter-header.md
	@echo 'footer-left: "\ "' >> $(BUILD)/chapter-header.md
	@echo 'fontsize: 13pt' >> $(BUILD)/chapter-header.md
	@echo 'colorlinks: true' >> $(BUILD)/chapter-header.md
	@echo 'urlcolor: blue' >> $(BUILD)/chapter-header.md
	@echo 'book: true' >> $(BUILD)/chapter-header.md
	@echo 'language: en-US' >> $(BUILD)/chapter-header.md
	@tail -n +20 $(TITLE) >> $(BUILD)/chapter-header.md
	@echo '---' >> $(BUILD)/chapter-header.md
	@echo '' >> $(BUILD)/chapter-header.md
	
	# Step 3: Compile individual chapters (without title page or TOC)
	@echo "Compiling individual chapters..."
	@for chapter in $(CHAPTERS); do \
		echo "Compiling $$chapter..."; \
		cat $(BUILD)/chapter-header.md $$chapter > $(BUILD)/temp-chapter.md; \
		docker run --rm $(EXTRA_OPTS) \
			--volume `pwd`:/data pandoc/extra \
			--pdf-engine=xelatex \
			--pdf-engine-opt=--interaction=nonstopmode \
			--include-in-header=clean-table-styling.tex \
			-o /data/$(BUILD)/eisvogel/chapters/`basename $$chapter .md`.pdf \
			/data/$(BUILD)/temp-chapter.md \
			--from markdown --template eisvogel --listings --filter pandoc-latex-environment --top-level-division=chapter; \
	done
	
	# Step 4: Merge all PDFs using the best available tool
	@echo "Merging title page and chapters into final PDF..."
	@chapter_pdfs="$(BUILD)/eisvogel/title-and-toc.pdf"; \
	for chapter in $(CHAPTERS); do \
		chapter_name=$$(basename $$chapter .md); \
		chapter_pdfs="$$chapter_pdfs $(BUILD)/eisvogel/chapters/$${chapter_name}.pdf"; \
	done; \
	$(MAKE) merge-pdfs PDFS="$$chapter_pdfs" OUTPUT="$(BUILD)/eisvogel/$(BOOKNAME).pdf"
	
	# Cleanup temporary files
	@rm -f $(BUILD)/toc-only.md $(BUILD)/chapter-header.md $(BUILD)/temp-chapter.md
	@echo "Separate compilation completed successfully!"

# Helper target for PDF merging - tries multiple tools in order of preference
merge-pdfs:
	@if command -v gs >/dev/null 2>&1; then \
		echo "Merging PDFs using Ghostscript..."; \
		gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=$(OUTPUT) $(PDFS); \
		echo "PDFs merged successfully using Ghostscript!"; \
	elif command -v pdftk >/dev/null 2>&1; then \
		echo "Merging PDFs using pdftk..."; \
		pdftk $(PDFS) cat output $(OUTPUT); \
		echo "PDFs merged successfully using pdftk!"; \
	elif python3 -c "import PyPDF2" 2>/dev/null; then \
		echo "Merging PDFs using Python PyPDF2..."; \
		python3 -c " \
import sys; \
from PyPDF2 import PdfMerger; \
merger = PdfMerger(); \
pdf_files = '$(PDFS)'.strip().split(); \
[merger.append(f) for f in pdf_files if f]; \
merger.write('$(OUTPUT)'); \
merger.close(); \
print('PDFs merged successfully using PyPDF2!')"; \
	else \
		echo "Error: No PDF merging tool found."; \
		echo "Please install one of: ghostscript, pdftk-java, or PyPDF2"; \
		echo "  macOS: brew install ghostscript"; \
		echo "  macOS: brew install pdftk-java"; \
		echo "  Python: pip3 install PyPDF2"; \
		exit 1; \
	fi

# Add covers to the PDF (if cover files exist)
add_cover: $(BUILD)/eisvogel/$(BOOKNAME).pdf
	@if [ -f front_cover.pdf ] && [ -f back_cover.pdf ]; then \
		echo "Adding covers to PDF..."; \
		pdftk front_cover.pdf $(BUILD)/eisvogel/$(BOOKNAME).pdf back_cover.pdf cat output $(BUILD)/eisvogel/$(BOOKNAME)_with_covers.pdf; \
		mv $(BUILD)/eisvogel/$(BOOKNAME)_with_covers.pdf $(BUILD)/eisvogel/$(BOOKNAME).pdf; \
		echo "Covers added successfully!"; \
	else \
		echo "Cover files not found, skipping cover addition..."; \
	fi

# Help target
help:
	@echo "Available targets:"
	@echo "  eisvogel         - Build PDF using Eisvogel template (with covers if available)"
	@echo "  eisvogel-separate - Build PDF by compiling chapters separately and merging"
	@echo "  add_cover        - Add front and back covers to existing PDF"
	@echo "  merge-pdfs       - Helper target for merging multiple PDFs"
	@echo "  clean            - Remove build directory"
	@echo "  all              - Build eisvogel PDF with covers (default)"