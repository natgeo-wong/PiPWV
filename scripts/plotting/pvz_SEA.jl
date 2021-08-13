using DrWatson
@quickactivate "PiPWV"

using JLD2
using DelimitedFiles
using PyCall, LaTeXStrings
pplt = pyimport("proplot");

@load datadir("compiled/Tm_RE5.jld2") lon lat Tm_avg Tm_dhr Tm_sea Tm_ian Tm_itr
R5_avg = Tm_avg; R5_dhr = Tm_dhr; R5_sea = Tm_sea;
R5_ian = Tm_ian; R5_itr = Tm_itr;

R5_tot = Tm_dhr + Tm_ian + Tm_sea + Tm_itr
@load datadir("compiled/Tm_REP.jld2") lon lat Tm_avg Tm_dhr Tm_sea Tm_ian Tm_itr
Tm_tot = Tm_dhr + Tm_ian + Tm_sea + Tm_itr

coast = readdlm(srcdir("GLB-i.txt"),comments=true,comment_char='#')
x = coast[:,1]; y = coast[:,2];

pplt.close(); f,axs = pplt.subplots(ncols=2,nrows=3,axwidth=3,aspect=15/7)

c = axs[1].contourf(
    lon,lat,(Tm_avg.-R5_avg)'*100,
    cmap="RdBu_r",levels=vcat(-5:-1,-0.5,0.5,1:5),extend="both"
)
axs[1].plot(x,y,lw=0.5,c="k")
axs[1].format(title=L"$\mu$ (REP-RE5) / $10^{-2}$ K")

c = axs[2].contourf(
    lon,lat,(Tm_tot.-R5_tot)'*100,
    cmap="RdBu_r",levels=vcat(-5:-1,-0.5,0.5,1:5),extend="both"
)
axs[2].plot(x,y,lw=0.5,c="k")
axs[2].format(title=L"$\delta_t$ (REP-RE5) / $10^{-2}$ K")

c = axs[3].contourf(
    lon,lat,(Tm_sea.-R5_sea)'*100,
    cmap="RdBu_r",levels=vcat(-5:-1,-0.5,0.5,1:5),extend="both"
)
axs[3].plot(x,y,lw=0.5,c="k")
axs[3].format(title=L"$\delta_s$ (REP-RE5) / $10^{-2}$ K")

c = axs[4].contourf(
    lon,lat,(Tm_itr.-R5_itr)'*100,
    cmap="RdBu_r",levels=vcat(-5:-1,-0.5,0.5,1:5),extend="both"
)
axs[4].plot(x,y,lw=0.5,c="k")
axs[4].format(title=L"$\delta_i$ (REP-RE5) / $10^{-2}$ K")

c = axs[5].contourf(
    lon,lat,(Tm_dhr.-R5_dhr)'*1000,
    cmap="RdBu_r",levels=vcat(-5:-1,-0.5,0.5,1:5),extend="both"
)
axs[5].plot(x,y,lw=0.5,c="k")
axs[5].format(title=L"$\delta_d$ (REP-RE5) / $10^{-3}$ K")

c = axs[6].contourf(
    lon,lat,(Tm_ian.-R5_ian)'*1000,
    cmap="RdBu_r",levels=vcat(-5:-1,-0.5,0.5,1:5),extend="both"
)
axs[6].plot(x,y,lw=0.5,c="k")
axs[6].format(title=L"$\delta_a$ (REP-RE5) / $10^{-3}$ K")

for ax in axs
    ax.format(
        xlim=(90,165),xlocator=90:15:165,
        ylim=(-15,20),ylocator=-15:5:20,
    )
end

f.colorbar(c,loc="r",extend="both")
f.savefig(plotsdir("PvZ_SEA.png"),transparent=false,dpi=200)
