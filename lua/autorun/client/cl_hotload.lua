print( "VMF Parser" )

local GLOBAL_MESHES = {}
GLOBAL_WORLD = {}
local GLOBAL_WORLD_MATERIAL = Material( "editor/wireframe" )

local function stringToVector( strVector )
  local strTrimmed = string.Trim( strVector, "(" )
  strTrimmed = string.Trim( strTrimmed, ")" )

  local splitStr = string.Explode( ") (", strTrimmed )

  for key, value in pairs( splitStr ) do
    local vecStrSplit = string.Explode( " ", value )
    splitStr[key] = Vector( vecStrSplit[1], vecStrSplit[2], vecStrSplit[3] )
  end

  return splitStr
end

local function processSolid( solidTbl )
  local numSides = 0
  local sidesTbl = {}

  for key, value in pairs( solidTbl ) do
    if ( value.Key == "side" and value.Value[1].Key == "id" ) then

      local sideID = value.Value[1].Value
      print( string.format( "processSolid()->Side[%i]", sideID ) )

      numSides = numSides + 1
      sidesTbl[ sideID ] = {}

      for i=1, #value.Value do
        --print( value.Value[i].Key .. "<->" .. value.Value[i].Value )
        if ( value.Value[i].Key == "plane" ) then
          value.Value[i].Value = stringToVector( value.Value[i].Value )
        elseif ( value.Value[i].Key == "dispinfo" ) then
          --process displacements
          value.Value[i].Value = false --add callback?
        else
        end

        sidesTbl[ sideID ][ value.Value[i].Key ] = value.Value[i].Value

      end

    end
  end

  print( string.format( "processSolid() finished with %i sides.", numSides ) )
  return sidesTbl
end



local function processWorld( worldTbl )
  local numSolids = 0
  local world = {}

  for key, value in pairs( worldTbl ) do
    if ( value.Key == "solid" )  then
      numSolids = numSolids + 1
      world[ numSolids ] = processSolid( value.Value )
    end
  end

  print( string.format( "processWorld() finished with %i solids.", numSolids ) )
  return world
end

local function solidToMeshTriangle( solidTbl )

  local triangleSets = {}

  for key, value in pairs( solidTbl ) do

    local triangle = {}

    for i=1, #value.plane do
      table.insert( triangle, { pos=value.plane[i] } )
    end

    table.insert( triangleSets, triangle )

  end

  return triangleSets
end

local function renderBuildObject( triangleSet )

  for key, verts in pairs( triangleSet ) do
    local obj = Mesh()
    obj:BuildFromTriangles( verts )
    table.insert( GLOBAL_MESHES, obj )
  end
end


concommand.Add( "hlmap_debug", function( ply, cmd, args )
  local testFile = file.Read( "hlmaps/gm_construct_d.vmf" )
  testFile = string.format( "\"data\"\n{%s\n}", testFile )

  local tblKeyValues = util.KeyValuesToTablePreserveOrder( testFile, false, false )

  for key, value in pairs( tblKeyValues ) do
    if ( value.Key == "world" ) then
      GLOBAL_WORLD = processWorld( value.Value )
    end
  end


  for key, solid in pairs( GLOBAL_WORLD ) do
    local triangles = solidToMeshTriangle( solid )
    renderBuildObject( triangles )
  end



end )

----



local mat = Material( "editor/wireframe" )

hook.Add( "PostDrawOpaqueRenderables", "vmf-hotload-draw", function()
  for key, obj in pairs( GLOBAL_MESHES ) do
    render.SetMaterial( mat )
    obj:Draw()
  end
end )
