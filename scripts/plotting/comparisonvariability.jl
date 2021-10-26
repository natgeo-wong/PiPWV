using DrWatson
@quickactivate "PiPWV"

using JLD2
using NCDatasets
using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

@load datadir("compiled/Tm_ERA5.jld2") lon lat Tm_dhr Tm_sea Tm_ian Tm_itr Tm_var
Tm_tot = Tm_ian + Tm_sea + Tm_itr + Tm_dhr + Tm_var

ds  = NCDataset(datadir("compiled/erac5-GLBx1.00-t_sfc-sfc.nc"))
Ts_ian = ds["variability_interannual"][:]
Ts_sea = ds["variability_seasonal"][:]
Ts_itr = ds["variability_intraseasonal"][:]
Ts_dhr = ds["variability_diurnal"][:]
close(ds)
Ts_tot = Ts_ian + Ts_sea + Ts_itr + Ts_dhr

pplt.close(); proj = pplt.Proj("robin",lon_0=180)
f,axs = pplt.subplots(ncols=3,nrows=4,axwidth=2,proj=proj,sharey=0)
clvls = (1:9)*10
dlvls = vcat(-5:-1,-0.5,0.5,1:5)*10

c = axs[1].contourf(lon,lat,(Tm_sea./Tm_tot)'*100,levels=clvls,extend="both")
axs[1].format(title=L"$T_m$")
axs[1].format(leftlabels=[L"$\delta_s/\delta_t$",L"$\delta_i/\delta_t$",L"$\delta_d/\delta_t$",L"$\delta_a/\delta_t$"])
f.colorbar(c,loc="l",label="%",rows=[2,3])

axs[2].contourf(lon,lat,(Ts_sea./Ts_tot)'*100,levels=clvls,extend="both")
axs[2].format(title=L"$T_{la}$")

axs[3].contourf(
    lon,lat,(Ts_sea./Ts_tot .- Tm_sea./Tm_tot)'*100,cmap="RdBu_r",
    levels=dlvls,extend="both"
)
axs[3].format(title=L"$T_{la}$ - $T_m$")

axs[4].contourf(lon,lat,(Tm_itr./Tm_tot)'*100,levels=clvls,extend="both")
axs[5].contourf(lon,lat,(Ts_itr./Ts_tot)'*100,levels=clvls,extend="both")
axs[6].contourf(
    lon,lat,(Ts_itr./Ts_tot .- Tm_itr./Tm_tot)'*100,cmap="RdBu_r",
    levels=dlvls,extend="both"
)

axs[7].contourf(lon,lat,(Tm_dhr./Tm_tot)'*100,levels=clvls,extend="both")
axs[8].contourf(lon,lat,(Ts_dhr./Ts_tot)'*100,levels=clvls,extend="both")
axs[9].contourf(
    lon,lat,(Ts_dhr./Ts_tot .- Tm_dhr./Tm_tot)'*100,cmap="RdBu_r",
    levels=dlvls,extend="both"
)

axs[10].contourf(lon,lat,(Tm_ian./Tm_tot)'*100,levels=clvls,extend="both")
axs[11].contourf(lon,lat,(Ts_ian./Ts_tot)'*100,levels=clvls,extend="both")
c = axs[12].contourf(
    lon,lat,(Ts_ian./Ts_tot .- Tm_ian./Tm_tot)'*100,cmap="RdBu_r",
    levels=dlvls,extend="both"
)

i = 0
alp = "abcdefghijkl"
for ax in axs
    global i += 1
    ax.format(coast=true,ultitle="($(alp[i]))")
end

f.colorbar(c,loc="r",label="%",rows=[2,3])
f.savefig(plotsdir("Tmdiff_TsTm.png"),transparent=false,dpi=200)
