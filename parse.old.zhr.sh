echo "Разрезает файл журнала регистрации старого формата без разбивки по дням на дни"

time cat /c/123/01_03_201720170129000000.lgp  | \
perl -ne 'BEGIN{
        $hdr="1CV8LOG(ver 2.0)\r\na74b9e9d-70f8-4246-8059-3148fc0fff04\r\n\r\n";
    }
    if(/\{(\d{8})\d{6},\w,/){
        $nm=$1;
        $prline=~s/,\r\n// if($fh ne "c:\\123\\".$nm."000000.lgp");                
        open(my $wrt,">>",$fh);        
        $fh="c:\\123\\".$nm."000000.lgp";
        $_=$hdr.$_ if(!(-f $fh));        
        print $wrt $prline;
        
    }else{
        open(my $wrt,">>",$fh);
        print $wrt $prline;    
    }
    $prline=$_;
    END{
        open(my $wrt,">>",$fh);
        print $wrt $prline;
    }
'