using ClimateERA
using JLD2

addpiparams() = eraparametersadd(srcdir("piparams.txt"));

function runPiPWV(init::Dict,eroot::Dict,proot::Dict;ID::AbstractString)

    if ID != "EMN"

        emod,epar,ereg,etime = erainitialize(init,modID="csfc",parID="t_mwv_$(ID)");

        if any(ID .== ["RE5","REI"]);     TmDavisz(emod,epar,ereg,etime,eroot,proot,init);
        elseif ID == "REP";               TmDavisp(emod,epar,ereg,etime,eroot,proot,init);
        elseif any(ID .== ["EBB","EBM"]); TmBevis(emod,epar,ereg,etime,eroot,proot,init);
        elseif ID == "EG2";               TmGPT2w(emod,epar,ereg,etime,eroot,proot,init);
        elseif ID == "RGA";               TmGGOSA(emod,epar,ereg,etime,proot);
        end

    end

    emod,epar,ereg,etime = erainitialize(init,modID="csfc",parID="Pi_$(ID)");
    if ID != "EMN"
          PiTm(emod,epar,ereg,etime,proot,proot,init);
    else; PiMN(emod,epar,ereg,etime,eroot,proot,init);
    end

end

function anaPiPWV(init::Dict,eroot::Dict;ID::AbstractString)

    if ID != "EMN"

        emod,epar,ereg,etime = erainitialize(init,modID="csfc",parID="t_mwv_$(ID)");
        for yr = etime["Begin"] : etime["End"]
            eraanalysis(emod,epar,ereg,yr,eroot);
        end

    end

    emod,epar,ereg,etime = erainitialize(init,modID="csfc",parID="Pi_$(ID)");
    for yr = etime["Begin"] : etime["End"]
        eraanalysis(emod,epar,ereg,yr,eroot);
    end

end

function putinfo(emod::Dict,epar::Dict,ereg::Dict,etime::Dict,eroot::Dict)

    rfol = pwd(); efol = erafolder(emod,epar,ereg,etime,eroot,"sfc");
    cd(efol["var"]); @save "info_par.jld2" emod epar;
    cd(efol["reg"]); @save "info_reg.jld2" ereg;
    cd(rfol);

end
