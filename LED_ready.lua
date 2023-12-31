
local minSateliteNumber = 3     -- Threshold for number of satelites to be considered ready for flight
local minBatteryVoltage = 12    -- Threshold for battery voltage to be considered ready for flight
local instanceNo = 0            -- Number of the instance checked
local desiredModeNumber = 18    -- ID of the mode to be set when ready for flight, default 18=THROW per ardupilot documentation

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

local ledFunction = 94; -- function used for LED control, 94-109 are avaliable for script control
local ledNumber = 5; -- number of LEDs on the used strip

function update()

    local readyForFlight = true -- if any of the checks fail, this will be set to false
    --Cant use "variable = condition" instead of "if condition true variable = true", have to only change value on false

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


    if not (vehicle:get_mode() == desiredModeNumber) then
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


--Led control/feedback:
    gcs:send_text(6,"\n".."Ready for flight: " .. tostring(readyForFlight).."\n\n")

    --Find channel used for LED control:
    local ledChannel = SRV_Channels:find_channel(ledFunction)
    if (ledChannel == nil) then
        gcs:send_text(3,"LEDs channel not set")
    end
    ledChannel = ledChannel+1 -- convert to 1-16 from 0-15

    -- Set number of LEDs on the strip:
    local ledSuccess = serialLED:set_num_neopixel(ledChannel, ledNumber)
    if not ledSuccess then
        gcs:send_text(3,"Failed LED setup on channel "..ledChannel)
    end

    -- Set color of LEDs:
    if readyForFlight then
        for i = 0, ledNumber-1, 1 do
            serialLED:set_RGB(ledChannel, i, 0, 255, 0) -- green
        end
    else
        for i = 0, ledNumber-1, 1 do
            serialLED:set_RGB(ledChannel, i, 255, 0, 0) -- red
        end
    end
    serialLED:send(ledChannel)

    return update, 10000 -- call again in 10 seconds
end

return update, 1000 -- first call after loading the script

