local CATEGORY_NAME = "Tropical"

function ulx.addrotationmap( calling_ply, map_name, stringTags )

    stringTags = string.Explode(" ",stringTags)

    local tags = {}

    --for each string-form tag
    for i, tag in ipairs(stringTags) do
        local valid = false
        --and each possible signature
        for sig, text in pairs(MAPTAG_SIGNATURES) do
            --if the text matches the signature (with completion)
            if string.match(text,tag) then
                --add that tag's signature to the list of tags
                tags[#tags+1] = sig
                valid = true
                break
            end
        end

        --if we didn't find a match, error out
        if not valid then
            ULib.tsayError(calling_ply,"tag " .. tag .. " failed to validate.")
            return
        end
    end

    if not GAMEMODE:ValidateTags(tags) then
        ULib.tsayError(calling_ply,"tags failed to validate. make sure you don't pick two from the same group.")
        return
    end

    GAMEMODE:AddMapToList(map_name, tags)
    ULib.tsay(calling_ply,"successfully added map " .. map_name .. " to rotation" )
end

local addrotationmap = ulx.command( CATEGORY_NAME, "ulx addrotationmap",ulx.addrotationmap, "!addrotationmap")
addrotationmap:addParam{ type=ULib.cmds.StringArg, hint="mapname" }
addrotationmap:addParam{ type=ULib.cmds.StringArg, hint="tags", ULib.cmds.takeRestOfLine }
addrotationmap:defaultAccess( ULib.ACCESS_SUPERADMIN )
addrotationmap:help( "space separated tags. see source for full list")
--tags: [huge|big|medium|small|tiny][closed,open]

function ulx.forcemap( calling_ply, map_name )
    if not map_name or map_name == "" then
        net.Start("trop_forcemap_open")
        net.Send(calling_ply)

        return
    end

    if map_name == "^" then
        map_name = game.GetMap()
    end

    if not GAMEMODE:IsMapEnabled(map_name) then
        ULib.tsayError(calling_ply,"map isn't enabled and may be low quality. use !map \"" .. map_name .. "\" if this was intended")
        return
    end

    timer.Simple(1, function()
        RunConsoleCommand("changelevel", map_name)
    end)

    ulx.fancyLogAdmin(calling_ply, "#A Initiated a map change to #s!", map_name)
end

local forcemap = ulx.command( CATEGORY_NAME, "ulx forcemap", ulx.forcemap, "!forcemap")
forcemap:addParam{ type=ULib.cmds.StringArg, hint="mapname", ULib.cmds.optional, default=false }
forcemap:defaultAccess( ULib.ACCESS_ADMIN )
forcemap:help( "open a GUI to force a map change, or, if given a mapname, change to that map.")

function ulx.forcemapvote( calling_ply )

    gamemode.Call("TropicalLoadNextMap")

    ulx.fancyLogAdmin(calling_ply, "#A forced a map vote!")
end

local forcemapvote = ulx.command( CATEGORY_NAME, "ulx forcemapvote", ulx.forcemapvote, "!forcemapvote")
forcemapvote:defaultAccess( ULib.ACCESS_ADMIN )
forcemapvote:help( "start a mapvote early")

function ulx.rollthedice( calling_ply )
    GAMEMODE:RollTheDice( calling_ply )
end

local rollthedice = ulx.command( CATEGORY_NAME, "ulx rtd", ulx.rollthedice, "!rtd")
rollthedice:defaultAccess( ULib.ACCESS_ALL )
