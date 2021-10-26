using DrWatson
@quickactivate "PiPWV"

using JLD2
using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

@load datadir("Ts2Tm.jld2") reg amat bmat
lvls1 = vcat(0:8) / 4
lvls2 = vcat(-4:-1,-0.5,0.5,1:4) * 100

pplt.close(); proj = pplt.Proj("robin",lon_0=180)
fig,axs = pplt.subplots(proj=proj,axwidth=3,ncols=2)

c = axs[1].contourf(reg["lon"],reg["lat"],amat',cmap="RdBu_r",levels=lvls2,extend="both")
axs[1].format(coast=true,title="(a) a",suptitle=L"$T_m$ = a + b$T_s$")
axs[1].colorbar(c,loc="r")
c = axs[2].contourf(reg["lon"],reg["lat"],bmat',cmap="Fire",levels=lvls1,extend="both")
axs[2].format(coast=true,title="(b) b")
axs[2].colorbar(c,loc="r")

fig.savefig(plotsdir("ts2tmab.png"),transparent=false,dpi=250)