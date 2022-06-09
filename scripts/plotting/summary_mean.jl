using DrWatson
@quickactivate "PiPWV"
using JLD2
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
f,axs = pplt.subplots(nrows=6,ncols=2,aspect=2,axwidth=2,proj=proj)

c = axs[1].contourf(lon,lat,Tm_avg',levels=250:2.5:300,extend="both")
axs[1].plot(x,y,lw=0.5,linestyle="--",c="w")
axs[2].contourf(lon,lat,Ts_avg',levels=250:2.5:300,extend="both")
axs[2].plot(x,y,lw=0.5,linestyle="--",c="w")
axs[2].colorbar(c,loc="r",row=[1,2],label="K")

c = axs[3].contourf(lon,lat,Tm_tot',levels=(1:9)*10,extend="both")
axs[4].contourf(lon,lat,Ts_tot',levels=(1:9)*10,extend="both")
axs[4].colorbar(c,loc="r",row=[3,4],label="K")

c = axs[5].contourf(lon,lat,Tm_sea',levels=(1:9)*5,extend="both")
axs[6].contourf(lon,lat,Ts_sea',levels=(1:9)*5,extend="both")
axs[6].colorbar(c,loc="r",row=[1,2],label="K")

axs[7].contourf(lon,lat,Tm_itr',levels=(1:9)*5,extend="both")
axs[8].contourf(lon,lat,Ts_itr',levels=(1:9)*5,extend="both")
axs[8].colorbar(c,loc="r",row=[1,2],label="K")

c = axs[9].contourf(lon,lat,Tm_dhr',levels=(1:9),extend="both")
axs[10].contourf(lon,lat,Ts_dhr',levels=(1:9),extend="both")
axs[10].colorbar(c,loc="r",row=[3,4],label="K")

axs[11].contourf(lon,lat,Tm_ian',levels=(1:9),extend="both")
axs[12].contourf(lon,lat,Ts_ian',levels=(1:9),extend="both")
axs[12].colorbar(c,loc="r",row=[3,4],label="K")

axs[1].format(
    leftlabels=[L"(a) $\mu$",L"(b) $\delta_t$",L"(c) $\delta_s$",L"(d) $\delta_i$",L"(e) $\delta_d$",L"(f) $\delta_a$"],
    leftlabelrotation="horizontal",
    title=L"T_m"
)
axs[2].format(title=L"T_s")

for ax in axs
    ax.format(coast=true)
end

f.savefig(plotsdir("TmTs_all.png"),transparent=false,dpi=300)
f.savefig(plotsdir("TmTs_all.pdf"),transparent=false)