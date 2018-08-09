
datadir = "/home/ctroupin/Projects/Diva-Workshops/notebooks/Adriatic/"
filelist = ["AdriaticSea_SDC_100000.txt",
            "AdriaticSea_SDC_200000.txt",
            "AdriaticSea_SDC_500000.txt",
            "AdriaticSea_SDC_1000000.txt",
            "AdriaticSea_SDC.txt"]

for ff in filelist[3:3]
    datafile = joinpath(datadir, ff)
    @timev ODVspreadsheet.readODVspreadsheet(datafile);
end

"""
datafile = joinpath(datadir, "AdriaticSea_SDC_1000.txt")
isfile(datafile)

@time dataODV = ODVspreadsheet.readODVspreadsheet(datafile);

obsval,obslon,obslat,obsdepth,obstime,obsid = ODVspreadsheet.load(Float64,[datafile],
                           ["Water body salinity"]; nametype = :localname );


Profile.init()
Profile.init(n = 10^7)
@profile ODVspreadsheet.readODVspreadsheet(datafile)
Profile.print()

ODVspreadsheet.readODVspreadsheet(datafile);



ODVspreadsheet.readODVspreadsheet(datafile)
"""
