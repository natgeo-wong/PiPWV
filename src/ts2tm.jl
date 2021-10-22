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

            ibeg  =  (dtiib - dtbeg).value * 24 + 1
            iend  = ((dtiie - dtbeg).value + 1) * 24

            tmds,tmvar = erarawread(tmmod,tmpar,reg,tmroot,dtii)
            tsds,tsvar = erarawread(tsmod,tspar,reg,tsroot,dtii)

            NCDatasets.load!(tmvar.var,Tmvec[:,ibeg:iend],  :,ilat,:)
            NCDatasets.load!(tsvar.var,Tsvec[:,ibeg:iend,1],:,ilat,:)
            
            close(tmds)
            close(tsds)

        end

        @info "$(now()) - PiPWV - Solving for (a,b) for all longitude points at the latitude band $(lat[ilat])"

        for ilon = 1 : nlon

            fsol = (@view Tsvec[ilon,:,:]) \ @view (Tmvec[ilon,:])
            amat[ilon,iat] = fsol[1]
            bmat[ilon,iat] = fsol[2]

        end

    end

    @save datadir("Ts2Tm.jld2") a b reg

end