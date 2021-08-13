using DrWatson
@quickactivate "PiPWV"

using JLD2
using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

function plotaxs(ID::AbstractString)

    @load datadir("compiled/Tm_$ID.jld2") lon lat Tm_avg Tm_dhr Tm_sea Tm_ian Tm_itr Tm_var
    Tm_tot = Tm_dhr + Tm_ian + Tm_sea + Tm_itr

    pplt.close(); proj = pplt.Proj("robin",lon_0=180)
    f,axs = pplt.subplots(ncols=2,nrows=2,axwidth=3,proj=proj)

    c = axs[1].contourf(lon,lat,(Tm_sea./Tm_tot)'*100,levels=(1:0.5:9)*10,extend="both")
    axs[1].format(title=L"(a) $\delta_s$ / $\delta_t$",coast=true)
    axs[1].colorbar(c,loc="r",extend="both")

    c = axs[2].contourf(lon,lat,(Tm_itr./Tm_tot)'*100,levels=(1:0.5:9)*10,extend="both")
    axs[2].format(title=L"(b) $\delta_i$ / $\delta_t$",coast=true)
    axs[2].colorbar(c,loc="r",extend="both")

    c = axs[3].contourf(lon,lat,(Tm_dhr./Tm_tot)'*100,levels=(1:0.5:9)*5,extend="both")
    axs[3].format(title=L"(c) $\delta_d$ / $\delta_t$",coast=true)
    axs[3].colorbar(c,loc="r",extend="both")

    c = axs[4].contourf(lon,lat,(Tm_ian./Tm_tot)'*100,levels=(1:0.5:9)*5,extend="both")
    axs[4].format(title=L"(d) $\delta_a$ / $\delta_t$",coast=true)
    axs[4].colorbar(c,loc="r",extend="both")

    for ax in axs
        ax.format(suptitle="$ID " * L"$T_m$ / K")
    end

    f.savefig(plotsdir("Tmvar_$ID.png"),transparent=false,dpi=200)

end

function plotaxs2(ID::AbstractString)

    @load datadir("compiled/Tm_$ID.jld2") lon lat Tm_avg Tm_dhr Tm_sea Tm_ian Tm_itr Tm_var
    Tm_tot = Tm_sea + Tm_itr

    pplt.close(); proj = pplt.Proj("robin",lon_0=180)
    f,axs = pplt.subplots(ncols=2,nrows=1,axwidth=3,proj=proj)

    c = axs[1].contourf(lon,lat,(Tm_sea./Tm_tot)'*100,levels=(1:0.5:9)*10,extend="both")
    axs[1].format(title=L"(a) $\delta_s$ / $\delta_t$",coast=true)
    axs[1].colorbar(c,loc="r",extend="both")

    c = axs[2].contourf(lon,lat,(Tm_itr./Tm_tot)'*100,levels=(1:0.5:9)*10,extend="both")
    axs[2].format(title=L"(b) $\delta_i$ / $\delta_t$",coast=true)
    axs[2].colorbar(c,loc="r",extend="both")

    for ax in axs
        ax.format(suptitle="$ID " * L"$T_m$ / K")
    end

    f.savefig(plotsdir("Tmvar_$ID.png"),transparent=false,dpi=200)

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

plotaxs("RE5");
plotaxs("REP"); plotaxs("REI"); plotaxs("RGA")
plotaxs("EBB"); plotaxs("EBM");
# plottwoaxs("EBB","EBM")
plotaxs2("EG2");
# plotaxs2("EMN")
