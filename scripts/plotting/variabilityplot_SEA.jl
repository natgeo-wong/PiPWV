using DrWatson
@quickactivate "PiPWV"

using JLD2
using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

function plotaxs(ID::AbstractString)

    @load datadir("compiled/Tm_$ID.jld2") lon lat Tm_avg Tm_dhr Tm_sea Tm_ian Tm_itr Tm_var
    Tm_tot = Tm_dhr + Tm_ian + Tm_sea + Tm_itr

    coast = readdlm(srcdir("GLB-i.txt"),comments=true,comment_char='#')
    x = coast[:,1]; y = coast[:,2];

    f,axs = pplt.subplots(ncols=2,nrows=2,axwidth=3,aspect=15/7)

    c = axs[1].contourf(lon,lat,(Tm_sea./Tm_tot)'*100,levels=(1:0.5:9)*10,extend="both")
    axs[1].format(title=L"(a) $\delta_s$ / $\delta_t$")
    axs[1].colorbar(c,loc="r",extend="both")

    c = axs[2].contourf(lon,lat,(Tm_itr./Tm_tot)'*100,levels=(1:0.5:9)*10,extend="both")
    axs[2].format(title=L"(b) $\delta_i$ / $\delta_t$")
    axs[2].colorbar(c,loc="r",extend="both")

    c = axs[3].contourf(lon,lat,(Tm_dhr./Tm_tot)'*100,levels=(1:0.5:9)*5,extend="both")
    axs[3].format(title=L"(c) $\delta_d$ / $\delta_t$")
    axs[3].colorbar(c,loc="r",extend="both")

    c = axs[4].contourf(lon,lat,(Tm_ian./Tm_tot)'*100,levels=(1:0.5:9)*5,extend="both")
    axs[4].format(title=L"(d) $\delta_a$ / $\delta_t$")
    axs[4].colorbar(c,loc="r",extend="both")

    for ax in axs
        ax.plot(x,y,lw=0.5,c="k")
        ax.format(
            suptitle="$ID " * L"$T_m$ / K",
            xlim=(90,165),xlocator=90:15:165,
            ylim=(-15,20),ylocator=-15:5:20,
        )
    end

    f.savefig(plotsdir("Tmvar_SEA_$ID.png"),transparent=false,dpi=200)

end

function plotaxs2(ID::AbstractString)

    @load datadir("compiled/Tm_$ID.jld2") lon lat Tm_avg Tm_dhr Tm_sea Tm_ian Tm_itr Tm_var
    Tm_tot = Tm_sea + Tm_itr

    coast = readdlm(srcdir("GLB-i.txt"),comments=true,comment_char='#')
    x = coast[:,1]; y = coast[:,2];

    pplt.close(); proj = pplt.Proj("robin",lon_0=180)
    f,axs = pplt.subplots(ncols=2,nrows=1,axwidth=3,aspect=15/7)

    c = axs[1].contourf(lon,lat,(Tm_sea./Tm_tot)'*100,levels=(1:0.5:9)*10,extend="both")
    axs[1].format(title=L"(a) $\delta_s$ / $\delta_t$")
    axs[1].colorbar(c,loc="r",extend="both")

    c = axs[2].contourf(lon,lat,(Tm_itr./Tm_tot)'*100,levels=(1:0.5:9)*10,extend="both")
    axs[2].format(title=L"(b) $\delta_i$ / $\delta_t$")
    axs[2].colorbar(c,loc="r",extend="both")

    for ax in axs
        ax.plot(x,y,lw=0.5,c="k")
        ax.format(
            suptitle="$ID " * L"$T_m$ / K",
            xlim=(90,165),xlocator=90:15:165,
            ylim=(-15,20),ylocator=-15:5:20,
        )
    end

    f.savefig(plotsdir("Tmvar_SEA_$ID.png"),transparent=false,dpi=200)

end

plotaxs("RE5");
plotaxs("REP"); plotaxs("REI"); plotaxs("RGA")
plotaxs("EBB"); plotaxs("EBM");
# plottwoaxs("EBB","EBM")
plotaxs2("EG2");
# plotaxs2("EMN")
