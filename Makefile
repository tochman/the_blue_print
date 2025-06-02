# Makefile for The Blue Print book
BOOKNAME = The_Blue_Print
TITLE = title.txt
BUILD = build

# Chapter files for React book
CHAPTERS = chapters/01-introduction-and-fundamentals.md \
    chapters/02-component-thinking.md \
    chapters/03-state-and-props.md \
    chapters/04-hooks-and-lifecycle.md \
    chapters/05-advanced-patterns.md \
    chapters/06-performance-optimization.md \
    chapters/07-testing-react-components.md \
    chapters/08-state-management.md \
    chapters/09-production-deployment.md \
    chapters/10-the-journey-continues.md

# Docker options
EXTRA_OPTS = 

# Main targets
.PHONY: all clean eisvogel add_cover

all: eisvogel add_cover

clean:
	rm -rf $(BUILD)

# Eisvogel PDF generation with automatic cover addition
eisvogel: $(BUILD)/eisvogel/$(BOOKNAME).pdf add_cover

$(BUILD)/eisvogel/$(BOOKNAME).pdf: $(TITLE) $(CHAPTERS)
	mkdir -p $(BUILD)/eisvogel 
	docker run --rm $(EXTRA_OPTS)\
		--volume `pwd`:/data pandoc/extra\
		-V toc-title="Content" -V lang=en-GB \
		--include-in-header=clean-table-styling.tex \
		-o /data/$@ $^  --from markdown --template eisvogel --listings --filter pandoc-latex-environment --top-level-division=chapter

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
	@echo "  eisvogel    - Build PDF using Eisvogel template (with covers if available)"
	@echo "  add_cover   - Add front and back covers to existing PDF"
	@echo "  clean       - Remove build directory"
	@echo "  all         - Build eisvogel PDF with covers (default)"