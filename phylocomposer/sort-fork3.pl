#!/usr/bin/perl -w

my %match = ('S' => 'S',
	     'E' => 'E',
	     'W' => 'W',
	     'D' => '\delta');

my %global = ('Start' => 'SSSS',
	      'End' => 'EEEE');

my (%order, @rest, %name, %longname, %shape);
my $nodes_to_print = 0;
while (<>) {
    if (/^\s*(\S+).*label=<<(.*)>>/) {
	my ($node, $label) = ($1, $2);
	while ($label =~ s/<[^>]+>//) { }
	if ($label =~ /([\*\-])([SWME]).([SWEMDI]).([SWEMDI]).([SWD])([0mflivcs]?).([SWEMDI]).([SWD])([0mflivcs]?).([SWEMDI]).([SWD])([0mflivcs]?)/) {
	    my ($input, $root, $tkf0, $tkf1, $state1, $pos1, $tkf2, $state2, $pos2, $tkf3, $state3, $pos3) = ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12);
	    my $suffix1 =
		$state1 eq 'S'
		? ""
		: ('_' . uc($pos1));
	    my $suffix2 =
		$state2 eq 'S'
		? ""
		: ('_' . uc($pos2));
	    my $suffix3 =
		$state3 eq 'S'
		? ""
		: ('_' . uc($pos3));
	    $pos1 = "0" if $pos1 eq "";
 	    $pos2 = "0" if $pos2 eq "";
	    $pos3 = "0" if $pos2 eq "";
	    my $name = $tkf0.$tkf1.$match{$state1}.$suffix1.$tkf2.$match{$state2}.$suffix2.$tkf3.$match{$state3}.$suffix3;
	    my $longname = "${root}${tkf0}${tkf1}_${state1}${pos1}__${tkf2}_${state2}${pos2}__${tkf3}_${state3}${pos3}";
	    warn "Processed state $longname\n";
	    die "Duplicate name $name:  $longname  $longname{$node}" if exists $name{$node};
	    $name{$node} = $name;
	    $longname{$node} = $longname;
	    push @{$order{$pos1}->{$pos2}->{$pos3}}, $node;
	    $shape{$node} =
		$input eq '*'
		? 'invhouse, color=red'
		: ("$root$tkf1$state1$tkf2$state2" eq "WWWWW"
		   ? 'octagon, color=red'
		   : 'circle');
	} else {
	    $longname{$node} = $node;
	    $name{$node} = $global{$node};
	    push @rest, $node;
	    $shape{$node} =
		$node eq 'Start'
		? "circle, color=red"
		: ($node eq 'End'
		   ? "diamond, color=red"
		   : "circle");
	}
	$nodes_to_print = 1;
    } elsif (/(\S+)\s*->\s*(\S+)/) {
	my ($src, $dest) = ($1, $2);
	if ($nodes_to_print) {
	    for my $node (@rest) {
		print_node ($node);
	    }
# Commented out outermost cluster as it messes up the left->right layout... sigh
#	    print "subgraph cluster_DPmatrix {\n";
	    for my $pos1 (sort keys %order) {
		print "subgraph cluster_$pos1 {\n";
		for my $pos2 (sort keys %{$order{$pos1}}) {
		    print "subgraph cluster_$pos1$pos2 {\n";
		    for my $pos3 (sort keys %{$order{$pos1}->{$pos2}}) {
			print "subgraph cluster_$pos1$pos2$pos3 {\n";
			for my $node (@{$order{$pos1}->{$pos2}->{$pos3}}) {
			    print_node ($node);
			}
			print "}\n";
		    }
		    print "}\n";
		}
		print "}\n";
	    }
#	    print "}\n";
	    $nodes_to_print = 0;
	}
	print "$longname{$src} -> $longname{$dest};\n";
    } else {
	print unless /plaintext/;
    }
}

sub print_node {
    my ($node) = @_;
    print "$longname{$node} [shape=$shape{$node}, label=\"\"];\n";
}
