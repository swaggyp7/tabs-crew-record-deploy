function VehicleInit(v,Vehicle,Weapons,Optics)
    if Vehicle ~= nil then
        for option, value in pairs(Vehicle) do
            local path = "level.tabs."..v..".vehicle."..option
            local stype = type(value)
            if stype == "number" then
                SetFloat(path, value)
            elseif stype == "boolean" then
                SetBool(path, value)
            elseif stype == "string" then
                SetString(path, value)
            end
        end
    end

    if Weapons ~= nil then
        for id, Weapon in pairs(Weapons) do
            local path = "level.tabs."..v..".weapons."..id

            for k, s in pairs(Weapon) do
                local stype = type(s)
                if stype == "number" then
                    SetFloat(path.."."..k, s)
                elseif stype == "boolean" then
                    SetBool(path.."."..k, s)
                elseif stype == "string" then
                    SetString(path.."."..k, s)
                elseif stype == "table" then
                    for id, preset in pairs(s) do
                        if type(preset) == "table" then
                            for key, stat in pairs(preset) do
                                local stype2 = type(stat)
                                if stype2 == "number" then
                                    SetFloat(path.."."..k.."."..id.."."..key, stat)
                                elseif stype2 == "boolean" then
                                    SetBool(path.."."..k.."."..id.."."..key, stat)
                                elseif stype2 == "string" then
                                    SetString(path.."."..k.."."..id.."."..key, stat)
                                end
                            end
                        else
                            SetString(path.."."..k.."."..id, preset)
                        end
                    end
                end
            end
        end
    end

    if Optics ~= nil then
        for id, Optic in pairs(Optics) do
            local path = "level.tabs."..v..".optics."..id

            for k, s in pairs(Optic) do
                local stype = type(s)
                if stype == "number" then
                    SetFloat(path.."."..k, s)
                elseif stype == "boolean" then
                    SetBool(path.."."..k, s)
                elseif stype == "string" then
                    SetString(path.."."..k, s)
                elseif stype == "table" then
                    for id, preset in pairs(s) do
                        for key, stat in pairs(preset) do
                            local stype2 = type(stat)
                            if stype2 == "number" then
                                SetFloat(path.."."..k.."."..id.."."..key, stat)
                            elseif stype2 == "boolean" then
                                SetBool(path.."."..k.."."..id.."."..key, stat)
                            elseif stype2 == "string" then
                                SetString(path.."."..k.."."..id.."."..key, stat)
                            end
                        end
                    end
                end
            end
        end
    end

    local team = GetIntParam("team",0)
    SetInt("level.tabs."..v..".vehicle.team",team)

end