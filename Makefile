
# All source files
# Figures:
ALLDOT := $(wildcard *.dot)
ALLBIGDOT := $(wildcard *.bigdot)
ALLFDPDOT := $(wildcard *.fdpdot)
ALLFIG := $(subst .dot,,$(ALLDOT)) $(subst .bigdot,,$(ALLBIGDOT)) $(subst .fdpdot,,$(ALLFDPDOT))

ALLFIGPNG := $(addsuffix .png,$(ALLFIG))
ALLFIGPDF := $(addsuffix -fig.pdf,$(ALLFIG)) 

ALLFIGJUNK := $(addsuffix .tex,$(ALLFIG)) $(addsuffix .aux,$(ALLFIG)) $(addsuffix .log,$(ALLFIG)) $(addsuffix -pics.pdf,$(ALLFIG))

# The following source files currently only render properly as PNGs
BAD := condensed-emission fanned-emission fanned-indel fanned-match mf-generator liv-small transitions fork3-tkf91liv-tkf91mf-tkf91cs root-fork-tkf91liv-tkf91mf viterbi-root-fork-tkf91liv-tkf91mf forward2-root-fork-tkf91liv-tkf91mf fork-tkf91forward2-tkf91cs
BADPNG := $(addsuffix .png,$(BAD))
GOODPDF := $(addsuffix -fig.pdf,$(filter-out $(BAD),$(ALLFIG)))

FIGURES := $(BADPNG) $(GOODPDF)

# Papers:
ALLTEX := $(filter-out $(ALLFIGJUNK),$(wildcard *.tex))
ALLTEXPDF := $(subst .tex,.pdf,$(ALLTEX))
ALLTEXJUNK := $(addsuffix .aux,$(ALLTEX)) $(addsuffix .log,$(ALLTEX))

# Top-level rules
all: $(FIGURES) $(ALLTEXPDF)

open: $(ALLTEXPDF)
	open $(ALLTEXPDF)

tidy:
	rm -f $(ALLFIGJUNK) $(ALLTEXJUNK) *~

clean: tidy
	rm -f $(ALLTEXPDF) $(ALLFIGPDF) $(ALLFIGPNG)

# General rules:
%.open: %
	open $<

# Paper rules:
%.pdf: %.tex $(FIGURES)
	test -e $*.aux && rm $*.aux || eval
	pdflatex -shell-escape $*
	bibtex $*
	pdflatex -shell-escape $*
	pdflatex -shell-escape $*

# Figure rules:
# PDFs (requires dot2tex + graphviz + pyparsing)
# Landscape orientation, letter paper
%.tex: %.dot
	dot2tex --autosize --crop --format pstricks --texmode raw $< | perl -ne 'if(/documentclass/){print"\\documentclass{article}\n\\usepackage[x11names,rgb]{xcolor}\n\\usepackage{auto-pst-pdf}\n\\usepackage[landscape]{geometry}\n"}else{print unless /usepackage.*xcolor/}' >$@

# Landscape orientation, A1 paper (workaround to avoid cropping big graphs)
%.tex: %.bigdot
	dot2tex --autosize --crop --format pstricks --texmode raw $< | perl -ne 'if(/documentclass/){print"\\documentclass[a1paper]{article}\n\\usepackage[x11names,rgb]{xcolor}\n\\usepackage{auto-pst-pdf}\n\\usepackage[landscape]{geometry}\n"}else{print unless /usepackage.*xcolor/}' >$@

# Using TikZ instead of PSTricks (some problems with this, e.g. TikZ doesn't have same node shapes as normal GraphViz...)
%.tikz.tex: %.dot
	cat $*.dot | perl -pe 's/invhouse/pentagon/g;s/house/triangle/g' >$*.tmpdot
	dot2tex --autosize --format tikz --texmode raw $*.tmpdot | perl -ne 'if(/documentclass/){print"\\documentclass{article}\n\\usepackage[x11names,rgb]{xcolor}\n\\usepackage{auto-pst-pdf}\n\\usepackage[landscape]{geometry}\n"}else{print unless /usepackage.*xcolor/}' >$@

# LaTeX -> PDF
%-fig.pdf: %.tex
	pdflatex -shell-escape $*.tex
	pdfcrop $*.pdf $*-fig.pdf
	rm $*.pdf

# PNGs (requires graphviz only)
%.png: %.dot
	dot -Tpng $< >$@

%.png: %.bigdot
	dot -Tpng $< >$@

%.png: %.fdpdot
	dot -Tpng -Kfdp $< >$@

# hey make! don't delete all my stuff
.SECONDARY:
