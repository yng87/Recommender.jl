function download_zip(url::AbstractString, name::AbstractString, dirpath::String; usecache=true, unzip=true, removezip=false)
    if usecache && isdir(dirpath)
        return
    end
    if isdir(dirpath)
        rm(dirpath, force=true, recursive=true)
    end

    # download zip
    mkdir(dirpath)
    zippath = joinpath(dirpath, "$(name).zip")
    
    try
        io = open(zippath, "w")
        HTTP.request("GET", url, response_stream=io)
    catch e
        if isfile(zippath)
          rm(zippath)
        end
        throw(e)
    end
   

    # unzip
    if unzip
        r = ZipFile.Reader(zippath)
        try
            for f in r.files
                if f.name[end]=='/'
                    continue
                end
                println("Extracting $(f.name)")
                io = open(joinpath(dirpath, basename(f.name)), "w")
                write(io, read(f, String))
            end
        finally
            close(r)
        end
    end

    # remove zip
    if removezip
        rm(zippath)
    end
end