
%.open: %
	open $<

%.png: %.dot
	dot -Tpng $< >$@

%.html.dot: %.sxpr
	phylocomposer $< -cd $@ >/dev/null

# Basic version of phylocomposer figure
%.dot: %.html.dot
	cat $< | perl -pe 'while(s/<[^>]+>//){};s/label=(\S+)>/label="$$1"/' | grep -v plaintext >$@

# Custom sort rules
fork-%.bigdot: fork-%.html.dot
	./sortpairdp.pl $< >$@

# Landscape orientation, A1 paper (workaround to avoid cropping big graphs)
%.tex: %.bigdot
	dot2tex --autosize --crop --format pstricks --texmode raw $< | perl -ne 'if(/documentclass/){print"\\documentclass[a1paper]{article}\n\\usepackage[x11names,rgb]{xcolor}\n\\usepackage{auto-pst-pdf}\n\\usepackage[landscape]{geometry}\n"}else{print unless /usepackage.*xcolor/}' >$@

# LaTeX -> PDF
%-fig.pdf: %.tex
	pdflatex -shell-escape $*.tex
	pdfcrop $*.pdf $*-fig.pdf
	rm $*.pdf

.SECONDARY:
