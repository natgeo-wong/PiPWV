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

    Pi_tot = Pi_dhr + Pi_ian + Pi_sea + Pi_itr + Pi_var

    c = axs[2].contourf(
        lon,lat,(Pi_ian ./ Pi_tot)'*100,
        cmap="viridis",levels=0:5:50
    )
    axs[2].format(
        title=L"$\frac{\Delta_a\Pi}{\Delta_t\Pi}$ / $\%$",coast=true,
        suptitle="$ID"
    )
    axs[2].colorbar(c,loc="r")

    c = axs[3].contourf(
        lon,lat,(Pi_dhr ./ Pi_tot)'*100,
        cmap="viridis",levels=0:5:50
    )
    axs[3].format(
        title=L"$\frac{\Delta_d\Pi}{\Delta_t\Pi}$ / $\%$",coast=true
    )
    axs[3].colorbar(c,loc="r")

    c = axs[4].contourf(
        lon,lat,(Pi_sea ./ Pi_tot)'*100,
        cmap="viridis",levels=0:10:100
    )
    axs[4].format(
        title=L"$\frac{\Delta_s\Pi}{\Delta_t\Pi}$ / $\%$",coast=true
    )
    axs[4].colorbar(c,loc="r")

    c = axs[5].contourf(
        lon,lat,(Pi_itr ./ Pi_tot)'*100,
        cmap="viridis",levels=0:10:100
    )
    axs[5].format(
        title=L"$\frac{\Delta_i\Pi}{\Delta_t\Pi}$ / $\%$",coast=true
    )
    axs[5].colorbar(c,loc="r")

    normPi!(Pi_avg,Pi_tot)
    c = axs[1].contourf(
        lon,lat,Pi_tot'*100,
        cmap="viridis",levels=0:2:20,extend="max"
    )
    axs[1].format(
        title=L"$\Delta_t\Pi$ / $\%$",coast=true,
        suptitle="$ID"
    )
    axs[1].colorbar(c,loc="r",extend="max")

    for ii = 1 : 5
        axs[ii].format(abc=true)
    end

    f.savefig(plotsdir("Pivar_$ID.png"),transparent=false,dpi=200)

end

function plotaxs2(ID::AbstractString)

    @load datadir("compiled/Pi_$ID.jld2") lon lat Pi_avg Pi_dhr Pi_sea Pi_ian Pi_itr Pi_var

    arr = [[0,1,1,0],[2,2,3,3]]
    pplt.close(); proj = pplt.Proj("robin",lon_0=180); f,axs = pplt.subplots(
        arr,axwidth=3,proj=proj
    )

    Pi_tot = Pi_sea + Pi_itr + Pi_var

    c = axs[2].contourf(
        lon,lat,(Pi_sea ./ Pi_tot)'*100,
        cmap="viridis",levels=0:10:100
    )
    axs[2].format(
        title=L"$\frac{\Delta_s\Pi}{\Delta_t\Pi}$ / $\%$",coast=true,
        suptitle="$ID"
    )
    axs[2].colorbar(c,loc="r")

    c = axs[3].contourf(
        lon,lat,(Pi_itr ./ Pi_tot)'*100,
        cmap="viridis",levels=0:10:100
    )
    axs[3].format(
        title=L"$\frac{\Delta_i\Pi}{\Delta_t\Pi}$ / $\%$",coast=true
    )
    axs[3].colorbar(c,loc="r")

    normPi!(Pi_avg,Pi_tot)
    c = axs[1].contourf(
        lon,lat,Pi_tot'*100,
        cmap="viridis",levels=0:2:20,extend="max"
    )
    axs[1].format(
        title=L"$\Delta_t\Pi$ / $\%$",coast=true,
        suptitle="$ID"
    )
    axs[1].colorbar(c,loc="r",extend="max")

    for ii = 1 : 3
        axs[ii].format(abc=true)
    end

    f.savefig(plotsdir("Pivar_$ID.png"),transparent=false,dpi=200)

end

function plottwoaxs(ID1::AbstractString,ID2::AbstractString)

    pplt.close(); proj = pplt.Proj("robin",lon_0=180); f,axs = pplt.subplots(
        nrows=3,ncols=2,axwidth=3,proj=proj
    )

    @load datadir("compiled/Pi_$ID1.jld2") lon lat Pi_avg Pi_dhr Pi_sea Pi_ian Pi_itr Pi_var
    Pi_tot = Pi_dhr + Pi_ian + Pi_sea + Pi_itr + Pi_var

    c = axs[3].contourf(
        lon,lat,(Pi_ian ./ Pi_tot)'*100,
        cmap="viridis",levels=0:5:50
    )
    axs[3].format(
        title=L"$\frac{\Delta_a\Pi}{\Delta_t\Pi}$ / $\%$",coast=true,
    )
    axs[3].colorbar(c,loc="r")

    c = axs[4].contourf(
        lon,lat,(Pi_dhr ./ Pi_tot)'*100,
        cmap="viridis",levels=0:5:50
    )
    axs[4].format(
        title=L"$\frac{\Delta_d\Pi}{\Delta_t\Pi}$ / $\%$",coast=true
    )
    axs[4].colorbar(c,loc="r")

    c = axs[5].contourf(
        lon,lat,(Pi_sea ./ Pi_tot)'*100,
        cmap="viridis",levels=0:10:100
    )
    axs[5].format(
        title=L"$\frac{\Delta_s\Pi}{\Delta_t\Pi}$ / $\%$",coast=true
    )
    axs[5].colorbar(c,loc="r")

    c = axs[6].contourf(
        lon,lat,(Pi_itr ./ Pi_tot)'*100,
        cmap="viridis",levels=0:10:100
    )
    axs[6].format(
        title=L"$\frac{\Delta_i\Pi}{\Delta_t\Pi}$ / $\%$",coast=true
    )
    axs[6].colorbar(c,loc="r")

    normPi!(Pi_avg,Pi_tot)
    c = axs[1].contourf(
        lon,lat,Pi_tot'*100,
        cmap="viridis",levels=0:2:20,extend="max"
    )
    axs[1].format(
        title=string(L"$\Delta_t\Pi$"," ($ID1) / %"),coast=true,
    )
    axs[1].colorbar(c,loc="r",extend="max")

    @load datadir("compiled/Pi_$ID2.jld2") lon lat Pi_avg Pi_dhr Pi_sea Pi_ian Pi_itr Pi_var
    Pi_tot = Pi_dhr + Pi_ian + Pi_sea + Pi_itr + Pi_var

    normPi!(Pi_avg,Pi_tot)
    c = axs[2].contourf(
        lon,lat,Pi_tot'*100,
        cmap="viridis",levels=0:2:20,extend="max"
    )
    axs[2].format(
        title=string(L"$\Delta_t\Pi$"," ($ID2) / %"),coast=true,
    )
    axs[2].colorbar(c,loc="r",extend="max")

    for ii = 1 : 6
        axs[ii].format(abc=true)
    end

    f.savefig(plotsdir("Pivar_$ID1$ID2.png"),transparent=false,dpi=200)

end

# plotaxs("RE5");
# plotaxs("REP"); plotaxs("REI"); plotaxs("RGA")
# plotaxs("EBB"); plotaxs("EBM");
plottwoaxs("EBB","EBM")
# plotaxs2("EG2");
# plotaxs2("EMN")
