using ClimateERA

addpiparams() = eraparametersadd(srcdir("piparams.txt"));

function ncsave(
    data::Array{<:Real,3},
    emod::Dict, epar::Dict, ereg::Dict, date::TimeType, eroot::Dict
)

    ebase = erarawfolder(epar,ereg,eroot);
    fnc = joinpath(ebase,erarawname(emod,epar,ereg,date));
    if isfile(fnc)
        @info "$(Dates.now()) - Stale NetCDF file $(fnc) detected.  Overwriting ..."
        rm(fnc);
    end
    ds = NCDataset(fnc,"c",attrib = Dict("Conventions"=>"CF-1.6"));

    ehr = hrindy(emod); nhr = ehr * daysinmonth(dateii);
    scale,offset = NCoffsetscale(Pi);

    ds.dim["longitude"] = ereg["size"][1];
    ds.dim["latitude"] = ereg["size"][2];
    ds.dim["time"] = nhr

    nclongitude = defVar(ds,"longitude",Float32,("longitude",),attrib = Dict(
        "units"                     => "degrees_east",
        "long_name"                 => "longitude",
    ))

    nclatitude = defVar(ds,"latitude",Float32,("latitude",),attrib = Dict(
        "units"                     => "degrees_north",
        "long_name"                 => "latitude",
    ))

    nctime = defVar(ds,"time",Int32,("time",),attrib = Dict(
        "units"                     => "hours since $(date) 00:00:00.0",
        "long_name"                 => "time",
        "calendar"                  => "gregorian",
    ))

    ncvar = defVar(ds,epar["ID"],Int16,("longitude","latitude","time"),attrib = Dict(
        "scale_factor"              => scale,
        "add_offset"                => offset,
        "_FillValue"                => Int16(-32767),
        "missing_value"             => Int16(-32767),
        "units"                     => "K",
        "long_name"                 => epar["name"],
    ))

    nclongitude[:] = ereg["lon"]; nclatitude[:] = ereg["lat"]
    nctime[:] = collect(1:nhr); ncvar[:] = data;

    close(ds)

end
