local version = "1.5.0"

return {
    Name = "version",
    Description = "Shows the current version of Cmdr",
    Group = "DefaultDebug",
    
    ClientRun = function(_, _)
        return ("Cmdr Version %s"):format(version)
    end
}