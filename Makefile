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
HIGHMEM_IMAGE = pandoc-highmem
HIGHMEM_DOCKERFILE = Dockerfile.pandoc-highmem

# Common pandoc options
PANDOC_OPTS = --pdf-engine=xelatex \
              --pdf-engine-opt=--interaction=nonstopmode \
              --from markdown \
              --template eisvogel \
              --listings \
              --filter pandoc-latex-environment \
              --top-level-division=chapter \
              -V lang=en-GB \
              -V book=true \
              -V colorlinks=true \
              -V linkcolor=blue \
              -V filecolor=magenta \
              -V urlcolor=blue \
              -V citecolor=black \
              --include-in-header=clean-table-styling.tex

# Main targets
.PHONY: all clean eisvogel eisvogel-simple eisvogel-chunked eisvogel-single eisvogel-optimized eisvogel-highmem build-highmem-image add_cover help

all: eisvogel-chunked

clean:
	rm -rf $(BUILD)

# Build the high-memory Docker image
build-highmem-image:
	@echo "Building high-memory pandoc Docker image..."
	docker build -f $(HIGHMEM_DOCKERFILE) -t $(HIGHMEM_IMAGE) .
	@echo "High-memory image '$(HIGHMEM_IMAGE)' built successfully!"

# Main eisvogel target uses chunked build for reliability
eisvogel: eisvogel-chunked

# High-memory single PDF build using custom Docker image
eisvogel-highmem: build-highmem-image $(BUILD)/eisvogel/$(BOOKNAME)_highmem.pdf
	@echo "Complete book generated successfully with high-memory build at $(BUILD)/eisvogel/$(BOOKNAME)_highmem.pdf"

$(BUILD)/eisvogel/$(BOOKNAME)_highmem.pdf: $(TITLE) $(CHAPTERS)
	mkdir -p $(BUILD)/eisvogel
	@echo "Building complete book with high-memory Docker image..."
	docker run --rm $(EXTRA_OPTS) \
		--volume `pwd`:/data $(HIGHMEM_IMAGE) \
		$(PANDOC_OPTS) \
		--toc --toc-depth=3 \
		-V toc-title="Table of Contents" \
		-o /data/$@ $(TITLE) $(CHAPTERS)

# Optimized single PDF build with better memory management
eisvogel-optimized: $(BUILD)/eisvogel/$(BOOKNAME).pdf
	@echo "Complete book generated successfully at $(BUILD)/eisvogel/$(BOOKNAME).pdf"

$(BUILD)/eisvogel/$(BOOKNAME).pdf: $(TITLE) $(CHAPTERS)
	mkdir -p $(BUILD)/eisvogel
	@echo "Building complete book with eisvogel template (optimized)..."
	docker run --rm $(EXTRA_OPTS) \
		--volume `pwd`:/data pandoc/extra \
		$(PANDOC_OPTS) \
		--toc --toc-depth=3 \
		-V toc-title="Table of Contents" \
		-V geometry:margin=1in \
		-V fontsize=11pt \
		-V linestretch=1.2 \
		-o /data/$@ $(TITLE) $(CHAPTERS)

# Original single PDF build (may hit memory limits with large books)
eisvogel-single: $(BUILD)/eisvogel/$(BOOKNAME)_single.pdf
	@echo "Complete book generated successfully at $(BUILD)/eisvogel/$(BOOKNAME)_single.pdf"

$(BUILD)/eisvogel/$(BOOKNAME)_single.pdf: $(TITLE) $(CHAPTERS)
	mkdir -p $(BUILD)/eisvogel
	@echo "Building complete book with eisvogel template..."
	docker run --rm $(EXTRA_OPTS) \
		--volume `pwd`:/data pandoc/extra \
		$(PANDOC_OPTS) \
		--toc --toc-depth=3 \
		-V toc-title="Table of Contents" \
		-o /data/$@ $(TITLE) $(CHAPTERS)

# Alternative chunked build for memory-constrained environments with complete TOC
eisvogel-chunked: $(BUILD)/eisvogel/$(BOOKNAME)_chunked.pdf
	@echo "Chunked book with complete TOC generated successfully!"

# First, generate a comprehensive TOC by processing all files
$(BUILD)/eisvogel/complete-toc.md: $(TITLE) $(CHAPTERS)
	mkdir -p $(BUILD)/eisvogel
	@echo "Generating comprehensive table of contents..."
	./generate-toc.sh

# Build book in chunks to avoid memory issues
CHUNK1 = front-matter.md chapters/01-introduction-and-fundamentals.md chapters/02-building-react-applications.md chapters/03-state-and-props.md chapters/04-hooks-and-lifecycle.md
CHUNK2 = chapters/05-testing-react-components.md chapters/06-performance-optimization.md chapters/07-1-compound-components.md chapters/07-2-render-props.md chapters/07-3-higher-order-components.md
CHUNK3 = chapters/07-4-context-patterns.md chapters/07-5-advanced-hooks.md chapters/07-6-provider-patterns.md chapters/07-7-error-boundaries.md chapters/07-8-advanced-composition.md
CHUNK4 = chapters/07-9-performance-optimization.md chapters/07-10-testing-patterns.md chapters/07-11-exercises.md chapters/08-state-management.md
CHUNK5 = chapters/09-production-deployment.md chapters/09-1-build-optimization.md chapters/09-2-quality-assurance.md chapters/09-3-cicd-pipeline-implementation.md chapters/09-4-hosting-platform-deployment.md chapters/09-5-monitoring-and-observability.md chapters/09-6-operational-excellence.md chapters/10-the-journey-continues.md

# Create a complete TOC file first
$(BUILD)/eisvogel/toc.md: $(TITLE) $(CHAPTERS)
	mkdir -p $(BUILD)/eisvogel
	@echo "Generating complete table of contents..."
	docker run --rm $(EXTRA_OPTS) \
		--volume `pwd`:/data pandoc/extra \
		--from markdown --to markdown \
		--template /data/toc-template.md \
		--toc --toc-depth=3 \
		-V toc-title="Table of Contents" \
		-o /data/$@ $(TITLE) $(CHAPTERS) || \
	(echo "# Table of Contents" > $@ && \
	 echo "" >> $@ && \
	 echo "This is a comprehensive guide to React development." >> $@)

# Build chunk 1 with title, front matter, and complete TOC including all chapters
$(BUILD)/eisvogel/$(BOOKNAME)_chunk1.pdf: $(BUILD)/eisvogel/complete-toc.md $(TITLE) $(CHUNK1)
	mkdir -p $(BUILD)/eisvogel
	@echo "Building chunk 1 with front matter and complete TOC..."
	docker run --rm $(EXTRA_OPTS) \
		--volume `pwd`:/data pandoc/extra \
		$(PANDOC_OPTS) \
		-o /data/$@ $(TITLE) $(BUILD)/eisvogel/complete-toc.md $(CHUNK1)

# Build remaining chunks without TOC but with consistent styling
$(BUILD)/eisvogel/$(BOOKNAME)_chunk2.pdf: $(CHUNK2)
	mkdir -p $(BUILD)/eisvogel
	@echo "Building chunk 2..."
	docker run --rm $(EXTRA_OPTS) \
		--volume `pwd`:/data pandoc/extra \
		$(PANDOC_OPTS) \
		-o /data/$@ $(CHUNK2)

$(BUILD)/eisvogel/$(BOOKNAME)_chunk3.pdf: $(CHUNK3)
	mkdir -p $(BUILD)/eisvogel
	@echo "Building chunk 3..."
	docker run --rm $(EXTRA_OPTS) \
		--volume `pwd`:/data pandoc/extra \
		$(PANDOC_OPTS) \
		-o /data/$@ $(CHUNK3)

$(BUILD)/eisvogel/$(BOOKNAME)_chunk4.pdf: $(CHUNK4)
	mkdir -p $(BUILD)/eisvogel
	@echo "Building chunk 4..."
	docker run --rm $(EXTRA_OPTS) \
		--volume `pwd`:/data pandoc/extra \
		$(PANDOC_OPTS) \
		-o /data/$@ $(CHUNK4)

$(BUILD)/eisvogel/$(BOOKNAME)_chunk5.pdf: $(CHUNK5)
	mkdir -p $(BUILD)/eisvogel
	@echo "Building chunk 5..."
	docker run --rm $(EXTRA_OPTS) \
		--volume `pwd`:/data pandoc/extra \
		$(PANDOC_OPTS) \
		-o /data/$@ $(CHUNK5)

# Combine all chunks into final PDF using cpdf (maintaining bookmarks)
$(BUILD)/eisvogel/$(BOOKNAME)_chunked.pdf: $(BUILD)/eisvogel/$(BOOKNAME)_chunk1.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk2.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk3.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk4.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk5.pdf
	@echo "Combining chunks into final PDF..."
	@if command -v cpdf >/dev/null 2>&1; then \
		cpdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk1.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk2.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk3.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk4.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk5.pdf -o $(BUILD)/eisvogel/$(BOOKNAME)_chunked.pdf; \
		echo "Complete chunked book generated at $(BUILD)/eisvogel/$(BOOKNAME)_chunked.pdf"; \
	elif command -v pdftk >/dev/null 2>&1; then \
		pdftk $(BUILD)/eisvogel/$(BOOKNAME)_chunk1.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk2.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk3.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk4.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk5.pdf cat output $(BUILD)/eisvogel/$(BOOKNAME)_chunked.pdf; \
		echo "Complete chunked book generated at $(BUILD)/eisvogel/$(BOOKNAME)_chunked.pdf (using pdftk)"; \
	elif command -v gs >/dev/null 2>&1; then \
		gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=$(BUILD)/eisvogel/$(BOOKNAME)_chunked.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk1.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk2.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk3.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk4.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk5.pdf; \
		echo "Complete chunked book generated at $(BUILD)/eisvogel/$(BOOKNAME)_chunked.pdf (using Ghostscript)"; \
	else \
		echo "Error: No PDF merger found. Please install cpdf, pdftk, or ghostscript."; \
		exit 1; \
	fi

# Test build with first few chapters
test-chapters: $(BUILD)/eisvogel/$(BOOKNAME)_test.pdf

$(BUILD)/eisvogel/$(BOOKNAME)_test.pdf: $(TITLE) chapters/01-introduction-and-fundamentals.md chapters/02-building-react-applications.md chapters/03-state-and-props.md
	mkdir -p $(BUILD)/eisvogel
	@echo "Building test PDF with first few chapters..."
	docker run --rm $(EXTRA_OPTS) \
		--volume `pwd`:/data pandoc/extra \
		$(PANDOC_OPTS) \
		--toc --toc-depth=3 \
		-V toc-title="Table of Contents" \
		-o /data/$@ $(TITLE) chapters/01-introduction-and-fundamentals.md chapters/02-building-react-applications.md chapters/03-state-and-props.md

# Simple build without some advanced features
eisvogel-simple: $(BUILD)/eisvogel/$(BOOKNAME)_simple.pdf

$(BUILD)/eisvogel/$(BOOKNAME)_simple.pdf: $(TITLE) $(CHAPTERS)
	mkdir -p $(BUILD)/eisvogel
	@echo "Building simple PDF without advanced features..."
	docker run --rm $(EXTRA_OPTS) \
		--volume `pwd`:/data pandoc/extra \
		--pdf-engine=xelatex \
		--pdf-engine-opt=--interaction=nonstopmode \
		--from markdown \
		--template eisvogel \
		--top-level-division=chapter \
		--toc --toc-depth=2 \
		-V toc-title="Table of Contents" \
		-V lang=en-GB \
		-V colorlinks=true \
		-V linkcolor=blue \
		-V urlcolor=blue \
		-V toccolor=black \
		--include-in-header=clean-table-styling-simple.tex \
		-o /data/$@ $(TITLE) $(CHAPTERS)

# Add covers to the PDF (if cover files exist)
add_cover: $(BUILD)/eisvogel/$(BOOKNAME).pdf
	@if [ -f front_cover.pdf ] && [ -f back_cover.pdf ]; then \
		echo "Adding covers to PDF..."; \
		if command -v pdftk >/dev/null 2>&1; then \
			pdftk front_cover.pdf $(BUILD)/eisvogel/$(BOOKNAME).pdf back_cover.pdf cat output $(BUILD)/eisvogel/$(BOOKNAME)_with_covers.pdf; \
			mv $(BUILD)/eisvogel/$(BOOKNAME)_with_covers.pdf $(BUILD)/eisvogel/$(BOOKNAME).pdf; \
			echo "Covers added successfully!"; \
		else \
			echo "pdftk not found, skipping cover addition..."; \
		fi; \
	else \
		echo "Cover files not found, skipping cover addition..."; \
	fi

# Help target
help:
	@echo "Available targets:"
	@echo "  eisvogel-highmem   - Build complete PDF using high-memory Docker image (RECOMMENDED)"
	@echo "  eisvogel-chunked   - Build PDF in chunks to avoid memory issues"
	@echo "  eisvogel-optimized - Build complete PDF using single-pass approach with memory optimizations"
	@echo "  eisvogel-single    - Build complete PDF using original single-pass approach"  
	@echo "  eisvogel-simple    - Build PDF with simplified options"
	@echo "  test-chapters      - Build a test PDF with just the first few chapters"
	@echo "  build-highmem-image- Build the custom high-memory Docker image"
	@echo "  add_cover          - Add front and back covers to existing PDF"
	@echo "  clean              - Remove build directory"
	@echo "  all                - Build eisvogel PDF (default, uses chunked approach)"
	@echo ""
	@echo "Recommended build order:"
	@echo "  1. make test-chapters        # Test with a few chapters first"
	@echo "  2. make eisvogel-highmem     # Build complete book with high memory (BEST)"
	@echo "  3. make eisvogel-chunked     # If high-memory build fails, use chunked"
	@echo "  4. make add_cover            # Add covers if available"
	@echo ""
	@echo "The eisvogel-highmem target creates a custom Docker image with increased"
	@echo "memory limits specifically designed for large technical books."