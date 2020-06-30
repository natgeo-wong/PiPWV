using DrWatson
@quickactivate "PiPWV"
using ClimateERA

global_logger(ConsoleLogger(stdout,Logging.Info))
include(srcdir("common.jl"))

init,eroot = erastartup(aID=2,dID=1,path="/n/kuangdss01/users/nwong/PiPWV/");
addpiparams(); anaPiPWV(ID="RE5",init,eroot,proot)
