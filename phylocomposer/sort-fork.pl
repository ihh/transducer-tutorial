#!/usr/bin/perl -w

my %match = map (($_ => $_), qw(S E W D M I));

my %global = ('Start' => 'SSS',
	      'End' => 'EEE');

my %global_short = ('Start' => 'SS',
		    'End' => 'EE');

my (@nodes, %name, %longname, %root, %shape);
my $nodes_to_print = 0;
while (<>) {
    if (/^\s*(\S+).*label=<<(.*)>>/) {
	my ($node, $label) = ($1, $2);
	while ($label =~ s/<[^>]+>//) { }
	if ($label =~ /([\*\-])([SWEMDI]).([SWEMDI])([\*\-])([SWEMDI])([\*\-])/) {
	    my ($input, $root, $tkf1, $out1, $tkf2, $out2) = ($1, $2, $3, $4, $5, $6);
	    my $name = $tkf1.$tkf2;
	    my $longname = $root.$name;
	    die "Duplicate name $name:  $longname  $longname{$node}" if exists $name{$node};
	    ++$root{$root};
	    $name{$node} = $name;
	    $longname{$node} = $longname;
	    my $has_input = $input eq '*';
	    my $has_output = $out1 eq '*' || $out2 eq '*';
	    $shape{$node} =
		$has_input
		? ($has_output
		   ? 'rectangle, color=red'
		   : 'invhouse, color=red')
		: ($has_output
		   ? 'house, color=red'
		   : ("$root$tkf1$tkf2" eq "WWW"
		      ? 'octagon, color=red'
		      : 'circle'));
	} else {
	    $longname{$node} = $global{$node};
	    $name{$node} = $global_short{$node};
	    $shape{$node} =
		$node eq 'Start'
		? 'circle, color=red'
		: ($node eq 'End'
		   ? 'diamond, color=red'
		   : 'circle');
	}
	push @nodes, $node;
	$nodes_to_print = 1;
    } elsif (/(\S+)\s*->\s*(\S+)/) {
	my ($src, $dest) = ($1, $2);
	if ($nodes_to_print) {
	    print "rankdir=LR;\n";
	    for my $node (@nodes) {
		print_node ($node);
	    }
	    $nodes_to_print = 0;
	}
	print "$src -> $dest;\n";
    } else {
	print unless /plaintext/;
    }
}

sub print_node {
    my ($node) = @_;
#    my $label = $root{'M'} ? $name{$node} : $longname{$node};
    my $label = $longname{$node};
    print "$node [shape=$shape{$node}, label=\"\$$label\$\"];\n";
}
