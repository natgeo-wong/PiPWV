using Dierckx

ggosname(date::TimeType) = "GGOS-GLB-t_mwv_GA-sfc-$(Dates.year(date)).nc"

function ggostimeii(date::TimeType)

    date = DateTime(date);
    dvec = datetime2julian.(collect(date:Hour(6):(date+Month(1))));
    pop!(dvec); nt = length(dvec);

    return (dayofyear(date)-1)*4 .+ (1:nt)

end

function calcTmGGOSA(
    gTm::Array{<:Real,3},
    lon::Vector{<:Real},lat::Vector{<:Real},
    glon::Vector{<:Real},glat::Vector{<:Real}
)

    nlon,nlat,nt = size(gTm)
    Tm = zeros(length(lon),length(lat),nt);
    data = zeros(nlon,nlat); out = zeros(length(lon),length(lat))

    for it = 1 : size(gTm,3)

        data .= reverse(gTm[:,:,it],dims=2);
        spline = Spline2D(glon,reverse(glat),data)
        out  .= evalgrid(spline,lon,reverse(lat));
        Tm[:,:,it] .= reverse(out,dims=2)

    end

    return Tm

end
