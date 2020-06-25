using DrWatson
@quickactivate "PiPWV"

using JLD2
using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

function normPi!(Piavg::Array{<:Real,2},Pistat::Array{<:Real,2})

    nlon,nlat = size(Piavg)
    for ilat = 1 : nlat, ilon = 1 : nlon
        Pistat[ilon,ilat] = Pistat[ilon,ilat] / Piavg[ilon,ilat]
    end

    return

end

@load datadir("compiled/Pi_RE5.jld2") lon lat Pi_avg Pi_dhr Pi_sea Pi_ian Pi_itr Pi_var

arr = [[1,1,6,6],[2,2,7,7],[3,3,8,8],[4,4,9,9],[5,5,10,10]]
pplt.close(); proj = pplt.Proj("robin",lon_0=180); f,axs = pplt.subplots(
    arr,axwidth=3,proj=proj
)

normPi!(Pi_avg,Pi_dhr)
normPi!(Pi_avg,Pi_sea)
normPi!(Pi_avg,Pi_ian)
normPi!(Pi_avg,Pi_itr)
normPi!(Pi_avg,Pi_var)

Pi_tot = Pi_dhr + Pi_ian + Pi_sea + Pi_itr + Pi_var

c = axs[1].contourf(lon,lat,Pi_avg',cmap="viridis",levels=(52:68)/400,extend="both")
axs[1].format(
    title=L"$\mu_\Pi$",coast=true,suptitle="RE5"
)
axs[1].colorbar(c,loc="r",extend="both",locator=0.01)

c = axs[2].contourf(lon,lat,Pi_ian'*100,cmap="viridis",levels=(0:10)/4,extend="max")
axs[2].format(
    title=L"$\Delta_a\Pi$ / $\%$",coast=true
)
axs[2].colorbar(c,loc="r",extend="max",locator=0.5)

c = axs[3].contourf(lon,lat,Pi_dhr'*100,cmap="viridis",levels=(0:10)/5,extend="max")
axs[3].format(
    title=L"$\Delta_d\Pi$ / $\%$",coast=true
)
axs[3].colorbar(c,loc="r",extend="max")

c = axs[4].contourf(lon,lat,Pi_sea'*100,cmap="viridis",levels=0:15,extend="max")
axs[4].format(
    title=L"$\Delta_s\Pi$ / $\%$",coast=true
)
axs[4].colorbar(c,loc="r",extend="max",locator=3)

c = axs[5].contourf(lon,lat,Pi_itr'*100,cmap="viridis",levels=(0:16)/2,extend="max")
axs[5].format(
    title=L"$\Delta_i\Pi$ / $\%$",coast=true
)
axs[5].colorbar(c,loc="r",extend="max",locator=1)

c = axs[6].contourf(
    lon,lat,Pi_tot'*100,
    cmap="viridis",levels=0:2:20,extend="max"
)
axs[6].format(
    title=L"$\Delta_t\Pi$ / $\%$",coast=true,
)
axs[6].colorbar(c,loc="r",extend="max")

c = axs[7].contourf(
    lon,lat,(Pi_ian ./ Pi_tot)'*100,
    cmap="viridis",levels=0:5:50
)
axs[7].format(
    title=L"$\frac{\Delta_a\Pi}{\Delta_t\Pi}$ / $\%$",coast=true,
)
axs[7].colorbar(c,loc="r")

c = axs[8].contourf(
    lon,lat,(Pi_dhr ./ Pi_tot)'*100,
    cmap="viridis",levels=0:5:50
)
axs[8].format(
    title=L"$\frac{\Delta_d\Pi}{\Delta_t\Pi}$ / $\%$",coast=true
)
axs[8].colorbar(c,loc="r")

c = axs[9].contourf(
    lon,lat,(Pi_sea ./ Pi_tot)'*100,
    cmap="viridis",levels=0:10:100
)
axs[9].format(
    title=L"$\frac{\Delta_s\Pi}{\Delta_t\Pi}$ / $\%$",coast=true
)
axs[9].colorbar(c,loc="r")

c = axs[10].contourf(
    lon,lat,(Pi_itr ./ Pi_tot)'*100,
    cmap="viridis",levels=0:10:100
)
axs[10].format(
    title=L"$\frac{\Delta_i\Pi}{\Delta_t\Pi}$ / $\%$",coast=true
)
axs[10].colorbar(c,loc="r")

for ii = 1 : 10
    axs[ii].format(abc=true)
end

f.savefig(plotsdir("Piall_RE5.png"),transparent=false,dpi=200)
