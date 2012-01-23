#!/usr/bin/perl -w

my (%order, @rest, %name, %shape);
my $nodes_to_print = 0;
while (<>) {
    if (/^\s*(\S+).*label=<<(.*)>>/) {
	my ($node, $label) = ($1, $2);
	while ($label =~ s/<[^>]+>//) { }
	if ($label =~ /([\*\-])(.).*([SWEMDI]).([SWD])([0mflivcs]?).*([SWEMDI]).([WD])([0mflivcs])/) {
	    my ($input, $root, $tkf1, $state1, $pos1, $tkf2, $state2, $pos2) = ($1, $2, $3, $4, $5, $6, $7, $8);
	    $pos1 = "0" if $pos1 eq "";
	    $name{$node} = "${root}__${tkf1}_${state1}${pos1}__${tkf2}_${state2}${pos2}";
	    push @{$order{$pos1}->{$pos2}}, $node;
	    $shape{$node} =
		$input eq '*'
		? 'shape=invhouse, color=red'
		: ("$root$tkf1$state1$tkf2$state2" eq "WWWWW"
		   ? 'shape=octagon, color=red'
		   : 'shape=circle');
	} else {
	    $name{$node} = $node;
	    push @rest, $node;
	    $shape{$node} =
		$node eq 'Start'
		? "shape=circle, color=red"
		: ($node eq 'End'
		   ? "shape=diamond, color=red"
		   : "shape=circle");
	}
	$nodes_to_print = 1;
    } elsif (/(\S+)\s*->\s*(\S+)/) {
	my ($src, $dest) = ($1, $2);
	if ($nodes_to_print) {
	    for my $node (@rest) {
		print "$name{$node} [$shape{$node}, label=\"\"];\n";
	    }
	    for my $pos1 (sort keys %order) {
		print "subgraph cluster_$pos1 {\n";
		for my $pos2 (sort keys %{$order{$pos1}}) {
		    print "subgraph cluster_$pos1$pos2 {\n";
		    for my $node (@{$order{$pos1}->{$pos2}}) {
			print "$name{$node} [$shape{$node}, label=\"\"];\n";
		    }
		    print "}\n";
		}
		print "}\n";
	    }
	    $nodes_to_print = 0;
	}
	print "$name{$src} -> $name{$dest};\n";
    } else {
	print unless /plaintext/;
    }
}
