using DrWatson
@quickactivate "PiPWV"

using JLD2
using NCDatasets
using Statistics

using PyCall, LaTeXStrings
pplt = pyimport("proplot");

@load datadir("t2m-lvlcentroid.jld2") lon lat lvlmom t2m

ds = NCDataset(datadir("t850hPa.nc"))
t  = dropdims(mean(ds["t"][:],dims=3),dims=3)
close(ds)

pplt.close(); proj = pplt.Proj("robin",lon_0=180)
f,a = pplt.subplots(aspect=2,axwidth=3,ncols=2,proj=proj)

c = a[1].contourf(lon,lat,lvlmom',cmap="boreal",levels=800:10:900,extend="both")
a[1].contour(lon,lat,lvlmom',lw=1,c="r",levels=[850])
a[1].format(title="(a) q-weighted Centroid Pressure",coast=true)
a[1].colorbar(c,loc="r",locator=800:20:900)

c = a[2].contourf(lon,lat,t',levels=275:2:295,extend="both")
a[2].format(title="(b) 850hPa Air Temperature",coast=true)
a[2].colorbar(c,loc="r",275:2:295)

f.savefig(plotsdir("lvlmomt850hPa.png"),transparent=false,dpi=200)
