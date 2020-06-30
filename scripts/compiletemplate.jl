using DrWatson
@quickactivate "PiPWV"
using ClimateERA

global_logger(ConsoleLogger(stdout,Logging.Info))
include(srcdir("common.jl"))

init,eroot = erastartup(aID=2,dID=1,path="/n/kuangdss01/users/nwong/PiPWV/");
compilePiPWV(ID="RE5",init,eroot)
compilePiPWV(ID="REP",init,eroot)
compilePiPWV(ID="EBB",init,eroot)
compilePiPWV(ID="EBM",init,eroot)
compilePiPWV(ID="EMN",init,eroot)

init,eroot = erastartup(aID=2,dID=2,path="/n/kuangdss01/users/nwong/PiPWV/");
compilePiPWV(ID="REI",init,eroot)
compilePiPWV(ID="RGA",init,eroot)
