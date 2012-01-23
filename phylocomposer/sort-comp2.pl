#!/usr/bin/perl -w

my %match = ('S' => 'S',
	     'E' => 'E',
	     'W' => 'W',
	     'D' => '\delta',
	     'I' => '\imath');

my %global = ('Start' => 'SSS',
	      'End' => 'EEE');

my %pos1rank = ('0' => 0,
		'm' => 1,
		'f' => 2);

my %pos2rank = ('0' => 0,
		'l' => 1,
		'i' => 2,
		'v' => 3);

my (%order, @rest, %name, %longname, %shape);
my $nodes_to_print = 0;
while (<>) {
    if (/^\s*(\S+).*label=<<(.*)>>/) {
	my ($node, $label) = ($1, $2);
	while ($label =~ s/<[^>]+>//) { }
	if ($label =~ /([SWI])([0mflivcs]?).([SWEMDI]).([WD])([0mflivcs])/) {
	    my ($state1, $pos1, $tkf, $state2, $pos2) = ($1, $2, $3, $4, $5);
	    $pos1 = "0" if $pos1 eq "";
	    $pos2 = "0" if $pos2 eq "";
	    my $suffix1 =
		$state1 eq 'S'
		? ""
		: ('_' . uc($pos1));
	    my $name = $match{$state1}.$suffix1.$tkf.$match{$state2}.'_'.uc($pos2);
	    my $longname = "${state1}${pos1}_${tkf}_${state2}${pos2}";
	    die "Duplicate name $name:  $longname  $longname{$node}" if exists $name{$node};
	    $name{$node} = $name;
	    $longname{$node} = $longname;
	    if ($state1 eq 'W') {
		$shape{$node} = 'octagon, color=red';
		push @rest, $node;
	    } else {
		$shape{$node} = 'circle';
		push @{$order{$pos2}->{$pos1}}, $node;
	    }
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
	    print "subgraph cluster_DPmatrix {\n";
	    print "rankdir=LR;\n";
	    for my $pos2 (sort {$pos2rank{$a} <=> $pos2rank{$b}} keys %order) {
		print "subgraph cluster_$pos2 {\n";
		for my $pos1 (sort {$pos1rank{$a} <=> $pos1rank{$b}} keys %{$order{$pos2}}) {
		    print "subgraph cluster_$pos2$pos1 {\n";
		    for my $node (@{$order{$pos2}->{$pos1}}) {
			print_node ($node);
		    }
		    print "}\n";
		}
		print "}\n";
	    }
	    print "}\n";
	    $nodes_to_print = 0;
	}
	print "$longname{$src} -> $longname{$dest};\n";
    } else {
	print unless /plaintext/;
    }
}

sub print_node {
    my ($node) = @_;
    my $label = "\$$name{$node}\$";
    print "$longname{$node} [shape=$shape{$node}, label=\"$label\"];\n";
}
