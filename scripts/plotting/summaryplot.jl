using DrWatson
@quickactivate "PiPWV"

using JLD2
using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

function plotaxs(ID::AbstractString)

    @load datadir("compiled/Tm_$ID.jld2") lon lat Tm_avg Tm_dhr Tm_sea Tm_ian Tm_itr Tm_var
    Tm_tot = Tm_dhr + Tm_ian + Tm_sea + Tm_itr + Tm_var

    pplt.close(); proj = pplt.Proj("robin",lon_0=180)
    f,axs = pplt.subplots(ncols=2,nrows=3,axwidth=3,proj=proj)

    x = [60,75,95,175,160,175,115,70,60]
    y = [-5,5,10,5,0,-10,-10,-7,-5]

    c = axs[1].contourf(lon,lat,Tm_avg',levels=270:2.5:290,extend="both")
    axs[1].plot(x,y,lw=0.5,linestyle="--",c="w")
    axs[1].format(title=L"(a) $\mu$",coast=true)
    axs[1].colorbar(c,loc="r",extend="both")

    c = axs[2].contourf(lon,lat,Tm_tot',levels=(1:0.5:10)*10,extend="both")
    axs[2].format(title=L"(b) $\delta_t$",coast=true)
    axs[2].colorbar(c,loc="r",extend="both")

    c = axs[3].contourf(lon,lat,Tm_sea',levels=(1:0.5:9)*5,extend="both")
    axs[3].format(title=L"(c) $\delta_s$",coast=true)
    axs[3].colorbar(c,loc="r",extend="both")

    c = axs[4].contourf(lon,lat,Tm_itr',levels=(1:0.5:9)*5,extend="both")
    axs[4].format(title=L"(d) $\delta_i$",coast=true)
    axs[4].colorbar(c,loc="r",extend="both")

    c = axs[5].contourf(lon,lat,Tm_dhr',levels=(1:10),extend="both")
    axs[5].format(title=L"(e) $\delta_d$",coast=true)
    axs[5].colorbar(c,loc="r",extend="both")

    c = axs[6].contourf(lon,lat,Tm_ian',levels=(1:10),extend="both")
    axs[6].format(title=L"(f) $\delta_a$",coast=true)
    axs[6].colorbar(c,loc="r",extend="both")

    for ax in axs
        ax.format(suptitle="$ID " * L"$T_m$ / K")
    end

    f.savefig(plotsdir("Tm_$ID.png"),transparent=false,dpi=200)

end

function plotaxs2(ID::AbstractString)

    @load datadir("compiled/Tm_$ID.jld2") lon lat Tm_avg Tm_dhr Tm_sea Tm_ian Tm_itr Tm_var
    Tm_tot = Tm_sea + Tm_itr + Tm_var

    pplt.close(); proj = pplt.Proj("robin",lon_0=180)
    f,axs = pplt.subplots(ncols=2,nrows=2,axwidth=3,proj=proj)

    c = axs[1].contourf(lon,lat,Tm_avg',levels=270:2.5:300,extend="both")
    axs[1].format(title=L"(a) $\mu$",coast=true)
    axs[1].colorbar(c,loc="r",extend="both")

    c = axs[2].contourf(lon,lat,Tm_tot',levels=(2:0.5:10)*5,extend="both")
    axs[2].format(title=L"(b) $\delta_t$",coast=true)
    axs[2].colorbar(c,loc="r",extend="both")

    c = axs[3].contourf(lon,lat,Tm_sea',levels=(1:0.5:9)*5,extend="both")
    axs[3].format(title=L"(c) $\delta_s$",coast=true)
    axs[3].colorbar(c,loc="r",extend="both")

    c = axs[4].contourf(lon,lat,Tm_itr',levels=(1:0.5:9)*5,extend="both")
    axs[4].format(title=L"(d) $\delta_i$",coast=true)
    axs[4].colorbar(c,loc="r",extend="both")

    for ax in axs
        ax.format(suptitle="$ID " * L"$T_m$ / K")
    end

    f.savefig(plotsdir("Tm_$ID.png"),transparent=false,dpi=200)

end

plotaxs("ERA5")
plotaxs("ERA5P")
plotaxs("ERAI")
plotaxs("GGOSA")
plotaxs("Bevis")
plotaxs("EBM");
plotaxs2("GPT2w")
plotaxs2("MN2017")
