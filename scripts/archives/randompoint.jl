using DrWatson
@quickactivate "PiPWV"

using ClimateERA
using CFTime
using DelimitedFiles
using Glob
using NCDatasets
using PyCall, LaTeXStrings

pplt = pyimport("proplot");

function extractpoint(ilon::Integer,ilat::Integer;ID::AbstractString)

    ddir = datadir("raw/Pi_$(ID)"); fnc = glob("*.nc",ddir)
    ipnt = []; idt = [];
    if any(ID .== ["REI","RGA"]); nhr = 6; else nhr = 1; end

    for inc = 1 : length(fnc)
        ids  = Dataset(fnc[inc]);
        ipnt = vcat(ipnt,ids["Pi_$(ID)"][ilon,ilat,:]*1)
        dt = ids["time"][:]
        dt = timeencode.(dt,"hours since 2018-$(inc)-01 00:00:00")
        dt = (dt.-1) * nhr
        dt = timedecode(dt,"hours since 2018-$(inc)-01 00:00:00")
        idt  = vcat(idt,dt)
        close(ids)
    end

    return ipnt,idt

end

function extractgrid(;ID::AbstractString)

    ddir = datadir("raw/Pi_$(ID)"); fnc = glob("*.nc",ddir);
    data = zeros(Float32,360,181,0);

    for inc = 1 : length(fnc)
        ids  = Dataset(fnc[inc]);
        data = cat(data,ids["Pi_$(ID)"][:]*1,dims=3)
        close(ids)
    end

    return data

end

# ilon = rand(1:360); lon = collect(0:360);
# ilat = rand(1:181); lat = collect(90:-1:-90);
# RE5,t1 = extractpoint(ID="RE5",ilon,ilat)
# # REI,t2 = extractpoint(ID="REI",ilon,ilat)
# # EBB,__ = extractpoint(ID="EBB",ilon,ilat)
# # EBM,__ = extractpoint(ID="EBM",ilon,ilat)
# EG2,__ = extractpoint(ID="EG2",ilon,ilat)
# EMN,__ = extractpoint(ID="EMN",ilon,ilat)
#
# EG2 = reshape(EG2,:,12); EG2 = cat(EG2[:,3:12],EG2[:,1:2],dims=2); EG2 = EG2[:];
#
# coasts = readdlm(datadir("GLB-c.txt"),comments=true);
# x = coasts[:,1]; y = coasts[:,2];
#
# ax = [[1],[1],[2]]
# pplt.close(); f,axs = pplt.subplots(ax,aspect=2,axwidth=4,sharex=0,sharey=0)
#
# axs[1].plot(x,y,c="k",lw=0.2)
# axs[1].scatter(lon[ilon],lat[ilat],marker="x")
# axs[1].format(
#     xlabel=L"Longitude / $\degree$",xlim=(0,360),
#     ylabel=L"Latitude / $\degree$",ylim=(-90,90)
#
# )
#
# axs[2].plot(t1,RE5,lw=0.5)
# # axs[2].plot(t2,REI,lw=0.5)
# # axs[2].plot(t1,EBB,lw=0.5)
# # axs[2].plot(t1,EBM,lw=0.5)
# axs[2].plot(t1,EG2,lw=1)
# axs[2].plot(t1,EMN,lw=1)
# axs[2].format(
#     xlabel="Date",xlim=(t1[1],t1[end]),
#     ylabel=L"$\Pi$"
#
# )
#
# f.savefig(plotsdir("rand.png"),transparent=false,dpi=200)

RE5 = extractgrid(ID="RE5")
REP = extractgrid(ID="REP")

pplt.close(); f,axs = pplt.subplots(axwidth=4)

axs[1].scatter(RE5[:],REP[:],markersize=1)
axs[1].format(
    xlabel=L"\Pi_{RE5}",
    ylabel=L"\Pi_{REP}",

)

f.savefig(plotsdir("corrPvZ.png"),transparent=false,dpi=200)
