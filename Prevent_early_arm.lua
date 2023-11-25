---@diagnostic disable: lowercase-global
local triggerAltitude = 5  -- altitude above which start will be detected in meters (as calibrated by the barometer)
local throwModeID = 18
local checkDelay = 1000    -- delay between calling functions in milliseconds
local armingDelay = 100000 -- delay between detecting start and calling arming function in milliseconds

function detectStart()
  if baro:get_altitude() > triggerAltitude then
    print("Mini drone start detected, arming in " .. armingDelay / 1000 .. " seconds.")
    --TODO: possibly disarm here?
    return armThrow, armingDelay
  else
    return detectStart, checkDelay
  end
end

function armThrow()
  assert(arming:arm(), "Mini drone failed to arm!")
  assert(vehicle:set_mode(throwModeID), "Mini drone failed to set throw mode!")
  if not (vehicle:get_mode() == throwModeID and arming:is_armed()) then
    return armThrow, checkDelay -- try to set throw mode again, or the drone could fall to its death
  end
  print("Mini drone armed and in throw mode, ready for drop")
end

return detectStart, checkDelay
