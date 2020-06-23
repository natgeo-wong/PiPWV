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

@load datadir("compiled/Pi_RE5.jld2") lon lat Pi_avg Pi_dhr Pi_sea Pi_ian Pi_itr
R5_avg = Pi_avg; R5_dhr = Pi_dhr; R5_sea = Pi_sea;
R5_ian = Pi_ian; R5_itr = Pi_itr;
@load datadir("compiled/Pi_REP.jld2") lon lat Pi_avg Pi_dhr Pi_sea Pi_ian Pi_itr

arr = [[0,1,1,0],[2,2,3,3],[4,4,5,5]]
pplt.close(); proj = pplt.Proj("robin",lon_0=180); f,axs = pplt.subplots(
    arr,axwidth=3,proj=proj
)

normPi!(Pi_avg,Pi_dhr); normPi!(Pi_avg,Pi_sea); normPi!(Pi_avg,Pi_ian);
normPi!(Pi_avg,Pi_itr);
normPi!(R5_avg,R5_dhr); normPi!(R5_avg,R5_sea); normPi!(R5_avg,R5_ian);
normPi!(R5_avg,R5_itr);

c = axs[1].contourf(
    lon,lat,((Pi_avg.-R5_avg)./R5_avg)'*10000,
    cmap="RdBu_r",levels=(-10:2:10)/5,extend="both"
)
axs[1].format(
    title=L"$\mu_\Pi$ (REP-RE5)/RE5 / $10^{-2}$ %",coast=true
)
axs[1].colorbar(c,loc="r",extend="both")

c = axs[2].contourf(
    lon,lat,(Pi_ian.-R5_ian)'*10000,
    cmap="RdBu_r",levels=(-10:2:10)/100,extend="both"
)
axs[2].format(
    title=L"$\Delta_a\Pi$ (REP-RE5) / $10^{-2}$ %",coast=true
)
axs[2].colorbar(c,loc="r",extend="both")

c = axs[3].contourf(
    lon,lat,(Pi_dhr.-R5_dhr)'*10000,
    cmap="RdBu_r",levels=(-10:2:10)/100,extend="both"
)
axs[3].format(
    title=L"$\Delta_d\Pi$ (REP-RE5) / $10^{-2}$ %",coast=true
)
axs[3].colorbar(c,loc="r",extend="both")

c = axs[4].contourf(
    lon,lat,(Pi_sea.-R5_sea)'*10000,
    cmap="RdBu_r",levels=(-10:2:10)/10,extend="both"
)
axs[4].format(
    title=L"$\Delta_s\Pi$ (REP-RE5) / $10^{-2}$ %",coast=true
)
axs[4].colorbar(c,loc="r",extend="both")

c = axs[5].contourf(
    lon,lat,(Pi_itr.-R5_itr)'*10000,
    cmap="RdBu_r",levels=(-10:2:10)/10,extend="both"
)
axs[5].format(
    title=L"$\Delta_s\Pi$ (REP-RE5) / $10^{-2}$ %",coast=true
)
axs[5].colorbar(c,loc="r",extend="both")

for ii = 1 : 5
    axs[ii].format(abc=true)
end

f.savefig(plotsdir("PvZ.png"),transparent=false,dpi=200)
