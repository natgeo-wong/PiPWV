using ClimateERA

include(srcdir("davis.jl"));
include(srcdir("bevis.jl"));
include(srcdir("ggosa.jl"));
include(srcdir("bevis.jl"));

function TmDavisz(
    emod::Dict, epar::Dict, ereg::Dict, etime::Dict,
    eroot::Dict, proot::Dict, init::Dict
)

    @info "$(Dates.now()) - Tm Calculation Method: Davis et al. [1995] in Vertical Coordinates"
    ID = split(epar["ID"],"_")[end]; ehr = hrindy(emod);
    p = ClimateERA.erapressureload(); nlon,nlat = ereg["size"]; np = length(p);

    datevec = collect(Date(etime["Begin"],1):Month(1):Date(etime["End"],12));

    global_logger(ConsoleLogger(stdout,Logging.Warn))
    smod,spar,_,_ = erainitialize(init,modID="dsfc",parID="t_sfc");
    tmod,tpar,_,_ = erainitialize(init,modID="dpre",parID="t_air");
    dmod,dpar,_,_ = erainitialize(init,modID="msfc",parID="t_dew");
    hmod,hpar,_,_ = erainitialize(init,modID="mpre",parID="shum");
    omod,opar,_,_ = erainitialize(init,modID="dsfc",parID="z_sfc");
    zmod,zpar,_,_ = erainitialize(init,modID="dpre",parID="z_air");
    global_logger(ConsoleLogger(stdout,Logging.Info))

    @info "$(Dates.now()) - Extracting surface orography information ..."
    ods,ovar = erarawread(omod,opar,ereg,eroot,Date(2019,12));
    zs = mean(ovar[:]*1,dims=3); close(ods);

    Ta = zeros(nlon,nlat,np); sH = zeros(nlon,nlat,np); za = zeros(nlon,nlat,np);
    Taii = zeros(np); sHii = zeros(np); zaii = zeros(np);

    for dtii in datevec

        @info "$(Dates.now()) - Preallocating arrays ..."
        nhr = ehr * daysinmonth(dtii); Tm = zeros(nlon,nlat,nhr);

        @info "$(Dates.now()) - Calculating Davis Tm data for $(dtii) ..."
        for it = 1 : nhr

            sds,svar = erarawread(smod,spar,ereg,eroot,dtii);
            dds,dvar = erarawread(dmod,dpar,ereg,eroot,dtii);
            Ts = svar[:,:,it]*1; close(sds);
            Td = dvar[:,:,it]*1; close(dds);

            for ip = 1 : np; pre = p[ip];
                tpar["level"] = pre; tds,tvar = erarawread(tmod,tpar,ereg,eroot,dtii);
                hpar["level"] = pre; hds,hvar = erarawread(hmod,hpar,ereg,eroot,dtii);
                zpar["level"] = pre; zds,zvar = erarawread(zmod,zpar,ereg,eroot,dtii);
                Ta[:,:,ip] = tvar[:,:,it]*1; close(tds);
                sH[:,:,ip] = hvar[:,:,it]*1; close(hds);
                za[:,:,ip] = zvar[:,:,it]*1; close(zds);
            end

            for ilat = 1 : nlat, ilon = 1 : nlon

                Tsii = Ts[ilon,ilat]; Tdii = Td[ilon,ilat]; zsii = zs[ilon,ilat];
                for ip = 1 : np
                    Taii[ip] = Ta[ilon,ilat,ip];
                    sHii[ip] = sH[ilon,ilat,ip];
                    zaii[ip] = za[ilon,ilat,ip];
                end

                Tmpre = calcTmDaviszd(p,Taii,Tsii,Tdii,sHii,zaii,zsii); Tmpre[1] = Taii[1];
                Tm[ilon,ilat,it] = calcTmsfcz(Tmpre,Tsii,zsii,zaii);

            end

        end

        @info "$(Dates.now()) - Saving Davis Tm data for $(dtii) ..."
        erarawsave(Tm,emod,epar,ereg,dtii,proot)

    end

    putinfo(emod,epar,ereg,etime,proot);

end

function TmDavisp(
    emod::Dict, epar::Dict, ereg::Dict, etime::Dict,
    eroot::Dict, proot::Dict, init::Dict
)

    @info "$(Dates.now()) - Tm Calculation Method: Davis et al. [1995] in Pressure Coordinates"
    ID = split(epar["ID"],"_")[end]; ehr = hrindy(emod);
    p = ClimateERA.erapressureload(); np = length(p); nlon,nlat = ereg["size"];

    datevec = collect(Date(etime["Begin"],1):Month(1):Date(etime["End"],12));

    global_logger(ConsoleLogger(stdout,Logging.Warn))
    smod,spar,_,_ = erainitialize(init,modID="dsfc",parID="t_sfc");
    tmod,tpar,_,_ = erainitialize(init,modID="dpre",parID="t_air");
    dmod,dpar,_,_ = erainitialize(init,modID="msfc",parID="t_dew");
    hmod,hpar,_,_ = erainitialize(init,modID="mpre",parID="shum");
    pmod,ppar,_,_ = erainitialize(init,modID="dsfc",parID="p_sfc");
    global_logger(ConsoleLogger(stdout,Logging.Info))

    Ta = zeros(nlon,nlat,np); sH = zeros(nlon,nlat,np);
    Taii = zeros(np); sHii = zeros(np);

    for dtii in datevec

        @info "$(Dates.now()) - Preallocating arrays ..."
        nhr = ehr * daysinmonth(dtii); Tm = zeros(nlon,nlat,nhr);

        @info "$(Dates.now()) - Calculating Davis Tm data for $(dtii) ..."
        for it = 1 : nhr

            sds,svar = erarawread(smod,spar,ereg,eroot,dtii);
            dds,dvar = erarawread(dmod,dpar,ereg,eroot,dtii);
            pds,pvar = erarawread(pmod,ppar,ereg,eroot,dtii);
            Ts = svar[:,:,it]*1; close(sds);
            Td = dvar[:,:,it]*1; close(dds);
            ps = pvar[:,:,it]/100; close(pds);

            for ip = 1 : np; pre = p[ip];
                tpar["level"] = pre; tds,tvar = erarawread(tmod,tpar,ereg,eroot,dtii);
                hpar["level"] = pre; hds,hvar = erarawread(hmod,hpar,ereg,eroot,dtii);
                Ta[:,:,ip] = tvar[:,:,it]*1; close(tds);
                sH[:,:,ip] = hvar[:,:,it]*1; close(hds);
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

        @info "$(Dates.now()) - Saving Davis Tm data for $(dtii) ..."
        erarawsave(Tm,emod,epar,ereg,dtii,proot)

    end

    putinfo(emod,epar,ereg,etime,proot);

end

function TmBevis(
    emod::Dict, epar::Dict, ereg::Dict, etime::Dict,
    eroot::Dict, proot::Dict, init::Dict
)

    @info "$(Dates.now()) - Tm Calculation Method: Bevis et al. [1992]"
    ID = split(epar["ID"],"_")[end]; lat = ereg["lat"]; ehr = hrindy(emod);

    @info "$(Dates.now()) - Calculating indices (a,b) ..."
    a,b = calcTmBevisab(ID,lat); a = reshape(a,1,:); b = reshape(b,1,:)

    global_logger(ConsoleLogger(stdout,Logging.Warn))
    tmod,tpar,_,_ = erainitialize(init,modID="dsfc",parID="t_sfc");
    global_logger(ConsoleLogger(stdout,Logging.Info))

    datevec = collect(Date(etime["Begin"],1):Month(1):Date(etime["End"],12));

    for dtii in datevec

        @info "$(Dates.now()) - Extracting Surface Temperature data for $(dtii) ..."
        tds,tvar = erarawread(tmod,tpar,ereg,eroot,dtii); Ts = tvar[:]*1; close(tds);
        Tm = deepcopy(Ts);

        @info "$(Dates.now()) - Calculating Bevis Tm data for $(dtii) ..."
        Tm = a .+ b .* Ts;

        @info "$(Dates.now()) - Saving Bevis Tm data for $(dtii) ..."
        erarawsave(Tm,emod,epar,ereg,dtii,proot)

    end

    putinfo(emod,epar,ereg,etime,proot);

end

function TmGGOSA(
    emod::Dict, epar::Dict, ereg::Dict, etime::Dict, proot::Dict
)

    @info "$(Dates.now()) - Tm Calculation Method: Interpolation from GGOS Atmospheres [Bohm & Schuh, 2013]"
    if emod["datasetID"] != 2
        error("$(Dates.now()) - The GGOS Atmosphere dataset is based on ERA-Interim reanalysis output.  Therefore for comparison purposes the only valid dataset is ERA-Interim.")
    end

    ggosdir = datadir("GGOS")
    ID = split(epar["ID"])[end]; lon = ereg["lon"]; lat = ereg["lat"];
    datevec = collect(Date(etime["Begin"],1):Month(1):Date(etime["End"],12));

    for dtii in datevec

        tind  = ggostimeii(dtii);

        @info "$(Dates.now()) - Extracting GGOS data for $(dtii) ..."
        gds = erancread(ggosname(dtii),ggosdir); gTm = gds["t_mwv"][:,:,tind]*1;
        glon = gds["longitude"][:]*1; glat = gds["latitude"][:]*1; close(gds)

        @info "$(Dates.now()) - Interpolating GGOS data to GeoRegion Grid for $(dtii) ..."
        Tm = calcTmGGOSA(gTm,lon,lat,glon,glat);

        @info "$(Dates.now()) - Saving GGOS Tm data for $(dtii) ..."
        erarawsave(Tm,emod,epar,ereg,dtii,proot)

    end

    putinfo(emod,epar,ereg,etime,proot);

end
