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

function plotaxs(ID::AbstractString)

    @load datadir("compiled/Pi_$ID.jld2") lon lat Pi_avg Pi_dhr Pi_sea Pi_ian Pi_itr Pi_var

    arr = [[0,1,1,0],[2,2,3,3],[4,4,5,5]]
    pplt.close(); proj = pplt.Proj("robin",lon_0=180); f,axs = pplt.subplots(
        arr,axwidth=3,proj=proj
    )

    normPi!(Pi_avg,Pi_dhr)
    normPi!(Pi_avg,Pi_sea)
    normPi!(Pi_avg,Pi_ian)
    normPi!(Pi_avg,Pi_itr)
    normPi!(Pi_avg,Pi_var)

    c = axs[1].contourf(lon,lat,Pi_avg',cmap="viridis",levels=(52:68)/400,extend="both")
    axs[1].format(
        title=L"$\mu_\Pi$",coast=true,
        suptitle="ID = $ID"
    )
    axs[1].colorbar(c,loc="r",extend="both")

    c = axs[2].contourf(lon,lat,Pi_ian'*100,cmap="viridis",levels=(0:10)/10,extend="max")
    axs[2].format(
        title=L"$\Delta_a\Pi$ / $\%$",coast=true
    )
    axs[2].colorbar(c,loc="r",extend="max")

    c = axs[3].contourf(lon,lat,Pi_dhr'*100,cmap="viridis",levels=(0:10)/5,extend="max")
    axs[3].format(
        title=L"$\Delta_d\Pi$ / $\%$",coast=true
    )
    axs[3].colorbar(c,loc="r",extend="max")

    c = axs[4].contourf(lon,lat,Pi_sea'*100,cmap="viridis",levels=0:15,extend="max")
    axs[4].format(
        title=L"$\Delta_s\Pi$ / $\%$",coast=true
    )
    axs[4].colorbar(c,loc="r",extend="max")

    c = axs[5].contourf(lon,lat,Pi_itr'*100,cmap="viridis",levels=0:8,extend="max")
    axs[5].format(
        title=L"$\Delta_i\Pi$ / $\%$",coast=true
    )
    axs[5].colorbar(c,loc="r",extend="max")

    for ii = 1 : 5
        axs[ii].format(abc=true)
    end

    f.savefig(plotsdir("Pi_$ID.png"),transparent=false,dpi=200)

end

function plotaxs2(ID::AbstractString)

    @load datadir("compiled/Pi_$ID.jld2") lon lat Pi_avg Pi_dhr Pi_sea Pi_ian Pi_itr Pi_var

    arr = [[0,1,1,0],[2,2,3,3]]
    pplt.close(); proj = pplt.Proj("robin",lon_0=180); f,axs = pplt.subplots(
        arr,axwidth=3,proj=proj
    )

    normPi!(Pi_avg,Pi_dhr)
    normPi!(Pi_avg,Pi_sea)
    normPi!(Pi_avg,Pi_ian)
    normPi!(Pi_avg,Pi_itr)
    normPi!(Pi_avg,Pi_var)

    c = axs[1].contourf(lon,lat,Pi_avg',cmap="viridis",levels=(52:68)/400,extend="both")
    axs[1].format(
        title=L"$\mu_\Pi$",coast=true,
        suptitle="ID = $ID"
    )
    axs[1].colorbar(c,loc="r",extend="both")

    c = axs[2].contourf(lon,lat,Pi_sea'*100,cmap="viridis",levels=0:15,extend="max")
    axs[2].format(
        title=L"$\Delta_s\Pi$ / $\%$",coast=true
    )
    axs[2].colorbar(c,loc="r",extend="max")

    c = axs[3].contourf(lon,lat,Pi_itr'*100,cmap="viridis",levels=0:8,extend="max")
    axs[3].format(
        title=L"$\Delta_i\Pi$ / $\%$",coast=true
    )
    axs[3].colorbar(c,loc="r",extend="max")

    for ii = 1 : 3
        axs[ii].format(abc=true)
    end

    f.savefig(plotsdir("Pi_$ID.png"),transparent=false,dpi=200)

end

plotaxs("RE5");
plotaxs("REP"); plotaxs("REI"); plotaxs("RGA")
plotaxs("EBB"); plotaxs("EBM");
plotaxs2("EG2");
plotaxs2("EMN")
