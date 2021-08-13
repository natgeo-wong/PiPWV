#!/usr/bin/env python
import cdsapi
import os

datadir = '/n/holyscratch01/kuang_lab/nwong/PiPWV/data/'

c = cdsapi.Client()

if not os.path.exists(datadir):
    os.makedirs(datadir)

c.retrieve(
    'reanalysis-era5-pressure-levels-monthly-means',
    {
        'format': 'netcdf',
        'product_type': 'monthly_averaged_reanalysis',
        'variable': 'temperature',
        'year': [
            '1979', '1980', '1981',
            '1982', '1983', '1984',
            '1985', '1986', '1987',
            '1988', '1989', '1990',
            '1991', '1992', '1993',
            '1994', '1995', '1996',
            '1997', '1998', '1999',
            '2000', '2001', '2002',
            '2003', '2004', '2005',
            '2006', '2007', '2008',
            '2009', '2010', '2011',
            '2012', '2013', '2014',
            '2015', '2016', '2017',
            '2018', '2019',
        ],
        'pressure_level': 850,
        'month': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
        'area': [90, 0, -90, 360],
        'time': '00:00',
    },
    datadir + 'era5-GLBx0.25-t_air-850hPa.nc')
