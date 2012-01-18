
ALLDOT := $(wildcard *.dot)
ALLBIG := $(wildcard *.a1dot)
ALLBASE := $(subst .dot,,$(ALLDOT)) $(subst .a1dot,,$(ALLBIG))

ALLPNG := $(addsuffix .png,$(ALLBASE))
ALLPDF := $(addsuffix .pdf,$(ALLBASE))
ALLTEX := $(addsuffix .tex,$(ALLBASE))

all: $(ALLPDF)

open: $(ALLPDF)
	open $(ALLPDF)

clean:
	rm $(ALLTEX) $(ALLPDF) $(ALLPNG)

%.open: %
	open $<

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
%.pdf: %.tex
	pdflatex -shell-escape $<

# PNGs (requires graphviz only)
%.png: %.dot
	dot -Tpng $< >$@

# hey make! don't delete all my stuff
.SECONDARY:
