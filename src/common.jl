using ClimateERA
using JLD2

include(srcdir("compile.jl"))

addpiparams() = eraparameteradd(srcdir("piparams.txt"));

function nanmean(data::AbstractArray)
    dataii = @view data[.!isnan.(data)]
    if dataii != []; return mean(dataii); else; return NaN; end
end

function nanstd(data::AbstractArray)
    dataii = @view data[.!isnan.(data)]
    if dataii != []; return std(dataii); else; return NaN; end
end

function nanrange(data::AbstractArray)
    dataii = @view data[.!isnan.(data)]
    if dataii != []; return maximum(dataii) - minimum(dataii); else; return NaN; end
end

function runPiPWV(
    init::Dict,eroot::Dict,proot::Dict;
    ID::AbstractString,regID::AbstractString="GLB"
)

    if ID != "EMN"

        emod,epar,ereg,etime = erainitialize(
            init,
            modID="csfc",parID="t_mwv_$(ID)",regID=regID
        );

        if     ID == "RE5";               TmDavisz(emod,epar,ereg,etime,eroot,proot,init);
        elseif any(ID .== ["REP","REI"]); TmDavisp(emod,epar,ereg,etime,eroot,proot,init);
        elseif any(ID .== ["EBB","EBM"]); TmBevis(emod,epar,ereg,etime,eroot,proot,init);
        elseif ID == "EG2";               TmGPT2w(emod,epar,ereg,etime,eroot,proot,init);
        elseif ID == "RGA";               TmGGOSA(emod,epar,ereg,etime,proot);
        end

    end

    emod,epar,ereg,etime = erainitialize(init,modID="csfc",parID="Pi_$(ID)",regID=regID);
    if ID != "EMN"
          PiTm(emod,epar,ereg,etime,proot,proot,init);
    else; PiMN(emod,epar,ereg,etime,eroot,proot,init);
    end

end

function anaPiPWV(
    init::Dict,eroot::Dict;
    ID::AbstractString,regID::AbstractString="GLB"
)

    if ID != "EMN"

        emod,epar,ereg,etime = erainitialize(
            init,
            modID="csfc",parID="t_mwv_$(ID)",regID=regID
        );
        for yr = etime["Begin"] : etime["End"]
            if !((ID == "RGA") && (yr == 1997)); eraanalysis(emod,epar,ereg,yr,eroot); end
        end

    end

    emod,epar,ereg,etime = erainitialize(init,modID="csfc",parID="Pi_$(ID)",regID=regID);
    for yr = etime["Begin"] : etime["End"]
        if !((ID == "RGA") && (yr == 1997)); eraanalysis(emod,epar,ereg,yr,eroot); end
    end

end

function compilePiPWV(
    init::Dict,eroot::Dict;
    ID::AbstractString,regID::AbstractString="GLB"
)


    if ID != "EMN"
        emod,epar,ereg,etime = erainitialize(
            init,
            modID="csfc",parID="t_mwv_$(ID)",regID=regID
        );
        lon = ereg["lon"]; lat = ereg["lat"]
        Tm_avg,Tm_var,Tm_dhr,Tm_itr,Tm_sea,Tm_ian = compilePiTm(ID=ID,emod,epar,ereg,etime,eroot)
        if !isdir(datadir("compiled")); mkpath(datadir("compiled")) end
        @save datadir("compiled/Tm_$(ID).jld2") lon lat Tm_avg Tm_var Tm_dhr Tm_itr Tm_sea Tm_ian
    end

    emod,epar,ereg,etime = erainitialize(init,modID="csfc",parID="Pi_$(ID)",regID=regID);
    lon = ereg["lon"]; lat = ereg["lat"]
    Pi_avg,Pi_var,Pi_dhr,Pi_itr,Pi_sea,Pi_ian = compilePiTm(ID=ID,emod,epar,ereg,etime,eroot)
    if !isdir(datadir("compiled")); mkpath(datadir("compiled")) end
    @save datadir("compiled/Pi_$(ID).jld2") lon lat Pi_avg Pi_var Pi_dhr Pi_itr Pi_sea Pi_ian

end

function putinfo(emod::Dict,epar::Dict,ereg::Dict,etime::Dict,eroot::Dict)

    rfol = pwd(); efol = erafolder(emod,epar,ereg,etime,eroot);
    cd(efol["var"]); @save "info_par.jld2" emod epar;
    cd(efol["reg"]); @save "info_reg.jld2" ereg;
    cd(rfol);

end
