using DrWatson
@quickactivate "PiPWV"

using PyCall
using LaTeXStrings
pplt = pyimport("proplot")

arr = [
    [1,1,8,8,2,3,9,9,10,10,4,5,11,11],
    [1,1,8,8,2,3,9,9,10,10,4,5,11,11],
    [1,1,8,8,2,3,9,9,10,10,4,5,11,11],
    [1,1,8,8,2,3,9,9,10,10,4,5,11,11],
    [1,1,8,8,2,3,9,9,10,10,4,5,11,11],
    [1,1,8,8,2,3,9,9,10,10,4,5,11,11],
    [0,0,6,6,6,6,6,6,7,7,7,7,7,7]
]

function hump(radius)
    x  = -1 : 0.01 : 1
    nx = length(x)
    y  = zeros(nx)
    for ix = 1 : nx
        if abs(x[ix]) < radius
            y[ix] = cos(x[ix] / radius * pi/2) * 0.8
        end
    end
    return x,y
end

pplt.close(); fig,axs = pplt.subplots(
    arr,wspace=[0,1,0,0,0.1,0,0,1.5,0,0,0.1,0,0],
    aspect=0.5,axwidth=1,sharey=0
)

# axs[1].plot(t,p)
axs[1].fill_between([180,320],125,70,color="gray",alpha=0.1)
axs[1].text(220,100,"Tropopause")
axs[1].format(ylim=(1000,25),yscale="log",xlim=(180,320),ylabel="Pressure / hPa",xlabel=L"$T_v$ / K",ltitle=L"(a) Large-Scale $T_v$")

axs[2].fill_between([-2,0],2,1.75,color="gray",alpha=0.1)
axs[2].arrow(-0.2,2.95,0,-0.95,width=0.1,head_width=0.25,head_length=0.1,edgecolor="none",facecolor="k",length_includes_head=true)
axs[2].text(-0.8,2.5,L"w_{wtg}")
axs[2].format(xlim=(-1,0),ltitle="(b) Warm Perturbation")

axs[3].fill_between([0,2],2,1.75,color="gray",alpha=0.1)
axs[3].plot(sin.(((1.9:0.01:3).-1.9)*pi/1.1)/1.2,1.9:0.01:3,c="red3",lw=1,linestyle="--")
axs[3].plot(sin.(((1.9:0.01:3).-1.9)*pi/1.1)/5,1.9:0.01:3,c="red9")
axs[3].arrow(0.8,2.45,-0.6,0,width=0.02,head_width=0.05,head_length=0.15,edgecolor="none",facecolor="gray4",length_includes_head=true)
axs[3].format(grid=false)

axs[4].fill_between([-2,0],2.1,1.85,color="gray",alpha=0.1)
axs[4].plot(-sin.(((2.05:0.01:3).-2.05)*pi/0.95)/1.2,2.05:0.01:3,c="blue3",lw=1,linestyle="--")
axs[4].plot(-sin.(((2.05:0.01:3).-2.05)*pi/0.95)/5,2.05:0.01:3,c="blue9")
axs[4].arrow(-0.8,2.525,0.6,0,width=0.02,head_width=0.05,head_length=0.15,edgecolor="none",facecolor="gray4",length_includes_head=true)
axs[4].format(grid=false,ltitle="(c) Cool Perturbation")

axs[5].fill_between([0,2],2.1,1.85,color="gray",alpha=0.1)
axs[5].arrow(0.2,2.15,0,0.8,width=0.1,head_width=0.25,head_length=0.1,edgecolor="none",facecolor="k",length_includes_head=true)
axs[5].text(0.35,2.55,L"w_{wtg}")
axs[5].format(xlim=(0,1))

axs[6].plot(hump(0.1)[1],hump(0.1)[2],c="red3",lw=1,linestyle="--")
axs[6].plot(hump(0.8)[1],hump(0.8)[2]*0.25,c="red9")

axs[7].plot(hump(0.1)[1],-hump(0.1)[2],c="blue3",lw=1,linestyle="--")
axs[7].plot(hump(0.8)[1],-hump(0.8)[2]*0.25,c="blue9")

for ii in 6 : 7
    axs[ii].arrow(0.2,0.5,0.6,0,width=0.1,head_width=0.25,head_length=0.05,edgecolor="none",facecolor="gray4",length_includes_head=true)
    axs[ii].arrow(0.2,-0.5,0.6,0,width=0.1,head_width=0.25,head_length=0.05,edgecolor="none",facecolor="gray4",length_includes_head=true)
    axs[ii].arrow(-0.2,0.5,-0.6,0,width=0.1,head_width=0.25,head_length=0.05,edgecolor="none",facecolor="gray4",length_includes_head=true)
    axs[ii].arrow(-0.2,-0.5,-0.6,0,width=0.1,head_width=0.25,head_length=0.05,edgecolor="none",facecolor="gray4",length_includes_head=true)
    axs[ii].text(-0.95,0.35,"+")
    axs[ii].text(-0.95,-.75,L"-")
    axs[ii].text(0.9,0.35,"+")
    axs[ii].text(0.9,-.75,L"-")
    axs[ii].format(
        xloc="neither",xticks=[],ytickloc="neither",
        ylim=(-1,1),xlim=(-1,1),yticks=[0],yticklabels=[]
    )
end

for ii in [8 10]
    for addii = 1.55 : 0.15 : 2.95
        axs[ii].plot(-1:0.01:0.8,sin.((-1:0.01:0.8)*pi*4)*0.02 .+addii,c="gray4")
    end
end

for ii in [9 11]
    for addii = 1.55 : 0.15 : 2.95
        axs[ii].plot(-0.8:0.01:1,sin.((-0.8:0.01:1)*pi*4)*0.02 .+addii,c="gray4")
    end
end

for ii in 8 : 11
    axs[ii].format(xloc="neither",yloc="neither",xticks=[],yticks=[],xlim=(-1,1))
end

for ii in [2,5]
    axs[ii].format(xloc="neither",yloc="neither",xticks=[],yticks=[])
end

axs[3].format(yticks=[],yloc="left",xloc="bottom",xlim=(0,1.1),xticklabels=["0","+"])
axs[4].format(yticks=[],yloc="right",xloc="bottom",xlim=(-1.1,0),xticklabels=["0","-","0"])

for ii = vcat(2:5,8:11)
    axs[ii].format(ylim=[3,1.4],yticks=[],yticklabels=[])
end

fig.savefig(plotsdir("wtgfiguretest.png"),transparent=false,dpi=300)