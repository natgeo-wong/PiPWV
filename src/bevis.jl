function calcTmBevisab(ID::AbstractString,lat::Real)

    if     ID == "EBB";   a = 70.2;  b = 0.72;
    elseif ID == "EBM"; lat = abs(lat);
        if lat <= 23;    a = 129.13; b = 0.52;
        elseif lat > 36; a = 67.12;  b = 0.73
        else;            a = 106.36; b = 0.60;
        end
    end

    return a,b

end

function calcTmBevisab(ID::AbstractString,lat::Vector)

    nlat = length(lat); a = zeros(nlat); b = zeros(nlat);
    for ii = 1 : nlat
        a[ii],b[ii] = calcTmBevisab(ID,lat[ii]);
    end

    return a,b

end

calcTmBevis(Ts::Real,a::Real,b::Real) = a + b * Ts
