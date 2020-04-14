nlon = 360; nlat = 181; nhr = 744; np = 37;

for loop = 1 : 5

      @info "$(Dates.now()) - Preallocating arrays ..."
      Ta = zeros(nlon,nlat,nhr,np); sH = zeros(nlon,nlat,nhr,np);
      za = zeros(nlon,nlat,nhr,np); Tm = zeros(nlon,nlat,nhr);

      @info "$(Dates.now()) - Extracting Surface-Level data for $(dtii) ..."
      Ts = rand(nlon,nlat,nhr); Td = rand(nlon,nlat,nhr)

      @info "$(Dates.now()) - Extracting Pressure-Level data for $(dtii) ..."
      for pii = 1 : np; pre = p[pii];
          Ta[:,:,:,pii] = rand(nlon,nlat,nhr)
          sH[:,:,:,pii] = rand(nlon,nlat,nhr)
          za[:,:,:,pii] = rand(nlon,nlat,nhr)
      end

  end
