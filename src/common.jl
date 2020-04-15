using ClimateERA

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
