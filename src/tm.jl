using ClimateERA
using Logging

include(srcdir("davis.jl"));
include(srcdir("bevis.jl"));
include(srcdir("ggosa.jl"));
include(srcdir("bevis.jl"));

function TmDavisz(
    emod::Dict, epar::Dict, ereg::Dict, etime::Dict,
    eroot::Dict, proot::Dict, init::Dict
)

    @info "$(now()) - PiPWV - Tm Calculation Method: Davis et al. [1995] in Vertical Coordinates"
    ID = split(epar["ID"],"_")[end]; ehr = hrindy(emod);
    p = ClimateERA.erapressureload(); nlon,nlat = ereg["size"]; np = length(p);

    datevec = collect(Date(etime["Begin"],1):Month(1):Date(etime["End"],12));

    disable_logging(Logging.Info)
    smod,spar,_,_ = erainitialize(init,modID="dsfc",parID="t_sfc");
    tmod,tpar,_,_ = erainitialize(init,modID="dpre",parID="t_air");
    dmod,dpar,_,_ = erainitialize(init,modID="msfc",parID="t_dew");
    hmod,hpar,_,_ = erainitialize(init,modID="mpre",parID="shum");
    omod,opar,_,_ = erainitialize(init,modID="dsfc",parID="z_sfc");
    zmod,zpar,_,_ = erainitialize(init,modID="dpre",parID="z_air");
    disable_logging(Logging.Debug)

    @info "$(now()) - PiPWV - Extracting surface orography information ..."
    ods,ovar = erarawread(omod,opar,ereg,eroot,Date(2019,12));
    zs = mean(ovar[:]*1,dims=3); close(ods);

    Ts = Array{Float32,3}(undef,nlon,nlat);
    Td = Array{Float32,3}(undef,nlon,nlat);
    Ta = Array{Float32,3}(undef,nlon,nlat,np); Taii = Vector{Float32}(undef,np);
    sH = Array{Float32,3}(undef,nlon,nlat,np); sHii = Vector{Float32}(undef,np);
    za = Array{Float32,3}(undef,nlon,nlat,np); zaii = Vector{Float32}(undef,np);

    for dtii in datevec

        @info "$(now()) - PiPWV - Preallocating arrays ..."
        nhr = ehr * daysinmonth(dtii); Tm = Array{Float32,3}(undef,nlon,nlat,nhr);

        @info "$(now()) - PiPWV - Calculating Davis Tm data for $(dtii) ..."
        for it = 1 : nhr

            sds,svar = erarawread(smod,spar,ereg,eroot,dtii);
            dds,dvar = erarawread(dmod,dpar,ereg,eroot,dtii);
            Ts .= svar[:,:,it]*1; close(sds);
            Td .= dvar[:,:,it]*1; close(dds);

            for ip = 1 : np; pre = p[ip];
                tpar["level"] = pre; tds,tvar = erarawread(tmod,tpar,ereg,eroot,dtii);
                hpar["level"] = pre; hds,hvar = erarawread(hmod,hpar,ereg,eroot,dtii);
                zpar["level"] = pre; zds,zvar = erarawread(zmod,zpar,ereg,eroot,dtii);
                Ta[:,:,ip] .= tvar[:,:,it]*1; close(tds);
                sH[:,:,ip] .= hvar[:,:,it]*1; close(hds);
                za[:,:,ip] .= zvar[:,:,it]*1; close(zds);
            end

            for ilat = 1 : nlat, ilon = 1 : nlon

                Tsii = Ts[ilon,ilat]; Tdii = Td[ilon,ilat]; zsii = zs[ilon,ilat];
                for ip = 1 : np
                    Taii[ip] .= Ta[ilon,ilat,ip];
                    sHii[ip] .= sH[ilon,ilat,ip];
                    zaii[ip] .= za[ilon,ilat,ip];
                end

                Tmpre = calcTmDaviszd(p,Taii,Tsii,Tdii,sHii,zaii,zsii); Tmpre[1] = Taii[1];
                Tm[ilon,ilat,it] = calcTmsfcz(Tmpre,Tsii,zsii,zaii);

            end

        end

        @info "$(now()) - PiPWV - Saving Davis Tm data for $(dtii) ..."
        erarawsave(Tm,emod,epar,ereg,dtii,proot)

    end

    putinfo(emod,epar,ereg,etime,proot);

end

function TmDavisp(
    emod::Dict, epar::Dict, ereg::Dict, etime::Dict,
    eroot::Dict, proot::Dict, init::Dict
)

    @info "$(now()) - PiPWV - Tm Calculation Method: Davis et al. [1995] in Pressure Coordinates"
    ID = split(epar["ID"],"_")[end]; ehr = hrindy(emod);
    p = ClimateERA.erapressureload(); np = length(p); nlon,nlat = ereg["size"];

    datevec = collect(Date(etime["Begin"],1):Month(1):Date(etime["End"],12));

    disable_logging(Logging.Info)
    smod,spar,_,_ = erainitialize(init,modID="dsfc",parID="t_sfc");
    tmod,tpar,_,_ = erainitialize(init,modID="dpre",parID="t_air");
    dmod,dpar,_,_ = erainitialize(init,modID="msfc",parID="t_dew");
    hmod,hpar,_,_ = erainitialize(init,modID="mpre",parID="shum");
    pmod,ppar,_,_ = erainitialize(init,modID="dsfc",parID="p_sfc");
    disable_logging(Logging.Debug)

    Ts = Array{Float32,3}(undef,nlon,nlat);
    Td = Array{Float32,3}(undef,nlon,nlat);
    ps = Array{Float32,3}(undef,nlon,nlat);
    Ta = Array{Float32,3}(undef,nlon,nlat,np); Taii = Vector{Float32}(undef,np);
    sH = Array{Float32,3}(undef,nlon,nlat,np); sHii = Vector{Float32}(undef,np);

    for dtii in datevec

        @info "$(now()) - PiPWV - Preallocating arrays ..."
        nhr = ehr * daysinmonth(dtii); Tm = zeros(nlon,nlat,nhr);

        @info "$(now()) - PiPWV - Calculating Davis Tm data for $(dtii) ..."
        for it = 1 : nhr

            sds,svar = erarawread(smod,spar,ereg,eroot,dtii);
            dds,dvar = erarawread(dmod,dpar,ereg,eroot,dtii);
            pds,pvar = erarawread(pmod,ppar,ereg,eroot,dtii);
            Ts .= svar[:,:,it]*1; close(sds);
            Td .= dvar[:,:,it]*1; close(dds);
            ps .= pvar[:,:,it]/100; close(pds);

            for ip = 1 : np; pre = p[ip];
                tpar["level"] = pre; tds,tvar = erarawread(tmod,tpar,ereg,eroot,dtii);
                hpar["level"] = pre; hds,hvar = erarawread(hmod,hpar,ereg,eroot,dtii);
                Ta[:,:,ip] .= tvar[:,:,it]*1; close(tds);
                sH[:,:,ip] .= hvar[:,:,it]*1; close(hds);
            end

            for ilat = 1 : nlat, ilon = 1 : nlon

                Tsii = Ts[ilon,ilat]; Tdii = Td[ilon,ilat]; psii = ps[ilon,ilat];
                for ip = 1 : np
                    Taii[ip] = Ta[ilon,ilat,ip]; sHii[ip] = sH[ilon,ilat,ip];
                end

                Tmpre = calcTmDavispd(psii,p,Taii,Tsii,Tdii,sHii); Tmpre[1] = Taii[1];
                Tm[ilon,ilat,it] = calcTmsfcp(Tmpre,psii,p);

            end

        end

        @info "$(now()) - PiPWV - Saving Davis Tm data for $(dtii) ..."
        erarawsave(Tm,emod,epar,ereg,dtii,proot)

    end

    putinfo(emod,epar,ereg,etime,proot);

end

function TmBevis(
    emod::Dict, epar::Dict, ereg::Dict, etime::Dict,
    eroot::Dict, proot::Dict, init::Dict
)

    @info "$(now()) - PiPWV - Tm Calculation Method: Bevis et al. [1992]"
    ID = split(epar["ID"],"_")[end]; lat = ereg["lat"]; ehr = hrindy(emod);

    @info "$(now()) - PiPWV - Calculating indices (a,b) ..."
    a,b = calcTmBevisab(ID,lat); a = reshape(a,1,:); b = reshape(b,1,:)

    disable_logging(Logging.Info)
    tmod,tpar,_,_ = erainitialize(init,modID="dsfc",parID="t_sfc");
    disable_logging(Logging.Debug)

    datevec = collect(Date(etime["Begin"],1):Month(1):Date(etime["End"],12));

    for dtii in datevec

        @info "$(now()) - PiPWV - Extracting Surface Temperature data for $(dtii) ..."
        tds,tvar = erarawread(tmod,tpar,ereg,eroot,dtii); Ts = tvar[:]*1; close(tds);
        Tm = deepcopy(Ts);

        @info "$(now()) - PiPWV - Calculating Bevis Tm data for $(dtii) ..."
        Tm = a .+ b .* Ts;

        @info "$(now()) - PiPWV - Saving Bevis Tm data for $(dtii) ..."
        erarawsave(Tm,emod,epar,ereg,dtii,proot)

    end

    putinfo(emod,epar,ereg,etime,proot);

end

function TmGGOSA(
    emod::Dict, epar::Dict, ereg::Dict, etime::Dict, proot::Dict
)

    @info "$(now()) - PiPWV - Tm Calculation Method: Interpolation from GGOS Atmospheres [Bohm & Schuh, 2013]"
    if emod["datasetID"] != 2
        error("$(now()) - PiPWV - The GGOS Atmosphere dataset is based on ERA-Interim reanalysis output.  Therefore for comparison purposes the only valid dataset is ERA-Interim.")
    end

    ggosdir = datadir("GGOS")
    ID = split(epar["ID"])[end]; lon = ereg["lon"]; lat = ereg["lat"];
    datevec = collect(Date(etime["Begin"],1):Month(1):Date(etime["End"],12));

    for dtii in datevec

        tind  = ggostimeii(dtii);

        @info "$(now()) - PiPWV - Extracting GGOS data for $(dtii) ..."
        gds = erancread(ggosname(dtii),ggosdir); gTm = gds["t_mwv"][:,:,tind]*1;
        glon = gds["longitude"][:]*1; glat = gds["latitude"][:]*1; close(gds)

        @info "$(now()) - PiPWV - Interpolating GGOS data to GeoRegion Grid for $(dtii) ..."
        Tm = calcTmGGOSA(gTm,lon,lat,glon,glat);

        @info "$(now()) - PiPWV - Saving GGOS Tm data for $(dtii) ..."
        erarawsave(Tm,emod,epar,ereg,dtii,proot)

    end

    putinfo(emod,epar,ereg,etime,proot);

end

function TmMN(
    emod::Dict, epar::Dict, ereg::Dict, etime::Dict, proot::Dict
)

    @info "$(now()) - PiPWV - Tm Calculation Method: Conversion from Pi calculated using Manandhar [2017]"

    disable_logging(Logging.Info)
    pmod,ppar,_,_ = erainitialize(init,modID="csfc",parID="Pi_EMN");
    disable_logging(Logging.Debug)

    datevec = collect(Date(etime["Begin"],1):Month(1):Date(etime["End"],12));

    for dtii in datevec

        @info "$(now()) - PiPWV - Extracting Manandhar [2017] Pi data for $(dtii) ..."
        pds,pvar = erarawread(pmod,ppar,ereg,eroot,dtii); Π = pvar[:]*1; close(pds);

        @info "$(now()) - PiPWV - Calculating Manandhar [2017] Tm data for $(dtii) ..."
        Tm = calcPi2Tm(Pi)

        @info "$(now()) - PiPWV - Saving Manandhar [2017] Tm data for $(dtii) ..."
        erarawsave(Tm,emod,epar,ereg,dtii,proot)

    end

    putinfo(emod,epar,ereg,etime,proot);

end

calcPi2Tm(Pi::Real) = Pi * 461.5181 * 3.739 * 0.221
