using DrWatson
@quickactivate "PiPWV"
using ClimateERA

init,eroot = erastartup(aID=1,dID=1,path="/n/holyscratch01/kuang_lab/nwong/ecmwf/");

eradownload(init,eroot,modID="dsfc",parID="t_sfc");
eradownload(init,eroot,modID="dsfc",parID="z_sfc");
eradownload(init,eroot,modID="dsfc",parID="p_sfc");

eradownload(init,eroot,modID="dpre",parID="t_air");
eradownload(init,eroot,modID="dpre",parID="z_air");

eradownload(init,eroot,modID="msfc",parID="t_dew");
eradownload(init,eroot,modID="mpre",parID="shum");
