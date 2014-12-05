#!/usr/bin/perl

$DEBUG = 0;
while (<>)
{
    $str = $_;
#    print "$str";
    $data.=$str;
}

($title, @data) = preprocessing($data, $DEBUG);
print "$title\n";

sub preprocessing
{
    ($str, $DEBUG) = @_;
    $str=~s/\r/\n/g;

    @data = split(/\n/, $str);
    $titleline = '';
    foreach $item (@data)
    {
	$item=~s/\;$//g;
	$item=~s/\,$//g;
	$titleline = $item unless ($titleline);
	push(@dataset, $item);
        # Found delimiter
        $delstr = $item;
        $delstr=~s/\w+//g;
    
	@delim = split(//, $delstr);
	for $d (@delim)
	{
	   $stats{$d}++;
	}
        print "$item => @delim\n" if ($DEBUG);
    }

    # Find delimiter
    for $curdelim (sort {$stats{$b} <=> $stats{$a}} keys %stats)
    {
	$delim = $curdelim unless ($delim);
	break;
    }

    print "$delim\n" if ($DEBUG);
    $DEBUG = 1;
    my ($origfieldshash, $refhash) = analyze_fields($titleline, $delim, $DEBUG);
    return ($titleline, $delim, @dataset);
}

sub analyze_fields
{
    my ($titleline, $delim, $DEBUG) = @_;
    my @origfields;

    if ($titleline)
    {
	@fields = split(/$delim/, $titleline);
	for ($i=0; $i<=$#fields; $i++)
	{
	    $item = $fields[$i];
	    $item=~s/^\"|\"$//g;
	    push(@origfields, "o_".$item);
	    print "[DEBUG] $i $item\n" if ($DEBUG);
	    # Find year
	    # Find location code (amsterdam code)
	    $name = $item;
	    my $rname;
	    if ($item=~/amsterdam/sxi)
	    {
	  	$rname = "amsterdam_code";
	    }
	    elsif ($item=~/(jaar|year)/i)
	    {
		$rname = "year";
	    }
	    elsif ($item=~/value/i)
	    {
	 	$rname = "value";
	    }

	    if ($rname)
	    { 
		$refnames{$rname} = $i;
		print "[DEBUG] $rname $i\n" if ($DEBUG);
	    }
	}
	print "[DEBUG] @origfields\n" if ($DEBUG);
    }

    return (\@origfields, \%refnames);
}
