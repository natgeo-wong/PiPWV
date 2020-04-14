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
    e38 = calcTd2e(Td); append!(e,e38); Ta = vcat(Ta,Ts);

    if ps >= p[end]; p = vcat(p,ps); else; p = vcat(p,1012.35); end
    top = e ./ p; bot = e ./ (p .* Ta);

    return cumul_integrate(p,top) ./ cumul_integrate(p,bot);

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
    e38 = calcTd2e(Td); append!(e,e38); Ta = vcat(Ta,Ts); za = vcat(za,zs);

    top = e ./ Ta; bot = e ./ Ta.^2;

    return cumul_integrate(za,top) ./ cumul_integrate(za,bot);

end

function calcTmsfcz(
    Tm::Vector{<:Real}, Ts::Real, zs::Real, za::Vector{<:Real}
)

    if zs >= za[37]; zs = za[37] - 287.05 * Ts * log(1.01235); end;
    za = reverse(vcat(za,zs)); spl = Spline1D(za,reverse(Tm)); return spl(zs)

end

function calcTmsfcp(
    Tm::Vector{<:Real}, ps::Real, p::Vector{<:Real}
)

    if ps >= p[end]; p = vcat(p,ps); else; p = vcat(p,1012.35); end
    spl = Spline1D(p,Tm); return spl(ps)

end
