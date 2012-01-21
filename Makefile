
# All source files
# Figures:
ALLDOT := $(wildcard *.dot)
ALLA1DOT := $(wildcard *.a1dot)
ALLA0DOT := $(wildcard *.a0dot)
ALLFIG := $(subst .dot,,$(ALLDOT)) $(subst .a1dot,,$(ALLA1DOT))  $(subst .a0dot,,$(ALLA0DOT))

ALLFIGPNG := $(addsuffix .png,$(ALLFIG))
ALLFIGPDF := $(addsuffix .pdf,$(ALLFIG)) 
ALLFIGPDFTARGET := $(addsuffix .figpdf,$(ALLFIG))

ALLFIGJUNK := $(addsuffix .tex,$(ALLFIG)) $(addsuffix .aux,$(ALLFIG)) $(addsuffix .log,$(ALLFIG)) $(addsuffix -pics.pdf,$(ALLFIG))

# The following source files currently only render properly as PNGs
BAD := condensed-emission fanned-emission fanned-indel fanned-match
BADPNG := $(addsuffix .png,$(BAD))
GOODPDF := $(addsuffix .pdf,$(filter-out $(BAD),$(ALLFIG)))
GOODFIGPDF := $(addsuffix .figpdf,$(filter-out $(BAD),$(ALLFIG)))

FIGURES := $(BADPNG) $(GOODFIGPDF)

# Papers:
ALLTEX := $(filter-out $(ALLFIGJUNK),$(wildcard *.tex))
ALLTEXPDF := $(subst .tex,.pdf,$(ALLTEX))
ALLTEXJUNK := $(addsuffix .aux,$(ALLTEX)) $(addsuffix .log,$(ALLTEX))

# Top-level rules
all: $(FIGURES) $(ALLTEXPDF)

open: $(FIGURES) $(ALLTEXPDF)
	open $(BADPNG) $(GOODPDF) $(ALLTEXPDF)

tidy:
	rm -f $(ALLFIGJUNK) $(ALLTEXJUNK) *~

clean: tidy
	rm -f $(ALLTEXPDF) $(ALLFIGPDF) $(ALLFIGPDFTARGET) $(ALLFIGPNG)

# General rules:
%.open: %
	open $<

%.figopen: %.figpdf
	open $*.pdf

# Paper rules:
%.pdf: %.tex $(FIGURES)
	pdflatex -shell-escape $<
	pdflatex -shell-escape $<

# Figure rules:
# PDFs (requires dot2tex + graphviz + pyparsing)
# Landscape orientation, letter paper
%.tex: %.dot
	dot2tex --autosize --format pstricks --texmode raw $< | perl -ne 'if(/documentclass/){print"\\documentclass{article}\n\\usepackage[x11names,rgb]{xcolor}\n\\usepackage{auto-pst-pdf}\n\\usepackage[landscape]{geometry}\n"}else{print unless /usepackage.*xcolor/}' >$@

# Landscape orientation, A1 paper (to avoid cropping big graphs)
%.tex: %.a1dot
	dot2tex --autosize --crop --format pstricks --texmode raw $< | perl -ne 'if(/documentclass/){print"\\documentclass[a1paper]{article}\n\\usepackage[x11names,rgb]{xcolor}\n\\usepackage{auto-pst-pdf}\n\\usepackage[landscape]{geometry}\n"}else{print unless /usepackage.*xcolor/}' >$@

# Using TikZ instead of PSTricks (some problems with this, e.g. TikZ doesn't have same node shapes as normal GraphViz...)
%.tikz.tex: %.dot
	cat $*.dot | perl -pe 's/invhouse/pentagon/g;s/house/triangle/g' >$*.tmpdot
	dot2tex --autosize --format tikz --texmode raw $*.tmpdot | perl -ne 'if(/documentclass/){print"\\documentclass{article}\n\\usepackage[x11names,rgb]{xcolor}\n\\usepackage{auto-pst-pdf}\n\\usepackage[landscape]{geometry}\n"}else{print unless /usepackage.*xcolor/}' >$@

# LaTeX -> PDF
# Makes PDF in $TEXNAME.pdf, touches $TEXNAME.figpdf
%.figpdf: %.tex
	pdflatex -shell-escape $*.tex
	touch $*.figpdf

# PNGs (requires graphviz only)
%.png: %.dot
	dot -Tpng $< >$@

%.png: %.a1dot
	dot -Tpng $< >$@

%.png: %.a0dot
	dot -Tpng $< >$@

# hey make! don't delete all my stuff
.SECONDARY:
