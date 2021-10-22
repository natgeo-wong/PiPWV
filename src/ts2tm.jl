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

    nlon  = ereg["size"][1]; lon = reg["lon"];
    nlat  = ereg["size"][2]; lat = reg["lat"];
    dtbeg = Date(dt["Begin"],1)
    dtend = Date(dt["End"],12); ndy = daysinmonth(dtend); dtend = Date(dt["End"],12,ndy)
    dtvec = collect(dtbeg:Month(1):dtend);
    nhr   = length(dtbeg:Day(1):dtend) * 24
    Tmvec = ones(nhr)
    Tsvec = ones(nhr,2)
    amat  = zeros(nlon,nlat)
    bmat  = zeros(nlon,nlat)

    for ilat = 1 : nlat, ilon = 1 : nlon

        @info "$(now()) - PiPWV - Extracting Tm and Ts data for the coordinates ($(lon[ilon]),$(lat[ilat]))"
        
        for dtii in dtvec

            yri   = Year(dtii)
            moi   = Month(dtii)
            ndyii = daysinmonth(dtii)

            dtiib = Date(yri,moi,1)
            dtiie = Date(yri,moi,ndyii)

            ibeg  =  (dtiib - dtbeg).value * 24 + 1
            iend  = ((dtiie - dtbeg).value + 1) * 24

            tmds,tmvar = erarawread(tmmod,tmpar,reg,tmroot,dtii)
            tsds,tsvar = erarawread(tsmod,tspar,reg,tsroot,dtii)

            NCDatasets.load!(tmvar.var,Tmvec[ibeg:iend],ilon,ilat,:)
            NCDatasets.load!(tsvar.var,Tsvec[ibeg:iend,1],ilon,ilat,:)
            
            close(tmds)
            close(tsds)

        end

        @info "$(now()) - PiPWV - Solving for (a,b) at coordinates ($(lon[ilon]),$(lat[ilat]))"

        fsol = Tsvec \ Tmvec
        amat[ilon,iat] = fsol[1]
        bmat[ilon,iat] = fsol[2]

    end

    @save datadir("Ts2Tm.jld2") a b reg

end