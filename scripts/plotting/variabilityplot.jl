using DrWatson
@quickactivate "PiPWV"

using JLD2
using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

function plotaxs(ID::AbstractString)

    @load datadir("compiled/Tm_$ID.jld2") lon lat Tm_avg Tm_dhr Tm_sea Tm_ian Tm_itr Tm_var
    Tm_tot = Tm_dhr + Tm_ian + Tm_sea + Tm_itr + + Tm_var

    pplt.close(); proj = pplt.Proj("robin",lon_0=180)
    f,axs = pplt.subplots(ncols=2,nrows=2,axwidth=3,proj=proj)

    c = axs[1].contourf(lon,lat,(Tm_sea./Tm_tot)'*100,levels=(1:0.5:9)*10,extend="both")
    axs[1].format(title=L"(a) $\delta_s$ / $\delta_t$",coast=true)
    axs[1].colorbar(c,loc="r",extend="both")

    c = axs[2].contourf(lon,lat,(Tm_itr./Tm_tot)'*100,levels=(1:0.5:9)*10,extend="both")
    axs[2].format(title=L"(b) $\delta_i$ / $\delta_t$",coast=true)
    axs[2].colorbar(c,loc="r",extend="both")

    c = axs[3].contourf(lon,lat,(Tm_dhr./Tm_tot)'*100,levels=(1:0.5:9)*10,extend="both")
    axs[3].format(title=L"(c) $\delta_d$ / $\delta_t$",coast=true)
    axs[3].colorbar(c,loc="r",extend="both")

    c = axs[4].contourf(lon,lat,(Tm_ian./Tm_tot)'*100,levels=(1:0.5:9)*10,extend="both")
    axs[4].format(title=L"(d) $\delta_a$ / $\delta_t$",coast=true)
    axs[4].colorbar(c,loc="r",extend="both")

    for ax in axs
        ax.format(suptitle="$ID " * L"$T_m$ / K")
    end

    f.savefig(plotsdir("Tmvar_$ID.png"),transparent=false,dpi=200)

end

function plotaxs2(ID::AbstractString)

    @load datadir("compiled/Tm_$ID.jld2") lon lat Tm_avg Tm_dhr Tm_sea Tm_ian Tm_itr Tm_var
    Tm_tot = Tm_sea + Tm_itr + + Tm_var

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

plotaxs("RE5")
plotaxs("REP")
plotaxs("REI")
plotaxs("RGA")
plotaxs("EBB")
plotaxs("EBM")
plotaxs2("EG2")
plotaxs2("EMN")
