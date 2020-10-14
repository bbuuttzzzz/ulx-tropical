local CATEGORY_NAME = "Zombie Survival"


--Redeem
function ulx.redeem( calling_ply, target_plys, doResetLoadout)
  local affected_plys = {}

  for i=1, #target_plys do
    local v = target_plys[ i ]
    if v:IsValidZombie() then
      v:Redeem(nil, doResetLoadout)
    end
    table.insert( affected_plys, v )
  end

  ulx.fancyLogAdmin( calling_ply, "#A redeemed #T!", target_plys )
end

local redeem = ulx.command( CATEGORY_NAME, "ulx redeem", ulx.redeem, "!redeem")
redeem:addParam{ type=ULib.cmds.PlayersArg }
redeem:addParam{ type=ULib.cmds.BoolArg, hint="reset loadout?", ULib.cmds.optional, default=false}
redeem:defaultAccess( ULib.ACCESS_ADMIN )
redeem:help( "redeems target(s)")


--Give Item
function ulx.give( calling_ply, target_plys, itemstr)
  local affected_plys = {}

  local itemtab = GAMEMODE:FindItem(itemstr)
  if not itemtab then
    ULib.tsayError( calling_ply, "Couldn't find item " .. itemstr .. ". try !finditems?", true)
    return
  end

  for i=1, #target_plys do
    local v = target_plys[ i ]
    GAMEMODE:GiveItem(v, itemtab)
    table.insert( affected_plys, v )
  end

  local name
  if itemtab.swep then
    name = weapons.GetStored(itemtab.swep).PrintName
  else
    name = itemtab.item.PrintName
  end

	ulx.fancyLogAdmin( calling_ply, "#A gave #T a #s", target_plys, name )
end

local give = ulx.command( CATEGORY_NAME, "ulx give", ulx.give, "!give")
give:addParam{ type=ULib.cmds.PlayersArg }
give:addParam{ type=ULib.cmds.StringArg, hint="itemname" }
give:defaultAccess( ULib.ACCESS_ADMIN )
give:help( "Gives target(s) the specified Item")

--Find Items
function ulx.finditems( calling_ply, itemstr)

  if itemstr == "*" then itemstr = "" end

  local tabs = GAMEMODE:FindItems(itemstr)

  ULib.tsay( calling_ply, "Matching item names printed to console" )
  ULib.console( calling_ply, "signature \titem/swep name")

  for _, item in ipairs(tabs) do
    local name = (item.swep
      or (item.item and item.item.ClassName)
      or "?")

      local str = string.format("%-16s%-25s",item.signature,name)

    ULib.console( calling_ply, str )
  end
end

local finditems = ulx.command( CATEGORY_NAME, "ulx finditems", ulx.finditems, "!finditems")
finditems:addParam{ type=ULib.cmds.StringArg, hint="itemname", default="" }
finditems:defaultAccess( ULib.ACCESS_ADMIN )
finditems:help( "prints to console every item that matches the supplied text")

--Set Class
function ulx.setclass( calling_ply, target_plys, classstr)
  local affected_plys = {}

  --figure out what class this is
  local classIndex = GAMEMODE:FindZombieClassByName(classstr)
  if not classIndex then
    ULib.tsayError( calling_ply, "Couldn't find class " .. classstr .. ".", true)
    return
  end

  --get affected players
  for i=1, #target_plys do
    local v = target_plys[ i ]
    if v:IsValidZombie() then
      v:BecomeClass(classIndex, true)
    end
    table.insert( affected_plys, v )
  end

  ulx.fancyLogAdmin( calling_ply, "#A Set #T to #s!", target_plys, GAMEMODE.ZombieClasses[classIndex].Name)
end

local setclass = ulx.command( CATEGORY_NAME, "ulx setclass", ulx.setclass, "!setclass")
setclass:addParam{ type=ULib.cmds.PlayersArg }
setclass:addParam{ type=ULib.cmds.StringArg, hint="classname" }
setclass:defaultAccess( ULib.ACCESS_ADMIN )
setclass:help( "Sets target(s) to the specified class")

--Force Boss
function ulx.forceboss( calling_ply, target_plys)

  if not target_plys then
    local pl = GAMEMODE:SpawnBoss()

    if pl then
      ulx.fancyLogAdmin(calling_ply, "#A Forced #s to boss!", pl:GetName())
    end
    return
  end

  local affected_plys = {}

  --get affected players
  for i=1, #target_plys do
    local v = target_plys[ i ]
    if v:IsValidZombie() then
      GAMEMODE:SpawnBoss(v)
    end
    table.insert( affected_plys, v )
  end

  ulx.fancyLogAdmin( calling_ply, "#A Forced #T to boss!", target_plys)
end

local forceboss = ulx.command( CATEGORY_NAME, "ulx forceboss", ulx.forceboss, "!forceboss")
forceboss:addParam{ type=ULib.cmds.PlayersArg, ULib.cmds.optional, default=false }
forceboss:defaultAccess( ULib.ACCESS_ADMIN )
forceboss:help( "Sets target(s) to the specified class")

--Force MiniBoss
function ulx.forceminiboss( calling_ply, target_plys)

  if not target_plys then
    local pl = GAMEMODE:SpawnMiniBoss()

    if pl then
      ulx.fancyLogAdmin(calling_ply, "#A Forced #s to miniboss!", pl:GetName())
    end
    return
  end

  local affected_plys = {}

  --get affected players
  for i=1, #target_plys do
    local v = target_plys[ i ]
    if v:IsValidZombie() then
      GAMEMODE:SpawnMiniBoss(v)
    end
    table.insert( affected_plys, v )
  end

  ulx.fancyLogAdmin( calling_ply, "#A Forced #T to miniboss!", target_plys)
end

local forceminiboss = ulx.command( CATEGORY_NAME, "ulx forceboss", ulx.forceboss, "!forceboss")
forceminiboss:addParam{ type=ULib.cmds.PlayersArg, ULib.cmds.optional, default=false }
forceminiboss:defaultAccess( ULib.ACCESS_ADMIN )
forceminiboss:help( "Sets target(s) to the specified class")

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
addrotationmap:help( "tags: [huge|big|medium|small|tiny][no_navmesh,navmesh][barricade][run_and_gun][closed,open]")

function ulx.forcemap( calling_ply, map_name )
  if not map_name or map_name == "" then
    net.Start("tzs_forcemap_open")
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
