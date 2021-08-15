using DrWatson
@quickactivate "PiPWV"

using JLD2
using PyCall, LaTeXStrings
pplt = pyimport("proplot");

@load datadir("compiled/Tm_RE5.jld2") lon lat Tm_avg Tm_dhr Tm_sea Tm_ian Tm_itr
R5_avg = Tm_avg; R5_dhr = Tm_dhr; R5_sea = Tm_sea;
R5_ian = Tm_ian; R5_itr = Tm_itr;

R5_tot = Tm_dhr + Tm_ian + Tm_sea + Tm_itr
@load datadir("compiled/Tm_REP.jld2") lon lat Tm_avg Tm_dhr Tm_sea Tm_ian Tm_itr
Tm_tot = Tm_dhr + Tm_ian + Tm_sea + Tm_itr

pplt.close(); proj = pplt.Proj("robin",lon_0=180)
f,axs = pplt.subplots(ncols=2,nrows=3,axwidth=3,proj=proj)

c = axs[1].contourf(
    lon,lat,(Tm_avg.-R5_avg)'*100,
    cmap="RdBu_r",levels=vcat(-5:-1,-0.5,0.5,1:5),extend="both"
)
axs[1].format(title=L"(a) $\mu$ (REP-RE5) / $10^{-2}$ K",coast=true)

c = axs[2].contourf(
    lon,lat,(Tm_tot.-R5_tot)'*100,
    cmap="RdBu_r",levels=vcat(-5:-1,-0.5,0.5,1:5),extend="both"
)
axs[2].format(title=L"(b) $\delta_t$ (REP-RE5) / $10^{-2}$ K",coast=true)

c = axs[3].contourf(
    lon,lat,(Tm_sea.-R5_sea)'*100,
    cmap="RdBu_r",levels=vcat(-5:-1,-0.5,0.5,1:5),extend="both"
)
axs[3].format(title=L"(c) $\delta_s$ (REP-RE5) / $10^{-2}$ K",coast=true)

c = axs[4].contourf(
    lon,lat,(Tm_itr.-R5_itr)'*100,
    cmap="RdBu_r",levels=vcat(-5:-1,-0.5,0.5,1:5),extend="both"
)
axs[4].format(title=L"(d) $\delta_i$ (REP-RE5) / $10^{-2}$ K",coast=true)

c = axs[5].contourf(
    lon,lat,(Tm_dhr.-R5_dhr)'*1000,
    cmap="RdBu_r",levels=vcat(-5:-1,-0.5,0.5,1:5),extend="both"
)
axs[5].format(title=L"(e) $\delta_d$ (REP-RE5) / $10^{-3}$ K",coast=true)

c = axs[6].contourf(
    lon,lat,(Tm_ian.-R5_ian)'*1000,
    cmap="RdBu_r",levels=vcat(-5:-1,-0.5,0.5,1:5),extend="both"
)
axs[6].format(title=L"(f) $\delta_a$ (REP-RE5) / $10^{-3}$ K",coast=true)

f.colorbar(c,loc="r",extend="both")
f.savefig(plotsdir("PvZ.png"),transparent=false,dpi=200)
