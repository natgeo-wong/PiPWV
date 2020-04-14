using ClimateERA
using JLD2

function PiTm(
    emod::Dict, epar::Dict, ereg::Dict, etime::Dict,
    eroot::Dict, proot::Dict, init::Dict
)

    ID = split(epar["ID"])[end];
    tmod,tpar,_,_ = erainitialize(init,modID="csfc",parID="t_mwv_$ID");
    tbase = eravarfolder(tpar,ereg,eroot);

    datevec = collect(Date(etime["Begin"],1):Month(1):Date(etime["End"],12));

    for dateii in datevec

        Tm = erancread(tbase,erarawname(tmod,tpar,dateii),tpar)[:];
        Pi = calcTm2Pi.(Tm);
        erarawsave(Pi,emod,epar,ereg,dateii,proot)

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

    zmod,zpar,_,_ = erainitialize(init,modID="dsfc",parID="z_sfc");
    zbase = eravarfolder(zpar,ereg,eroot); znc = erarawname(zmod,zpar,ereg,Date(2019,12));
    zs = mean(erancread(zbase,znc,zpar)[:],dims=3); zs[zs.<0] = 0;

    datevec = collect(Date(etime["Begin"],1):Month(1):Date(etime["End"],12));

    for dateii in datevec

        date = DateTime(date);
        dvec = datetime2julian.(collect(date:Hour(ehr):(date+Month(1))));
        nlon = size(zs,1); nlat = length(lat); ndt = length(dvec);
        Pi = zeros(nlon,nlat,ndt)

        for it = 1 : ndt, ilat = 1 : nlat, ilon = 1 : nlon
            Pi[ilon,ilat,it] = calcPiMN(lat[ilat],zs[ilon,ilat],dvec[it]);
        end
        Pi = calcPiMN(lat,zs,dateii,ehr);
        erarawsave(Pi,emod,epar,ereg,dateii,proot)

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
