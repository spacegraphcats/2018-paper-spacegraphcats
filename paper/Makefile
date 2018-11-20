MAIN=main
all:    $(MAIN).pdf

.PRECIOUS: $(MAIN).pdf appendix.pdf

$(MAIN).pdf: $(MAIN).tex *.tex algorithms/*.tex tables/*.tex *.bib
	pdflatex $(MAIN).tex
	bibtex $(MAIN)
	pdflatex $(MAIN).tex
	pdflatex $(MAIN).tex

appendix.pdf: appendix.tex algorithms/*.tex
	pdflatex appendix.tex
	pdflatex appendix.tex

again:
	touch $(MAIN).tex
	make

clean:
	rm -f *.bbl *.blg *.aux *.end *.fls *.log *.out *.fdb_latexmk *.xwm $(MAIN).pdf appendix.pdf

.PHONY: clean again all
