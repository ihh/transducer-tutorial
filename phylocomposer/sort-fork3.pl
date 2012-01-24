#!/usr/bin/perl -w

my %match = ('S' => 'S',
	     'E' => 'E',
	     'W' => 'W',
	     'D' => '\delta');

my %global = ('Start' => 'SSSS',
	      'End' => 'EEEE');

my %pos1rank = ('0' => 0,
		'l' => 1,
		'i' => 2,
		'v' => 3);

my %pos2rank = ('0' => 0,
		'm' => 1,
		'f' => 2);

my %pos3rank = ('0' => 0,
		'c' => 1,
		's' => 2);

my (%order, @rest, %name, %longname, %shape, %pos1, %pos2, %pos3, %edge);
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
	    $pos1{$node} = $pos1;
	    $pos2{$node} = $pos2;
	    $pos3{$node} = $pos3;
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
	    $pos1{$node} = $pos2{$node} = $pos3{$node} = "";
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
#	    print "subgraph cluster_DPmatrix {\n";
	    my $n1 = 0;
	    for my $pos1 (sort {$pos1rank{$a} <=> $pos1rank{$b}} keys %order) {
		print "subgraph cluster_$pos1 {\n";
		my $n2 = 0;
		for my $pos2 (sort {$pos2rank{$a} <=> $pos2rank{$b}} keys %{$order{$pos1}}) {
		    print "subgraph cluster_$pos1$pos2 {\n";
		    my $n3 = 0;
		    for my $pos3 (sort {$pos3rank{$a} <=> $pos3rank{$b}} keys %{$order{$pos1}->{$pos2}}) {
			print "subgraph cluster_$pos1$pos2$pos3 {\n";
			my $label = uc("$pos1,$pos2,$pos3");
			$label =~ s/0/*/g;
			print "label=\"Cell ($n1,$n2,$n3) = ($label)\";\n";
			for my $node (@{$order{$pos1}->{$pos2}->{$pos3}}) {
			    print_node ($node);			}
			print "}\n";
			++$n3;
		    }
		    print "}\n";
		    ++$n2;
		}
		print "}\n";
		++$n1;
	    }
#	    print "}\n";
	    $nodes_to_print = 0;
	}
	my ($s1, $s2, $s3) = ($pos1{$src}, $pos2{$src}, $pos3{$src});
	my ($d1, $d2, $d3) = ($pos1{$dest}, $pos2{$dest}, $pos3{$dest});
	my ($s, $d);
	if ($s1 eq "") {
	    ($s, $d) = ($longname{$src}, "cluster_$d1$d2$d3");
	} elsif ($d1 eq "") {
	    ($s, $d) = ("cluster_$s1$s2$s3", $longname{$dest});
	} elsif ($s1 eq $d1) {
	    if ($s2 eq $d2) {
		if ($s3 eq $d3) {
		    next;
#		    ($s, $d) = ($longname{$src}, $longname{$dest});
		} else {
		    ($s, $d) = ("cluster_$s1$s2$s3", "cluster_$d1$d2$d3");
		}
	    } else {
		($s, $d) = ("cluster_$s1$s2$s3", "cluster_$d1$d2");
	    }
	} else {
	    ($s, $d) = ("cluster_$s1$s2", "cluster_$d1");
	}
	unless (defined $edge{$s.$d}) {
	    print "$s -> $d;\n";
	    ++$edge{$s.$d};
	}
    } else {
	print unless /plaintext/;
    }
}

sub print_node {
    my ($node) = @_;
    print "$longname{$node} [shape=$shape{$node}, label=\"\"];\n";
}
