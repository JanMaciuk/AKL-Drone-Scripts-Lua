
local minSateliteNumber = 3     -- Threshold for number of satelites to be considered ready for flight
local minBatteryVoltage = 12    -- Threshold for battery voltage to be considered ready for flight TODO: verify units, likely mV not V
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


function update()

    local readyForFlight = true -- if any of the checks fail, this will be set to false

    --Cant use "variable = condition" instead of "if condition true variable = true", have to only change value on false
-- Conditions:
    if (battery:voltage(instanceNo) < minBatteryVoltage) then
        readyForFlight = false
        print("voltage: ")
        print(battery:voltage(instanceNo))
    end

    if (gps:num_sats(instanceNo) < minSateliteNumber) then
        readyForFlight = false
        print("num_sats: ")
        print(gps:num_sats(instanceNo))
    end

    if not arming:is_armed() then
        readyForFlight = false
        print("is_armed: ")
        print(tostring(arming:is_armed()))
    end

    if not (vehicle:get_mode() == desiredModeNumber) then
        readyForFlight = false
        print("get_mode: ")
        print(vehicle:get_mode())
    end

--Parameters:
    if not (param_ThrottleFailsafe:get() == value_ThrottleFailsafe) then
        readyForFlight = false
        print("ThrottleFailsafe: ")
        print(param_ThrottleFailsafe:get())
    end

    if not (param_CrashCheck:get() == value_CrashCheck) then
        readyForFlight = false
        print("CrashCheck: ")
        print(param_CrashCheck:get())
    end

    if not (param_DeadReckon:get() == value_DeadReckon) then
        readyForFlight = false
        print("DeadReckon: ")
        print(param_DeadReckon:get())
    end

    if not (param_EKFAction:get() == value_EKFAction) then
        readyForFlight = false
        print("EKFAction: ")
        print(param_EKFAction:get())
    end

    if not (param_GroundStationFail:get() == value_GroundStationFail) then
        readyForFlight = false
        print("GroundStationFail: ")
        param_GroundStationFail:get()
    end


--Led control/feedback:
    print("Ready for flight: " .. tostring(readyForFlight).."\n\n")
    return update, 10000 -- call again in 10 seconds
end

return update, 100 -- first call after loading the script

