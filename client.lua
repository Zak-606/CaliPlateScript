local vehiclesProcessed = {}

local function CenterPlateText(plate)
    local maxLength = 8  -- Maximum length of a plate
    local spacesToAdd = maxLength - #plate
    local leftSpaces = math.floor(spacesToAdd / 2)
    local rightSpaces = spacesToAdd - leftSpaces
    return string.rep(" ", leftSpaces) .. plate .. string.rep(" ", rightSpaces)
end

local function GenerateRandomPlate()
    local numbers = {"0","1","2","3","4","5","6","7","8","9"}
    local letters = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
    
    local plate = ""
    plate = plate .. numbers[math.random(#numbers)]
    for i = 1, 3 do
        plate = plate .. letters[math.random(#letters)]
    end
    for i = 1, 3 do
        plate = plate .. numbers[math.random(#numbers)]
    end
    
    plate = CenterPlateText(plate)
    return plate
end

local function IsEmergencyVehicle(vehicle)
    local class = GetVehicleClass(vehicle)
    return class == 18 -- 18 is the class for emergency vehicles
end

local function IsValidPlateFormat(plate)
    -- Trim any leading or trailing spaces
    plate = string.gsub(plate, "^%s*(.-)%s*$", "%1")
    return string.match(plate, "^%d%a%a%a%d%d%d$") ~= nil
end

local function ModifyLicensePlates()
    Citizen.CreateThread(function()
        while true do
            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            
            if vehicle ~= 0 and not vehiclesProcessed[vehicle] and not IsEmergencyVehicle(vehicle) then
                local currentPlate = GetVehicleNumberPlateText(vehicle)
                
                if not IsValidPlateFormat(currentPlate) then
                    local newPlate = GenerateRandomPlate()
                    SetVehicleNumberPlateText(vehicle, newPlate)
                    Citizen.Wait(100) -- Wait a short time for the change to apply
                    local randomIndex = math.random(1, 3)
                    SetVehicleNumberPlateTextIndex(vehicle, randomIndex)
                else
                    -- Center the existing plate if it's already in the correct format
                    local centeredPlate = CenterPlateText(string.gsub(currentPlate, "^%s*(.-)%s*$", "%1"))
                    SetVehicleNumberPlateText(vehicle, centeredPlate)
                end
                vehiclesProcessed[vehicle] = true
            end
            
            Citizen.Wait(1000) -- Check every second
        end
    end)
end

Citizen.CreateThread(function()
    ModifyLicensePlates()
end)