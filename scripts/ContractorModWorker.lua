--
-- ContractorMod
-- Specialization for storing each character data
-- No event plugged, only called when interacting with ContractorMod
--
-- @author  yumi
-- free for noncommercial-usage
--

source(Utils.getFilename("scripts/Passenger.lua", g_currentModDirectory))

ContractorModWorker = {};
ContractorModWorker_mt = Class(ContractorModWorker);

debug = false --true --

function ContractorModWorker:getParentComponent(node)
    return self.graphicsRootNode;
end;

function ContractorModWorker:new(name, index, gender, playerColorIndex, displayOnFoot)
  if debug then print("ContractorModWorker:new()") end
  local self = {};
  setmetatable(self, ContractorModWorker_mt);

  self.name = name
  self.nickname = g_settingsNickname
  g_settingsNickname = name
  self.currentVehicle = nil
  self.isPassenger = false
  self.isNewPassenger = false -- to replace isPassenger waiting code cleaning
  self.passengerPlace = nil
  self.playerIndex = 2
  self.gender=gender
  if self.gender == "female" then
    self.xmlFile = "dataS2/character/player/player02.xml"
  else
    self.xmlFile = "dataS2/character/player/player01.xml"
  end

  self.playerColorIndex = playerColorIndex
  self.followMeIsStarted = false
  self.displayOnFoot = displayOnFoot
  -- Bellow needed to load player character to make character visible with displayOnFoot.
  self.ikChains = {}
  self.idleWeight = 1;
  self.walkWeight = 0;
  self.runWeight = 0;
  self.cuttingWeight = 0;

  self.mapHotSpot = nil
  self.color = g_availableMpColorsTable[self.playerColorIndex].value

  -- start now with default one + offset
  if g_currentMission.controlPlayer and g_currentMission.player ~= nil then  
    self.x, self.y, self.z = getWorldTranslation(g_currentMission.player.rootNode);
    self.dx, self.dy, self.dz = localDirectionToWorld(g_currentMission.player.rootNode, 0, 0, 1);
    self.rotY = 0.73;
    self.x = self.x + (1 * index)

    Player.loadVisuals(self, self.xmlFile, self.playerColorIndex, nil, true, self.ikChains, self.getParentComponent, self, nil)

    if self.skeletonThirdPerson ~= nil and index > 1 and self.displayOnFoot then
      print("this is the meshThirdPerson: ".. self.skeletonThirdPerson) -- shows me an id
      setVisibility(self.meshThirdPerson, true);
      setVisibility(self.animRootThirdPerson, true);
      setTranslation(self.graphicsRootNode , self.x, self.y+0.2, self.z)
      setRotation(self.graphicsRootNode , 0,self.rotY, 0)
      --setScale(meshThirdPerson, 5, 5, 5)
    else
      print("this is the skeletonThirdPerson: nil") -- shows me nil
    end
  end
    
  return self
end



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
      if self.meshThirdPerson ~= nil and self.displayOnFoot then
        if noEventSend == nil or noEventSend == false then
          setVisibility(self.meshThirdPerson, true)
          setVisibility(self.animRootThirdPerson, true)
        end
        setTranslation(self.graphicsRootNode, self.x, self.y+0.2, self.z)
        setRotation(self.graphicsRootNode, 0,self.rotY, 0)
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
      setTranslation(g_currentMission.player.rootNode, self.x,self.y+0.2,self.z);
      g_currentMission.player:moveToAbsolute(self.x,self.y,self.z);
      if noEventSend == nil or noEventSend == false then
        g_client:getServerConnection():sendEvent(PlayerTeleportEvent:new(self.x,self.y+0.2,self.z));
      end
      g_currentMission.player.rotY = self.rotY--Utils.getYRotationFromDirection(self.dx, self.dz) + math.pi;
      if self.displayOnFoot then
        setVisibility(self.meshThirdPerson, false)
        setVisibility(self.animRootThirdPerson, false)
        end
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

