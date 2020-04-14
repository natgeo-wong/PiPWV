using ClimateERA
using JLD2

function PiTm(
    emod::Dict, epar::Dict, ereg::Dict, etime::Dict,
    eroot::Dict, proot::Dict, init::Dict
)

    ID = split(epar["ID"])[end];
    tmod,tpar,_,_ = erainitialize(init,modID="csfc",parID="t_mwv_$ID");

    datevec = collect(Date(etime["Begin"],1):Month(1):Date(etime["End"],12));

    for dtii in datevec

        Tm = erarawread(tmod,tpar,ereg,eroot,dtii);
        Pi = calcTm2Pi.(Tm);
        erarawsave(Pi,emod,epar,ereg,dtii,proot)

    end

    efol = erafolder(emod,epar,ereg,etime,proot,"sfc");
    @save "info_par.jld2" emod epar;
    mv("info_par.jld2",joinpath(efol["var"],"info_par.jld2"),force=true)
    @save "info_reg.jld2" ereg;
    mv("info_reg.jld2",joinpath(efol["reg"],"info_reg.jld2"),force=true)

end

function PiMN(
    emod::Dict, epar::Dict, ereg::Dict, etime::Dict,
    eroot::Dict, proot::Dict, init::Dict
)

    nlon = ereg["size"][1]; nlat = ereg["size"][2];
    lat = ereg["lat"]; ehr = hrind(emod);

    global_logger(ConsoleLogger(stdout,Logging.Warn))
    zmod,zpar,_,_ = erainitialize(init,modID="dsfc",parID="z_sfc");
    global_logger(ConsoleLogger(stdout,Logging.Info))

    @info "$(Dates.now()) - Extracting surface orography information ..."
    zs = mean(erarawread(zmod,zpar,ereg,eroot,Date(2019,12)),dims=3);

    datevec = collect(Date(etime["Begin"],1):Month(1):Date(etime["End"],12));

    for dtii in datevec

        date = DateTime(date);
        dvec = datetime2julian.(collect(date:Hour(ehr):(date+Month(1))));
        ndt = length(dvec);
        Pi  = zeros(nlon,nlat,ndt)

        for it = 1 : ndt, ilat = 1 : nlat, ilon = 1 : nlon
            Pi[ilon,ilat,it] = calcPiMN(lat[ilat],zs[ilon,ilat],dvec[it]);
        end
        Pi = calcPiMN(lat,zs,dtii,ehr);
        erarawsave(Pi,emod,epar,ereg,dtii,proot)

    end

    efol = erafolder(emod,epar,ereg,etime,proot,"sfc");
    @save "info_par.jld2" emod epar;
    mv("info_par.jld2",joinpath(efol["var"],"info_par.jld2"),force=true)
    @save "info_reg.jld2" ereg;
    mv("info_reg.jld2",joinpath(efol["reg"],"info_reg.jld2"),force=true)

end

calcTm2Pi(Tm::Real) = 10^6 / ((3.739e3 / Tm + 0.221) * 461.5181) / 1000;

function calcPiMN(
    lat::Real, zs::Real, date::TimeType
)

    if abs(lat) > 0; hfac = 1.48; else; hfac = 1.25; end
    dy = yearday(date) - 1 + Hour(date)/24;

    Pi = (-sign(lat) * 1.7e-5 * abs(lat)^hfac - 0.0001) * cos((dy-28) * 2 * pi / 365.25)
         + 0.165 - 1.7*10^(-5) * abs(lat)^1.65- 2.38 * 10^-6 * zs

    return Pi

end
