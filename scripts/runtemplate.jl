using DrWatson
@quickactivate "PiPWV"
using ClimateERA

include(srcdir("tm.jl"))
include(srcdir("pi.jl"))
include(srcdir("common.jl"))

init,eroot = erastartup(aID=2,dID=1,path="/n/holyscratch01/kuang_lab/nwong/ecmwf/");
init,proot = erastartup(aID=2,dID=1,path="/n/kuangdss01/users/nwong/PiPWV",welcome=false);
addpiparams(); runPiPWV(ID="EBB",init,eroot,proot)
