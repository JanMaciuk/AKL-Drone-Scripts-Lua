local minSateliteNumber = 3     -- Threshold for number of satelites to be considered ready for flight
local minBatteryVoltage = 12    -- Threshold for battery voltage to be considered ready for flight
local instanceNo = 0            -- Number of the instance checked
local readyModeNumber = 18      -- ID of the mode to be set when ready for flight, default 18=THROW per ardupilot documentation
local beaconModeNumber = 3      -- ID of the mode that will be set when drone becomes a beacon, 3=AUTO per ardupilot documentation
local ledFunction = 94;         -- function used for LED control, 94-109 are avaliable for script control
local ledNumber = 5;            -- number of LEDs on the used strip
local checkDelay = 5000         -- delay between calling functions in milliseconds

--Checked parameters and values:
--For more parameters it would be better to use an array of parameters and values, for just a few this is more readable
local param_ThrottleFailsafe = Parameter()  --Throttle/radio failsafe
param_ThrottleFailsafe:init('FS_THR_ENABLE')
local value_ThrottleFailsafe = 0

local param_CrashCheck = Parameter()
param_CrashCheck:init('FS_CRASH_CHECK')
local value_CrashCheck = 1

local param_DeadReckon = Parameter()
param_DeadReckon:init('FS_DR_ENABLE')
local value_DeadReckon = 2

local param_EKFAction = Parameter()
param_EKFAction:init('FS_EKF_ACTION')
local value_EKFAction = 1

local param_GroundStationFail = Parameter()
param_GroundStationFail:init('FS_GCS_ENABLE')
local value_GroundStationFail = 0


function readyForFlight()
    local readyForFlight = true -- if any of the checks fail, this will be set to false

 -- Conditions:
    if (battery:voltage(instanceNo) < minBatteryVoltage) then
        readyForFlight = false
        gcs:send_text(5,"\n".."voltage: ".. tostring(battery:voltage(instanceNo)).. "\n")
    end
    
    if (gps:num_sats(instanceNo) < minSateliteNumber) then
        readyForFlight = false
        gcs:send_text(5,"num_sats: ".. tostring(gps:num_sats(instanceNo)).. "\n")
    end

    if not arming:is_armed() then
        readyForFlight = false
        gcs:send_text(5,"is_armed: ".. tostring(arming:is_armed()).. "\n")
    end

    if not (vehicle:get_mode() == readyModeNumber) then
        readyForFlight = false
        gcs:send_text(5,"mode: ".. tostring(vehicle:get_mode()).. "\n")
    end

 --Parameters:
    if not (param_ThrottleFailsafe:get() == value_ThrottleFailsafe) then
        readyForFlight = false
        gcs:send_text(5,"ThrottleFailsafe: ".. tostring(param_ThrottleFailsafe:get()).. "\n")
    end

    if not (param_CrashCheck:get() == value_CrashCheck) then
        readyForFlight = false
        gcs:send_text(5,"CrashCheck: ".. tostring(param_CrashCheck:get()).. "\n")
    end

    if not (param_DeadReckon:get() == value_DeadReckon) then
        readyForFlight = false
        gcs:send_text(5,"DeadReckon: ".. tostring(param_DeadReckon:get()).. "\n")
    end

    if not (param_EKFAction:get() == value_EKFAction) then
        readyForFlight = false
        gcs:send_text(5,"EKFAction: ".. tostring(param_EKFAction:get()).. "\n")
    end

    if not (param_GroundStationFail:get() == value_GroundStationFail) then
        readyForFlight = false
        gcs:send_text(5,"GroundStationFail: "..tostring(param_GroundStationFail:get()).. "\n")
    end

    return readyForFlight
end

function ledControl()
    --Find channel used for LED control:
    local ledChannel = SRV_Channels:find_channel(ledFunction)
    if (ledChannel == nil) then
        gcs:send_text(3,"LEDs channel not set")
        return ledControl, checkDelay -- try again in a moment
    end
    ledChannel = ledChannel+1 -- convert to 1-16 from 0-15

    -- Set number of LEDs on the strip:
    local ledSuccess = serialLED:set_num_neopixel(ledChannel, ledNumber)
    if not ledSuccess then
        gcs:send_text(3,"Failed LED setup on channel "..ledChannel)
        return ledControl, checkDelay -- try again in a moment
    end

    if not (vehicle:get_mode() == beaconModeNumber) then
        -- Set color of LEDs:
        if readyForFlight() then
            serialLED:set_RGB(ledChannel, (ledNumber-1)/2, 0, 255, 0) -- middle led to green if ready
        else
            serialLED:set_RGB(ledChannel, (ledNumber-1)/2, 255, 0, 0) -- middle led to red if not ready
        end
    else
        for i = 0, ledNumber-1, 1 do
            serialLED:set_RGB(ledChannel, i, 255, 255, 255) -- all leds to white if beacon
        end
    end
    serialLED:send(ledChannel)
    return ledControl, checkDelay -- check again after delay
end

return ledControl, checkDelay