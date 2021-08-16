using Dates
using ClimateERA
using Logging
using Statistics

function compilePiTm(
    emod::AbstractDict, epar::AbstractDict, ereg::AbstractDict, etime::AbstractDict,
    eroot::AbstractDict;
    ID::AbstractString
)

    @info "$(now()) - PiPWV - Preallocating arrays ..."
    nlon,nlat = ereg["size"]; nt = etime["End"] + 1 - etime["Begin"]; it = 0;
    eavg = zeros(nlon,nlat,nt); erng = zeros(nlon,nlat,nt);
    edhr = zeros(nlon,nlat,nt); eitr = zeros(nlon,nlat,nt); esea = zeros(nlon,nlat,nt);
    PiTm_avg = zeros(nlon,nlat); PiTm_var = zeros(nlon,nlat); PiTm_dhr = zeros(nlon,nlat);
    PiTm_sea = zeros(nlon,nlat); PiTm_ian = zeros(nlon,nlat); PiTm_itr = zeros(nlon,nlat);

    @info "$(now()) - PiPWV - Extracting preliminarily-analyzed reanalysis data ..."
    for yr = etime["Begin"] : etime["End"]
        it = it + 1;
        if !((ID == "RGA") && (yr == 1997));

            eds,evar = eraanaread(
                "domain_yearly_mean_climatology",
                emod,epar,ereg,eroot,Date(yr)
            )
            eavg[:,:,it] = evar[:]
            close(eds)

            ds1,emax = eraanaread(
                "domain_yearly_maximum_climatology",
                emod,epar,ereg,eroot,Date(yr)
            )
            ds2,emin = eraanaread(
                "domain_yearly_minimum_climatology",
                emod,epar,ereg,eroot,Date(yr)
            )
            erng[:,:,it] = emax[:] .- emin[:]
            close(ds1); close(ds2)

            eds,evar = eraanaread(
                "domain_monthly_mean_climatology",
                emod,epar,ereg,eroot,Date(yr)
            )
            esea[:,:,it] = maximum(evar[:],dims=3) .- minimum(evar[:],dims=3)
            close(eds)

            ds1,emax = eraanaread(
                "domain_monthly_maximum_climatology",
                emod,epar,ereg,eroot,Date(yr)
            )
            ds2,emin = eraanaread(
                "domain_monthly_minimum_climatology",
                emod,epar,ereg,eroot,Date(yr)
            )
            eitr[:,:,it] = mean(emax[:] .- emin[:],dims=3)
            close(ds1); close(ds2)

            eds,evar = eraanaread(
                "domain_yearly_mean_hourly",
                emod,epar,ereg,eroot,Date(yr)
            )
            edhr[:,:,it] = maximum(evar[:],dims=3) .- minimum(evar[:],dims=3)
            close(eds)

            erng[:,:,it] = erng[:,:,it] .- (esea[:,:,it] .+ eitr[:,:,it])

        else
            eavg[:,:,it] .= NaN; erng[:,:,it] .= NaN;
            esea[:,:,it] .= NaN; eitr[:,:,it] .= NaN; edhr[:,:,it] .= NaN;
        end
    end

    @info "$(now()) - PiPWV - Calculating yearly mean, and diurnal, seasonal and interannual variability ..."
    for ilat = 1 : nlat, ilon = 1 : nlon
        PiTm_avg[ilon,ilat] = nanmean(@view eavg[ilon,ilat,:])
        PiTm_ian[ilon,ilat] = nanrange(@view eavg[ilon,ilat,:])
        PiTm_var[ilon,ilat] = nanmean(@view erng[ilon,ilat,:])
        PiTm_itr[ilon,ilat] = nanmean(@view eitr[ilon,ilat,:])
        PiTm_sea[ilon,ilat] = nanmean(@view esea[ilon,ilat,:])
        PiTm_dhr[ilon,ilat] = nanmean(@view edhr[ilon,ilat,:])
    end

    return PiTm_avg,PiTm_var,PiTm_dhr,PiTm_itr,PiTm_sea,PiTm_ian

end
