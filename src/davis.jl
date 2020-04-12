using NumericalIntegration
using Dierckx

calcTd2e(Td::Real) = 6.1078 * exp((2.5e6/461.51) * (1/273.16 - 1/Td))

function calcTmDavispd(
    p::Vector{<:Real},
    Ta::Vector{<:Real},
    Ts::Real,
    Td::Real,
    sH::Vector{<:Real}
)

    e = p .* sH ./ ((1 .- sH) * (287.05/461.51) .+ sH);
    e38 = calcTd2e(Td); append!(e,e38); append!(Ta,Ts);

    append!(p,1012.35); top = e ./ p; bot = e ./ (p .* Ta);

    return cumul_integrate(p,top) ./ bot = cumul_integrate(p,bot);

end

function calcTmDaviszd(
    p::Vector{<:Real},
    Ta::Vector{<:Real},
    Ts::Real,
    Td::Real,
    sH::Vector{<:Real},
    za::Vector{<:Real},
    zs::Real
)

    e = p .* sH ./ ((1 .- sH) * (287.05/461.51) .+ sH);
    e38 = calcTd2e(Td); append!(e,e38); append!(Ta,Ts); append!(za,zs);

    top = e ./ Ta; bot = e ./ Ta.^2;

    return cumul_integrate(za,top) ./ bot = cumul_integrate(za,bot);

end

function calcTmsfcz(
    Tm::Vector{<:Real}, Ts::Real, zs::Real, za::Vector{<:Real}
)

    if zs > za[37]; zs = za[37] - 287.05 * Ts * log(1.01235); end;
    append!(za,zs); spl = Spline1D(za,Tm); return spl(zs)

end

function calcTmsfcz(
    Tm::Vector{<:Real}, ps::Real, p::Vector{<:Real}
)

    append!(p,1012.35); spl = Spline1D(p,Tm); return spl(ps)

end
