using DrWatson
@quickactivate "PiPWV"

using NCDatasets
using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

ds  = NCDataset(datadir("compiled/erac5-GLBx1.00-t_sfc-sfc.nc"))
lon = ds["longitude"][:]
lat = ds["latitude"][:]
Ts_avg = ds["average"][:]
Ts_ian = ds["variability_interannual"][:]
Ts_sea = ds["variability_seasonal"][:]
Ts_itr = ds["variability_intraseasonal"][:]
Ts_dhr = ds["variability_diurnal"][:]
close(ds)

Ts_tot = Ts_dhr + Ts_ian + Ts_sea + Ts_itr

@load datadir("compiled/Tm_ERA5.jld2") Tm_avg Tm_dhr Tm_sea Tm_ian Tm_itr Tm_var
Tm_tot = Tm_dhr + Tm_ian + Tm_sea + Tm_itr + Tm_var

x = [60,75,95,175,160,175,115,70,60]
y = [-5,5,10,5,0,-10,-10,-7,-5]

pplt.close(); proj = pplt.Proj("robin",lon_0=180)
f,axs = pplt.subplots(nrows=4,ncols=3,axwidth=2,proj=proj)

c = axs[1].contourf(lon,lat,Tm_avg',levels=275:2.5:300,extend="both")
axs[1].plot(x,y,lw=0.5,linestyle="--",c="w")
axs[1].format(leftlabels=[L"$\T_m$",L"$\T_s$",L"$\T_m$",L"$\T_s$"])
axs[4].contourf(lon,lat,Ts_avg',levels=275:2.5:300,extend="both")
axs[4].plot(x,y,lw=0.5,linestyle="--",c="w")
f.colorbar(c,loc="l",row=[1,2])

c = axs[2].contourf(lon,lat,Tm_sea',levels=(1:9)*5,extend="both",cmap="viridis")
axs[5].contourf(lon,lat,Ts_sea',levels=(1:9)*5,extend="both",cmap="viridis")

axs[3].contourf(lon,lat,Tm_itr',levels=(1:9)*5,extend="both",cmap="viridis")
axs[6].contourf(lon,lat,Ts_itr',levels=(1:9)*5,extend="both",cmap="viridis")
f.colorbar(c,loc="r",row=[1,2])

c = axs[7].contourf(lon,lat,Tm_tot',levels=(1:9)*10,extend="both")
axs[7].plot(x,y,lw=0.5,linestyle="--",c="w")
axs[10].contourf(lon,lat,Ts_tot',levels=(1:9)*10,extend="both")
axs[10].plot(x,y,lw=0.5,linestyle="--",c="w")
f.colorbar(c,loc="l",row=[3,4])

c = axs[8].contourf(lon,lat,Tm_dhr',levels=(1:9),extend="both",cmap="viridis")
axs[11].contourf(lon,lat,Ts_dhr',levels=(1:9),extend="both",cmap="viridis")

axs[9].contourf(lon,lat,Tm_ian',levels=(1:9),extend="both",cmap="viridis")
axs[12].contourf(lon,lat,Ts_ian',levels=(1:9),extend="both",cmap="viridis")
f.colorbar(c,loc="r",row=[3,4])

axs[1].format(title=L"(a) $\mu$ / K")
axs[2].format(title=L"(c) $\delta_s$ / K")
axs[3].format(title=L"(e) $\delta_i$ / K")
axs[7].format(title=L"(b) $\delta_t$ / K")
axs[8].format(title=L"(d) $\delta_d$ / K")
axs[9].format(title=L"(f) $\delta_a$ / K")

for ax in axs
    ax.format(coast=true)
end

f.savefig(plotsdir("TmTs.png"),transparent=false,dpi=250)