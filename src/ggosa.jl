using GridInterpolations

ggosname(date::TimeType) = "GGOS-GLB-t_mwv_GA-sfc-$(Dates.year(date)).nc"

function ggostimeii(date::TimeType)

    date = DateTime(date);
    dvec = datetime2julian.(collect(date:Hour(ehr):(date+Month(1))));
    pop!(dvec);

    return (yearday(date)-1)*4 .+ collect(1:nt)

end

function calcTmGGOSA(
    gTm::Array{<:Real,3},
    lon::Vector{<:Real},lat::Vector{<:Real},
    glon::Vector{<:Real},glat::Vector{<:Real}
)

    grid = RectangleGrid(glon,glat);
    Tm = zeros(length(lon),length(lat),size(gTm,3));

    for it = 1 : size(gTm,3)

        data = @view gTm[:,;,it][:];
        for ilat = 1 : length(lat), ilon = 1 : length(lon)
            Tm[ilon,ilat,it] = interpolate(grid,data,[lon[ilon],lat[ilat]]);
        end

    end

end
