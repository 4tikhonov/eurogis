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

    print "$delim\n";
    if ($titleline)
    {
	@fields = split(/$delim/, $titleline);
	foreach $item (@fields)
	{
	    # Find year
	    # Find location code (amsterdam code)
	    $name = $item;
	    if ($item=~/amsterdam/sxi)
	    {
	  	$name = "ams_code";
	    }
	    elsif ($item=~/(jaar|year)/i)
	    {
		$name = "year";
	    }

	    push(@refields, $name);
	}
	print "@fields => @refields\n";
    }

    return ($titleline, $delim, @dataset);
}
