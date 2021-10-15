using DrWatson
@quickactivate "PiPWV"

using JLD2
using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

function plotaxs(ID::AbstractString)

    @load datadir("compiled/Tm_ERA5.jld2") lon lat Tm_avg Tm_dhr Tm_sea Tm_ian Tm_itr Tm_var
    R5_avg = Tm_avg; R5_dhr = Tm_dhr; R5_sea = Tm_sea;
    R5_ian = Tm_ian; R5_itr = Tm_itr;

    R5_tot = Tm_dhr + Tm_ian + Tm_sea + Tm_itr + Tm_var
    @load datadir("compiled/Tm_$ID.jld2") lon lat Tm_avg Tm_dhr Tm_sea Tm_ian Tm_itr Tm_var
    Tm_tot = Tm_dhr + Tm_ian + Tm_sea + Tm_itr + Tm_var

    pplt.close(); proj = pplt.Proj("robin",lon_0=180)
    f,axs = pplt.subplots(ncols=2,nrows=3,axwidth=3,proj=proj)
    lvls  = vcat(-5:-1,-0.5,0.5,1:5)*2

    c = axs[1].contourf(lon,lat,(Tm_avg.-R5_avg)',cmap="RdBu_r",levels=lvls,extend="both")
    axs[1].format(title=L"(a) $\mu$ " * "($ID - ERA5) / K",coast=true)

    c = axs[2].contourf(lon,lat,(Tm_tot.-R5_tot)',cmap="RdBu_r",levels=lvls,extend="both")
    axs[2].format(title=L"(b) $\delta_t$ " * "($ID - ERA5) / K",coast=true)

    c = axs[3].contourf(lon,lat,(Tm_sea.-R5_sea)',cmap="RdBu_r",levels=lvls,extend="both")
    axs[3].format(title=L"(c) $\delta_s$ " * "($ID - ERA5) / K",coast=true)

    c = axs[4].contourf(lon,lat,(Tm_itr.-R5_itr)',cmap="RdBu_r",levels=lvls,extend="both")
    axs[4].format(title=L"(d) $\delta_i$ " * "($ID - ERA5) / K",coast=true)

    c = axs[5].contourf(lon,lat,(Tm_dhr.-R5_dhr)',cmap="RdBu_r",levels=lvls,extend="both")
    axs[5].format(title=L"(e) $\delta_d$ " * "($ID - ERA5) / K",coast=true)

    c = axs[6].contourf(lon,lat,(Tm_ian.-R5_ian)',cmap="RdBu_r",levels=lvls,extend="both")
    axs[6].format(title=L"(f) $\delta_a$ " * "($ID - ERA5) / K",coast=true)

    f.colorbar(c,loc="r",extend="both")
    f.savefig(plotsdir("Tmdiff_$ID.png"),transparent=false,dpi=200)

end

function plotaxs2(ID::AbstractString)

    @load datadir("compiled/Tm_ERA5.jld2") lon lat Tm_avg Tm_dhr Tm_sea Tm_ian Tm_itr Tm_var
    R5_avg = Tm_avg; R5_sea = Tm_sea; R5_itr = Tm_itr;
    R5_tot = Tm_sea + Tm_itr + Tm_var

    @load datadir("compiled/Tm_$ID.jld2") lon lat Tm_avg Tm_dhr Tm_sea Tm_ian Tm_itr Tm_var
    Tm_tot = Tm_sea + Tm_itr + Tm_var

    pplt.close(); proj = pplt.Proj("robin",lon_0=180)
    f,axs = pplt.subplots(ncols=2,nrows=2,axwidth=3,proj=proj)
    lvls  = vcat(-5:-1,-0.5,0.5,1:5)*2

    c = axs[1].contourf(lon,lat,(Tm_avg.-R5_avg)',cmap="RdBu_r",levels=lvls,extend="both")
    axs[1].format(title=L"(a) $\mu$ " * "($ID - ERA5) / K",coast=true)

    c = axs[2].contourf(lon,lat,(Tm_tot.-R5_tot)',cmap="RdBu_r",levels=lvls,extend="both")
    axs[2].format(title=L"(b) $\delta_t$ " * "($ID - ERA5) / K",coast=true)

    c = axs[3].contourf(lon,lat,(Tm_sea.-R5_sea)',cmap="RdBu_r",levels=lvls,extend="both")
    axs[3].format(title=L"(c) $\delta_s$ " * "($ID - ERA5) / K",coast=true)

    c = axs[4].contourf(lon,lat,(Tm_itr.-R5_itr)',cmap="RdBu_r",levels=lvls,extend="both")
    axs[4].format(title=L"(d) $\delta_i$ " * "($ID - ERA5) / K",coast=true)

    f.colorbar(c,loc="r",extend="both")
    f.savefig(plotsdir("Tmdiff_$ID.png"),transparent=false,dpi=200)

end

plotaxs("ERAI")
plotaxs("GGOSA")
plotaxs("Bevis")
plotaxs2("GPT2w")
plotaxs2("MN2017")
