use File::stat;
my $folder = '/C/1C/Ddd/zhu/fin/';
my $lgf = $folder.'1Cv8.lgf';
open($fh, '<:encoding(UTF-8)', $lgf) or die "Could not open file '$lgf' $!";
while (<$fh>) {
    $id_start =$1 if(/\_\$Session\$\_\.Start\",(\d+)/);
    $id_finish=$1 if(/\_\$Session\$\_\.Finish\",(\d+)/);
    $id_1cv8c =$1 if(/1CV8C\",(\d+)/);
    $id_1cv8  =$1 if(/1CV8\",(\d+)/);
    $id_webc  =$1 if(/WebClient\",(\d+)/);
    $id_dsgnr =$1 if(/Designer\",(\d+)/);
}
close($fh);
open($fout, '>:encoding(UTF-8)', $folder."result.csv") or die "Could not create file $!";
foreach my $lgp(<$folder*.lgp>) {
    my $ttl = 0;
    my %cnt = ();
    open(my $fh, '<', $lgp) or die "Can not open file $!";
    read($fh,$_,stat($fh)->size) or die "Could not read file '$lgp' $!";
    close($fh);
    foreach $item(/\{\d{14},\w,\r*\n\{[0-9abcdef]+,[0-9abcdef]+\},\d+,\d+,[$id_1cv8c,$id_1cv8,$id_webc,$id_dsgnr],\d+,[$id_start,$id_finish],/g){
        $cnt{$1}+=1 if ($item=~/\{(\d{10})\d{4},\w,\r*\n\{[0-9abcdef]+,[0-9abcdef]+\},\d+,\d+,[$id_1cv8c,$id_1cv8,$id_webc,$id_dsgnr],\d+,[$id_start],/g);
        $cnt{$1}-=1 if ($item=~/\{(\d{10})\d{4},\w,\r*\n\{[0-9abcdef]+,[0-9abcdef]+\},\d+,\d+,[$id_1cv8c,$id_1cv8,$id_webc,$id_dsgnr],\d+,[$id_finish],/g);
    }
    foreach $k(sort (keys(%cnt))){
        $ttl+=$cnt{$k};
        if ($k=~/(\d{4})(\d{2})(\d{2})(\d{2})/){
            print $fout "$1.$2.$3 $4:00:00,$ttl\r\n" if($ttl>0);
            print $fout "$1.$2.$3 $4:00:00,0\r\n"  if($ttl<0);#отрицательного количества быть не может
        }
    }
}
