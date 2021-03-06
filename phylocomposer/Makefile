
%.open: %
	open $<

%.png: %.dot
	dot -Tpng $< >$@

%-big.png: %.bigdot
	dot -Tpng $< >$@

%-fdp.png: %.fdpdot
	dot -Tpng -Kfdp $< >$@

%.html.dot: %.sxpr
	phylocomposer $< -cd $@ >/dev/null

# Basic version of phylocomposer figure
%.dot: %.html.dot
	cat $< | perl -pe 'while(s/<[^>]+>//){};s/label=(\S+)>/label="$$1"/' | grep -v plaintext >$@

# Custom sort rules
# Fork
fork-%.bigdot: fork-%.html.dot
	./sort-fork.pl $< >$@

root-fork-%.bigdot: root-fork-%.html.dot
	./sort-fork.pl $< >$@

# Two-sequence DP via a forked recognizer
fork2-%.bigdot: fork2-%.html.dot
	./sort-fork2.pl $< >$@

root-fork2-%.bigdot: root-fork2-%.html.dot
	./sort-fork2.pl $< >$@

# Two-sequence DP via a generator-transducer-recognizer composition
comp2-%.bigdot: comp2-%.html.dot
	./sort-comp2.pl $< >$@

# Three-sequence DP via a doubly-forked recognizer
fork3-%.fdpdot: fork3-%.html.dot
	./sort-fork3.pl $< >$@

root-fork3-%.fdpdot: root-fork3-%.html.dot
	./sort-fork3.pl $< >$@

# Landscape orientation, A1 paper (workaround to avoid cropping big graphs)
%.tex: %.bigdot
	dot2tex --autosize --crop --format pstricks --texmode raw $< | perl -ne 'if(/documentclass/){print"\\documentclass[a1paper]{article}\n\\usepackage[x11names,rgb]{xcolor}\n\\usepackage{auto-pst-pdf}\n\\usepackage[landscape]{geometry}\n"}else{print unless /usepackage.*xcolor/}' >$@

# Landscape orientation, A1 paper (workaround to avoid cropping big graphs)
# FDP layout algorithm
%.tex: %.fdpdot
	dot2tex --autosize --crop --format pstricks --texmode raw --prog=fdp $< | perl -ne 'if(/documentclass/){print"\\documentclass[a1paper]{article}\n\\usepackage[x11names,rgb]{xcolor}\n\\usepackage{auto-pst-pdf}\n\\usepackage[landscape]{geometry}\n"}else{print unless /usepackage.*xcolor/}' >$@

# LaTeX -> PDF
%-fig.pdf: %.tex
	pdflatex -shell-escape $*.tex
	pdfcrop $*.pdf $*-fig.pdf
	rm $*.pdf

.SECONDARY:
