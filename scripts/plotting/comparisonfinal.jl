using DrWatson
@quickactivate "PiPWV"

using JLD2
using NCDatasets
using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

@load datadir("compiled/Tm_ERA5.jld2") lon lat Tm_avg Tm_dhr Tm_sea Tm_ian Tm_itr Tm_var
R5_avg = Tm_avg; R5_dhr = Tm_dhr; R5_sea = Tm_sea;
R5_ian = Tm_ian; R5_itr = Tm_itr;
R5_tot = Tm_dhr + Tm_ian + Tm_sea + Tm_itr + Tm_var

@load datadir("compiled/Tm_Linear.jld2") lon lat Tm_avg Tm_dhr Tm_sea Tm_ian Tm_itr Tm_var
Tm_tot = Tm_dhr + Tm_ian + Tm_sea + Tm_itr + Tm_var

pplt.close(); proj = pplt.Proj("robin",lon_0=180)
f,axs = pplt.subplots(ncols=3,nrows=6,axwidth=2,proj=proj,sharey=0)
clvls = (1:9)*10
dlvls = vcat(-5:-1,-0.5,0.5,1:5)*2

c = axs[1].contourf(lon,lat,R5_avg',levels=levels=270:2.5:290,extend="both")
axs[1].format(title=L"$T_m$")
# axs[1].format(leftlabels=[L"$\mu$",L"$\delta_t$",L"$\delta_s$",L"$\delta_i$",L"$\delta_d$",L"$\delta_a$"])
axs[1].colorbar(c,loc="l",label=L"$\mu$ / K")

axs[2].contourf(lon,lat,Tm_avg',levels=levels=270:2.5:290,extend="both")
axs[2].format(title=L"$T_{la}$")

axs[3].contourf(lon,lat,(Tm_avg.-R5_avg)',cmap="RdBu_r",levels=dlvls,extend="both")
axs[3].format(title=L"$T_{la}$ - $T_m$")

c = axs[4].contourf(lon,lat,R5_tot',levels=(1:9)*10,extend="both")
axs[5].contourf(lon,lat,Tm_tot',levels=(1:10)*10,extend="both")
axs[6].contourf(lon,lat,(Tm_tot.-R5_tot)',cmap="RdBu_r",levels=dlvls,extend="both")
axs[4].colorbar(c,loc="l",label=L"$\delta_t$ / K")

c = axs[7].contourf(lon,lat,R5_sea',levels=(1:9)*5,extend="both")
axs[8].contourf(lon,lat,Tm_sea',levels=(1:9)*5,extend="both")
axs[9].contourf(lon,lat,(Tm_sea.-R5_sea)',cmap="RdBu_r",levels=dlvls,extend="both")
axs[7].colorbar(c,loc="l",label=L"$\delta_s$ / K")

c = axs[10].contourf(lon,lat,R5_itr',levels=(1:9)*5,extend="both")
axs[11].contourf(lon,lat,Tm_itr',levels=(1:9)*5,extend="both")
axs[12].contourf(lon,lat,(Tm_itr.-R5_itr)',cmap="RdBu_r",levels=dlvls,extend="both")
axs[10].colorbar(c,loc="l",label=L"$\delta_i$ / K")

c = axs[13].contourf(lon,lat,R5_dhr',levels=(1:9),extend="both")
axs[14].contourf(lon,lat,Tm_dhr',levels=(1:10),extend="both")
axs[15].contourf(lon,lat,(Tm_dhr.-R5_dhr)',cmap="RdBu_r",levels=dlvls,extend="both")
axs[13].colorbar(c,loc="l",label=L"$\delta_d$ / K")

c = axs[16].contourf(lon,lat,R5_ian',levels=(1:9),extend="both")
axs[17].contourf(lon,lat,Tm_ian',levels=(1:10),extend="both")
cd = axs[18].contourf(lon,lat,(Tm_ian.-R5_ian)',cmap="RdBu_r",levels=dlvls,extend="both")
axs[16].colorbar(c,loc="l",label=L"$\delta_a$ / K")

i = 0
alp = "abcdefghijklmnopqrstuv"
for ax in axs
    global i += 1
    ax.format(coast=true,ultitle="($(alp[i]))")
end

f.colorbar(cd,loc="r",label="K",rows=[3,4])
f.savefig(plotsdir("Tmdiff_TaTm.png"),transparent=false,dpi=250)
