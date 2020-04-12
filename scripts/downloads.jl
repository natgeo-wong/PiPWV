using DrWatson
@quickactivate "PiPWV"
using ClimateERA

global_logger(ConsoleLogger(stdout,Logging.Info))

init,eroot = erastartup(aID=1,dID=1,path="/n/holyscratch01/kuang_lab/nwong/ecmwf/");

emod,epar,ereg,etime = erainitialize(init,modID="dsfc",parID="t_sfc");
eradownload(emod,epar,ereg,etime,eroot)

emod,epar,ereg,etime = erainitialize(init,modID="dsfc",parID="z_sfc");
eradownload(emod,epar,ereg,etime,eroot)

emod,epar,ereg,etime = erainitialize(init,modID="dpre",parID="t_air");
eradownload(emod,epar,ereg,etime,eroot)

emod,epar,ereg,etime = erainitialize(init,modID="dpre",parID="z_air");
eradownload(emod,epar,ereg,etime,eroot)

emod,epar,ereg,etime = erainitialize(init,modID="msfc",parID="t_dew");
eradownload(emod,epar,ereg,etime,eroot)

emod,epar,ereg,etime = erainitialize(init,modID="mpre",parID="shum");
eradownload(emod,epar,ereg,etime,eroot)

emod,epar,ereg,etime = erainitialize(init,modID="dsfc",parID="p_sfc");
eradownload(emod,epar,ereg,etime,eroot)
