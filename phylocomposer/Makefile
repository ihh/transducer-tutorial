
%.open: %
	open $<

%.png: %.dot
	dot -Tpng $< >$@

%.bigpng: %.bigdot
	dot -Tpng $< >$@

%.html.dot: %.sxpr
	phylocomposer $< -cd $@ >/dev/null

# Basic version of phylocomposer figure
%.dot: %.html.dot
	cat $< | perl -pe 'while(s/<[^>]+>//){};s/label=(\S+)>/label="$$1"/' | grep -v plaintext >$@

# Custom sort rules
# Two-sequence DP via a forked recognizer
fork2-%.bigdot: fork2-%.html.dot
	./sort-fork2.pl $< >$@

# Two-sequence DP via a generator-transducer-recognizer composition
comp2-%.bigdot: comp2-%.html.dot
	./sort-comp2.pl $< >$@

# Three-sequence DP via a doubly-forked recognizer
fork3-%.bigdot: fork3-%.html.dot
	./sort-fork3.pl $< >$@

# Landscape orientation, A1 paper (workaround to avoid cropping big graphs)
%.tex: %.bigdot
	dot2tex --autosize --crop --format pstricks --texmode raw $< | perl -ne 'if(/documentclass/){print"\\documentclass[a1paper]{article}\n\\usepackage[x11names,rgb]{xcolor}\n\\usepackage{auto-pst-pdf}\n\\usepackage[landscape]{geometry}\n"}else{print unless /usepackage.*xcolor/}' >$@

# LaTeX -> PDF
%-fig.pdf: %.tex
	pdflatex -shell-escape $*.tex
	pdfcrop $*.pdf $*-fig.pdf
	rm $*.pdf

.SECONDARY:
