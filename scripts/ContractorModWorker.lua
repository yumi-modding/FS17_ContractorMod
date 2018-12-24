--
-- ContractorMod
-- Specialization for storing each character data
-- No event plugged, only called when interacting with ContractorMod
--
-- @author  yumi
-- free for noncommercial-usage
--

ContractorModWorker = {};
ContractorModWorker_mt = Class(ContractorModWorker);

ContractorModWorker.debug = true --false --

function ContractorModWorker:getParentComponent(node)
    return self.graphicsRootNode;
end;

function ContractorModWorker:new(name, index, gender, workerStyle, farmId, displayOnFoot)
  if ContractorModWorker.debug then print("ContractorModWorker:new()") end
  local self = {};
  setmetatable(self, ContractorModWorker_mt);

  self.name = name
  self.nickname = g_settingsNickname
  g_settingsNickname = name
  self.currentVehicle = nil
  self.isPassenger = false    -- to be removed when all code clean
  self.isNewPassenger = false -- to replace isPassenger waiting code cleaning
  self.playerIndex = 2
  self.gender = gender
  if self.gender == "female" then
    workerStyle.playerModelIndex = 2
  else
    workerStyle.playerModelIndex = 1
  end
  self.xmlFile = "dataS/character/humans/player/player0"..tostring(workerStyle.playerModelIndex)..".xml"

  -- if ContractorModWorker.debug then print("ContractorMod: playerStyle "..tostring(playerStyle.selectedColorIndex)) end
  -- playerStyle:setColor(index + 1)
  -- if ContractorModWorker.debug then print("ContractorMod: playerStyle "..tostring(playerStyle.selectedColorIndex)) end
  local playerStyle = PlayerStyle:new()
  playerStyle:copySelection(g_currentMission.missionInfo.playerStyle)
  -- playerStyle.selectedModelIndex = workerStyle.playerModelIndex -- = gender
  playerStyle.selectedColorIndex = workerStyle.playerColorIndex
  playerStyle.selectedBodyIndex = workerStyle.playerBodyIndex
  playerStyle.selectedHatIndex = workerStyle.playerHatIndex
  playerStyle.selectedAccessoryIndex = workerStyle.playerAccessoryIndex
  playerStyle.selectedHairIndex = workerStyle.playerHairIndex
  playerStyle.selectedJacketIndex = workerStyle.playerJacketIndex

  self.playerStyle = PlayerStyle:new()
  self.playerStyle:copySelection(playerStyle)
  self.farmId = farmId
  self.followMeIsStarted = false
  self.displayOnFoot = displayOnFoot
  -- Bellow needed to load player character to make character visible with displayOnFoot.
  self.ikChains = {}
  self.idleWeight = 1;
  self.walkWeight = 0;
  self.runWeight = 0;
  self.cuttingWeight = 0;
  self.baseInformation = {};
  self.animationInformation = {};
  self.animationInformation.parameters = {};
  self.animationInformation.parameters = {};
  self.networkInformation = {};
  self.soundInformation = {}
  self.soundInformation.samples = {}
  self.soundInformation.samples.swim = {}
  self.soundInformation.samples.plunge = {}
  self.soundInformation.samples.horseBrush = {}
  self.soundInformation.distancePerFootstep = {}
  self.soundInformation.distancePerFootstep.crouch = 0.5
  self.soundInformation.distancePerFootstep.walk = 0.75
  self.soundInformation.distancePerFootstep.run = 1.5
  self.soundInformation.distanceSinceLastFootstep = 0.0
  self.soundInformation.isSampleSwinPlaying = false
  self.particleSystemsInformation = {}
  self.particleSystemsInformation.systems = {}
  self.particleSystemsInformation.systems.swim = {}
  self.particleSystemsInformation.systems.plunge = {}
  self.particleSystemsInformation.swimNode = 0
  self.particleSystemsInformation.plungeNode = 0
  self.animationInformation = {}
  self.animationInformation.player = nil
  self.animationInformation.parameters = {}
  self.animationInformation.parameters.forwardVelocity = {id=1, value=0.0, type=1}
  self.animationInformation.parameters.verticalVelocity = {id=2, value=0.0, type=1}
  self.animationInformation.parameters.yawVelocity = {id=3, value=0.0, type=1}
  self.animationInformation.parameters.onGround = {id=4, value=false, type=0}
  self.animationInformation.parameters.inWater = {id=5, value=false, type=0}
  self.animationInformation.parameters.isCrouched = {id=6, value=false, type=0}
  self.animationInformation.parameters.absForwardVelocity = {id=7, value=0.0, type=1}
  self.animationInformation.parameters.isCloseToGround = {id=8, value=false, type=0}
  self.animationInformation.parameters.isUsingChainsawHorizontal = {id=9, value=false, type=0}
  self.animationInformation.parameters.isUsingChainsawVertical = {id=10, value=false, type=0}
  -- @see Player.loadCustomization for the content of this struct
  --self.visualInformation = nil
  -- cached info
  self.animationInformation.oldYaw = 0.0                               -- in rad
  self.animationInformation.newYaw = 0.0                               -- in rad
  self.animationInformation.estimatedYawVelocity = 0.0                 -- in rad/s
  self.inputInformation = {};
  self.rootNode = createTransformGroup("PlayerCCT")
  link(getRootNode(), self.rootNode)

  self.mapHotSpot = nil
  --self.color = {1, 1, 1}--@FS19g_availableMpColorsTable[self.playerColorIndex].value -- g_availableMpColorsTable is nil
  self.color = g_playerColors[(workerStyle.playerColorIndex + 1)].value

  -- start now with default one + offset
  if g_currentMission.controlPlayer and g_currentMission.player ~= nil then
    self.x, self.y, self.z = getWorldTranslation(g_currentMission.player.rootNode);
    self.dx, self.dy, self.dz = localDirectionToWorld(g_currentMission.player.rootNode, 0, 0, 1);
    self.rotX = 0.;
    self.rotY = 0.73;
    self.x = self.x + (1 * index)
    
    print("g_currentMission.player")
    -- DebugUtil.printTableRecursively(g_currentMission.player, " ", 1, 2);

    Player.loadVisuals(self, self.xmlFile, self.playerStyle, nil, true, self.ikChains, self.getParentComponent, self, nil)
    self.playerStateMachine = PlayerStateMachine:new(self)
    self.playerStateMachine:load()
    self.playerStateMachine:activateState("idle")

    --self:moveToAbsolute()

    -- a:dataS/character/humans/player/player02.xml
    -- b:table: 0x02455d96d3f8
    -- c:82463 = characterNode
    -- d:false
    -- e:table: 0x02451dc40d58 = ikChains
    -- f:nil
    -- g:nil
    -- h:82463 = characterNode
    -- i:nil
    -- j:nil
    -- k:nil
    print("self")
    -- DebugUtil.printTableRecursively(self, " ", 1, 2);
    
    if self.skeletonThirdPerson ~= nil and index > 1 and self.displayOnFoot then
      if ContractorModWorker.debug then print("this is the meshThirdPerson: ".. self.skeletonThirdPerson) end-- shows me an id
      setVisibility(self.meshThirdPerson, true);
      setVisibility(self.animRootThirdPerson, true);
      local playerOffSet = g_currentMission.player.baseInformation.capsuleTotalHeight * 0.5
      setTranslation(self.graphicsRootNode, self.x, self.y - playerOffSet, self.z)
      setRotation(self.graphicsRootNode , 0, self.rotY, 0)
      --setScale(meshThirdPerson, 5, 5, 5)
    else
      if ContractorModWorker.debug then print("this is the skeletonThirdPerson: nil") end-- shows me nil
    end
  end
    
  return self
end

function ContractorModWorker:displayName()
  --if ContractorModWorker.debug then print("ContractorModWorker:displayName()") end
  if self.name == "PLAYER" then return end
  setTextBold(true);
  setTextAlignment(RenderText.ALIGN_RIGHT);
  
  setTextColor(self.color[1], self.color[2], self.color[3], 1.0);
  renderText(0.9828, 0.45, 0.024, self.name);
  
  if ContractorModWorker.debug then
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
  -- Restore default alignment (to avoid impacting other mods like FarmingTablet)
  setTextAlignment(RenderText.ALIGN_LEFT);
end

-- @doc Capture worker position before switching to another one
function ContractorModWorker:beforeSwitch(noEventSend)
  if ContractorModWorker.debug then print("ContractorModWorker:beforeSwitch()") end
  self.currentVehicle = g_currentMission.controlledVehicle

  if self.currentVehicle == nil then
    -- Old passenger condition
    local passengerHoldingVehicle = g_currentMission.passengerHoldingVehicle;
    if passengerHoldingVehicle ~= nil then
      -- source worker is passenger in a vehicle
    else
      -- source worker is not in a vehicle
      self.x, self.y, self.z = getWorldTranslation(g_currentMission.player.rootNode);
      self.rotX = g_currentMission.player.rotX;
      self.rotY = g_currentMission.player.rotY;
      if self.meshThirdPerson ~= nil and self.displayOnFoot then
        if noEventSend == nil or noEventSend == false then
          setVisibility(self.meshThirdPerson, true)
          setVisibility(self.animRootThirdPerson, true)
        end
        local playerOffSet = g_currentMission.player.baseInformation.capsuleTotalHeight * 0.5
        setTranslation(self.graphicsRootNode, self.x, self.y - playerOffSet, self.z)
        setRotation(self.graphicsRootNode, 0, self.rotY, 0)
      end
    end
  else
    -- source worker is in a vehicle
    self.x, self.y, self.z = getWorldTranslation(self.currentVehicle.rootNode);
    self.y = self.y + 2 --to avoid being under the ground
    self.dx, self.dy, self.dz = localDirectionToWorld(self.currentVehicle.rootNode, 0, 0, 1);

    if noEventSend == nil or noEventSend == false then
      if ContractorModWorker.debug then print("ContractorModWorker: sendEvent(onLeaveVehicle") end
      g_currentMission:onLeaveVehicle()
    end
  end
end

-- @doc Teleport to target worker when switching 
function ContractorModWorker:afterSwitch(noEventSend)
  if ContractorModWorker.debug then print("ContractorModWorker:afterSwitch()") end
  
  if self.currentVehicle == nil then
    -- target worker is not in a vehicle
    if g_currentMission.controlPlayer and g_currentMission.player ~= nil then
      if ContractorModWorker.debug then print("ContractorModWorker: moveToAbsolute"); end
      local playerOffSet = g_currentMission.player.baseInformation.capsuleTotalHeight * 0.5
      setTranslation(g_currentMission.player.rootNode, self.x, self.y - playerOffSet, self.z);
      g_currentMission.player:moveToAbsolute(self.x, self.y, self.z);
      if noEventSend == nil or noEventSend == false then
        g_client:getServerConnection():sendEvent(PlayerTeleportEvent:new(self.x, self.y - playerOffSet, self.z, true, true));
      end
      g_currentMission.player.rotX = self.rotX
      g_currentMission.player.rotY = self.rotY
      if self.displayOnFoot then
        setVisibility(self.meshThirdPerson, false)
        setVisibility(self.animRootThirdPerson, false)
        end
    end

  else
    -- if self.isPassenger then
      -- target worker is passenger
    -- else
      -- target worker is in a vehicle
      if noEventSend == nil or noEventSend == false then      
        if ContractorModWorker.debug then print("ContractorModWorker: sendEvent(VehicleEnterRequestEvent:" ) end
        g_client:getServerConnection():sendEvent(VehicleEnterRequestEvent:new(self.currentVehicle, self.playerStyle, self.farmId));
        if ContractorModWorker.debug then print("ContractorModWorker: playerStyle "..tostring(self.playerStyle)) end
      end
    -- end
  end
end

