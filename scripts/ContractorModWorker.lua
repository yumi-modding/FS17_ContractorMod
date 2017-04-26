source(Utils.getFilename("scripts/Passenger.lua", g_currentModDirectory))

ContractorModWorker = {};
ContractorModWorker_mt = Class(ContractorModWorker);

debug = false --true --
-- TODO: Check colorIndex value OK
--       To try all color index and map to worker color

function ContractorModWorker:new(name, index)
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
  self.playerIndex = 1
  self.playerColorIndex = 1
  self.followMeIsStarted = false
  if (g_currentMission.player ~= nil) then 
    self.playerColorIndex = g_currentMission.player.playerColorIndex
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
    self.x = self.x + (0.5 * index)
  end
  
  
  --local filename = '$data/character/farmer/farmer_player.i3d'--getXMLString(xmlFile, "vehicle.characterNode#filename");
  --local nodeId = ContractorModWorker:createNode(filename);
  --setTranslation(nodeId, self.x, self.y+2, self.z);
  --setRotation(nodeId, self.dx, self.dy, self.dz);
  --setVisibility(nodeId, true)

  return self
end

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
        if debug then print("ContractorModWorker: sendEvent(VehicleEnterRequestEvent:" ) end
        g_client:getServerConnection():sendEvent(VehicleEnterRequestEvent:new(self.currentVehicle, g_settingsNickname, self.playerIndex, self.playerColorIndex));
      end
    end
  end
end

