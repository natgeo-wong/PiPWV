using DrWatson
@quickactivate "PiPWV"

using JLD2
using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

@load datadir("Ts2Tm.jld2") reg amat bmat
lvls1 = vcat(0:8) / 4
lvls2 = vcat(-4:-1,-0.5,0.5,1:4) * 100

pplt.close();
arr = [[1,1,1,1,2,2,2,2],[0,0,0,3,3,0,0,0]]
prj = pplt.Proj("robin",lon_0=180)
fig,axs = pplt.subplots(arr,axwidth=3,proj=prj)#Dict(1=>prj,2=>prj))

c = axs[1].contourf(reg["lon"],reg["lat"],amat',cmap="RdBu_r",levels=lvls2,extend="both")
axs[1].format(coast=true,title="(a) a")
axs[1].colorbar(c,loc="l")

c = axs[2].contourf(reg["lon"],reg["lat"],bmat',cmap="RdBu_r",levels=lvls1,extend="both")
axs[2].format(coast=true,title="(b) b")
axs[2].colorbar(c,loc="r")

# axs[3].scatter(amat[:],bmat[:],s=1)
# axs[3].format(xlabel="a",ylabel="b",title="(c) b against a",ylim=(-0.5,2))

fig.savefig(plotsdir("ts2tmab.png"),transparent=false,dpi=300)