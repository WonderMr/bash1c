echo "Все события без фильтров"
time grep -r ".*" -H /c/1c_logs/logs/*/*.log  | \
perl -ne '
    s/\xef\xbb\xbf//;                               #BOM - обязательно в начале, иначе с певой строкой будут проблемы
    if(/log:\d\d:\d\d\.\d+-\d+,(\w+),/){            #если в строке есть идентификатор начала строки и это наш тип события
        if(//){                                     #первоначальный отбор по событиям
            s/\s+/ /g;                              #сворачиваю много пробелов в один, и перенос строки тоже здесь улетит в пробел
            if(s/^.*\/(\w+)_(\d+)\/(\d{2})(\d{2})(\d{2})(\d{2})\.log\:\s*(\d+:\d+\.\d+)\-(\d+),(\w+),(\d+)//){
                $_="\r\n".",dt=20".$3.".".$4.".".$5.",time=".$6.":".$7.",prc=".$1.",pid=".$2.",dur=".$8.",evnt=".$9.",ukn=".$10.$_ ;
            }#добавляю в строки событий dt=ГГГГ.ММ.ДД,time=ЧЧ:ММ:СС.МКСМКС,prc=ИмяПпроцессаИзПути,pid=PidПроцессаИзПути и форматирую dur=длительность,evnt=событие
            $f=1;
        }else{$f=0};
    }
    elsif($f) {                                     #если наше событие, то обрабатываем эту висячую  строку
        s/^.*log://;                                #из перенесённых строк просто вытираю начало
        s/\s+/ /g;                                  #сворачиваю много пробелов в один, и перенос строки тоже здесь улетит в пробел
    }
    if($f){
        s/\x27//g;                                  #убираю апострофы
        print;
    }END{print "\r\n"}                              #надо поставить, чтобы последняя строка в обработку попала
' | \
perl -ne '{
    s/\r\n//g;
    #if(!/CONN/){
    #if(/time=17:[3-9][6]/){
        for (split /(?=\,\w+:*\w*=)/, $_){
            s/,//g;
            print "\r\n".$_."   [][][]   " if(/dt=/);
            print $_."   [][][]   " if(!/dt=/ && !/ukn=/ );
        }
    #}
}' |\
sort |\
head -n 1500