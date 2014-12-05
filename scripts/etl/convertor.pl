#!/usr/bin/perl

$DEBUG = 0;
$DEBUGALL = 0;
$file = $ARGV[0];
open(file, $file);
while (<file>)
{
    $str = $_;
    $data.=$str;
}
close(file);

($title, $delim, $datahash, $fieldshash, $refhash) = preprocessing($data, $DEBUG);

open(convfile, ">$file.out.csv");
if ($datahash)
{
   %data = %{$datahash};
   %ref = %{$refhash};
   %fields = %{$fieldshash};
   my $titleline;
   foreach $i (sort keys %fields)
   {
	$titleline.="$fields{$i}$delim"
   }
   foreach $i (sort keys %ref)
   {
	$titleline.="$i$delim"
   }
   $titleline=~s/$delim$//g;
   print convfile "$titleline\n";

   foreach $lID (sort keys %data)
   {
	my %values = %{$data{$lID}};
	my $datavalue;
	print "D $lID " if ($DEBUGALL);
	foreach $i (sort keys %fields)
	{
	   my $field = $fields{$i};
	   my $value = $values{$i};
	   $datavalue.="$value$delim";
	   print "	$field $value\n" if ($DEBUGALL);
	}
	foreach $i (sort keys %ref)
	{
	   my $value = $values{$ref{$i}};
	   $datavalue.="$value$delim";
	   print "	$i $value\n" if ($DEBUGALL);
	}

	# Save datavalue 
	$datavalue=~s/$delim$//g;
	print convfile "$datavalue\n";
   }
};
close(convfile);

sub preprocessing
{
    ($str, $DEBUG) = @_;
    my (%dataset, @tmpdataset);
    $str=~s/\r/\n/g;

    @data = split(/\n/, $str);
    $titleline = '';
    foreach $item (@data)
    {
	$item=~s/\;$//g;
	$item=~s/\,$//g;
	$titleline = $item unless ($titleline);
	push(@tmpdataset, $item) if ($item=~/\w+/);
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
    my ($origfieldshash, $refhash) = analyze_fields($titleline, $delim, $DEBUG);
    my $lID = 0;
    foreach $datavalue (@tmpdataset)
    {
	my @data = split(/$delim/, $datavalue);
	for ($i=0; $i<=$#data; $i++)
	{
	    if ($lID)
	    {
	       $value = $data[$i];
	       $value=~s/^\"|\"$//g;
	       $dataset{$lID}{$i} = $value;
	    };
	}
	$lID++;
    }

    return ($titleline, $delim, \%dataset, $origfieldshash, $refhash);
}

sub analyze_fields
{
    my ($titleline, $delim, $DEBUG) = @_;
    my %origfields;

    if ($titleline)
    {
	@fields = split(/$delim/, $titleline);
	for ($i=0; $i<=$#fields; $i++)
	{
	    $item = $fields[$i];
	    $item=~s/^\"|\"$//g;
	    $origfields{$i} = "o_".$item;

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

    return (\%origfields, \%refnames);
}
