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

function plotaxs(ID::AbstractString,cID::AbstractString="RE5")

    @load datadir("compiled/Pi_$cID.jld2") lon lat Pi_avg Pi_dhr Pi_sea Pi_ian Pi_itr
    cID_avg = Pi_avg; cID_dhr = Pi_dhr; cID_sea = Pi_sea;
    cID_ian = Pi_ian; cID_itr = Pi_itr;
    @load datadir("compiled/Pi_$ID.jld2") lon lat Pi_avg Pi_dhr Pi_sea Pi_ian Pi_itr

    arr = [[0,1,1,0],[2,2,3,3],[4,4,5,5]]
    pplt.close(); proj = pplt.Proj("robin",lon_0=180); f,axs = pplt.subplots(
        arr,axwidth=3,proj=proj
    )

    normPi!(Pi_avg,Pi_dhr); normPi!(Pi_avg,Pi_sea); normPi!(Pi_avg,Pi_ian);
    normPi!(Pi_avg,Pi_itr);
    normPi!(cID_avg,cID_dhr); normPi!(cID_avg,cID_sea); normPi!(cID_avg,cID_ian);
    normPi!(cID_avg,cID_itr);

    c = axs[1].contourf(
        lon,lat,((Pi_avg.-cID_avg)./cID_avg)'*100,
        cmap="RdBu_r",levels=-3:0.5:3,
        extend="both"
    )
    axs[1].format(
        title=string(L"$\mu_\Pi$"," ($ID-$cID)/$cID / %"),coast=true,
    )
    axs[1].colorbar(c,loc="r",extend="both")

    c = axs[2].contourf(
        lon,lat,(Pi_ian.-cID_ian)'*100,
        cmap="RdBu_r",levels=(-4:4)/2,
        extend="both"
    )
    axs[2].format(
        title=string(L"$\Delta_a\Pi$"," ($ID-$cID) / %"),coast=true
    )
    axs[2].colorbar(c,loc="r",extend="both",locator=1)

    c = axs[3].contourf(
        lon,lat,(Pi_dhr.-cID_dhr)'*100,
        cmap="RdBu_r",levels=-1.5:0.25:1.5,
        extend="both"
    )
    axs[3].format(
        title=string(L"$\Delta_d\Pi$"," ($ID-$cID) / %"),coast=true
    )
    axs[3].colorbar(c,loc="r",extend="both")

    c = axs[4].contourf(
        lon,lat,(Pi_sea.-cID_sea)'*100,
        cmap="RdBu_r",levels=-5:5,
        extend="both"
    )
    axs[4].format(
        title=string(L"$\Delta_s\Pi$"," ($ID-$cID) / %"),coast=true
    )
    axs[4].colorbar(c,loc="r",extend="both",locator=2)

    c = axs[5].contourf(
        lon,lat,(Pi_itr.-cID_itr)'*100,
        cmap="RdBu_r",levels=-5:5,
        extend="both"
    )
    axs[5].format(
        title=string(L"$\Delta_i\Pi$"," ($ID-$cID) / %"),coast=true
    )
    axs[5].colorbar(c,loc="r",extend="both",locator=2)

    for ii = 1 : 5
        axs[ii].format(abc=true)
    end

    f.savefig(plotsdir("Pidiff_$(ID)v$(cID).png"),transparent=false,dpi=200)

end

function plotaxs2(ID::AbstractString,cID::AbstractString="RE5")

    @load datadir("compiled/Pi_$cID.jld2") lon lat Pi_avg Pi_dhr Pi_sea Pi_ian Pi_itr
    cID_avg = Pi_avg; cID_dhr = Pi_dhr; cID_sea = Pi_sea;
    cID_ian = Pi_ian; cID_itr = Pi_itr;
    @load datadir("compiled/Pi_$ID.jld2") lon lat Pi_avg Pi_dhr Pi_sea Pi_ian Pi_itr

    arr = [[0,1,1,0],[2,2,3,3]]
    pplt.close(); proj = pplt.Proj("robin",lon_0=180); f,axs = pplt.subplots(
        arr,axwidth=3,proj=proj
    )

    normPi!(Pi_avg,Pi_dhr); normPi!(Pi_avg,Pi_sea); normPi!(Pi_avg,Pi_ian);
    normPi!(Pi_avg,Pi_itr);
    normPi!(cID_avg,cID_dhr); normPi!(cID_avg,cID_sea); normPi!(cID_avg,cID_ian);
    normPi!(cID_avg,cID_itr);

    c = axs[1].contourf(
        lon,lat,((Pi_avg.-cID_avg)./cID_avg)'*100,
        cmap="RdBu_r",levels=-3:0.5:3,extend="both"
    )
    axs[1].format(
        title=string(L"$\mu_\Pi$"," ($ID-$cID)/$cID / %"),coast=true,
    )
    axs[1].colorbar(c,loc="r",extend="both")

    c = axs[2].contourf(
        lon,lat,(Pi_sea.-cID_sea)'*100,
        cmap="RdBu_r",levels=-5:5,extend="both"
    )
    axs[2].format(
        title=string(L"$\Delta_s\Pi$"," ($ID-$cID)/ %"),coast=true
    )
    axs[2].colorbar(c,loc="r",extend="both",locator=2)

    c = axs[3].contourf(
        lon,lat,(Pi_itr.-cID_itr)'*100,
        cmap="RdBu_r",levels=-5:5,extend="both"
    )
    axs[3].format(
        title=string(L"$\Delta_i\Pi$"," ($ID-$cID) / %"),coast=true
    )
    axs[3].colorbar(c,loc="r",extend="both",locator=2)

    for ii = 1 : 3
        axs[ii].format(abc=true)
    end

    f.savefig(plotsdir("Pidiff_$(ID)v$(cID).png"),transparent=false,dpi=200)

end

function plotaxscombined(ID1::AbstractString,ID2::AbstractString,cID::AbstractString="RE5")

    @load datadir("compiled/Pi_$cID.jld2") lon lat Pi_avg Pi_dhr Pi_sea Pi_ian Pi_itr
    cID_avg = Pi_avg; cID_dhr = Pi_dhr; cID_sea = Pi_sea;
    cID_ian = Pi_ian; cID_itr = Pi_itr;
    @load datadir("compiled/Pi_$ID1.jld2") lon lat Pi_avg Pi_dhr Pi_sea Pi_ian Pi_itr
    ID1_avg = Pi_avg; ID1_dhr = Pi_dhr; ID1_sea = Pi_sea;
    ID1_ian = Pi_ian; ID1_itr = Pi_itr;
    @load datadir("compiled/Pi_$ID2.jld2") lon lat Pi_avg Pi_dhr Pi_sea Pi_ian Pi_itr
    ID2_avg = Pi_avg; ID2_dhr = Pi_dhr; ID2_sea = Pi_sea;
    ID2_ian = Pi_ian; ID2_itr = Pi_itr;

    arr = [[1,1,6,6],[2,2,7,7],[3,3,8,8],[4,4,9,9],[5,5,10,10]]
    pplt.close(); proj = pplt.Proj("robin",lon_0=180); f,axs = pplt.subplots(
        arr,axwidth=3,proj=proj
    )

    normPi!(ID1_avg,ID1_dhr); normPi!(ID1_avg,ID1_sea); normPi!(ID1_avg,ID1_ian);
    normPi!(ID1_avg,ID1_itr);
    normPi!(ID2_avg,ID2_dhr); normPi!(ID2_avg,ID2_sea); normPi!(ID2_avg,ID2_ian);
    normPi!(ID2_avg,ID2_itr);
    normPi!(cID_avg,cID_dhr); normPi!(cID_avg,cID_sea); normPi!(cID_avg,cID_ian);
    normPi!(cID_avg,cID_itr);

    c = axs[1].contourf(
        lon,lat,((ID1_avg.-cID_avg)./cID_avg)'*100,
        cmap="RdBu_r",levels=-3:0.5:3,
        extend="both"
    )
    axs[1].format(
        title=string(L"$\mu_\Pi$"," ($ID1-$cID)/$cID / %"),coast=true,
    )
    axs[1].colorbar(c,loc="r",extend="both")

    c = axs[2].contourf(
        lon,lat,(ID1_ian.-cID_ian)'*100,
        cmap="RdBu_r",levels=(-4:4)/2,
        extend="both"
    )
    axs[2].format(
        title=string(L"$\Delta_a\Pi$"," ($ID1-$cID) / %"),coast=true
    )
    axs[2].colorbar(c,loc="r",extend="both",locator=1)

    c = axs[3].contourf(
        lon,lat,(ID1_dhr.-cID_dhr)'*100,
        cmap="RdBu_r",levels=-1.5:0.25:1.5,
        extend="both"
    )
    axs[3].format(
        title=string(L"$\Delta_d\Pi$"," ($ID1-$cID) / %"),coast=true
    )
    axs[3].colorbar(c,loc="r",extend="both")

    c = axs[4].contourf(
        lon,lat,(ID1_sea.-cID_sea)'*100,
        cmap="RdBu_r",levels=-5:5,
        extend="both"
    )
    axs[4].format(
        title=string(L"$\Delta_s\Pi$"," ($ID1-$cID) / %"),coast=true
    )
    axs[4].colorbar(c,loc="r",extend="both",locator=2)

    c = axs[5].contourf(
        lon,lat,(ID1_itr.-cID_itr)'*100,
        cmap="RdBu_r",levels=-5:5,
        extend="both"
    )
    axs[5].format(
        title=string(L"$\Delta_i\Pi$"," ($ID1-$cID) / %"),coast=true
    )
    axs[5].colorbar(c,loc="r",extend="both",locator=2)

    c = axs[6].contourf(
        lon,lat,((ID2_avg.-cID_avg)./cID_avg)'*100,
        cmap="RdBu_r",levels=-3:0.5:3,
        extend="both"
    )
    axs[6].format(
        title=string(L"$\mu_\Pi$"," ($ID2-$cID)/$cID / %"),coast=true,
    )
    axs[6].colorbar(c,loc="r",extend="both")

    c = axs[7].contourf(
        lon,lat,(ID2_ian.-cID_ian)'*100,
        cmap="RdBu_r",levels=(-4:4)/2,
        extend="both"
    )
    axs[7].format(
        title=string(L"$\Delta_a\Pi$"," ($ID2-$cID) / %"),coast=true
    )
    axs[7].colorbar(c,loc="r",extend="both",locator=1)

    c = axs[8].contourf(
        lon,lat,(ID2_dhr.-cID_dhr)'*100,
        cmap="RdBu_r",levels=-1.5:0.25:1.5,
        extend="both"
    )
    axs[8].format(
        title=string(L"$\Delta_d\Pi$"," ($ID2-$cID) / %"),coast=true
    )
    axs[8].colorbar(c,loc="r",extend="both")

    c = axs[9].contourf(
        lon,lat,(ID2_sea.-cID_sea)'*100,
        cmap="RdBu_r",levels=-5:5,
        extend="both"
    )
    axs[9].format(
        title=string(L"$\Delta_s\Pi$"," ($ID2-$cID) / %"),coast=true
    )
    axs[9].colorbar(c,loc="r",extend="both",locator=2)

    c = axs[10].contourf(
        lon,lat,(ID2_itr.-cID_itr)'*100,
        cmap="RdBu_r",levels=-5:5,
        extend="both"
    )
    axs[10].format(
        title=string(L"$\Delta_i\Pi$"," ($ID2-$cID) / %"),coast=true
    )
    axs[10].colorbar(c,loc="r",extend="both",locator=2)

    for ii = 1 : 10
        axs[ii].format(abc=true)
    end

    f.savefig(plotsdir("Pidiff_$(ID1)$(ID2)v$(cID).png"),transparent=false,dpi=200)

end

# plotaxs("REP");
# plotaxs("REI");
# plotaxs("RGA"); plotaxs("RGA","REI");
# plotaxs("EBB"); plotaxs("EBM");
# plotaxscombined("EBB","EBM");
#
# plotaxs2("EG2"); plotaxs2("EG2","REI");
# plotaxs2("EMN");
plotaxs2("EMN","REI");
