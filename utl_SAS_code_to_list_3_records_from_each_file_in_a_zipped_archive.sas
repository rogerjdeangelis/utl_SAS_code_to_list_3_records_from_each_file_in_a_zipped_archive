SAS code to list 3 records from each file in a zipped archive;

see
https://goo.gl/JSsT7W
https://stackoverflow.com/questions/48301313/code-to-list-the-content-of-zipped-text-files-in-cmd-or-sas


INPUT (three csv file)
================

  d:\csv\class.csv

    NAME,SEX,AGE,HEIGHT,WEIGHT
    Alfred,M,14,69,112.5
    Alice,F,13,56.5,84
    Barbara,F,13,65.3,98
    ....

  d:\csv\cars.csv

    MAKE,MODEL,TYPE,ORIGIN,DRIVETRAIN,MSRP,INVOICE,ENGINESIZE,CYLINDERS,HORSEPOWER,MPG_CITY,MPG_HIGHWAY,WEIGHT,WHEELBASE,LENGTH
    Acura,MDX,SUV,Asia,All,"$36,945","$33,337",3.5,6,265,17,23,4451,106,189
    Acura,RSX Type S 2dr,Sedan,Asia,Front,"$23,820","$21,761",2,4,200,24,31,2778,101,172
    Acura,TSX 4dr,Sedan,Asia,Front,"$26,990","$24,647",2.4,4,200,22,29,3230,105,183

  d:\csv\iris.csv

    SPECIES,SEPALLENGTH,SEPALWIDTH,PETALLENGTH,PETALWIDTH
    Setosa,50,33,14,2
    Setosa,46,34,14,3
    Setosa,46,36,10,2
    ,,

PROCESS (all the code)
======================

  ZIP the three csv files

    %utl_fkil(d:\zip\archive.zip);  * delete if exist;
    filename foo ZIP 'd:\zip\archive.zip';

    data _null_;
      do fyls="class","cars","iris";
          call symputx("fyl",fyls);
          rc=dosubl('
            data _null_;
               infile "d:\csv\&fyl..csv";
               input;
               file foo(&fyl..csv);
               put _infile_;
            run;quit;
          ');
      end;
   run;quit;

   *
   data _null_;
     if _n_=0 then do;
       * get contents of archive;
       * getting meta data is often more comples than the extraction of files;
       %let rc=%sysfunc(dosubl('
         data _null_;
             length memname $32 mems $200;
             retain mems;
             fid=dopen("inzip");
             memcount=dnum(fid);
             do i=1 to memcount;
                 memname=dread(fid,i);
                 mems=catx(",",mems,quote(trim(memname)));
             end;
             call symputx("mems",mems);
             rc=dclose(fid);
             stop;
         run;quit;
       '));
      end;

      * cycle through members of the archive;
      do mem=&mems;
        call symputx("mem",mem);
        rc=dosubl('
          data _null_;
            length filename $250;
            infile inzip(&mem.) filename=filename;
            input;
            if filename ne lag(filename) then putlog filename= "member= &mem." /;
            if _n_ < 4 then putlog _infile_;
          run;quit;
        ');
      end;
      stop;
   run;quit;

OUTPUT (unzip and list 3 records from each file)
================================================

    FILENAME=d:\zip\archive.zip  member= class.csv

    NAME,SEX,AGE,HEIGHT,WEIGHT
    Alfred,M,14,69,112.5
    Alice,F,13,56.5,84


    FILENAME=d:\zip\archive.zip  member= cars.csv

    MAKE,MODEL,TYPE,ORIGIN,DRIVETRAIN,MSRP,INVOICE,ENGINESIZE,CYLINDERS,HORSEPOWER,MPG_CITY,MPG_HIGHWAY,WE
    Acura,MDX,SUV,Asia,All,"$36,945","$33,337",3.5,6,265,17,23,4451,106,189
    Acura,RSX Type S 2dr,Sedan,Asia,Front,"$23,820","$21,761",2,4,200,24,31,2778,101,172


    FILENAME=d:\zip\archive.zip member= iris.csv

    SPECIES,SEPALLENGTH,SEPALWIDTH,PETALLENGTH,PETALWIDTH
    Setosa,50,33,14,2
    Setosa,46,34,14,3

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;
  * create three csv files;
  dm "dexport sashelp.class 'd:\csv\class.csv' replace";
  dm "dexport sashelp.iris 'd:\csv\iris.csv' replace";
  dm "dexport sashelp.cars 'd:\csv\cars.csv' replace";

  or type on Classic editor command line

   dexport sashelp.class 'd:\csv\class.csv' replace

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;
 %utl_fkil(d:\zip\archive.zip);  * delete if exist;
 filename foo ZIP 'd:\zip\archive.zip';

 data _null_;
   do fyls="class","cars","iris";
       call symputx("fyl",fyls);
       rc=dosubl('
         data _null_;
            infile "d:\csv\&fyl..csv";
            input;
            file foo(&fyl..csv);
            put _infile_;
         run;quit;
       ');
   end;
run;quit;

*
data _null_;
  if _n_=0 then do;
    * get contents of archive;
    * getting meta data is often more comples than the extraction of files;
    %let rc=%sysfunc(dosubl('
      data _null_;
          length memname $32 mems $200;
          retain mems;
          fid=dopen("inzip");
          memcount=dnum(fid);
          do i=1 to memcount;
              memname=dread(fid,i);
              mems=catx(",",mems,quote(trim(memname)));
          end;
          call symputx("mems",mems);
          rc=dclose(fid);
          stop;
      run;quit;
    '));
   end;

   * cycle through members of the archive;
   do mem=&mems;
     call symputx("mem",mem);
     rc=dosubl('
       data _null_;
         length filename $250;
         infile inzip(&mem.) filename=filename;
         input;
         if filename ne lag(filename) then putlog filename= "member= &mem." /;
         if _n_ < 4 then putlog _infile_;
       run;quit;
     ');
   end;
   stop;
run;quit;

