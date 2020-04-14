using ClimateERA
using JLD2

function TmDavisz(
    emod::Dict, epar::Dict, ereg::Dict, etime::Dict,
    eroot::Dict, proot::Dict, init::Dict
);

    @info "$(Dates.now()) - Tm Calculation Method: Davis et al. [1995] in Vertical Coordinates"
    ID = split(epar["ID"],"_")[end]; ehr = hrindy(emod);
    p = ClimateERA.erapressureload(); np = length(p);
    nlon = ereg["size"][1]; nlat = ereg["size"][2];

    global_logger(ConsoleLogger(stdout,Logging.Warn))
    smod,spar,_,_ = erainitialize(init,modID="dsfc",parID="t_sfc");
    tmod,tpar,_,_ = erainitialize(init,modID="dpre",parID="t_air");
    dmod,dpar,_,_ = erainitialize(init,modID="msfc",parID="t_dew");
    hmod,hpar,_,_ = erainitialize(init,modID="mpre",parID="shum");
    omod,opar,_,_ = erainitialize(init,modID="dsfc",parID="z_sfc");
    zmod,zpar,_,_ = erainitialize(init,modID="dpre",parID="z_air");
    global_logger(ConsoleLogger(stdout,Logging.Info))

    @info "$(Dates.now()) - Extracting surface orography information ..."
    zs = mean(erarawread(omod,opar,ereg,eroot,Date(2019,12))[:]*1,dims=3);
    datevec = collect(Date(etime["Begin"],1):Month(1):Date(etime["End"],12));
    Taii = zeros(np); sHii = zeros(np); zaii = zeros(np);

    for dtii in datevec

        @info "$(Dates.now()) - Preallocating arrays ..."
        nhr = ehr * daysinmonth(dtii);
        Ta = zeros(nlon,nlat,nhr,np); sH = zeros(nlon,nlat,nhr,np);
        za = zeros(nlon,nlat,nhr,np); Tm = zeros(nlon,nlat,nhr);

        @info "$(Dates.now()) - Extracting Surface-Level data for $(dtii) ..."
        Ts = erarawread(smod,spar,ereg,eroot,dtii)[:]*1;
        Td = erarawread(dmod,dpar,ereg,eroot,dtii)[:]*1;

        @info "$(Dates.now()) - Extracting Pressure-Level data for $(dtii) ..."
        for pii = 1 : np; pre = p[pii];
            tpar["level"] = pre; Ta[:,:,:,pii] = erarawread(tmod,tpar,ereg,eroot,dtii)[:]*1;
            hpar["level"] = pre; sH[:,:,:,pii] = erarawread(hmod,hpar,ereg,eroot,dtii)[:]*1;
            zpar["level"] = pre; za[:,:,:,pii] = erarawread(zmod,zpar,ereg,eroot,dtii)[:]*1;
        end

        @info "$(Dates.now()) - Calculating Davis Tm data for $(dtii) ..."
        for it = 1 : nhr, ilat = 1 : nlat, ilon = 1 : nlon

            Tsii = Ts[ilon,ilat,it]; Tdii = Td[ilon,ilat,it]; zsii = zs[ilon,ilat];
            for ip = 1 : np
                Taii[ip] = Ta[ilon,ilat,it,ip];
                sHii[ip] = sH[ilon,ilat,it,ip];
                zaii[ip] = za[ilon,ilat,it,ip];
            end

            Tmpre = calcTmDaviszd(p,Taii,Tsii,Tdii,sHii,zaii,zsii); Tmpre[1] = 0;
            Tm[ilon,ilat,it] = calcTmsfcz(Tmpre,Tsii,zsii,zaii);

        end

        @info "$(Dates.now()) - Saving Davis Tm data for $(dtii) ..."
        erarawsave(Tm,emod,epar,ereg,dtii,proot)

    end

    efol = erafolder(emod,epar,ereg,etime,proot,"sfc");
    @save "info_par.jld2" emod epar;
    mv("info_par.jld2",joinpath(efol["var"],"info_par.jld2"),force=true)
    @save "info_reg.jld2" ereg;
    mv("info_reg.jld2",joinpath(efol["reg"],"info_reg.jld2"),force=true)

end

function TmDavisp(
    emod::Dict, epar::Dict, ereg::Dict, etime::Dict,
    eroot::Dict, proot::Dict, init::Dict
);

    @info "$(Dates.now()) - Tm Calculation Method: Davis et al. [1995] in Pressure Coordinates"
    ID = split(epar["ID"],"_")[end]; ehr = hrindy(emod);
    p = ClimateERA.erapressureload(); np = length(p);
    nlon = ereg["size"][1]; nlat = ereg["size"][2];

    global_logger(ConsoleLogger(stdout,Logging.Warn))
    smod,spar,_,_ = erainitialize(init,modID="dsfc",parID="t_sfc");
    tmod,tpar,_,_ = erainitialize(init,modID="dpre",parID="t_air");
    dmod,dpar,_,_ = erainitialize(init,modID="msfc",parID="t_dew");
    hmod,hpar,_,_ = erainitialize(init,modID="mpre",parID="shum");
    pmod,ppar,_,_ = erainitialize(init,modID="dsfc",parID="p_sfc");
    global_logger(ConsoleLogger(stdout,Logging.Info))

    datevec = collect(Date(etime["Begin"],1):Month(1):Date(etime["End"],12));
    Taii = zeros(np); sHii = zero(np);

    for dtii in datevec

        @info "$(Dates.now()) - Preallocating arrays ..."
        nhr = ehr * daysinmonth(dtii);
        Ta = zeros(nlon,nlat,nhr,np); sH = zeros(nlon,nlat,nhr,np);
        Tm = zeros(nlon,nlat,nhr);

        @info "$(Dates.now()) - Extracting Surface-Level data for $(dtii) ..."
        Ts = erarawread(smod,spar,ereg,eroot,dtii)[:]*1;
        Td = erarawread(dmod,dpar,ereg,eroot,dtii)[:]*1;
        ps = erarawread(pmod,ppar,ereg,eroot,dtii)[:]*1;

        @info "$(Dates.now()) - Extracting Pressure-Level data for $(dtii) ..."
        for pii = 1 : np; pre = p[pii];
            tpar["level"] = pre; Ta[:,:,:,pii] = erarawread(tmod,tpar,ereg,eroot,dtii)[:]*1;
            hpar["level"] = pre; sH[:,:,:,pii] = erarawread(hmod,hpar,ereg,eroot,dtii)[:]*1;
        end

        @info "$(Dates.now()) - Calculating Davis Tm data for $(dtii) ..."
        for it = 1 : nhr, ilat = 1 : nlat, ilon = 1 : nlon

            Tsii = Ts[ilon,ilat,it]; Tdii = Td[ilon,ilat,it]; psii = ps[ilon,ilat,it];
            for ip = 1 : np
                Taii[ip] = Ta[ilon,ilat,it,ip]; sHii[ip] = sH[ilon,ilat,it,ip];
            end

            Tmpre = calcTmDavispd(p,Taii,Tsii,Tdii,sHii); Tmpre[1] = 0;
            Tm[ilon,ilat,it] = calcTmsfcp(Tmpre,psii,p);

        end

        @info "$(Dates.now()) - Saving Davis Tm data for $(dtii) ..."
        erarawsave(Tm,emod,epar,ereg,dtii,proot)

    end

    efol = erafolder(emod,epar,ereg,etime,proot,"sfc");
    @save "info_par.jld2" emod epar;
    mv("info_par.jld2",joinpath(efol["var"],"info_par.jld2"),force=true)
    @save "info_reg.jld2" ereg;
    mv("info_reg.jld2",joinpath(efol["reg"],"info_reg.jld2"),force=true)

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

        nhr = ehr * daysinmonth(dtii);

        @info "$(Dates.now()) - Extracting Surface Temperature data for $(dtii) ..."
        Ts = erarawread(tmod,tpar,ereg,eroot,dtii)[:]*1;
        Tm = deepcopy(Ts); nlon,nlat,nt = size(Tm);

        @info "$(Dates.now()) - Calculating Bevis Tm data for $(dtii) ..."
        Tm = a .+ b .* Ts;

        @info "$(Dates.now()) - Saving Bevis Tm data for $(dtii) ..."
        erarawsave(Tm,emod,epar,ereg,dtii,proot)

    end

    efol = erafolder(emod,epar,ereg,etime,proot,"sfc");
    @save "info_par.jld2" emod epar;
    mv("info_par.jld2",joinpath(efol["var"],"info_par.jld2"),force=true)
    @save "info_reg.jld2" ereg;
    mv("info_reg.jld2",joinpath(efol["reg"],"info_reg.jld2"),force=true)

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
        gTm  = erancread(ggosdir,ggosname(dtii),"t_mwv")[:,:,tind]*1;
        glon = erancread(ggosdir,ggosname(dtii),"longitude")[:]*1;
        glat = erancread(ggosdir,ggosname(dtii),"latitude")[:]*1;

        @info "$(Dates.now()) - Interpolating GGOS data to GeoRegion Grid for $(dtii) ..."
        Tm = calcTmGGOSA(gTm,lon,lat,glon,glat);

        @info "$(Dates.now()) - Saving GGOS Tm data for $(dtii) ..."
        erarawsave(Tm,emod,epar,ereg,dtii,proot)

    end

    efol = erafolder(emod,epar,ereg,etime,proot,"sfc");
    @save "info_par.jld2" emod epar;
    mv("info_par.jld2",joinpath(efol["var"],"info_par.jld2"),force=true)
    @save "info_reg.jld2" ereg;
    mv("info_reg.jld2",joinpath(efol["reg"],"info_reg.jld2"),force=true)

end

function TmGPT2w(
    emod::Dict, epar::Dict, ereg::Dict, etime::Dict, proot::Dict
)

    @info "$(Dates.now()) - Tm Calculation Method: Derived from GPT2w [Bohm et al., 2015]"
    ID = split(epar["ID"],"_")[end];
    lon = ereg["lon"]; lat = ereg["lat"]; ehr = hrstep(emod);
    datevec = collect(Date(etime["Begin"],1):Month(1):Date(etime["End"],12));

    global_logger(ConsoleLogger(stdout,Logging.Warn))
    zmod,zpar,_,_ = erainitialize(init,modID="dsfc",parID="z_sfc");
    global_logger(ConsoleLogger(stdout,Logging.Info))

    @info "$(Dates.now()) - Extracting surface orography information ..."
    zs = mean(erarawread(zmod,zpar,ereg,eroot,Date(2019,12))[:]*1,dims=3);
    nlon,nlat = size(zs);

    for dtii in datevec

        Tm = calcTmGPT2w(lon,lat,zs,dtii,ehr);
        erarawsave(Tm,emod,epar,ereg,dtii,proot);

    end

    efol = erafolder(emod,epar,ereg,etime,proot,"sfc");
    @save "info_par.jld2" emod epar;
    mv("info_par.jld2",joinpath(efol["var"],"info_par.jld2"),force=true)
    @save "info_reg.jld2" ereg;
    mv("info_reg.jld2",joinpath(efol["reg"],"info_reg.jld2"),force=true)

end
