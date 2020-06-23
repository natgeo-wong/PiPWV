using DrWatson
@quickactivate "PiPWV"

using JLD2
using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

function normPi!(Piavg::Array{<:Real,2},Pistat::Array{<:Real,2})

    nlon,nlat = size(Piavg)
    for ilat = 1 : nlat, ilon = 1 : nlon
        Pistat[ilon,ilat] = Pistat[ilon,ilat] / Piavg[ilon,ilat]
    end

    return

end

function plotaxs(ID::AbstractString,cID::AbstractString="RE5")

    @load datadir("compiled/Pi_$cID.jld2") lon lat Pi_avg Pi_dhr Pi_sea Pi_ian Pi_itr
    cID_avg = Pi_avg; cID_dhr = Pi_dhr; cID_sea = Pi_sea;
    cID_ian = Pi_ian; cID_itr = Pi_itr;
    @load datadir("compiled/Pi_$ID.jld2") lon lat Pi_avg Pi_dhr Pi_sea Pi_ian Pi_itr

    arr = [[0,1,1,0],[2,2,3,3],[4,4,5,5]]
    pplt.close(); proj = pplt.Proj("robin",lon_0=180); f,axs = pplt.subplots(
        arr,axwidth=3,proj=proj
    )

    normPi!(Pi_avg,Pi_dhr); normPi!(Pi_avg,Pi_sea); normPi!(Pi_avg,Pi_ian);
    normPi!(Pi_avg,Pi_itr);
    normPi!(cID_avg,cID_dhr); normPi!(cID_avg,cID_sea); normPi!(cID_avg,cID_ian);
    normPi!(cID_avg,cID_itr);

    c = axs[1].contourf(
        lon,lat,((Pi_avg.-cID_avg)./cID_avg)'*100,
        cmap="RdBu_r",levels=-3:0.5:3,
        extend="both"
    )
    axs[1].format(
        title=string(L"$\mu_\Pi$"," ($ID-$cID)/$cID / %"),coast=true,
    )
    axs[1].colorbar(c,loc="r",extend="both")

    c = axs[2].contourf(
        lon,lat,(Pi_ian.-cID_ian)'*100,
        cmap="RdBu_r",levels=(-5:5)/10,
        extend="both"
    )
    axs[2].format(
        title=string(L"$\Delta_a\Pi$"," ($ID-$cID) / %"),coast=true
    )
    axs[2].colorbar(c,loc="r",extend="both")

    c = axs[3].contourf(
        lon,lat,(Pi_dhr.-cID_dhr)'*100,
        cmap="RdBu_r",levels=-1.5:0.25:1.5,
        extend="both"
    )
    axs[3].format(
        title=string(L"$\Delta_d\Pi$"," ($ID-$cID) / %"),coast=true
    )
    axs[3].colorbar(c,loc="r",extend="both")

    c = axs[4].contourf(
        lon,lat,(Pi_sea.-cID_sea)'*100,
        cmap="RdBu_r",levels=-5:5,
        extend="both"
    )
    axs[4].format(
        title=string(L"$\Delta_s\Pi$"," ($ID-$cID) / %"),coast=true
    )
    axs[4].colorbar(c,loc="r",extend="both")

    c = axs[5].contourf(
        lon,lat,(Pi_itr.-cID_itr)'*100,
        cmap="RdBu_r",levels=-5:5,
        extend="both"
    )
    axs[5].format(
        title=string(L"$\Delta_i\Pi$"," ($ID-$cID) / %"),coast=true
    )
    axs[5].colorbar(c,loc="r",extend="both")

    for ii = 1 : 5
        axs[ii].format(abc=true)
    end

    f.savefig(plotsdir("Pidiff_$(ID)v$(cID).png"),transparent=false,dpi=200)

end

function plotaxs2(ID::AbstractString,cID::AbstractString="RE5")

    @load datadir("compiled/Pi_$cID.jld2") lon lat Pi_avg Pi_dhr Pi_sea Pi_ian Pi_itr
    cID_avg = Pi_avg; cID_dhr = Pi_dhr; cID_sea = Pi_sea;
    cID_ian = Pi_ian; cID_itr = Pi_itr;
    @load datadir("compiled/Pi_$ID.jld2") lon lat Pi_avg Pi_dhr Pi_sea Pi_ian Pi_itr

    arr = [[0,1,1,0],[2,2,3,3]]
    pplt.close(); proj = pplt.Proj("robin",lon_0=180); f,axs = pplt.subplots(
        arr,axwidth=3,proj=proj
    )

    normPi!(Pi_avg,Pi_dhr); normPi!(Pi_avg,Pi_sea); normPi!(Pi_avg,Pi_ian);
    normPi!(Pi_avg,Pi_itr);
    normPi!(cID_avg,cID_dhr); normPi!(cID_avg,cID_sea); normPi!(cID_avg,cID_ian);
    normPi!(cID_avg,cID_itr);

    c = axs[1].contourf(
        lon,lat,((Pi_avg.-cID_avg)./cID_avg)'*100,
        cmap="RdBu_r",levels=-3:0.5:3,extend="both"
    )
    axs[1].format(
        title=string(L"$\mu_\Pi$"," ($ID-$cID)/$cID / %"),coast=true,
    )
    axs[1].colorbar(c,loc="r",extend="both")

    c = axs[2].contourf(
        lon,lat,(Pi_sea.-cID_sea)'*100,
        cmap="RdBu_r",levels=-5:5,extend="both"
    )
    axs[2].format(
        title=string(L"$\Delta_s\Pi$"," ($ID-$cID)/ %"),coast=true
    )
    axs[2].colorbar(c,loc="r",extend="both")

    c = axs[3].contourf(
        lon,lat,(Pi_itr.-cID_itr)'*100,
        cmap="RdBu_r",levels=-5:5,extend="both"
    )
    axs[3].format(
        title=string(L"$\Delta_i\Pi$"," ($ID-$cID) / %"),coast=true
    )
    axs[3].colorbar(c,loc="r",extend="both")

    for ii = 1 : 3
        axs[ii].format(abc=true)
    end

    f.savefig(plotsdir("Pidiff_$(ID)v$(cID).png"),transparent=false,dpi=200)

end

# plotaxs("REP");
# plotaxs("REI");
# plotaxs("RGA");; plotaxs("RGA","REI");
# plotaxs("EBB");
plotaxs("EBM");
#
# plotaxs2("EG2"); plotaxs2("EG2","REI");
# plotaxs2("EMN");
