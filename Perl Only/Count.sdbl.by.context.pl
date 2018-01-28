use File::stat;
use strict;
#use warnings;
use encoding 'utf8';
use Encode;
use POSIX qw(strftime);
use Time::HiRes qw(time);
log_it("start");
my  %hash_data;
my  @events;

#my $logs = "c:\\v8\\logs";
my $logs = "c:\\v7\\logs";
#my @actions = ("SDBL","EXCP");                                         #список отбираемых событий
my @actions = ("DBMSSQL");                                              #список отбираемых событий
my %action = map { $_ => 1 } @actions;                                  #превращаем массив в хэш
my $id = -1;                                                            #глобальная переменная элементов массива отобранных записей

sub process_file{    
    my $file_name = @_[0];                                              #имя файла - первый параметр
    my @data = ($1,$2,$3,$4,$5,$6) if($file_name=~/[\\\/]{1}([\_\d\w]+)_(\d+)[\\\/]{1}(\d{2})(\d{2})(\d{2})(\d{2})\.log/); #получаем имя процесса, pid, дату и час из пути к файлу
    log_it("Processing $_[0]\n");
    open(my $fh, '<:encoding(UTF-8)', @_[0]) or die "Could not open file '@_[0]' $!"; #открываем файл
    #my $size = stat($fh)->size / 1024 / 1024;
    #printf("File $_[0] opened. It's size =  %0.2f mb. Prosessing\n", $size);                     #формирую заголовок
    my $my_event = 0;my $new_event = 0;my $next_is_my = 0;my $found_id;
    my $next=0;
    while (<$fh>){                                                      #читаем построчно
        $new_event  = (/\d\d:\d\d\.\d+-\d+,(\w+),/gi);                  #содержится ли в строке признак нового события
        $my_event   = ($new_event)&&(exists($action{$1}));              #если это новое событие, то проверяем его наличие в списке отбираемых событий
        $next_is_my = 1 if($my_event || !$new_event);                   #следующая строка тоже наша, если это моё событие и не начало нового события
        if($my_event||$next_is_my){                                     #очищаем строку от лишнего, если это нужное нам событие
            s/^\x{FEFF}//;                                              #clear BOM
            s/^\N{U+FEFF}//;                                            #clear BOM
            s/^\N{ZERO WIDTH NO-BREAK SPACE}//;                         #clear BOM
            s/^\N{BOM}//;                                               #clear BOM
            s/\s+/ /g;                                                  #empty spaces )) #сворачиваю много пробелов в один, и перенос строки тоже здесь улетит в пробел только на нужных строках
        }                         
        if($my_event&&$new_event){                                      #если это новое событие и оно из списка отбираемых событий
            $id+=1;
            s/(\d+:\d+\.\d+)\-(\d+),(\w+),(\d+)(.*)/dt=20$data[2].$data[3].$data[4],time=$data[5]:$1,prc=$data[0],pid=$data[1],dur=$2,evnt=$3,ukn=$4$5/gi;
            $events[$id]      .= $_; #содержимым - всё остальное
        }#добавляю в строки событий dt=ГГГГ.ММ.ДД,time=ЧЧ:ММ:СС.МКСМКС,prc=ИмяПпроцессаИзПути,pid=PidПроцессаИзПути и форматирую dur=длительность,evnt=событие
        if(!$new_event&&$next_is_my){
          #s/\t/\-/gi                        if $next_is_my;
          $events[$id]      .= $_  if $next_is_my;#в хэш ещё и остаток строки
        }
    }    
    close($fh);    
}
my $z = 0;
dir_walk($logs, \&process_file, sub{ print "Processing $_[0]\n"});
my $dur_ttl;my %dur;my $cnt_ttl;my %cnt;my $k;
log_it("Walk hash");
foreach my $item(@events){
  #print             "$item++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
  #print "$hash_data{$item}\n--------------------------------------------------------------\n";
  #$z+=1;
  #last if ($z eq 15);
  #print "$this_item\n";
  if($item=~/dur=(\d+),evnt=DBMSSQL.*Context=(.*)$/){
        $dur_ttl+=$1/1000;
        $dur{$2}+=$1/1000;
        $cnt_ttl+=1;
        $cnt{$2}+=1;
    }
    END{
        printf("=====TIME TOTAL(ms):%.2f      COUNT:%d      AVG(ms):%.2f\r\n",
            $dur_ttl,
            $cnt_ttl,
            $dur_ttl/(($cnt_ttl ge 1)?$cnt_ttl:1));                     #формирую заголовок
        foreach $k (sort {$dur{$b} <=> $dur{$a}} keys %dur) { #сортирую массив по убыванию длительности и вывожу его
            last if ($_+=1)>10;                     #но только первые 10 строк
            printf "$_: [][][] TIME(ms):%d [][][] TIME(%):%.2f [][][] COUNT:%d [][][] COUNT(%):%.2f [][][] AVG(ms):%d [][][] BY:$k \r\n",
            $dur{$k},                               #абсолютная продолжительность по контексту
            $dur{$k}/($dur_ttl>0?$dur_ttl:1)*100,   #процент продолжительности по времени
            $cnt{$k},                               #абсолютная количество по контексту
            $cnt{$k}/($cnt_ttl>0?$cnt_ttl:1)*100,   #процент количества по контексту
            $dur{$k}/$cnt{$k};                      #среднее время одного контекста
        }
    }
}
my $tm = time - $^T;
print "Job sec is $tm\n";

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

sub log_it{
    my $t                                           =   time;
    my $text                                        =   shift;
    my $datestring                                  =   strftime "%Y.%m.%d %H:%M:%S", localtime;
    $datestring .= sprintf ".%03d", ($t-int($t))*1000; # without rounding
    print "$datestring=$text\n";
}