---@diagnostic disable: lowercase-global
local triggerAltitude = 5  -- altitude above which start will be detected in meters (as calibrated by the barometer)
local throwModeID = 18
local checkDelay = 1000    -- delay between calling functions in milliseconds
local armingDelay = 100000 -- delay between detecting start and calling arming function in milliseconds

function detectStart()
  if baro:get_altitude() > triggerAltitude then
    gcs:send_text(6,"Mini drone start detected, arming in " .. armingDelay / 1000 .. " seconds.")
    --TODO: prevent automatic disarm, choose good mode for default
    return armThrow, armingDelay
  else
    return detectStart, checkDelay
  end
end

function armThrow()
  if not arming:arm() then
    gcs:send_text(4,"Mini drone failed to arm!")
  end
  if not vehicle:set_mode(throwModeID) then
    gcs:send_text(4,"Mini drone failed to set throw mode!")
  end
  if not (vehicle:get_mode() == throwModeID and arming:is_armed()) then
    return armThrow, checkDelay -- try to set throw mode again, or the drone could fall to its death
  end
  print("Mini drone armed and in throw mode, ready for drop")
end

return detectStart, checkDelay
