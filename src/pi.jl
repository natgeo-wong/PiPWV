using Dates
using ClimateERA
using Logging

function PiTm(
    emod::Dict, epar::Dict, ereg::Dict, etime::Dict,
    eroot::Dict, proot::Dict, init::Dict
)

    ID = split(epar["ID"],"_")[end];
    tmod,tpar,_,_ = erainitialize(init,modID="csfc",parID="t_mwv_$ID");

    datevec = collect(Date(etime["Begin"],1):Month(1):Date(etime["End"],12));

    for dtii in datevec

        @info "$(now()) - PiPWV - Extracting Tm data ..."
        tds,tvar = erarawread(tmod,tpar,ereg,eroot,dtii); Tm = tvar[:]*1; close(tds);

        @info "$(now()) - PiPWV - Calculating Askne and Nodius [1985] Pi data for $(dtii) ..."
        Pi = calcTm2Pi.(Tm);

        @info "$(now()) - PiPWV - Saving Askne and Nodius [1985] Pi data for $(dtii) ..."
        erarawsave(Pi,emod,epar,ereg,dtii,proot)

    end

    putinfo(emod,epar,ereg,etime,proot);

end

function PiMN(
    emod::Dict, epar::Dict, ereg::Dict, etime::Dict,
    eroot::Dict, proot::Dict, init::Dict
)

    nlon = ereg["size"][1]; nlat = ereg["size"][2];
    lat = ereg["lat"]; ehr = hrindy(emod);

    disable_logging(Logging.Info)
    zmod,zpar,_,_ = erainitialize(init,modID="dsfc",parID="z_sfc");
    disable_logging(Logging.Debug)

    @info "$(now()) - PiPWV - Extracting surface orography information ..."
    zds,zvar = erarawread(zmod,zpar,ereg,eroot,Date(2019,12));
    zs = mean(zvar[:]*1,dims=3); close(zds);

    datevec = collect(Date(etime["Begin"],1):Month(1):Date(etime["End"],12));

    for dtii in datevec

        @info "$(now()) - PiPWV - Preallocating arrays ..."
        date = DateTime(dtii);
        dvec = collect(date:Hour(24/ehr):(date+Month(1))); pop!(dvec)
        ndt = length(dvec);
        Pi  = Array{Float32,3}(undef,nlon,nlat,ndt)

        @info "$(now()) - PiPWV - Calculating Manandhar [2017] Pi data for $(dtii) ..."
        for it = 1 : ndt, ilat = 1 : nlat, ilon = 1 : nlon
            Pi[ilon,ilat,it] = calcPiMN(lat[ilat],zs[ilon,ilat],dvec[it]);
        end

        @info "$(now()) - PiPWV - Saving Manandhar Pi data for $(dtii) ..."
        erarawsave(Pi,emod,epar,ereg,dtii,proot)

    end

    putinfo(emod,epar,ereg,etime,proot);

end

calcTm2Pi(Tm::Real) = 10^6 / ((3.739e3 / Tm + 0.221) * 461.5181) / 1000;

function calcPiMN(
    lat::Real, zs::Real, date::TimeType
)

    if abs(lat) > 0; hfac = 1.48; else; hfac = 1.25; end
    dy = dayofyear(date) - 1 + hour(date)/24;

    Pi = (-sign(lat) * 1.7e-5 * abs(lat)^hfac - 0.0001) * cos((dy-28) * 2 * pi / 365.25) + 0.165 - 1.7e-5 * abs(lat)^1.65- 2.38 * 10^-6 * zs / 9.81

    return Pi

end
