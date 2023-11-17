
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
    --Maximum amount of ground station prints limited, have to use these massive prints
-- Conditions:
    if (battery:voltage(instanceNo) < minBatteryVoltage) then
        readyForFlight = false
    end
    print("\n".."voltage: ".. tostring(battery:voltage(instanceNo)).. tostring(battery:voltage(instanceNo) > minBatteryVoltage).. "\n".. "num_sats: ".. tostring(gps:num_sats(instanceNo)).. tostring(gps:num_sats(instanceNo) > minSateliteNumber).. "\n".. "is_armed: ".. tostring(arming:is_armed()).. "\n".. "get_mode: ".. tostring(vehicle:get_mode()).. tostring(vehicle:get_mode() == desiredModeNumber).. "\n")


    if (gps:num_sats(instanceNo) < minSateliteNumber) then
        readyForFlight = false
    end
    --print("num_sats: ".. tostring(gps:num_sats(instanceNo)).. tostring(gps:num_sats(instanceNo) > minSateliteNumber).. "\n")

    if not arming:is_armed() then
        readyForFlight = false
    end
    --print("is_armed: ".. tostring(arming:is_armed()).. "\n")


    if not (vehicle:get_mode() == desiredModeNumber) then
        readyForFlight = false
    end
    --print("get_mode: ".. tostring(vehicle:get_mode()).. tostring(vehicle:get_mode() == desiredModeNumber).. "\n")


--Parameters:
    if not (param_ThrottleFailsafe:get() == value_ThrottleFailsafe) then
        readyForFlight = false
    end
    print("\n".."ThrottleFailsafe: ".. tostring(param_ThrottleFailsafe:get()).. tostring(param_ThrottleFailsafe:get() == value_ThrottleFailsafe).. "\n".."CrashCheck: ".. tostring(param_CrashCheck:get()).. tostring(param_CrashCheck:get() == value_CrashCheck).. "\n".."DeadReckon: ".. tostring(param_DeadReckon:get()).. tostring(param_DeadReckon:get() == value_DeadReckon).. "\n".."EKFAction: ".. tostring(param_EKFAction:get()).. tostring(param_EKFAction:get() == value_EKFAction).. "\n".."GroundStationFail: "..tostring(param_GroundStationFail:get()).. tostring(param_GroundStationFail:get() == value_GroundStationFail).. "\n")


    if not (param_CrashCheck:get() == value_CrashCheck) then
        readyForFlight = false
    end
    --print("CrashCheck: ".. tostring(param_CrashCheck:get()).. tostring(param_CrashCheck:get() == value_CrashCheck).. "\n")


    if not (param_DeadReckon:get() == value_DeadReckon) then
        readyForFlight = false
    end
   -- print("DeadReckon: ".. tostring(param_DeadReckon:get()).. tostring(param_DeadReckon:get() == value_DeadReckon).. "\n")


    if not (param_EKFAction:get() == value_EKFAction) then
        readyForFlight = false
    end
    --print("EKFAction: ".. tostring(param_EKFAction:get()).. tostring(param_EKFAction:get() == value_EKFAction).. "\n")


    if not (param_GroundStationFail:get() == value_GroundStationFail) then
        readyForFlight = false
    end
   -- print("GroundStationFail: "..tostring(param_GroundStationFail:get()).. tostring(param_GroundStationFail:get() == value_GroundStationFail).. "\n")


--Led control/feedback:
    print("\n".."Ready for flight: " .. tostring(readyForFlight).."\n\n")
    return update, 10000 -- call again in 10 seconds
end

return update, 100 -- first call after loading the script

