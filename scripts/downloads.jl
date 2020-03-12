using DrWatson
@quickactivate "PiPWV"
using ClimateERA

global_logger(ConsoleLogger(stdout,Logging.Info))

init,eroot = erastartup(1,1,path="/n/holyscratch01/kuang_lab/lab/ecmwf/");
emod,epar,ereg,etime = erainitialize(init,modID="dsfc",parID="t_sfc",regID="GLB",timeID=0);
eradownload(emod,epar,ereg,etime,eroot)

init,eroot = erastartup(1,1,path="/n/holyscratch01/kuang_lab/lab/ecmwf/");
emod,epar,ereg,etime = erainitialize(init,modID="dsfc",parID="z_sfc",regID="GLB",timeID=0);
eradownload(emod,epar,ereg,etime,eroot)

init,eroot = erastartup(1,1,path="/n/holyscratch01/kuang_lab/lab/ecmwf/");
emod,epar,ereg,etime = erainitialize(init,modID="dpre",parID="t_air",regID="GLB",timeID=0);
eradownload(emod,epar,ereg,etime,eroot)

init,eroot = erastartup(1,1,path="/n/holyscratch01/kuang_lab/lab/ecmwf/");
emod,epar,ereg,etime = erainitialize(init,modID="dpre",parID="z_air",regID="GLB",timeID=0);
eradownload(emod,epar,ereg,etime,eroot)

init,eroot = erastartup(1,1,path="/n/holyscratch01/kuang_lab/lab/ecmwf/");
emod,epar,ereg,etime = erainitialize(init,modID="msfc",parID="t_dew",regID="GLB",timeID=0);
eradownload(emod,epar,ereg,etime,eroot)

init,eroot = erastartup(1,1,path="/n/holyscratch01/kuang_lab/lab/ecmwf/");
emod,epar,ereg,etime = erainitialize(init,modID="mpre",parID="shum",regID="GLB",timeID=0);
eradownload(emod,epar,ereg,etime,eroot)
