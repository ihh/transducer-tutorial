
%.open: %
	open $<

%.png: %.dot
	dot -Tpng $< >$@

%.html.dot: %.sxpr
	phylocomposer $< -cd $@ >/dev/null

%.dot: %.html.dot
	cat $< | perl -pe 'while(s/<[^>]+>//){};s/label=(\S+)>/label="$$1"/' | grep -v plaintext >$@

fork-%.sort.dot: fork-%.html.dot
	./sortpairdp.pl $< >$@

.SECONDARY:
