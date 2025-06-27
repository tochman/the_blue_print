# Makefile for The Blue Print book
BOOKNAME = The_Blue_Print
TITLE = title.txt
BUILD = build

# Chapter files for React book
CHAPTERS = front-matter.md \
    chapters/01-introduction-and-fundamentals.md \
    chapters/02-building-react-applications.md \
    chapters/03-state-and-props.md \
    chapters/04-hooks-and-lifecycle.md \
    chapters/05-testing-react-components.md \
    chapters/06-performance-optimization.md \
    chapters/07-1-compound-components.md \
    chapters/07-2-render-props.md \
    chapters/07-3-higher-order-components.md \
    chapters/07-4-context-patterns.md \
    chapters/07-5-advanced-hooks.md \
    chapters/07-6-provider-patterns.md \
    chapters/07-7-error-boundaries.md \
    chapters/07-8-advanced-composition.md \
    chapters/07-9-performance-optimization.md \
    chapters/07-10-testing-patterns.md \
    chapters/07-11-exercises.md \
    chapters/08-state-management.md \
    chapters/09-production-deployment.md \
    chapters/09-1-build-optimization.md \
    chapters/09-2-quality-assurance.md \
    chapters/09-3-cicd-pipeline-implementation.md \
    chapters/09-4-hosting-platform-deployment.md \
    chapters/09-5-monitoring-and-observability.md \
    chapters/09-6-operational-excellence.md \
    chapters/10-the-journey-continues.md

# Docker options
EXTRA_OPTS = --memory=8g

# Main targets
.PHONY: all clean eisvogel eisvogel-simple eisvogel-chunked add_cover merge-pdfs

all: eisvogel-chunked

clean:
	rm -rf $(BUILD)

# Try Eisvogel PDF generation (full featured) - single PDF with complete TOC
eisvogel: $(BUILD)/eisvogel/$(BOOKNAME).pdf

# Eisvogel PDF generation - fully featured with working boxes
$(BUILD)/eisvogel/$(BOOKNAME).pdf: $(TITLE) $(CHAPTERS)
	mkdir -p $(BUILD)/eisvogel 
	docker run --rm $(EXTRA_OPTS)\
		--volume `pwd`:/data pandoc/extra\
		--pdf-engine=xelatex \
		--pdf-engine-opt=--interaction=nonstopmode \
		-V toc-title="Content" -V lang=en-GB \
		--include-in-header=clean-table-styling.tex \
		-o /data/$@ $^  --from markdown --template eisvogel --listings --filter pandoc-latex-environment --top-level-division=chapter

# Build book in chunks to avoid memory issues with proper TOC
CHUNK1 = front-matter.md chapters/01-introduction-and-fundamentals.md chapters/02-building-react-applications.md chapters/03-state-and-props.md chapters/04-hooks-and-lifecycle.md
CHUNK2 = chapters/05-testing-react-components.md chapters/06-performance-optimization.md chapters/07-1-compound-components.md chapters/07-2-render-props.md chapters/07-3-higher-order-components.md
CHUNK3 = chapters/07-4-context-patterns.md chapters/07-5-advanced-hooks.md chapters/07-6-provider-patterns.md chapters/07-7-error-boundaries.md chapters/07-8-advanced-composition.md
CHUNK4 = chapters/07-9-performance-optimization.md chapters/07-10-testing-patterns.md chapters/07-11-exercises.md chapters/08-state-management.md
CHUNK5 = chapters/09-production-deployment.md chapters/09-1-build-optimization.md chapters/09-2-quality-assurance.md chapters/09-3-cicd-pipeline-implementation.md chapters/09-4-hosting-platform-deployment.md chapters/09-5-monitoring-and-observability.md chapters/09-6-operational-excellence.md chapters/10-the-journey-continues.md

eisvogel-chunked: $(BUILD)/eisvogel/$(BOOKNAME).pdf
	@echo "Chunked book generated successfully!"

# First generate a lightweight TOC-only document to get proper page structure
$(BUILD)/eisvogel/toc_reference.pdf: $(TITLE) $(CHAPTERS)
	mkdir -p $(BUILD)/eisvogel
	@echo "Generating TOC reference..."
	docker run --rm $(EXTRA_OPTS) \
		--volume `pwd`:/data pandoc/extra \
		--pdf-engine=xelatex \
		--pdf-engine-opt=--interaction=nonstopmode \
		--toc --toc-depth=3 \
		-V toc-title="Table of Contents" \
		-V lang=en-GB \
		--include-in-header=clean-table-styling-simple.tex \
		-o /data/$@ $^ \
		--from markdown --template eisvogel \
		--top-level-division=chapter \
		--pdf-engine-opt=--halt-on-error || echo "TOC reference generated with warnings"

# Build chunks with proper template and page numbering
$(BUILD)/eisvogel/$(BOOKNAME)_chunk1.pdf: $(TITLE) $(CHUNK1) $(BUILD)/eisvogel/toc_reference.pdf
	mkdir -p $(BUILD)/eisvogel 
	@echo "Building chunk 1 with front matter..."
	docker run --rm $(EXTRA_OPTS) \
		--volume `pwd`:/data pandoc/extra \
		--pdf-engine=xelatex \
		--pdf-engine-opt=--interaction=nonstopmode \
		--toc --toc-depth=3 \
		-V toc-title="Table of Contents" \
		-V lang=en-GB \
		-V book=true \
		--include-in-header=clean-table-styling.tex \
		-o /data/$@ $(TITLE) $(CHUNK1) \
		--from markdown --template eisvogel --listings \
		--filter pandoc-latex-environment \
		--top-level-division=chapter

$(BUILD)/eisvogel/$(BOOKNAME)_chunk2.pdf: $(CHUNK2) $(BUILD)/eisvogel/toc_reference.pdf
	mkdir -p $(BUILD)/eisvogel 
	@echo "Building chunk 2..."
	docker run --rm $(EXTRA_OPTS) \
		--volume `pwd`:/data pandoc/extra \
		--pdf-engine=xelatex \
		--pdf-engine-opt=--interaction=nonstopmode \
		-V lang=en-GB \
		-V book=true \
		--include-in-header=clean-table-styling.tex \
		-o /data/$@ $< \
		--from markdown --template eisvogel --listings \
		--filter pandoc-latex-environment \
		--top-level-division=chapter

$(BUILD)/eisvogel/$(BOOKNAME)_chunk3.pdf: $(CHUNK3) $(BUILD)/eisvogel/toc_reference.pdf
	mkdir -p $(BUILD)/eisvogel 
	@echo "Building chunk 3..."
	docker run --rm $(EXTRA_OPTS) \
		--volume `pwd`:/data pandoc/extra \
		--pdf-engine=xelatex \
		--pdf-engine-opt=--interaction=nonstopmode \
		-V lang=en-GB \
		-V book=true \
		--include-in-header=clean-table-styling.tex \
		-o /data/$@ $(CHUNK3) \
		--from markdown --template eisvogel --listings \
		--filter pandoc-latex-environment \
		--top-level-division=chapter

$(BUILD)/eisvogel/$(BOOKNAME)_chunk4.pdf: $(CHUNK4) $(BUILD)/eisvogel/toc_reference.pdf
	mkdir -p $(BUILD)/eisvogel 
	@echo "Building chunk 4..."
	docker run --rm $(EXTRA_OPTS) \
		--volume `pwd`:/data pandoc/extra \
		--pdf-engine=xelatex \
		--pdf-engine-opt=--interaction=nonstopmode \
		-V lang=en-GB \
		-V book=true \
		--include-in-header=clean-table-styling.tex \
		-o /data/$@ $(CHUNK4) \
		--from markdown --template eisvogel --listings \
		--filter pandoc-latex-environment \
		--top-level-division=chapter

$(BUILD)/eisvogel/$(BOOKNAME)_chunk5.pdf: $(CHUNK5) $(BUILD)/eisvogel/toc_reference.pdf
	mkdir -p $(BUILD)/eisvogel 
	@echo "Building chunk 5..."
	docker run --rm $(EXTRA_OPTS) \
		--volume `pwd`:/data pandoc/extra \
		--pdf-engine=xelatex \
		--pdf-engine-opt=--interaction=nonstopmode \
		-V lang=en-GB \
		-V book=true \
		--include-in-header=clean-table-styling.tex \
		-o /data/$@ $(CHUNK5) \
		--from markdown --template eisvogel --listings \
		--filter pandoc-latex-environment \
		--top-level-division=chapter

# Combine all chunks into final PDF using cpdf (maintaining bookmarks)
$(BUILD)/eisvogel/$(BOOKNAME).pdf: $(BUILD)/eisvogel/$(BOOKNAME)_chunk1.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk2.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk3.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk4.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk5.pdf
	@echo "Combining chunks into final PDF..."
	@if command -v cpdf >/dev/null 2>&1; then \
		cpdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk1.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk2.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk3.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk4.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk5.pdf -o $(BUILD)/eisvogel/$(BOOKNAME).pdf; \
		echo "Complete book generated at $(BUILD)/eisvogel/$(BOOKNAME).pdf"; \
	else \
		echo "cpdf not found. Trying alternative merge..."; \
		gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=$(BUILD)/eisvogel/$(BOOKNAME).pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk1.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk2.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk3.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk4.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk5.pdf; \
		echo "Complete book generated at $(BUILD)/eisvogel/$(BOOKNAME).pdf (using Ghostscript)"; \
	fi

test-chapters: $(BUILD)/eisvogel/$(BOOKNAME)_test.pdf

$(BUILD)/eisvogel/$(BOOKNAME)_test.pdf: $(TITLE) chapters/01-introduction-and-fundamentals.md chapters/02-building-react-applications.md chapters/03-state-and-props.md
	mkdir -p $(BUILD)/eisvogel 
	docker run --rm $(EXTRA_OPTS)\
		--volume `pwd`:/data pandoc/extra\
		--pdf-engine=xelatex \
		--pdf-engine-opt=--interaction=nonstopmode \
		-V toc-title="Content" -V lang=en-GB \
		--include-in-header=clean-table-styling.tex \
		-o /data/$@ $^  --from markdown --template eisvogel --listings --filter pandoc-latex-environment --top-level-division=chapter
eisvogel-simple: $(BUILD)/eisvogel/$(BOOKNAME)_simple.pdf

$(BUILD)/eisvogel/$(BOOKNAME)_simple.pdf: $(TITLE) $(CHAPTERS)
	mkdir -p $(BUILD)/eisvogel
	@echo "Building book with properly formatted Eisvogel configuration..."
	@docker run --rm $(EXTRA_OPTS) \
		--volume `pwd`:/data pandoc/extra \
		--pdf-engine=xelatex \
		--pdf-engine-opt=--interaction=nonstopmode \
		--toc \
		--toc-depth=2 \
		-V toc-title="Table of Contents" \
		-V lang=en-US \
		-V colorlinks=true \
		-V linkcolor=blue \
		-V urlcolor=blue \
		-V toccolor=black \
		--include-in-header=clean-table-styling.tex \
		--lua-filter=custom-boxes.lua \
		-o /data/$@ $^ \
		--from markdown+fenced_divs \
		--template eisvogel \
		--listings \
		--top-level-division=chapter

# Individual chapter build with combination
$(BUILD)/eisvogel/$(BOOKNAME)_combined.pdf: $(TITLE) $(CHAPTERS)
	mkdir -p $(BUILD)/eisvogel/chapters
	@echo "Building individual chapters..."
	
	# Build title page separately
	docker run --rm $(EXTRA_OPTS)\
		--volume `pwd`:/data pandoc/extra\
		-V toc-title="Content" -V lang=en-GB \
		--include-in-header=clean-table-styling.tex \
		-o /data/$(BUILD)/eisvogel/title.pdf $(TITLE) \
		--from markdown --template eisvogel --listings --filter pandoc-latex-environment
	
	# Build each chapter individually
	@for chapter in $(CHAPTERS); do \
		echo "Building $$chapter..."; \
		docker run --rm $(EXTRA_OPTS)\
			--volume `pwd`:/data pandoc/extra\
			-V lang=en-GB \
			--include-in-header=clean-table-styling.tex \
			-o /data/$(BUILD)/eisvogel/chapters/`basename $$chapter .md`.pdf $$chapter \
			--from markdown --template eisvogel --listings --filter pandoc-latex-environment --top-level-division=chapter; \
	done
	
	# Combine all PDFs into one
	@echo "Combining all chapters into final PDF..."
	@cd $(BUILD)/eisvogel && \
		pdftk title.pdf chapters/*.pdf cat output $(BOOKNAME)_combined.pdf
	
	@echo "Build complete: $(BUILD)/eisvogel/$(BOOKNAME)_combined.pdf"

# Create table of contents from combined PDF
toc: $(BUILD)/eisvogel/$(BOOKNAME)_combined.pdf
	@echo "Generating table of contents..."
	docker run --rm $(EXTRA_OPTS)\
		--volume `pwd`:/data pandoc/extra\
		-V toc-title="Content" -V lang=en-GB \
		--toc --toc-depth=2 \
		--include-in-header=clean-table-styling.tex \
		-o /data/$(BUILD)/eisvogel/toc.pdf $(TITLE) $(CHAPTERS) \
		--from markdown --template eisvogel --listings --filter pandoc-latex-environment --top-level-division=chapter \
		--pdf-engine-opt=--interaction=batchmode || true
	
	# If TOC generation succeeds, combine it with the main content
	@if [ -f $(BUILD)/eisvogel/toc.pdf ]; then \
		echo "Combining TOC with main content..."; \
		cd $(BUILD)/eisvogel && \
		pdftk toc.pdf $(BOOKNAME)_combined.pdf cat output $(BOOKNAME).pdf && \
		echo "Final PDF with TOC: $(BUILD)/eisvogel/$(BOOKNAME).pdf"; \
	else \
		echo "TOC generation failed, using combined PDF without TOC"; \
		cp $(BUILD)/eisvogel/$(BOOKNAME)_combined.pdf $(BUILD)/eisvogel/$(BOOKNAME).pdf; \
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
	@echo "  eisvogel         - Build complete PDF using full-featured Eisvogel template (may hit memory limits)"
	@echo "  eisvogel-chunked - Build PDF in chunks to avoid memory issues (recommended for complete book)"
	@echo "  eisvogel-simple  - Build PDF using basic Eisvogel template"
	@echo "  test-chapters    - Build a test PDF with just the first few chapters"
	@echo "  add_cover        - Add front and back covers to existing PDF"
	@echo "  clean            - Remove build directory"
	@echo "  all              - Build eisvogel PDF (default)"
	@echo ""
	@echo "For memory-constrained builds, use: make eisvogel-chunked"