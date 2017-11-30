#!/usr/bin/perl -w

use POSIX qw(ceil);

#initial dummy variable values for plate details
my @labPlateSerialNo = (32461,5500,21200,17800);
my @labPlateSerialSuffix = ("EXT","QUANT","PCR","CE");
my @labOperationProb = (1,0.95,0.9,0.9);
my @labPlateWellLoc  = (41,21,50,76);
my @labPlateRows = (8,8,24,24);
my @labPlateCols = (12,12,16,16);

my @sgmPlus=(       # marker  low                                                        high
                    # ------- -------------------------------------------------------    ---------------------------------------------------------------
                    [  "D2",  [14..29,15.2,16.2,17.2,18.2,19.2,20.2,21.2,22.2,23.2,
                               24.2,25.2,26.2,27.2,F],                                   [14..29,15.2,16.2,17.2,18.2,19.2,20.2,21.2,22.2,23.2,24.2,
                                                                                          25.2,26.2,27.2]],

                    [  "D3",  [9..21,12.2,13.2,14.2,15.2,16.2,17.2,18.2,F],              [9..21,12.2,13.2,14.2,15.2,16.2,17.2,18.2,F]],

                    [  "D8",  [6..20,8.2,9.2,10.2,11.2,12.2,13.2,14.2,15.2,
                               16.2,17.2,18.2,F],                                        [6..20,8.2,9.2,10.2,11.2,12.2,13.2,14.2,15.2,16.2,17.2,
                                                                                          18.2,F]],

                    [  "D16", [4..16,5.2,6.2,7.2,8.2,9.2,10.2,11.2,12.2,13.2,14.2,F],    [4..16,5.2,6.2,7.2,8.2,9.2,10.2,11.2,12.2,13.2,14.2,F]],

                    [  "D18", [6..28,9.2,10.2,11.2,12.2,13.2,14.2,15.2,16.2,17.2,
                               18.2,19.2,20.2,21.2,22.2,23.2,24.2,25.2,26.2,F],          [6..28,9.2,10.2,11.2,12.2,13.2,14.2,15.2,16.2,17.2,18.2,
                                                                                          19.2,20.2,21.2,22.2,23.2,24.2,25.2,26.2,F]],

                    [  "D19", [7..17,9.2,10.2,11.2,12.1,12.2,13.2,14.2,15.2,16.2,
                              17.2,18.2,F],                                              [7..17,9.2,10.2,11.2,12.1,12.2,13.2,14.2,15.2,16.2,
                                                                                           17.2,18.2,F]],

                    [  "D21", [23..39,24.2,24.3,25.2,26.2,27.2,28.1,28.2,28.3,29.1,
                               29.2,29.3,30.1,30.2,30.3,31.1,31.2,31.3,32.1,32.2,
                               32.3,33.1,33.2,33.3,34.1,34.2,34.3,35.1,35.2,35.3,
                               36.2,37.2,F],                                             [23..39,24.2,24.3,25.2,26.2,27.2,28.1,28.2,28.3,29.1,29.2,
                                                                                          29.3,30.1,30.2,30.3,31.1,31.2,31.3,32.1,32.2,32.3,33.1,
                                                                                          33.2,33.3,34.1,34.2,34.3,35.1,35.2,35.3,36.2,37.2,F]],

                    [  "Amel",    [X,F],                                                 [X,Y,F]],

                    [  "FGA", [16..33,42..51,17.2,18.2,19.2,20.2,21.2,22.2,23.2,
                               24.2,25.2,26.2,27.2,28.2,29.2,30.2,31.2,32.2,33.2,
                               42.2,43.2,44.2,45.2,46.2,47.2,48.2,50.2,51.2,F],          [16..33,42..51,17.2,18.2,19.2,20.2,21.2,22.2,23.2,24.2,
                                                                                          25.2,26.2,27.2,28.2,29.2,30.2,31.2,32.2,33.2,42.2,
                                                                                          43.2,44.2,45.2,46.2,47.2,48.2,50.2,51.2,F]],

                    [  "TH01",[3..13,5.1,5.3,6.1,6.3,7.1,7.3,8.1,8.3,9.1,9.3,13.3,F],    [3..13,5.1,5.3,6.1,6.3,7.1,7.3,8.1,8.3,9.1,9.3,13.3,F]],

                    [  "vWA", [9..25,11.2,12.2,13.2,14.2,15.2,16.2,17.2,18.2,
                               19.2,20.2,21.2,22.2,23.2,24.2,F],                         [9..25,11.2,12.2,13.2,14.2,15.2,16.2,17.2,18.2,
                                                                                          19.2,20.2,21.2,22.2,23.2,24.2,F]]
            );


#shuffle a 1D array of numbers
sub shuffle1D
 {
   my $aOfN=shift;
   for (my $i= @$aOfN;--$i;)
   {
    my $j = int rand($i+1);
    @$aOfN[$i,$j] = @$aOfN[$j,$i];
   }
}



#returns random array element from 1D array
sub rnElement
{
  my $aOfN=shift;
  return @$aOfN[int rand(scalar(@$aOfN))];
}



sub createDNAprofile
{
  my @locusOrder=(0..$#sgmPlus);
  shuffle1D(\@locusOrder);

  print "   \"profile\"  : [\r\n";
  for (my $j=0;$j<scalar(@locusOrder);$j++)
  {
    my $sgmIndex = $locusOrder[$j];                             
                          

    #minimum of a value for one chromosome loci (monosomy)
    #disomy normal/common, other aneuploidy possible althrough rare and accommodating
    #for trisomy, tetrasomy, and pentasomy
    my $one   = rnElement($sgmPlus[$sgmIndex][1]);
    my $two   = rand(100)>5?rnElement($sgmPlus[$sgmIndex][2]):"";
    my $three = rand(100)>98?rnElement($sgmPlus[$sgmIndex][2]):"";
    my $four  = rand(100)>98?rnElement($sgmPlus[$sgmIndex][2]):"";
    my $five  = rand(100)>98?rnElement($sgmPlus[$sgmIndex][2]):"";
    my $desigList = join ',', map qq("$_"), grep { length } ($one, $two, $three, $four, $five);
                                                                                   
    print "                   { \"locus\" : \"$sgmPlus[$sgmIndex][0]\" , \"alleles\" : [$desigList] }".terminalChar(1+$j,scalar(@locusOrder))."\r\n";
  }
  print "               ],\r\n";
}



sub wellLocation
{
  my $rows=shift;
  my $cols=shift;
  my $locationNumeric=shift;

  my $col = ($locationNumeric-1)%$cols +1;
  my $row = ceil(($locationNumeric % ($rows*$cols+1)) / $cols);

  return sprintf("%c%02d", $row+64,$col);
}



#recursively generate extraction, quantitation, pcr, and gel/ce plate information for the lab operation
sub labOperation
{
  my $opType=shift;
  my $probabilityOfFailure = $labOperationProb[$opType];
  if (rand()<=$labOperationProb[$opType])
  {
    printf("   \"plateNumber%s\" : \"%s%08d\",\r\n",$labPlateSerialSuffix[$opType],substr($labPlateSerialSuffix[$opType],0,1),$labPlateSerialNo[$opType]);
    printf("   \"wellLocation%s\" : \"%s\",\r\n",$labPlateSerialSuffix[$opType],wellLocation($labPlateRows[$opType],$labPlateCols[$opType],$labPlateWellLoc[$opType]));

    #increment/reset well location, and/or increment the plate serial number
    if ($labPlateWellLoc[$opType]>=($labPlateRows[$opType]*$labPlateCols[$opType]))
    {
      $labPlateWellLoc[$opType] = 0;
      $labPlateSerialNo[$opType]++; 
    }
    $labPlateWellLoc[$opType]++;

    if ($opType<3)
     {
       labOperation(++$opType);  
     }
    else { createDNAprofile }; #so if a gel/capillary electrophoresis lab operation performed, assume a DNA profile came out of it
  }
}



#in a list, have commas after all items except the terminal char
sub terminalChar
 {
  my $currentIndex=shift;
  my $terminalIndexPosn=shift;
  return $currentIndex<$terminalIndexPosn?',':"";
 }



my @locusOrder=(0..$#sgmPlus); 


if ($#ARGV != 0 ) {
        print "usage: generateSGM+.pl number, eg. \"generateSGM+.pl 3\" will generate 3 dummy DNA lab workflow JSON documents (as an array)\r\n";
        exit;
}

my $noSamples = shift; #the number of SGM+ lab workflow JSON documents to generate

print "[\r\n";
for $sampleID (1..$noSamples)
{
 shuffle1D(\@locusOrder);
 print " {\r\n";

 if (int(rand(1000)) == 500)
 {
  #Just spit out the DNA profile for about 1 in every 1000 without any of the laboratory workflow.
  #This is not an atypical scenario for DNA profiles that have been imported from another laboratory/company, or for
  #samples that are for example Police Elimination profiles. The lab profiles and other traceable information
  #is not provided
  createDNAprofile();
 }
 else 
 {
    print "   \"sampleID\" : $sampleID,\r\n";
    labOperation(0);
 }
 printf("   \"caseID\" : %d\r\n", int(rand(1000000)));
 printf(" }%s\r\n",terminalChar($sampleID,$noSamples));
}
print "]\r\n";


