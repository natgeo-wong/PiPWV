using DrWatson
@quickactivate "PiPWV"
using ClimateERA
using GeoRegions

gregioninfoadd(srcdir("gregionsadd.txt"))

init,eroot = erastartup(aID=2,dID=1,path="/n/kuangdss01/lab/");
erasubregion(init,eroot,modID="csfc",parID="t_mwv_RE5",regID="NPL");
erasubregion(init,eroot,modID="csfc",parID="Pi_RE5",regID="NPL");
