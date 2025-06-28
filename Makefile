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

# Docker configuration - EXTREME memory for ultra-large books
DOCKER_MEMORY = --memory=64g
HIGHMEM_IMAGE = pandoc-highmem
HIGHMEM_DOCKERFILE = Dockerfile.pandoc-highmem

# Common pandoc options with ultra-memory optimizations
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
.PHONY: all clean build-image highmem chunked test help

# Default target - use the single high-memory build for proper page numbering and TOC
all: highmem

clean:
	rm -rf $(BUILD)

# Build the ultra-high-memory Docker image
build-image:
	@echo "Building ultra-high-memory pandoc Docker image..."
	docker build -f $(HIGHMEM_DOCKERFILE) -t $(HIGHMEM_IMAGE) .
	@echo "Ultra-high-memory image '$(HIGHMEM_IMAGE)' built successfully!"

# Ultra-high-memory single PDF build using custom Docker image (RECOMMENDED)
highmem: build-image $(BUILD)/eisvogel/$(BOOKNAME)_highmem.pdf
	@echo "Complete book generated successfully with ultra-high-memory build at $(BUILD)/eisvogel/$(BOOKNAME)_highmem.pdf"

$(BUILD)/eisvogel/$(BOOKNAME)_highmem.pdf: $(TITLE) $(CHAPTERS)
	mkdir -p $(BUILD)/eisvogel
	@echo "Building complete book with ultra-high-memory Docker image..."
	docker run --rm $(DOCKER_MEMORY) \
		--volume `pwd`:/data $(HIGHMEM_IMAGE) \
		$(PANDOC_OPTS) \
		--toc --toc-depth=3 \
		-V toc-title="Table of Contents" \
		-o /data/$@ $(TITLE) $(CHAPTERS)

# Alternative: Chunked build for extremely large books
chunked: $(BUILD)/eisvogel/$(BOOKNAME)_chunked.pdf
	@echo "Chunked book generated successfully!"

# Build book in manageable chunks
CHUNK1 = front-matter.md chapters/01-introduction-and-fundamentals.md chapters/02-building-react-applications.md chapters/03-state-and-props.md chapters/04-hooks-and-lifecycle.md
CHUNK2 = chapters/05-testing-react-components.md chapters/06-performance-optimization.md chapters/07-1-compound-components.md chapters/07-2-render-props.md chapters/07-3-higher-order-components.md
CHUNK3 = chapters/07-4-context-patterns.md chapters/07-5-advanced-hooks.md chapters/07-6-provider-patterns.md chapters/07-7-error-boundaries.md chapters/07-8-advanced-composition.md
CHUNK4 = chapters/07-9-performance-optimization.md chapters/07-10-testing-patterns.md chapters/07-11-exercises.md chapters/08-state-management.md
CHUNK5 = chapters/09-production-deployment.md chapters/09-1-build-optimization.md chapters/09-2-quality-assurance.md chapters/09-3-cicd-pipeline-implementation.md chapters/09-4-hosting-platform-deployment.md chapters/09-5-monitoring-and-observability.md chapters/09-6-operational-excellence.md chapters/10-the-journey-continues.md

# Build individual chunks
$(BUILD)/eisvogel/$(BOOKNAME)_chunk1.pdf: build-image $(TITLE) $(CHUNK1)
	mkdir -p $(BUILD)/eisvogel
	@echo "Building chunk 1..."
	docker run --rm $(DOCKER_MEMORY) \
		--volume `pwd`:/data $(HIGHMEM_IMAGE) \
		$(PANDOC_OPTS) \
		--toc --toc-depth=3 \
		-V toc-title="Table of Contents" \
		-o /data/$@ $(TITLE) $(CHUNK1)

$(BUILD)/eisvogel/$(BOOKNAME)_chunk2.pdf: build-image $(CHUNK2)
	mkdir -p $(BUILD)/eisvogel
	@echo "Building chunk 2..."
	docker run --rm $(DOCKER_MEMORY) \
		--volume `pwd`:/data $(HIGHMEM_IMAGE) \
		$(PANDOC_OPTS) \
		-o /data/$@ $(CHUNK2)

$(BUILD)/eisvogel/$(BOOKNAME)_chunk3.pdf: build-image $(CHUNK3)
	mkdir -p $(BUILD)/eisvogel
	@echo "Building chunk 3..."
	docker run --rm $(DOCKER_MEMORY) \
		--volume `pwd`:/data $(HIGHMEM_IMAGE) \
		$(PANDOC_OPTS) \
		-o /data/$@ $(CHUNK3)

$(BUILD)/eisvogel/$(BOOKNAME)_chunk4.pdf: build-image $(CHUNK4)
	mkdir -p $(BUILD)/eisvogel
	@echo "Building chunk 4..."
	docker run --rm $(DOCKER_MEMORY) \
		--volume `pwd`:/data $(HIGHMEM_IMAGE) \
		$(PANDOC_OPTS) \
		-o /data/$@ $(CHUNK4)

$(BUILD)/eisvogel/$(BOOKNAME)_chunk5.pdf: build-image $(CHUNK5)
	mkdir -p $(BUILD)/eisvogel
	@echo "Building chunk 5..."
	docker run --rm $(DOCKER_MEMORY) \
		--volume `pwd`:/data $(HIGHMEM_IMAGE) \
		$(PANDOC_OPTS) \
		-o /data/$@ $(CHUNK5)

# Combine all chunks into final PDF
$(BUILD)/eisvogel/$(BOOKNAME)_chunked.pdf: $(BUILD)/eisvogel/$(BOOKNAME)_chunk1.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk2.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk3.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk4.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk5.pdf
	@echo "Combining chunks into final PDF..."
	@if [ -f deps/cpdf ]; then \
		./deps/cpdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk1.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk2.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk3.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk4.pdf $(BUILD)/eisvogel/$(BOOKNAME)_chunk5.pdf -o $(BUILD)/eisvogel/$(BOOKNAME)_chunked.pdf; \
		echo "Complete chunked book generated at $(BUILD)/eisvogel/$(BOOKNAME)_chunked.pdf"; \
	elif command -v cpdf >/dev/null 2>&1; then \
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
test: build-image $(BUILD)/eisvogel/$(BOOKNAME)_test.pdf

$(BUILD)/eisvogel/$(BOOKNAME)_test.pdf: $(TITLE) chapters/01-introduction-and-fundamentals.md chapters/02-building-react-applications.md
	mkdir -p $(BUILD)/eisvogel
	@echo "Building test PDF with first few chapters..."
	docker run --rm $(DOCKER_MEMORY) \
		--volume `pwd`:/data $(HIGHMEM_IMAGE) \
		$(PANDOC_OPTS) \
		--toc --toc-depth=3 \
		-V toc-title="Table of Contents" \
		-o /data/$@ $(TITLE) chapters/01-introduction-and-fundamentals.md chapters/02-building-react-applications.md

# Help target
help:
	@echo "Available targets:"
	@echo "  all (or highmem)   - Build complete PDF using 200M memory + optimizations (RECOMMENDED)"
	@echo "  chunked            - Build PDF in chunks - AVOID: breaks page numbering & TOC"
	@echo "  test               - Build a test PDF with just the first few chapters"
	@echo "  build-image        - Build the custom ultra-high-memory Docker image"
	@echo "  clean              - Remove build directory"
	@echo ""
	@echo "Recommended approach for large books:"
	@echo "  1. make test       # Test with a few chapters first"
	@echo "  2. make highmem    # Build complete book with 200M memory (BEST for proper numbering)"
	@echo ""
	@echo "EXTREME memory configuration now uses:"
	@echo "  - 200M main memory (was hitting 105M limit)"
	@echo "  - 100M extra memory top/bottom"
	@echo "  - 64GB Docker container memory"
	@echo "  - Aggressive mdframed optimizations"
	@echo "  - Single-pass build maintains proper page numbering and cross-references"