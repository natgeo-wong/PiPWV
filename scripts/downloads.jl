using DrWatson
@quickactivate "PiPWV"
using ClimateERA

global_logger(ConsoleLogger(stdout,Logging.Info))

init,eroot = erastartup(1,1,"/n/holyscratch01/kuang_lab/lab/ecmwf/");
emod,epar,ereg,etime = erainitialize(init,modID=1,parID=3,regID=1,timeID=0);
eradownload(emod,epar,ereg,etime,eroot)

init,eroot = erastartup(1,1,"/n/holyscratch01/kuang_lab/lab/ecmwf/");
emod,epar,ereg,etime = erainitialize(init,modID=1,parID=7,regID=1,timeID=0);
eradownload(emod,epar,ereg,etime,eroot)

init,eroot = erastartup(1,1,"/n/holyscratch01/kuang_lab/lab/ecmwf/");
emod,epar,ereg,etime = erainitialize(init,modID=2,parID=4,regID=1,timeID=0);
eradownload(emod,epar,ereg,etime,eroot)

init,eroot = erastartup(1,1,"/n/holyscratch01/kuang_lab/lab/ecmwf/");
emod,epar,ereg,etime = erainitialize(init,modID=2,parID=5,regID=1,timeID=0);

init,eroot = erastartup(1,1,"/n/holyscratch01/kuang_lab/lab/ecmwf/");
emod,epar,ereg,etime = erainitialize(init,modID=3,parID=7,regID=1,timeID=0);
eradownload(emod,epar,ereg,etime,eroot)

init,eroot = erastartup(1,1,"/n/holyscratch01/kuang_lab/lab/ecmwf/");
emod,epar,ereg,etime = erainitialize(init,modID=4,parID=3,regID=1,timeID=0);
eradownload(emod,epar,ereg,etime,eroot)
