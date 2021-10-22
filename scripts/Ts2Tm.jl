using DrWatson
@quickactivate "PiPWV"
using ClimateERA

include(srcdir("ts2tm.jl")); 

init,tmroot = erastartup(aID=2,dID=1,path="/n/kuangdss01/users/nwong/PiPWV")
init,tsroot = erastartup(aID=2,dID=1,path="/n/kuangdss01/lab")

findts2tm(init,tmroot,tsroot)