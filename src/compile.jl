using ClimateERA
using Statistics

function compilePiTm(
    emod::AbstractDict, epar::AbstractDict, ereg::AbstractDict, etime::AbstractDict,
    eroot::AbstractDict;
    ID::AbstractString
)

    @info "$(Dates.now()) - Preallocating arrays ..."
    nlon,nlat = ereg["size"]; nt = etime["End"] + 1 - etime["Begin"]; it = 0;
    eavg = zeros(nlon,nlat,nt); edhr = zeros(nlon,nlat,nt);
    esea = zeros(nlon,nlat,nt);
    PiTm_avg = zeros(nlon,nlat); PiTm_dhr = zeros(nlon,nlat);
    PiTm_sea = zeros(nlon,nlat); PiTm_ian = zeros(nlon,nlat);

    @info "$(Dates.now()) - Extracting preliminarily-analyzed reanalysis data ..."
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
            esea[:,:,it] = emax[:] .- emin[:]
            close(ds1); close(ds2)

            eds,evar = eraanaread(
                "domain_yearly_mean_diurnalvariance",
                emod,epar,ereg,eroot,Date(yr)
            )
            edhr[:,:,it] = evar[:]
            close(eds)

        else
            eavg[:,:,it] .= NaN; esea[:,:,it] .= NaN; edhr[:,:,it] .= NaN;
        end
    end

    @info "$(Dates.now()) - Calculating yearly mean, and diurnal, seasonal and interannual variability ..."
    for ilat = 1 : nlat, ilon = 1 : nlon
        PiTm_avg[ilon,ilat] = nanmean(@view eavg[ilon,ilat,:])
        PiTm_ian[ilon,ilat] = nanstd(@view eavg[ilon,ilat,:])
        PiTm_sea[ilon,ilat] = nanmean(@view esea[ilon,ilat,:])
        PiTm_dhr[ilon,ilat] = nanmean(@view edhr[ilon,ilat,:])
    end

    return PiTm_avg,PiTm_dhr,PiTm_sea,PiTm_ian

end
