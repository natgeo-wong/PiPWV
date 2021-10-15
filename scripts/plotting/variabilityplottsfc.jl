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

pplt.close(); proj = pplt.Proj("robin",lon_0=180)
f,axs = pplt.subplots(ncols=2,nrows=2,axwidth=3,proj=proj)

c = axs[1].contourf(lon,lat,(sea./tot)'*100,levels=(1:0.5:9)*10,extend="both")
axs[1].format(title=L"(a) $\delta_s$ / $\delta_t$",coast=true)
axs[1].colorbar(c,loc="r",extend="both")

c = axs[2].contourf(lon,lat,(itr./tot)'*100,levels=(1:0.5:9)*10,extend="both")
axs[2].format(title=L"(b) $\delta_i$ / $\delta_t$",coast=true)
axs[2].colorbar(c,loc="r",extend="both")

c = axs[3].contourf(lon,lat,(dhr./tot)'*100,levels=(1:0.5:9)*10,extend="both")
axs[3].format(title=L"(c) $\delta_d$ / $\delta_t$",coast=true)
axs[3].colorbar(c,loc="r",extend="both")

c = axs[4].contourf(lon,lat,(ian./tot)'*100,levels=(1:0.5:9)*10,extend="both")
axs[4].format(title=L"(d) $\delta_a$ / $\delta_t$",coast=true)
axs[4].colorbar(c,loc="r",extend="both")

for ax in axs
    ax.format(suptitle=L"ERA5 $T_s$ / K")
end

f.savefig(plotsdir("Tsvar_ERA5.png"),transparent=false,dpi=200)