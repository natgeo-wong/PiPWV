using Dates
using ClimateERA
using JLD2
using Logging
using NCDatasets

function findts2tm(
    init   :: Dict,
    tmroot :: Dict,
    tsroot :: Dict
)

    tmmod,tmpar,reg,dt = erainitialize(init,modID="csfc",parID="t_mwv_RE5",timeID=[1979,2019]);
    tsmod,tspar,_,_    = erainitialize(init,modID="dsfc",parID="t_sfc",timeID=[1979,2019]);

    nlon  = reg["size"][1]; lon = reg["lon"];
    nlat  = reg["size"][2]; lat = reg["lat"];
    dtbeg = Date(dt["Begin"],1)
    dtend = Date(dt["End"],12); ndy = daysinmonth(dtend); dtend = Date(dt["End"],12,ndy)
    dtvec = collect(dtbeg:Month(1):dtend);
    nhr   = length(dtbeg:Day(1):dtend) * 24
    Tmvec = ones(nlon,nhr)
    Tsvec = ones(nlon,nhr,2)
    tmp1  = zeros(Int16,nlon,31*24)
    tmp2  = zeros(Int16,nlon,31*24)
    amat  = zeros(nlon,nlat)
    bmat  = zeros(nlon,nlat)

    for ilat = 1 : nlat

        @info "$(now()) - PiPWV - Extracting Tm and Ts data for all longitude points at the latitude band $(lat[ilat])"
        
        for dtii in dtvec

            yri   = year(dtii)
            moi   = month(dtii)
            ndyii = daysinmonth(dtii)

            dtiib = Date(yri,moi,1)
            dtiie = Date(yri,moi,ndyii)

            ibeg  =  (dtiib - dtbeg).value * 24 + 1; @info ibeg

            tmds,tmvar = erarawread(tmmod,tmpar,reg,tmroot,dtii)
            tsds,tsvar = erarawread(tsmod,tspar,reg,tsroot,dtii)

            tmscale = tmvar.attrib["scale_factor"]; tmoff = tmvar.attrib["add_offset"]
            tsscale = tsvar.attrib["scale_factor"]; tsoff = tsvar.attrib["add_offset"]

            NCDatasets.load!(tmvar.var,tmp1[:,1:(ndyii*24)],:,ilat,:)
            NCDatasets.load!(tsvar.var,tmp2[:,1:(ndyii*24)],:,ilat,:)

            for ihr = 1 : (ndyii*24), ilon = 1 : nlon
                Tmvec[ilon,ibeg+ihr-1]   = tmp1[ilon,ihr] * tmscale + tmoff
                Tsvec[ilon,ibeg+ihr-1,1] = tmp2[ilon,ihr] * tsscale + tsoff
            end
            
            close(tmds)
            close(tsds)

        end

        @info "$(now()) - PiPWV - Solving for (a,b) for all longitude points at the latitude band $(lat[ilat])"

        for ilon = 1 : nlon

            fsol = (@view Tsvec[ilon,:,:]) \ (@view Tmvec[ilon,:])
            amat[ilon,iat] = fsol[1]
            bmat[ilon,iat] = fsol[2]

        end

    end

    @save datadir("Ts2Tm.jld2") a b reg

end