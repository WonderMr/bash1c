use File::stat;
use strict;
#use warnings;
use encoding 'utf8';
use Encode;
use POSIX qw(strftime);
my  %hash_data;

#my $logs = "c:\\v8\\logs";
my $logs = "c:\\v7\\logs";
#my @actions = ("SDBL","EXCP");                                        #список отбираемых событий
my @actions = ("DBMSSQL");                                        #список отбираемых событий
my %action = map { $_ => 1 } @actions;                                #превращаем массив в хэш

sub process_file{
    my $file_name = @_[0];                                            #имя файла - первый параметр
    my @data = ($1,$2,$3,$4,$5,$6) if($file_name=~/[\\\/]{1}([\_\d\w]+)_(\d+)[\\\/]{1}(\d{2})(\d{2})(\d{2})(\d{2})\.log/); #получаем имя процесса, pid, дату и час из пути к файлу
    print "Processing $_[0]\n";
    open(my $fh, '<:encoding(UTF-8)', @_[0]) or die "Could not open file '@_[0]' $!"; #открываем файл
    print "File $_[0] opened\n";
    my $my_event;my $new_event;my $next_is_my;my $found_id;
    my $next=0;
    while (<$fh>){                                                    #читаем построчно
        s/\xef\xbb\xbf//;                                             #replace BOM
        $new_event  = (/\d\d:\d\d\.\d+-\d+,(\w+),/gi);                #содержится ли в строке признак нового события
        $my_event   = ($new_event)&&(exists($action{$1}));            #если это новое событие, то проверяем его наличие в списке отбираемых событий
        $next_is_my = 1 if($my_event || !$new_event);                 #следующая строка тоже наша, если это моё событие и не начало нового события
        #s/\s+/ /g if ($my_event||!$new_event);                        #сворачиваю много пробелов в один, и перенос строки тоже здесь улетит в пробел только на нужных строках
        if(($my_event)&&(/(\d+:\d+\.\d+)\-(\d+),(\w+),(\d+)/)){          #если это новое событие и оно из списка отбираемых событий
            $found_id         = "dt=20$data[2].$data[3].$data[4],time=$data[5]:$1,prc=$data[0],pid=$data[1],dur=$2,evnt=$3,ukn=$4"; #идентификатором будем заголовочная часть строки
            $hash_data{$found_id}  .= $_; #содержимым - всё остальное
        }#добавляю в строки событий dt=ГГГГ.ММ.ДД,time=ЧЧ:ММ:СС.МКСМКС,prc=ИмяПпроцессаИзПути,pid=PidПроцессаИзПути и форматирую dur=длительность,evnt=событие
        else {
          $hash_data{$found_id}      .= $_ if $next_is_my;#в хэш ещё и остаток строки
        }
    }    
    close($fh);    
}
my $z = 0;
dir_walk($logs, \&process_file, sub{ print "Processing $_[0]\n"});
foreach my $item(sort keys %hash_data){
  print "$item\n$hash_data{$item}\n\n";
  $z+=1;
  last if ($z eq 10);
}


# From Higher-Order Perl by Mark Dominus, published by Morgan Kaufmann Publishers
# Copyright 2005 by Elsevier Inc
# LICENSE: http://hop.perl.plover.com/LICENSE.txt

sub dir_walk {
  my ($top, $filefunc, $dirfunc) = @_;
  my $DIR;

  if (-d $top) {
    my $file;
    unless (opendir $DIR, $top) {
      warn "Couldn't open directory: $!; skipping.\n";
      return;
    }

    my @results;
    while ($file = readdir $DIR) {
      next if $file eq '.' || $file eq '..';
      push @results, dir_walk("$top/$file", $filefunc, $dirfunc);
    }
    return $dirfunc->($top, @results);
  } else {
    return $filefunc->($top);
  }
}