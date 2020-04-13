using ClimateERA
using JLD2

function TmDavisz(
    emod::Dict, epar::Dict, ereg::Dict, etime::Dict,
    eroot::Dict, proot::Dict, init::Dict
);

    ID = split(epar["ID"],"_")[end]; ehr = hrindy(emod);
    p = erapressure(); np = length(p);

    smod,spar,_,_ = erainitialize(init,modID="dsfc",parID="t_sfc");
    tmod,tpar,_,_ = erainitialize(init,modID="dpre",parID="t_air");
    dmod,dpar,_,_ = erainitialize(init,modID="msfc",parID="t_dew");
    hmod,hpar,_,_ = erainitialize(init,modID="mpre",parID="shum");
    omod,opar,_,_ = erainitialize(init,modID="dsfc",parID="z_sfc");
    zmod,zpar,_,_ = erainitialize(init,modID="dpre",parID="z_air");

    sbase = erarawfolder(spar,ereg,eroot);
    dbase = erarawfolder(dpar,ereg,eroot);
    obase = erarawfolder(opar,ereg,eroot);

    onc = erarawname(omod,opar,ereg,Date(2019,12));
    zs  = mean(erancread(obase,onc,opar)[:],dims=3);

    datevec = collect(Date(etime["Begin"],1):Month(1):Date(etime["End"],12));

    for dateii in datevec

        nhr = ehr * daysinmonth(dateii);
        Ta = zeros(vcat(ereg["size"],nhr,np)); sH = zeros(vcat(ereg["size"],nhr,np));
        za = zeros(vcat(ereg["size"],nhr,np)); Tm = zeros(vcat(ereg["size"],nhr));

        Ts = erancread(sbase,erarawname(smod,spar,dateii),spar)[:];
        Td = erancread(dbase,erarawname(dmod,dpar,dateii),dpar)[:];

        for pii = 1 : np
            tpar["level"] = pii; tbase = erarawfolder(tpar,ereg,eroot);
            hmod["level"] = pii; hbase = erarawfolder(hpar,ereg,eroot);
            zmod["level"] = pii; zbase = erarawfolder(zpar,ereg,eroot);
            Ta[:,:,:,pii] = erancread(tbase,erarawname(tmod,tpar,dateii),tpar)[:];
            sH[:,:,:,pii] = erancread(hbase,erarawname(hmod,hpar,dateii),hpar)[:];
            za[:,:,:,pii] = erancread(zbase,erarawname(zmod,zpar,dateii),zpar)[:];
        end

        for it = 1 : nhr, ilat = 1 : nlat, ilon = 1 : nlon

            Taii = @view Ta[ilon,ilat,it,:]; Tsii = Ta[ilon,ilat,it];
            sHii = @view sH[ilon,ilat,it,:]; Tdii = Td[ilon,ilat,it];
            zaii = @view za[ilon,ilat,it,:]; zsii = zs[ilon,ilat];

            Tmpre = calcTmDaviszd(p,Taii,Tsii,Tdii,sHii,zaii,zsii);
            Tm[ilon,ilat,it] = calcTmsfcz(Tmpre,Tsii,zsii,zaii);

        end

        ncsave(Tm,emod,epar,ereg,dateii,proot)

    end

    efol = erafolder(emod,epar,ereg,etime,proot);
    @save "info_par.jld2" emod epar;
    mv("info_par.jld2",joinpath(efol["var"],"info_par.jld2"),force=true)

end

function TmDavisp(
    emod::Dict, epar::Dict, ereg::Dict, etime::Dict,
    eroot::Dict, proot::Dict, init::Dict
);

    ID = split(epar["ID"],"_")[end]; ehr = hrindy(emod);
    p = erapressure(); np = length(p);

    smod,spar,_,_ = erainitialize(init,modID="dsfc",parID="t_sfc");
    tmod,tpar,_,_ = erainitialize(init,modID="dpre",parID="t_air");
    dmod,dpar,_,_ = erainitialize(init,modID="msfc",parID="t_dew");
    hmod,hpar,_,_ = erainitialize(init,modID="mpre",parID="shum");
    pmod,ppar,_,_ = erainitialize(init,modID="dsfc",parID="p_sfc");

    sbase = erarawfolder(spar,ereg,eroot);
    dbase = erarawfolder(dpar,ereg,eroot);
    pbase = erarawfolder(ppar,ereg,eroot);

    datevec = collect(Date(etime["Begin"],1):Month(1):Date(etime["End"],12));

    for dateii in datevec

        nhr = ehr * daysinmonth(dateii);
        Ta = zeros(vcat(ereg["size"],nhr,np)); sH = zeros(vcat(ereg["size"],nhr,np));
        Tm = zeros(vcat(ereg["size"],nhr));

        Ts = erancread(sbase,erarawname(smod,spar,dateii),spar)[:];
        Td = erancread(dbase,erarawname(dmod,dpar,dateii),dpar)[:];
        ps = erancread(pbase,erarawname(pmod,ppar,dateii),ppar)[:];

        for pii = 1 : np
            tpar["level"] = pii; tbase = erarawfolder(tpar,ereg,eroot);
            hmod["level"] = pii; hbase = erarawfolder(hpar,ereg,eroot);
            Ta[:,:,:,pii] = erancread(tbase,erarawname(tmod,tpar,dateii),tpar)[:];
            sH[:,:,:,pii] = erancread(hbase,erarawname(hmod,hpar,dateii),hpar)[:];
        end

        for it = 1 : nhr, ilat = 1 : nlat, ilon = 1 : nlon

            Taii = @view Ta[ilon,ilat,it,:]; Tsii = Ta[ilon,ilat,it];
            sHii = @view sH[ilon,ilat,it,:]; Tdii = Td[ilon,ilat,it];
            psii = zs[ilon,ilat,it];

            Tmpre = calcTmDavispd(p,Taii,Tsii,Tdii,sHii);
            Tm[ilon,ilat,it] = calcTmsfcp(Tmpre,psii,p);

        end

        ncsave(Tm,emod,epar,ereg,etime,proot)

    end

    efol = erafolder(emod,epar,ereg,etime,proot);
    @save "info_par.jld2" emod epar;
    mv("info_par.jld2",joinpath(efol["var"],"info_par.jld2"),force=true)

end

function TmBevis(
    emod::Dict, epar::Dict, ereg::Dict, etime::Dict,
    eroot::Dict, proot::Dict, init::Dict
)

    ID = split(epar["ID"],"_")[end]; lat = ereg["lat"]; ehr = hrindy(emod);
    a,b = calcTmBevisab(ID,lat);
    tmod,tpar,_,_ = erainitialize(init,modID="dsfc",parID="t_sfc");
    tbase = erarawfolder(tpar,ereg,eroot);
    datevec = collect(Date(etime["Begin"],1):Month(1):Date(etime["End"],12));

    #for dateii in datevec
        dateii = datevec[1]
        nhr = ehr * daysinmonth(dateii);
        Ts = erancread(tbase,erarawname(tmod,tpar,ereg,dateii),tpar)[:]*1;
        Tm = deepcopy(Ts); nlon,nlat,nt = size(Tm);

        for it = 1 : nhr, ilat = 1 : nlat, ilon = 1 : nlon
            Tm[ilon,ilat,it] = calcTmBevis(Ts[ilon,ilat,it],a[ilat],b[ilat]);
        end

        #ncsave(Tm,emod,epar,ereg,etime,proot)

    #end

    # efol = erafolder(emod,epar,ereg,etime,proot);
    # @save "info_par.jld2" emod epar;
    # mv("info_par.jld2",joinpath(efol["var"],"info_par.jld2"),force=true)

    return Tm

end

function TmGGOSA(
    emod::Dict, epar::Dict, ereg::Dict, etime::Dict, proot::Dict
)

    if emod["datasetID"] != 2
        error("$(Dates.now()) - The GGOS Atmosphere dataset is based on ERA-Interim reanalysis output.  Therefore for comparison purposes the only valid dataset is ERA-Interim.")
    end

    ggosdir = datadir("GGOS")
    ID = split(epar["ID"])[end]; lon = ereg["lon"]; lat = ereg["lat"];
    datevec = collect(Date(etime["Begin"],1):Month(1):Date(etime["End"],12));

    for dateii in datevec

        dii  = ggostimeii(dateii);
        gTm  = erancread(ggosdir,ggosname(dateii),"t_mwv")[:,:,dii];
        glon = erancread(ggosdir,ggosname(dateii),"longitude")[:]*1;
        glat = erancread(ggosdir,ggosname(dateii),"latitude")[:]*1;

        Tm = calcTmGGOSA(gTm,lon,lat,glon,glat);
        ncsave(Tm,emod,epar,ereg,etime,proot);

    end

    efol = erafolder(emod,epar,ereg,etime,proot);
    @save "info_par.jld2" emod epar;
    mv("info_par.jld2",joinpath(efol["var"],"info_par.jld2"),force=true)

end

function TmGPT2w(
    emod::Dict, epar::Dict, ereg::Dict, etime::Dict, proot::Dict
)

    ID = split(epar["ID"],"_")[end];
    lon = ereg["lon"]; lat = ereg["lat"]; ehr = hrstep(emod);
    datevec = collect(Date(etime["Begin"],1):Month(1):Date(etime["End"],12));
    zmod,zpar,_,_ = erainitialize(init,modID="dsfc",parID="z_sfc");
    zbase = erarawfolder(zpar,ereg,eroot); znc = erarawname(zmod,zpar,ereg,Date(2019,12));
    zs = mean(erancread(zbase,znc,zpar)[:],dims=3); nlon,nlat = size(zs);

    for dateii in datevec

        Tm = calcTmGPT2w(lon,lat,zs,dateii,ehr); ncsave(Tm,emod,epar,ereg,etime,proot);

    end

    efol = erafolder(emod,epar,ereg,etime,proot);
    @save "info_par.jld2" emod epar;
    mv("info_par.jld2",joinpath(efol["var"],"info_par.jld2"),force=true)

end
