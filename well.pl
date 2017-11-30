#!/usr/bin/perl -w
use POSIX qw(ceil floor);

sub wellLocation
{
  my $rows=shift;
  my $cols=shift;
  my $locationNumeric=shift;

  my $col = ($locationNumeric-1)%$cols +1;
  my $row = ceil(($locationNumeric % ($rows*$cols+1)) / $cols);
 
  return sprintf("%c%02d", $row+64,$col);
}

#96 well plate test
#for $i (1..(8*12)) 
#{
#  print(wellLocation(8, 12, $i)."\r\n");
#}


#384 well plate test
for $i (1..(16*24))
{
  print(wellLocation(16, 24, $i)."\r\n");
}
