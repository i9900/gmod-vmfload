print( "VMF Parser" )

local function processWorld( worldTbl )
  for key, value in pairs( worldTbl ) do
    if ( value.Key == "solid" )  then
      PrintTable( value.Value )
    end
  end
end


concommand.Add( "hlmap_debug", function( ply, cmd, args )
  local testFile = file.Read( "hlmaps/cube_256_floor.vmf" )


  testFile = string.format( "\"data\"\n{%s\n}", testFile )
  local tblKeyValues = util.KeyValuesToTablePreserveOrder( testFile, false, false )

  for key, value in pairs( tblKeyValues ) do
    if ( value.Key == "world" ) then
      processWorld( value.Value )
    end
  end

end )
