rem set datetimef=%date:~-4%_%date:~3,2%_%date:~0,2%__%time:~0,2%_%time:~3,2%_%time:~6,2%
set month=%date:~4,2%
if "%month:~0,1%" == " " set month=0%month:~1,1%
echo month=%month%
set day=%date:~7,2%
if "%day:~0,1%" == " " set day=0%day:~1,1%
echo day=%day%
set year=%date:~10,4%
set datetimef=%:%%year%-%month%-%day%

mv FS17_ContractorMod.zip FS17_ContractorMod_%datetimef%.zip
zip -r FS17_ContractorMod.zip * -x *.bat *.md *.zip