
for %%A in (test_gui_1 test_gui_2 test_gui_3) do call :run %%A
exit /b 0

:run
echo Processing parameter %1
call bundle exec rake db:drop & call bundle exec rake db:migrate
echo on
start /MIN cmd /c START_SERVER.bat
call bundle exec rake db:seed & call bundle exec rake db:test:clone & pushd gui-tests & call bundle exec cucumber features -c -t @%1 & popd
call :kill_server
exit /b 0

:kill_server
if not exist tmp\pids\server.pid exit /b 0
setlocal
set /P pid=<tmp\pids\server.pid
echo killing server PID: %pid%
taskkill /f /t /pid %pid%
del tmp\pids\server.pid

endlocal
exit /b 0

for %%A in (test_gui_1 test_gui_2 test_gui_3) do (
bundle exec rake db:drop & bundle exec rake db:migrate
start cmd /k Call START_SERVER.bat
bundle exec rake db:seed & bundle exec rake db:test:clone & pushd gui-tests & bundle exec cucumber features -c -t @%%A & popd
IF EXIST tmp/pids/server.pid (
        set /P pid=<tmp/pids/server.pid
        ::echo %pid%
        taskkill /f /t /pid %pid%
        del tmp\pids\server.pid
        set pid=
)
)
::%%~nA