-- Lade die Konfigurationsdatei
local Config = Config or {}

-- Funktion, um Fahrzeuge basierend auf ihren Klassen zu deaktivieren
local function DisableNPCVehicles()
    local vehicleClasses = {
        Boats = 14,
        Commercials = 20,
        Compacts = 0,
        Coupes = 1,
        Cycles = 13,
        Emergency = 18,
        Helicopters = 15,
        Industrial = 10,
        Military = 19,
        Motorcycles = 8,
        Muscle = 4,
        OffRoad = 9,
        OpenWheel = 22,
        Planes = 16,
        SUVs = 7,
        Sedans = 3,
        Service = 17,
        Sports = 6,
        SportsClassic = 5,
        Super = 2,
        Trailer = 21,
        Trains = 21,
        Utility = 11,
        Vans = 12
    }

    -- Deaktivierung von Fahrzeugen, die in der Config auf false stehen
    for category, classId in pairs(vehicleClasses) do
        if Config.DisableVehicles[category] then
            -- Loop durch alle Fahrzeuge
            for vehicle in EnumerateVehicles() do
                if GetVehicleClass(vehicle) == classId then
                    -- Fahrzeug löschen, wenn es der entsprechenden Klasse angehört
                    DeleteEntity(vehicle)
                end
            end
        end
    end
end

-- Vehicle enumerator (Utility function to loop over vehicles)
function EnumerateVehicles()
    return coroutine.wrap(function()
        local vehicle, iter = FindFirstVehicle()
        if not vehicle or vehicle == 0 then
            EndFindVehicle(iter)
            return
        end

        local enum = {handle = iter, destructor = EndFindVehicle}
        repeat
            coroutine.yield(vehicle)
            success, vehicle = FindNextVehicle(iter)
        until not success

        EndFindVehicle(iter)
    end)
end

-- Hauptthread, um NPC-Fahrzeuge regelmäßig zu entfernen
Citizen.CreateThread(function()
    while true do
        -- Alle 5 Sekunden prüfen und Fahrzeuge deaktivieren
        DisableNPCVehicles()
        Citizen.Wait(5000)
    end
end)
