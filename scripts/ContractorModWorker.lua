--
-- ContractorMod
-- Specialization for storing each character data
-- No event plugged, only called when interacting with ContractorMod
--
-- @author  yumi
-- free for noncommerical-usage
--

source(Utils.getFilename("scripts/Passenger.lua", g_currentModDirectory))

ContractorModWorker = {};
ContractorModWorker_mt = Class(ContractorModWorker);

debug = false --true --
-- TODO: Check colorIndex value OK
--       To try all color index and map to worker color

function ContractorModWorker:new(name, index, displayOnFoot)
  if debug then print("ContractorModWorker:new()") end
  local self = {};
  setmetatable(self, ContractorModWorker_mt);

  self.name = name
  self.nickname = g_settingsNickname
  --print("self.nickname " .. self.nickname)
  g_settingsNickname = name
  --print("g_settingsNickname " .. g_settingsNickname)
  --self.index = index
  self.currentVehicle = nil
  self.isPassenger = false
  self.passengerPlace = nil
  self.playerIndex = 2
  self.playerColorIndex = 1
  self.followMeIsStarted = false
  self.farmerId = nil
  self.displayOnFoot = displayOnFoot
  if (g_currentMission.player ~= nil) then 
    self.playerColorIndex = index; --g_currentMission.player.playerColorIndex
    if debug then print("ContractorModWorker: playerColorIndex "..tostring(self.playerColorIndex)) end
    -- color:
    -- white      : 1
    -- grey       : 2
    -- blue       : 3
    -- navy       : 4
    -- green      : 5
    -- dark green : 6
    -- red        : 7
    -- brown      : 8
  end
  self.mapHotSpot = nil
  self.color = {0.,0.,0.}
  if index == 1 then
    self.color = {0.957,0.263,0.212}
  elseif index == 2 then
    self.color = {0.012,0.663,0.957}
  elseif index == 3 then
    self.color = {1.,0.922,0.231}
  elseif index == 4 then
    self.color = {0.298,0.686,0.314}
  elseif index == 5 then
    self.color = {1.0,0.341,0.137}
  elseif index == 6 then
    self.color = {0.008,0.588,0.537}
  elseif index == 7 then
    self.color = {0.474,0.333,0.286}
  elseif index == 8 then
    self.color = {0.247,0.317,0.709}
  end

  -- we should store position/vehicle in savegame
  -- start now with default one + offset
  if g_currentMission.controlPlayer and g_currentMission.player ~= nil then  
    self.x, self.y, self.z = getWorldTranslation(g_currentMission.player.rootNode);
    self.dx, self.dy, self.dz = localDirectionToWorld(g_currentMission.player.rootNode, 0, 0, 1);
    self.rotY = 0.73;
    self.x = self.x + (1 * index)

    if index == 1 then
      sceneToLoad = loadI3DFile("dataS2/character/player/player01.i3d");
    else
    --sceneToLoad = loadI3DFile("dataS2/character/player/player01.i3d");
      if index < 7 then 
        sceneToLoad = loadI3DFile("dataS2/character/pedestrians/man0" .. tostring(index) .. ".i3d", true, true, true);
      else
        sceneToLoad = loadI3DFile("dataS2/character/pedestrians/woman0" .. tostring(index-6) .. ".i3d", true, true, true);
      end
 --   sceneToLoad = loadI3DFile("dataS2/character/player/player02.i3d", true);
    --sceneToLoad = Utils.loadSharedI3DFile("character/player/player0" .. tostring(1 + (index % 2)) .. ".i3d","dataS2/",true,true, true);
 
    --sceneToLoad = Utils.loadSharedI3DFile("character/player/player01.i3d","dataS2/",false,false, true);
    --local newPlayer = Player:new(g_currentMission.player)
    --ContractorModWorker.testClass("Player", Player)
    --local newPlayer = ContractorModWorker.shallowcopy(g_currentMission.player)
    end
    
    self.skeletonId = getChildAt(sceneToLoad, 0);
		self.farmerId = getChildAt(sceneToLoad, 1);
		self.PRTG = createTransformGroup("PedestrianRoot");
		link(self.PRTG, self.skeletonId);
		link(getRootNode(), self.farmerId);
    self.clipDistance = 200;
    
    
    
		self.animCharSet = getAnimCharacterSet(sceneToLoad);
    local id = self.skeletonId
		if self.animCharSet ~= 0 then
      print("animCharSet not nil " .. tostring(self.animCharSet))
			self.isEnabled = true;
			local clip = 19; --getAnimClipIndex(self.animCharSet, "walkClipIndex");
      print("clip " .. tostring(clip))

      if clip ~= nil then
        assignAnimTrackClip(self.animCharSet, 1, clip);
        setAnimTrackLoopState(self.animCharSet, 1, true);
        setAnimTrackSpeedScale(self.animCharSet, 1, 1);
        print("AnimalPedestrian: clip found");
      end;
			-- local walkClips = getAnimClipIndex(self.animCharSet, "walkClips");
      -- print("walkClips " .. tostring(walkClips))
			-- self.walkTracks = Utils.splitString(" ", walkClips);
			-- for i=1, #self.walkTracks do
				-- self.walkTracks[i] = tonumber(self.walkTracks[i]);
			-- end;
      enableAnimTrack(self.animCharSet, 0);
    else
      print("animCharSet nil")
      self.animCharSet = getAnimCharacterSet(self.farmerId);
      if self.animCharSet ~= 0 then
        print("new animCharSet not nil")
      end
    end
    
    --ContractorModWorker.testClass("Player OBJ",g_currentMission.player)
    --ContractorModWorker.testClass("g_currentMission",g_currentMission)

    -- self.farmerId = getChildAt( sceneToLoad, 0)
    if self.farmerId ~= nil and index > 1 and self.displayOnFoot then
      --link(getRootNode(), self.farmerId)
      print("this is the farmerId: ".. self.farmerId) -- shows me an id
      setVisibility(self.farmerId, true)
      setVisibility(self.skeletonId, true)
      setTranslation(self.PRTG, self.x, self.y-0.7, self.z)
      setRotation(self.PRTG, 0, math.pi + self.rotY, 0)
      --setScale(farmerId, 5, 5, 5)
    else
      print("this is the farmerId: nil") -- shows me nil
    end
  end
    
  return self
end

--[[
function ContractorModWorker.shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function ContractorModWorker.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[ContractorModWorker.deepcopy(orig_key)] = ContractorModWorker.deepcopy(orig_value)
        end
        setmetatable(copy, ContractorModWorker.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function ContractorModWorker.testClass(className, classToTest)

	print("testing " .. tostring(className));		
	for _,k in pairs(classToTest) do
		print("function name : " .. tostring(_) .. " value : " .. tostring(k));			
	end;
	
	table.foreach(classToTest,print);
	
	print("end testing " .. tostring(className));
	
end;

function ContractorModWorker.testObject(displayName, object)

	print("testing " .. tostring(displayName));
	for key, value in pairs(getmetatable(object)) do
		print(key, value);
	end;
	print("end testing " .. tostring(displayName));
end;

--comes from courseplay. Thanks Jakob !
function ContractorModWorker.testTable(t, name, indent, maxDepth)
	
	local cart -- a container
	local autoref -- for self references
	maxDepth = maxDepth or 50;
	local depth = 0;

--counts the number of elements in a table
-- local function tablecount(t)
   -- local n = 0
   -- for _, _ in pairs(t) do n = n+1 end
   -- return n
-- end

	-- (RiciLake) returns true if the table is empty
	local function isemptytable(t) return next(t) == nil end

	local function basicSerialize(o)
		local so = tostring(o)
		if type(o) == "function" then
			local info = debug.getinfo(o, "S")
			-- info.name is nil because o is not a calling level
			if info.what == "C" then
				return string.format("%q", so .. ", C function")
			else
				-- the information is defined through lines
				return string.format("%q", so .. ", defined in (" ..
						info.linedefined .. "-" .. info.lastlinedefined ..
						")" .. info.source)
			end
		elseif type(o) == "number" then
			return so
		else
			return string.format("%q", so)
		end
	end

	local function addtocart(value, name, indent, saved, field, curDepth)
		indent = indent or ""
		saved = saved or {}
		field = field or name
		cart = cart .. indent .. field

		if type(value) ~= "table" then
			cart = cart .. " = " .. basicSerialize(value) .. ";\n"
		else
			if saved[value] then
				cart = cart .. " = {}; -- " .. saved[value]
						.. " (self reference)\n"
				autoref = autoref .. name .. " = " .. saved[value] .. ";\n"
			else
				saved[value] = name
				--if tablecount(value) == 0 then
				if isemptytable(value) then
					cart = cart .. " = {};\n"
				else
					if curDepth <= maxDepth then
						cart = cart .. " = {\n"
						for k, v in pairs(value) do
							k = basicSerialize(k)
							local fname = string.format("%s[%s]", name, k)
							field = string.format("[%s]", k)
							-- three spaces between levels
							addtocart(v, fname, indent .. "\t", saved, field, curDepth + 1);
						end
						cart = cart .. indent .. "};\n"
					else
						cart = cart .. " = { ... };\n";
					end;
				end
			end
		end;
	end

	name = name or "__unnamed__"
	if type(t) ~= "table" then
		return name .. " = " .. basicSerialize(t)
	end
	cart, autoref = "", ""
	addtocart(t, name, indent, nil, nil, depth + 1)
	return cart .. autoref
end;

-- ]]--

function ContractorModWorker:createNode(i3dFilename)
    --self.i3dFilename = i3dFilename;
    --self.customEnvironment, self.baseDirectory = Utils.getModNameAndBaseDirectory(i3dFilename);
    local i3dNode = Utils.loadSharedI3DFile(i3dFilename);
    if i3dNode ~= 0 then
      --print("i3d loaded")
      
      local farmerId = getChildAt(i3dNode, 0);
      link(getRootNode(), farmerId);
      delete(i3dNode);
    end
    
    local baseDirectory = "./"
    Utils.loadSharedI3DFile(i3dFilename, baseDirectory, true, true, self.loadFinished, self, {xmlFile, positionX, offsetY, positionZ, yRot, asyncCallbackFunction, asyncCallbackObject, asyncCallbackArguments});

    return farmerId;
end;

function ContractorModWorker:displayName()
  setTextBold(true);
  setTextAlignment(RenderText.ALIGN_RIGHT);
  
  setTextColor(self.color[1], self.color[2], self.color[3], 1.0);
  renderText(0.9828, 0.45, 0.024, self.name);
  
  if debug then
    renderText(0.9828, 0.43, 0.012, g_settingsNickname);
    if self.currentVehicle ~= nil then
      local vehicleName = ""
      if self.currentVehicle ~= nil then
        if self.currentVehicle.name ~= nil then
          vehicleName = self.currentVehicle.name
        end
      end
      renderText(0.9828, 0.42, 0.012, vehicleName);
    end
    renderText(0.9828, 0.41, 0.012, self.name);
    renderText(0.9828, 0.40, 0.012, "x:" .. tostring(self.x) .. " y:" .. tostring(self.y) .. " z:" .. tostring(self.z));
    renderText(0.9828, 0.39, 0.012, "dx:" .. tostring(self.dx) .. " dy:" .. tostring(self.dy) .. " dz:" .. tostring(self.dz));
  end
end

function ContractorModWorker:beforeSwitch(noEventSend)
  if debug then print("ContractorModWorker:beforeSwitch()") end
  self.currentVehicle = g_currentMission.controlledVehicle
  --g_settingsNickname = self.nickname

  if self.currentVehicle == nil then
    --print("currentVehicle is nil")
    local passengerHoldingVehicle = g_currentMission.passengerHoldingVehicle;
    if passengerHoldingVehicle ~= nil then
      -- source worker is passenger in a vehicle
      self.isPassenger = true
      self.currentVehicle = passengerHoldingVehicle
      self.passengerPlace = g_currentMission.passengerPlace
      --print("self.isPassenger = true " .. passengerHoldingVehicle.name)
      --print("passengerPlace " .. tostring(self.passengerPlace))
      self.x, self.y, self.z = getWorldTranslation(passengerHoldingVehicle.rootNode);
      self.y = self.y + 2 --to avoid being under the ground
      self.dx, self.dy, self.dz = localDirectionToWorld(passengerHoldingVehicle.rootNode, 0, 0, 1);
      if noEventSend == nil or noEventSend == false then
        --print("sendEvent(LeaveAsPassengerEvent")
        g_client:getServerConnection():sendEvent(LeaveAsPassengerEvent:new(passengerHoldingVehicle, g_currentMission.player, self.passengerPlace));
      end
      if passengerHoldingVehicle.places[self.passengerPlace].passengerNode ~= nil then
        -- keep passenger visible
        setVisibility(passengerHoldingVehicle.places[self.passengerPlace].passengerNode, true)
      end
    else
      -- source worker is not in a vehicle
      self.x, self.y, self.z = getWorldTranslation(g_currentMission.player.rootNode);
      self.rotY = g_currentMission.player.rotY;
      if self.farmerId ~= nil and self.displayOnFoot then
        setVisibility(self.farmerId, true)
        setTranslation(self.PRTG, self.x, self.y-0.7, self.z)
        setRotation(self.PRTG, 0, math.pi + self.rotY, 0)
      end
    end
  else
    -- source worker is in a vehicle
    --print("currentVehicle " .. self.currentVehicle.name)
    --print(networkGetObjectId(self.currentVehicle))
    self.x, self.y, self.z = getWorldTranslation(self.currentVehicle.rootNode);
    self.y = self.y + 2 --to avoid being under the ground
    self.dx, self.dy, self.dz = localDirectionToWorld(self.currentVehicle.rootNode, 0, 0, 1);

    if noEventSend == nil or noEventSend == false then
      if debug then print("ContractorModWorker: sendEvent(onLeaveVehicle") end
      g_currentMission:onLeaveVehicle()
    end
  end
end

function ContractorModWorker:afterSwitch(noEventSend)
  if debug then print("ContractorModWorker:afterSwitch()") end
  --g_settingsNickname = self.name
  
  if self.currentVehicle == nil then
    -- target worker is not in a vehicle
    --print("x:" .. tostring(self.x) .. " y:" .. tostring(self.y) .. " z:" .. tostring(self.z));
    --print("dx:" .. tostring(self.dx) .. " dy:" .. tostring(self.dy) .. " dz:" .. tostring(self.dz));

    --print(g_currentMission.controlPlayer)
    --print(g_currentMission.player)
    if g_currentMission.controlPlayer and g_currentMission.player ~= nil then
      if debug then print("ContractorModWorker: moveToAbsolute"); end
      setTranslation(g_currentMission.player.rootNode, self.x,self.y,self.z);
      g_currentMission.player:moveToAbsolute(self.x,self.y,self.z);
      if noEventSend == nil or noEventSend == false then
        g_client:getServerConnection():sendEvent(PlayerTeleportEvent:new(self.x,self.y,self.z));
      end
      g_currentMission.player.rotY = self.rotY--Utils.getYRotationFromDirection(self.dx, self.dz) + math.pi;
      if self.displayOnFoot then setVisibility(self.farmerId, false) end
    end

  else
    if self.isPassenger then
      -- target worker is passenger
      if noEventSend == nil or noEventSend == false then
        --print("sendEvent(EnterAsPassengerEvent")
        g_client:getServerConnection():sendEvent(EnterAsPassengerEvent:new(self.currentVehicle, g_currentMission.player, self.passengerPlace));
      end
    else
      -- target worker is in a vehicle
      if noEventSend == nil or noEventSend == false then      
        if debug then 
          print("ContractorModWorker: sendEvent(VehicleEnterRequestEvent:" ) end
        g_client:getServerConnection():sendEvent(VehicleEnterRequestEvent:new(self.currentVehicle, g_settingsNickname, self.playerIndex, self.playerColorIndex));
        if debug then
          print("ContractorModWorker: playerColorIndex "..tostring(self.playerColorIndex)) end
      end
    end
  end
end

