using DrWatson
@quickactivate "PiPWV"

using NCDatasets
using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

ds  = NCDataset(datadir("compiled/erac5-GLBx1.00-t_sfc-sfc.nc"))
lon = ds["longitude"][:]
lat = ds["latitude"][:]
avg = ds["average"][:]
ian = ds["variability_interannual"][:]
sea = ds["variability_seasonal"][:]
itr = ds["variability_intraseasonal"][:]
dhr = ds["variability_diurnal"][:]
close(ds)

tot = dhr + ian + sea + itr

x = [60,75,95,175,160,175,115,70,60]
y = [-5,5,10,5,0,-10,-10,-7,-5]

pplt.close(); proj = pplt.Proj("robin",lon_0=180)
f,axs = pplt.subplots(ncols=2,nrows=3,axwidth=3,proj=proj)

c = axs[1].contourf(lon,lat,avg',levels=280:2.5:300,extend="both")
axs[1].plot(x,y,lw=0.5,linestyle="--",c="w")
axs[1].format(title=L"(a) $\mu$",coast=true)
axs[1].colorbar(c,loc="r",extend="both")

c = axs[2].contourf(lon,lat,tot',levels=(2:0.5:10)*10,extend="both")
axs[2].format(title=L"(b) $\delta_t$",coast=true)
axs[2].colorbar(c,loc="r",extend="both")

c = axs[3].contourf(lon,lat,sea',levels=(1:0.5:9)*5,extend="both")
axs[3].format(title=L"(c) $\delta_s$",coast=true)
axs[3].colorbar(c,loc="r",extend="both")

c = axs[4].contourf(lon,lat,itr',levels=(1:0.5:9)*5,extend="both")
axs[4].format(title=L"(d) $\delta_i$",coast=true)
axs[4].colorbar(c,loc="r",extend="both")

c = axs[5].contourf(lon,lat,dhr',levels=(1:10),extend="both")
axs[5].format(title=L"(e) $\delta_d$",coast=true)
axs[5].colorbar(c,loc="r",extend="both")

c = axs[6].contourf(lon,lat,ian',levels=(1:0.5:9),extend="both")
axs[6].format(title=L"(f) $\delta_a$",coast=true)
axs[6].colorbar(c,loc="r",extend="both")

for ax in axs
    ax.format(suptitle=L"ERA5 $T_s$ / K")
end

f.savefig(plotsdir("Ts_ERA5.png"),transparent=false,dpi=200)