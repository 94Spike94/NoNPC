-- Lade die Konfigurationsdatei
local Config = Config or {}

-- Funktion, um NPC-Fahrzeuge basierend auf ihren Klassen zu deaktivieren
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

    -- Deaktivierung von NPC-Fahrzeugen basierend auf der Konfiguration
    for category, classId in pairs(vehicleClasses) do
        if Config.DisableVehicles[category] then
            -- Loop durch alle Fahrzeuge
            for vehicle in EnumerateVehicles() do
                if GetVehicleClass(vehicle) == classId then
                    -- Prüfen, ob das Fahrzeug einem Spieler gehört oder von einem NPC gesteuert wird
                    if not IsVehicleOwnedByPlayer(vehicle) and not IsVehicleOccupiedByPlayer(vehicle) then
                        -- Fahrzeug löschen, wenn es der entsprechenden Klasse angehört und nicht von einem Spieler benutzt wird
                        DeleteEntity(vehicle)
                    end
                end
            end
        end
    end
end

-- Funktion, um zu prüfen, ob ein Fahrzeug einem Spieler gehört
function IsVehicleOwnedByPlayer(vehicle)
    -- Überprüfen, ob ein Spieler in der Nähe ist, der das Fahrzeug besitzen könnte
    for i = 0, GetNumPlayerIndices() - 1 do
        local player = GetPlayerFromServerId(i)
        if DoesEntityExist(vehicle) and NetworkHasControlOfEntity(vehicle) and IsPedAPlayer(GetPedInVehicleSeat(vehicle, -1)) then
            return true -- Fahrzeug wird von einem Spieler gesteuert
        end
    end
    return false -- Fahrzeug gehört keinem Spieler
end

-- Funktion, um zu prüfen, ob das Fahrzeug von einem Spieler besetzt ist
function IsVehicleOccupiedByPlayer(vehicle)
    -- Überprüfen, ob ein Spieler im Fahrzeug sitzt (nicht NPC)
    for i = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
        local ped = GetPedInVehicleSeat(vehicle, i)
        if DoesEntityExist(ped) and IsPedAPlayer(ped) then
            return true -- Spieler ist im Fahrzeug
        end
    end
    return false -- Kein Spieler im Fahrzeug
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

-- Hauptthread, der die Fahrzeuge beim Start entfernt
Citizen.CreateThread(function()
    -- Sofortige Deaktivierung beim Start des Skripts
    DisableNPCVehicles()

    -- Dann alle 5 Sekunden prüfen und Fahrzeuge deaktivieren
    while true do
        DisableNPCVehicles()
        Citizen.Wait(5000) -- 5 Sekunden warten, bevor erneut geprüft wird
    end
end)
