#include "umf.lua"
#include "presets.lua"
local config = OptionsKeys {
    key = {
        rotation = {"string", "T"},
        Ctype = {"string", "G"},
        uion = {"boolean", true},
        toolenable = {"boolean", true},		
        record = {"string", "R"},
        place = {"string", "Y"},
    }
}

function init()

	if config.key.toolenable then
		tool_name = "tabscrew"
		RegisterTool(tool_name, "TABS Crew", "vox/tablet.vox", 2)
		SetBool("game.tool." .. tool_name ..".enabled", true)
		sound_place = LoadSound("metal/hit-s0.ogg")	
	end

	selectedcrew = 1
	spawnready = true
	


	spawncrew = nil
	outline = nil
	Vehicles = Vehicles or {}
	
	ignore_shapes = {}
	rotation = false
	recMsg = ""
	guideMsg = ""

	-- R曾是旋转键: 若老存档 rotation 仍是 R, 与录制冲突则把旋转让到 T
	if config.key.rotation == config.key.record then
		config.key.rotation = "T"
		SetString("savegame.mod.key.rotation", "T")
	end
	
	snd = LoadSound("MOD/snd/destroyed.ogg")
	duration = 3
	my_duration = 0	
	ui_time = 0
	PresetLoad()
end

function PresetKey(vname)
	local s = string.lower(vname or "unnamed")
	s = string.gsub(s, "[^a-z0-9]+", "_")
	if s == "" then s = "unnamed" end
	return s
end

function PresetSerialize(vname, list)
	local parts = {}
	for _, f in ipairs(list) do
		local r = f.rot or {0,0,0,1}
		parts[#parts+1] = f.role..","..f.pos[1]..","..f.pos[2]..","..f.pos[3]..","..r[1]..","..r[2]..","..r[3]..","..r[4]..","..(f.variant or "wall")
	end
	return vname.."|"..table.concat(parts, "|")
end

function PresetDeserialize(val)
	local segs = {}
	for seg in string.gmatch(val, "([^|]+)") do
		segs[#segs+1] = seg
	end
	if #segs < 1 then return nil, {} end
	local vname = segs[1]
	local list = {}
	for i=2, #segs do
		local f = {}
		for tok in string.gmatch(segs[i], "([^,]+)") do
			f[#f+1] = tok
		end
		if #f >= 4 then
			local e = {role=f[1], pos={tonumber(f[2]) or 0, tonumber(f[3]) or 0, tonumber(f[4]) or 0}, rot=nil, variant="wall"}
			if #f >= 8 then
				e.rot = {tonumber(f[5]) or 0, tonumber(f[6]) or 0, tonumber(f[7]) or 0, tonumber(f[8]) or 1}
			end
			if #f >= 9 and (f[9] == "floor" or f[9] == "wall") then
				e.variant = f[9]
			end
			list[#list+1] = e
		end
	end
	return vname, list
end

function PresetSave(vname, list)
	Presets = Presets or {}
	Presets[vname] = {crews=list}
	local ok, err = pcall(SetString, "savegame.mod.crewpreset."..PresetKey(vname), PresetSerialize(vname, list))
	if not ok then
		DebugPrint("[record] autosave failed: "..tostring(err))
	end
end

function PresetLoad()
	Presets = Presets or {}
	local n = 0
	local ok, keys = pcall(ListKeys, "savegame.mod.crewpreset")
	if ok and keys ~= nil then
		for _, k in ipairs(keys) do
			local vok, val = pcall(GetString, "savegame.mod.crewpreset."..k)
			if vok and val ~= nil and val ~= "" then
				local pok, vname, list = pcall(PresetDeserialize, val)
				if pok and vname ~= nil and list ~= nil and #list > 0 then
					Presets[vname] = {crews=list}
					n = n + 1
				end
			end
		end
	end
	DebugPrint("[record] loaded "..tostring(n).." presets")
end

function tick(dt)

    TickVehicleCrew()
	
	if config.key.toolenable then
		handle_input(dt)
		handle_record(dt)
	end
end


-- 纯手动 + 录制: 只读瞄准车辆, 按 record 键导出 joint 到该车的 crew 预设, 不做任何自动放置
function RecordAimVehicle()
	local cam = GetPlayerCameraTransform()
	local dir = TransformToParentVec(cam, Vec(0,0,-1))
	-- 预览outline/已放crew/隐藏shape会挡射线, 穿透它们找后面的车体 (最多5次)
	for tries=1, 5 do
		QueryRequire("physical")
		if outline ~= nil and outline ~= 0 and IsHandleValid(outline) then
			QueryRejectBody(outline)
		end
		QueryRejectAnimator(GetPlayerAnimator())
		if ignore_shapes ~= nil then
			for i=1, #ignore_shapes do
				QueryRejectShape(ignore_shapes[i])
			end
		end
		local hit, dist, normal, shape = QueryRaycast(cam.pos, dir, 60)
		if not hit or shape == 0 then return 0 end
		local body = GetShapeBody(shape)
		if body == 0 then
			QueryRejectShape(shape)
		else
			local veh = GetBodyVehicle(body)
			if veh ~= 0 then return veh end
			-- 非载具 (ghost/已放crew/零件): 拒掉继续穿透
			QueryRejectBody(body)
		end
	end
	return 0
end

function RecordName(veh)
	if HasTag(veh, "Name") then
		return GetTagValue(veh, "Name")
	end
	return "Unnamed"
end

function handle_record(dt)
	if GetString("game.player.tool") ~= tool_name then return end
	if not GetBool("game.player.canusetool") then return end
	if GetPlayerVehicle() ~= 0 then return end
	-- 引导: 准星车辆若有存档, 把存的位置画出来, 手动照着放 (无自动生成)
	local gveh = RecordAimVehicle()
	guideMsg = ""
	if gveh ~= 0 then
		local gvname = RecordName(gveh)
		local gp = Presets and Presets[gvname] or nil
		if gp ~= nil and gp.crews ~= nil then
			local gvehT = GetVehicleTransform(gveh)
			for _, c in ipairs(gp.crews) do
				local wp = TransformToParentPoint(gvehT, Vec(c.pos[1], c.pos[2], c.pos[3]))
				if c.role == "driver" then
					DebugCross(wp, 1, 0, 0, 1)
				else
					DebugCross(wp, 0, 1, 0, 1)
				end
			end
			guideMsg = "preset "..tostring(#gp.crews).." for "..gvname.." (green=crew red=driver)"
		else
			guideMsg = "no preset for "..gvname..", place manually then R"
		end
	end
	if InputPressed(config.key.record) then
		local veh = RecordAimVehicle()
		if veh == 0 then
			recMsg = "record: no vehicle aimed"
			DebugPrint("[record] no vehicle aimed")
			return
		end
		local vehT = GetVehicleTransform(veh)
		local vname = RecordName(veh)
		local found = {}
		local all = FindBodies("tabscrew", true)
		for _, cb in ipairs(all) do
			if HasTag(cb, "role") then
				for _, jb in ipairs(GetJointedBodies(cb)) do
					if GetBodyVehicle(jb) == veh then
						local role = GetTagValue(cb, "role")
						local variant = "wall"
						if HasTag(cb, "variant") then
							local vv = GetTagValue(cb, "variant")
							if vv == "floor" then variant = "floor" end
						end
						local bt = GetBodyTransform(cb)
						local lt = TransformToLocalTransform(vehT, bt)
						found[#found+1] = {role=role, variant=variant, pos={lt.pos[1], lt.pos[2], lt.pos[3]}, rot={lt.rot[1], lt.rot[2], lt.rot[3], lt.rot[4]}}
						break
					end
				end
			end
		end
		if #found == 0 then
			recMsg = "record: no crew jointed to "..vname
			DebugPrint("[record] "..recMsg)
			return
		end
		PresetSave(vname, found)
		local nw, nf = 0, 0
		for _, f in ipairs(found) do
			if f.variant == "floor" then nf = nf + 1 else nw = nw + 1 end
		end
		recMsg = "saved "..tostring(#found).." (wall "..tostring(nw).. " floor "..tostring(nf)..") for "..vname
		DebugPrint("[record] "..recMsg)
	end
	if InputPressed(config.key.place) then
		local veh = RecordAimVehicle()
		if veh == 0 then
			recMsg = "place: no vehicle aimed"
			return
		end
		local vname = RecordName(veh)
		local p = Presets and Presets[vname] or nil
		if p == nil or p.crews == nil or #p.crews == 0 then
			recMsg = "place: no preset for "..vname..", record with R first"
			DebugPrint("[place] "..recMsg)
			return
		end
		local vehT = GetVehicleTransform(veh)
		local n = 0
		-- wall系prefab内body偏移 (back系): B = S * L, Lpos=(-0.3,-0.4,0) Lrot=Euler(0,-90,0)
		-- floor系 (ass) 内层group与body相抵消, L近似单位, 直接按body位刷
		local Lpos = Vec(-0.3, -0.4, 0)
		local Linv = QuatEuler(0, 90, 0)
		for _, c in ipairs(p.crews) do
			local variant = c.variant or "wall"
			local xml = "MOD/xml/crew back.xml"
			if variant == "floor" then xml = "MOD/xml/crew ass.xml" end
			if c.role == "driver" and variant == "wall" then xml = "MOD/xml/driver back.xml" end
			if c.role == "driver" and variant == "floor" then xml = "MOD/xml/driver ass.xml" end
			local bw
			if c.rot ~= nil then
				bw = TransformToParentTransform(vehT, Transform(Vec(c.pos[1], c.pos[2], c.pos[3]), {c.rot[1], c.rot[2], c.rot[3], c.rot[4]}))
			else
				bw = TransformToParentTransform(vehT, Transform(Vec(c.pos[1], c.pos[2], c.pos[3]), vehT.rot))
			end
			local sw, srot
			if variant == "floor" then
				sw, srot = bw.pos, bw.rot
			else
				srot = QuatRotateQuat(bw.rot, Linv)
				sw = VecSub(bw.pos, QuatRotateVec(srot, Lpos))
			end
			local h = Spawn(xml, Transform(sw, srot), false, true)[1]
			if h ~= nil and h ~= 0 then
				for _, s in ipairs(GetBodyShapes(h)) do
					SetShapeCollisionFilter(s, 2, 1)
				end
				n = n + 1
			end
		end
		PlaySound(sound_place, GetPlayerCameraTransform().pos)
		recMsg = "placed "..tostring(n).."/"..tostring(#p.crews).." for "..vname
		DebugPrint("[place] "..recMsg)
	end
end


function handle_input(dt)

	--[[

	]]
	if GetString("game.player.tool") == tool_name and GetBool("game.player.canusetool") then

	   	if InputPressed(config.key.Ctype) then
			Delete(outline)
			spawnready = true
		    selectedcrew = selectedcrew + 1
			if selectedcrew > 2 then selectedcrew = 1 end
		end		

	   	if InputPressed(config.key.rotation) and rotation == false then		
			Delete(outline)
			spawnready = true
			rotation = true
	   	elseif InputPressed(config.key.rotation) and rotation == true then
			Delete(outline)
			spawnready = true		
			rotation = false			
		end		
		
		
		if spawnready == true then
		
			if rotation ==false then
				if selectedcrew == 1 then
					outline = Spawn("MOD/xml/crew back outline.xml", Transform(hit_pos))[1]
					spawnready = false	
				elseif selectedcrew == 2 then
					outline = Spawn("MOD/xml/driver back outline.xml", Transform(hit_pos))[1]
					spawnready = false					
				end
			elseif rotation then
				if selectedcrew == 1 then
					outline = Spawn("MOD/xml/crew ass outline.xml", Transform(hit_pos))[1]
					spawnready = false	
				elseif selectedcrew == 2 then
					outline = Spawn("MOD/xml/driver ass outline.xml", Transform(hit_pos))[1]
					spawnready = false					
				end			
			
			end
			
		end		
		

		local headTrans = GetCameraTransform()
		local lookDir = TransformToParentVec(headTrans, Vec(0, 0, -1))
		local maxDist = 5
		QueryRejectBody(outline)
		QueryRequire("physical")
		
		if  #ignore_shapes > 0 then
			for i=1, #ignore_shapes do
				local ignore_shape = ignore_shapes[i]
				QueryRejectShape(ignore_shape)
			end
		end
		QueryRejectAnimator(GetPlayerAnimator())

		local hit, dist, normal, shape = QueryRaycast(headTrans.pos, lookDir, maxDist)			
		hit_pos = VecAdd(headTrans.pos, VecScale(lookDir, dist))
		local offset = 0.05
		
		

		local outline_shapes = GetBodyShapes(outline)			
		for i=1,#outline_shapes do
			local outline_shape = outline_shapes[i]			
			if hit then
				RemoveTag(outline_shape,"invisible")
			else
				SetTag(outline_shape,"invisible")	
			end
		end

	
		DrawShapeOutline(shape, 0.5)		
		if InputPressed("rmb") then
			SetTag(shape,"invisible")
			table.insert(ignore_shapes, shape)
		
		elseif InputPressed("mmb") then --reset
			for i=1, #ignore_shapes do
				local ignore_shape = ignore_shapes[i]
				RemoveTag(ignore_shape,"invisible")
			end
			ignore_shapes = {}
		end
		

		if rotation then
			-- 1. 플레이어 방향만 계산 (Y축 기준)
			local lookDir = VecNormalize(VecSub(headTrans.pos, hit_pos))
			lookDir[2] = 0  -- Y축 회전만 남기고, 앞뒤 기울기 제거
			lookDir = VecNormalize(lookDir) -- 다시 정규화

			-- 2. Y축 고정 up 벡터
			local up = Vec(0,1,0)

			-- 3. 회전 쿼터니언 생성
			rot = QuatLookAt(lookDir, up)
			correctedRot = QuatRotateQuat(rot, QuatEuler(-50,0,0)) --
			-- 4. 객체 Transform 적용
			SetBodyTransform(outline, Transform(hit_pos, correctedRot))
		elseif not rotation then	 		
			SetBodyTransform(outline,Transform(hit_pos,QuatRotateQuat(QuatLookAt(Vec(), normal),QuatEuler(0, 180, 0))))
		end
		
		SetBodyDynamic(outline,false)			
	
	
		if InputPressed("lmb") and hit then		
			PlaySound(sound_place, hit_pos)		
			
			if rotation == false then 
				if selectedcrew == 1 then
					spawncrew = Spawn("MOD/xml/crew back.xml",Transform(hit_pos,QuatRotateQuat(QuatLookAt(Vec(), normal),QuatEuler(0, -90, 0))),false,true)[1]
				elseif selectedcrew == 2 then
					spawncrew = Spawn("MOD/xml/driver back.xml",Transform(hit_pos,QuatRotateQuat(QuatLookAt(Vec(), normal),QuatEuler(0, -90, 0))),false,true)[1]			
				end			
			elseif rotation then
				if selectedcrew == 1 then
					spawncrew = Spawn("MOD/xml/crew ass.xml",Transform(hit_pos, correctedRot),false,true)[1]
				elseif selectedcrew == 2 then
					spawncrew = Spawn("MOD/xml/driver ass.xml",Transform(hit_pos, correctedRot),false,true)[1]			
				end							
			end
			
		end	

		local shapes = GetBodyShapes(spawncrew)
		for i=1,#shapes do
			local shape = shapes[i]
			SetShapeCollisionFilter(shape,2,1)
		end		
		
	else

		Delete(outline)	
		spawnready = true
	end
end




function draw(dt)

	if ui_time > 0 then
		ui_time = ui_time - dt
		
		UiPush()
			UiTranslate(UiCenter(), UiHeight()-900) --120
			UiAlign("center middle")
			UiColor(1, 1, 1)
			UiFont("bold.ttf", 30)
			UiTextOutline(1,0,0,1,0.2)
			local type_text2
			local mode_text2			
			type_text2 = "Target Destroyed" 					
			UiText(type_text2)			
		UiPop()				
		
	end


	if my_duration > 0 then
		my_duration = my_duration - dt
		
		UiPush()
			UiTranslate(UiCenter(), UiHeight()-900) --120
			UiAlign("center middle")
			UiColor(1, 1, 1)
			UiFont("bold.ttf", 30)
			UiTextOutline(0,0,0,1,0.2)
			local type_text2
			local mode_text2			
			type_text2 = "You've been destroyed" 					
			UiText(type_text2)			
		UiPop()				
		
	end






	if GetString("game.player.tool") == tool_name and GetPlayerVehicle() == 0 then
	
		UiPush()
			UiTranslate(UiCenter()-180, UiHeight()-205) --120
			UiAlign("center middle")
			UiColor(1, 1, 1)
			UiFont("bold.ttf", 20)
			UiTextOutline(0,0,0,1,0.1)
			local type_text2
			local mode_text2			
			type_text2 = "Place = LMB" 					
			UiText(type_text2)			
		UiPop()	

		UiPush()
			UiTranslate(UiCenter(), UiHeight()-205) --120
			UiAlign("center middle")
			UiColor(1, 1, 1)
			UiFont("bold.ttf", 20)
			UiTextOutline(0,0,0,1,0.1)
			local type_text2
			local mode_text2			
			type_text2 = "Reset shapes = MMB" 					
			UiText(type_text2)			
		UiPop()			
		
		UiPush()
			UiTranslate(UiCenter()+180, UiHeight()-205) --120
			UiAlign("center middle")
			UiColor(1, 1, 1)
			UiFont("bold.ttf", 20)
			UiTextOutline(0,0,0,1,0.1)
			local type_text2
			local mode_text2			
			type_text2 = "Hide shape = RMB" 					
			UiText(type_text2)			
		UiPop()				
		
	

	
		UiPush()
			UiTranslate(UiCenter(), UiHeight()-175) --120
			UiAlign("center middle")
			UiColor(1, 1, 1)
			UiFont("bold.ttf", 20)
			UiTextOutline(0,0,0,1,0.1)
			local type_text2
			local mode_text2			
			type_text2 = "Crew Rotation = ("..config.key.rotation..")" 					
			UiText(type_text2)			
		UiPop()		
	
		UiPush()
			UiTranslate(UiCenter(), UiHeight()-150) --120
			UiAlign("center middle")
			UiColor(1, 1, 1)
			UiFont("bold.ttf", 20)
			UiTextOutline(0,0,0,1,0.1)
			local type_text2
			local mode_text2			
			type_text2 = "Crew Type = ("..config.key.Ctype..")" 					
			UiText(type_text2)			
		UiPop()		
	
	
	
		if not rotation then
			if selectedcrew == 1 then
				UiPush()
					UiTranslate(UiCenter(), UiHeight()-120) --120
					UiAlign("center middle")
					UiColor(1, 1, 1)
					UiFont("bold.ttf", 26)
					UiTextOutline(0,0,0,1,0.1)
					local type_text2
					local mode_text2			
					type_text2 = "Crew Wall" 					
					UiText(type_text2)			
				UiPop()	

			elseif selectedcrew == 2 then
				UiPush()
					UiTranslate(UiCenter(), UiHeight()-120) --120
					UiAlign("center middle")
					UiColor(1, 1, 1)
					UiFont("bold.ttf", 26)
					UiTextOutline(0,0,0,1,0.1)
					local type_text2
					local mode_text2			
					type_text2 = "Driver Wall" 					
					UiText(type_text2)			
				UiPop()	
			end
		elseif rotation then
			if selectedcrew == 1 then
				UiPush()
					UiTranslate(UiCenter(), UiHeight()-120) --120
					UiAlign("center middle")
					UiColor(1, 1, 1)
					UiFont("bold.ttf", 26)
					UiTextOutline(0,0,0,1,0.1)
					local type_text2
					local mode_text2			
					type_text2 = "Crew Floor" 					
					UiText(type_text2)			
				UiPop()	

			elseif selectedcrew == 2 then
				UiPush()
					UiTranslate(UiCenter(), UiHeight()-120) --120
					UiAlign("center middle")
					UiColor(1, 1, 1)
					UiFont("bold.ttf", 26)
					UiTextOutline(0,0,0,1,0.1)
					local type_text2
					local mode_text2			
					type_text2 = "Driver Floor" 					
					UiText(type_text2)			
				UiPop()	
			end
		end


		
		
		UiPush()
			UiTranslate(UiCenter(), UiHeight()-80) --120
			UiAlign("center middle")
			UiColor(1, 1, 1)
			UiFont("bold.ttf", 20)
			UiTextOutline(0,0,0,1,0.1)
			local type_text2
			local mode_text2			
			type_text2 = "Ignored Shapes = " .. tostring(#ignore_shapes) .. ""										
			UiText(type_text2)			
		UiPop()			
		
		UiPush()
			UiTranslate(UiCenter(), UiHeight()-55) --120
			UiAlign("center middle")
			UiColor(1, 1, 1)
			UiFont("bold.ttf", 18)
			UiTextOutline(0,0,0,1,0.1)
			UiText(config.key.record.."=record "..config.key.place.."=place  "..recMsg)			
		UiPop()			
		UiPush()
			UiTranslate(UiCenter(), UiHeight()-32) --120
			UiAlign("center middle")
			UiColor(0.6, 1, 0.6)
			UiFont("bold.ttf", 18)
			UiTextOutline(0,0,0,1,0.1)
			UiText(guideMsg)			
		UiPop()		
		
		
	end
end

function TickVehicleCrew() -----------------------------------------------------구조 확인필요
    -- 1. 새로 부착된 승무원/운전자 탐지 및 등록
    local allBodies = FindBodies("tabscrew", true)
    for _, crewBody in ipairs(allBodies) do
        if HasTag(crewBody, "role") then
            local role = GetTagValue(crewBody, "role") -- driver 또는 crew

            -- 승무원/운전자가 부착된 차량 찾기
            local connectedBodies = GetJointedBodies(crewBody)
            for _, attachedBody in ipairs(connectedBodies) do
                local veh = GetBodyVehicle(attachedBody)
                if veh ~= 0 then
                    if Vehicles[veh] == nil then
                        Vehicles[veh] = {drivers = {}, crews = {}, active = true, registered = false}
                    end

                    if Vehicles[veh][role.."s"] == nil then
                        Vehicles[veh][role.."s"] = {}
                    end

                    -- 이미 등록된 바디인지 확인
                    local already = false
                    for _, entry in ipairs(Vehicles[veh][role.."s"]) do
                        if entry.body == crewBody then
                            already = true
                            break
                        end
                    end

                    if not already then
                        table.insert(Vehicles[veh][role.."s"], {body = crewBody, alive = true})
                        --DebugPrint("Registered "..role.." for vehicle "..veh)
                        Vehicles[veh].registered = true -- 등록된 tick 표시
                    end
                end
            end
        end
    end

    -- 2. 생존 상태 업데이트 및 차량 기능 제어
    for veh, data in pairs(Vehicles) do
		
        if data.active and data.registered then
            local driverAlive = nil
            local crewAlive = nil

            -- 운전자 생존 체크
            if data.drivers and #data.drivers > 0 then
                driverAlive = false
                for _, driver in ipairs(data.drivers) do
                    if IsHandleValid(driver.body) and not IsBodyBroken(driver.body) then
						vehicleConnection = 0
						local D_jointeds = GetJointedBodies(driver.body)
						for i=1, #D_jointeds do
							local D_jointed = D_jointeds[i]
							if GetBodyVehicle(D_jointed) == veh then
								vehicleConnection = vehicleConnection + 1
							end							
						end
						
						if vehicleConnection < 1 then
							driver.alive = false
						else
							driverAlive = true
							driver.alive = true							
						end						
						
                    else
                        driver.alive = false
                    end
                end
            end



            -- 승무원 생존 체크
            if data.crews and #data.crews > 0 then
                crewAlive = false
                for _, crews in ipairs(data.crews) do
                    if IsHandleValid(crews.body) and not IsBodyBroken(crews.body) then					
						vehicleConnection2 = 0
						local D_jointeds = GetJointedBodies(crews.body)
						for i=1, #D_jointeds do
							local D_jointed = D_jointeds[i]
							if GetBodyVehicle(D_jointed) == veh then
								vehicleConnection2 = vehicleConnection2 + 1
							end							
						end						
						
						if vehicleConnection2 < 1 then
							crews.alive = false
						else
							crewAlive = true
							crews.alive = true						
						end					
						
                    else
                        crews.alive = false
                    end
                end
            end


			------------- 승무원 총 숫자 체크
			local totalCrewCount = 0
			local aliveCrewCount = 0

			if data.drivers then
				for _, driver in ipairs(data.drivers) do
					totalCrewCount = totalCrewCount + 1
					if driver.alive then
						aliveCrewCount = aliveCrewCount + 1
					end
				end
			end

			if data.crews then
				for _, crew in ipairs(data.crews) do
					totalCrewCount = totalCrewCount + 1
					if crew.alive then
						aliveCrewCount = aliveCrewCount + 1
					end
				end
			end
			---------------

            -- 운전자 모두 사망 → 차량 운전 불능
            if driverAlive == false then
				local wheels = GetEntityChildren(veh, "", true, "wheel")
				for i = 1, #wheels do
					SetProperty(wheels[i], "drive", 0)
					SetProperty(wheels[i], "steer", 0)
				end	
            end

            -- 승무원 모두 사망 → 조인트 정지
            if crewAlive == false then --and data.crew and #data.crew > 0 then
					
            end

			
			--DebugPrint(aliveCrewCount)

            -- 차량 상태 활성/비활성 관리
            if totalCrewCount >= 2 and aliveCrewCount < 2 or totalCrewCount == 1 and aliveCrewCount == 0 or HasTag(veh,"nodrive") then
				SetTag(veh,"customhealth")				
				SetVehicleHealth(veh, 0.3)

				if not HasTag(veh, "disabled") and config.key.uion then				
					if veh ~= GetPlayerVehicle() then
						ui_time = ui_time + duration
						PlaySound(snd, GetPlayerCameraTransform().pos, 10)
					elseif veh == GetPlayerVehicle() then
						my_duration = my_duration + duration
						SetPlayerVehicle(0)
						--SetTag(veh, "nodrive")
					end
				end			
								
                SetTag(veh, "disabled")				
                --SetTag(veh, "nodrive")							

                data.active = false
                Vehicles[veh] = nil
            end
        end
    end
end