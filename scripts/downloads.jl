using DrWatson
@quickactivate "PiPWV"
using ClimateERA

global_logger(ConsoleLogger(stdout,Logging.Info))

init,eroot = erastartup(1,1,"/n/holyscratch01/kuang_lab/lab/ecmwf/");
emod,epar,ereg,etime = erainitialize(1,3,1,0,init);
eradownload(emod,epar,ereg,etime,eroot)

init,eroot = erastartup(1,1,"/n/holyscratch01/kuang_lab/lab/ecmwf/");
emod,epar,ereg,etime = erainitialize(1,7,1,0,init);
eradownload(emod,epar,ereg,etime,eroot)

init,eroot = erastartup(1,1,"/n/holyscratch01/kuang_lab/lab/ecmwf/");
emod,epar,ereg,etime = erainitialize(2,4,1,0,init);
eradownload(emod,epar,ereg,etime,eroot)

init,eroot = erastartup(1,1,"/n/holyscratch01/kuang_lab/lab/ecmwf/");
emod,epar,ereg,etime = erainitialize(2,5,1,0,init);

init,eroot = erastartup(1,1,"/n/holyscratch01/kuang_lab/lab/ecmwf/");
emod,epar,ereg,etime = erainitialize(3.7,1,0,init);
eradownload(emod,epar,ereg,etime,eroot)

init,eroot = erastartup(1,1,"/n/holyscratch01/kuang_lab/lab/ecmwf/");
emod,epar,ereg,etime = erainitialize(4,3,1,0,init);
eradownload(emod,epar,ereg,etime,eroot)
