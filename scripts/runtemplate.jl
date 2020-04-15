using DrWatson
@quickactivate "PiPWV"
using ClimateERA

global_logger(ConsoleLogger(stdout,Logging.Info))

include(srcdir("tm.jl"))
include(srcdir("pi.jl"))
include(srcdir("common.jl"))

init,eroot = erastartup(aID=2,dID=1,path=datadir());
init,proot = erastartup(aID=2,dID=1,path=datadir(),welcome=false);
addpiparams(); runPiPWV(ID="EBB",init,eroot,proot)
