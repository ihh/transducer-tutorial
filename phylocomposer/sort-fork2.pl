#!/usr/bin/perl -w

my %match = ('S' => 'S',
	     'E' => 'E',
	     'W' => 'W',
	     'D' => '\delta');

my %global = ('Start' => 'SSSS',
	      'End' => 'EEEE');

my (%order, @rest, %name, %longname, %shape);
my $nodes_to_print = 0;
my $has_IO = 0;
my $has_pos4 = 0;
while (<>) {
    if (/^\s*(\S+).*label=<<(.*)>>/) {
	my ($node, $label) = ($1, $2);
	while ($label =~ s/<[^>]+>//) { }
	if ($label =~ /([\*\-])(.).*([SWEMDI]).([SWD])([0mflivcs\d]?).*([SWEMDI]).([WD])([0mflivcs\d])/) {
	    my ($input, $root, $tkf1, $state1, $pos1, $tkf2, $state2, $pos2) = ($1, $2, $3, $4, $5, $6, $7, $8);
	    my $suffix1 =
		$state1 eq 'S'
		? ""
		: ('_' . uc($pos1));
	    my $suffix2 = '_' . ($pos2 eq "" ? "0" : uc($pos2));
	    $pos1 = "0" if $pos1 eq "";
	    $pos2 = "0" if $pos2 eq "";
	    ++$has_pos4 if $pos1 == 4;
	    my $name = $tkf1.$match{$state1}.$suffix1.$tkf2.$match{$state2}.$suffix2;
	    my $longname = "${root}${tkf1}_${state1}${pos1}__${tkf2}_${state2}${pos2}";
	    die "Duplicate name $name:  $longname  $longname{$node}" if exists $name{$node};
	    $name{$node} = $name;
	    $longname{$node} = $longname;
	    push @{$order{$pos1}->{$pos2}}, $node;
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
		? 'circle, color=red'
		: ($node eq 'End'
		   ? 'diamond, color=red'
		   : 'circle');
	}
	$nodes_to_print = 1;
    } elsif (/(\S+)\s*->\s*(\S+)/) {
	my ($src, $dest) = ($1, $2);
	if ($nodes_to_print) {
	    $has_IO = grep (/house/, values %shape);
	    for my $node (@rest) {
		print_node ($node);
	    }
# Only print outermost cluster border for non-IO version of the transducer
# Anything else messes up the left->right layout... *sigh*
	    print "subgraph cluster_DPmatrix {\n" if !$has_IO;
	    for my $pos1 (sort keys %order) {
		print "subgraph cluster_$pos1 {\n";
		for my $pos2 (sort keys %{$order{$pos1}}) {
		    print "subgraph cluster_$pos1$pos2 {\n";
		    for my $node (@{$order{$pos1}->{$pos2}}) {
			print_node ($node);
		    }
		    print "}\n";
		}
		print "}\n";
	    }
	    print "}\n" if !$has_IO;
	    $nodes_to_print = 0;
	}
	print "$longname{$src} -> $longname{$dest};\n";
    } else {
	print unless /plaintext/;
    }
}

sub print_node {
    my ($node) = @_;
    my $label = ($has_IO == 0 || $has_pos4 || $shape{$node} eq 'circle') ? "" : "\$$name{$node}\$";
    print "$longname{$node} [shape=$shape{$node}, label=\"$label\"];\n";
}
