using DrWatson
@quickactivate "PiPWV"
using ClimateERA

global_logger(ConsoleLogger(stdout,Logging.Info))

include(srcdir("tm.jl"))
include(srcdir("pi.jl"))
include(srcdir("pipwvcommon.jl"))

erawelcome(); addpiparams(); ID = "RE5"
init,eroot = erastartup(aID=2,dID=1,path="/n/holyscratch01/kuang_lab/nwong/ecmwf/");
init,proot = erastartup(aID=2,dID=1,path="/n/kuangdss01/lab/ecmwf/",welcome=false);

emod,epar,ereg,etime = erainitialize(init,modID="csfc",parID="t_mwv_$(ID)");

if any(ID .== ["RE5","REI"])
    include(srcdir("davis.jl")); TmDavisz(emod,epar,ereg,etime,eroot,proot,init);
elseif ID == "REP"
    include(srcdir("davis.jl")); TmDavisp(emod,epar,ereg,etime,eroot,proot,init);
elseif any(ID .== ["EBB","EBM"])
    include(srcdir("bevis.jl")); TmBevis(emod,epar,ereg,etime,eroot,proot,init);
elseif ID == "EG2"
    include(srcdir("gpt2w.jl")); TmGPT2w(emod,epar,ereg,etime,eroot,proot,init);
elseif ID == "RGA"
    include(srcdir("ggosa.jl")); TmGGOSA(emod,epar,ereg,etime,proot,init);
end

emod,epar,ereg,etime = erainitialize(init,modID="csfc",parID="Pi_$(ID)");

if ID == "EMN";
      PiTm(emod,epar,ereg,etime,proot,proot,init);
else; PiMN(emod,epar,ereg,etime,proot,proot,init);
end
