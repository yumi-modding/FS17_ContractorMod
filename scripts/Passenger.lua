EnterAsPassengerEvent = {};
EnterAsPassengerEvent_mt = Class(EnterAsPassengerEvent, Event);

InitEventClass(EnterAsPassengerEvent, "EnterAsPassengerEvent");

function EnterAsPassengerEvent:emptyNew()
    local self = Event:new(EnterAsPassengerEvent_mt);
    self.className="EnterAsPassengerEventEvent";
    return self;
end;

function EnterAsPassengerEvent:new(object, passenger, place)
    local self = EnterAsPassengerEvent:emptyNew()
    self.object = object;
	self.passenger = passenger;
	self.place = place;
    return self;
end;

function EnterAsPassengerEvent:readStream(streamId, connection)
	self.object = networkGetObject(streamReadInt32(streamId));
	self.passenger = networkGetObject(streamReadInt32(streamId));
	self.place = streamReadInt8(streamId);
    self:run(connection);
end;

function EnterAsPassengerEvent:writeStream(streamId, connection)
    streamWriteInt32(streamId, networkGetObjectId(self.object));
	streamWriteInt32(streamId, networkGetObjectId(self.passenger));
	streamWriteInt8(streamId, self.place);
end;

function EnterAsPassengerEvent:run(connection)
    self.object:enterAsPassenger(self.passenger, self.place, true);
    if not connection:getIsServer() then
        g_server:broadcastEvent(EnterAsPassengerEvent:new(self.object, self.passenger, self.place), nil, connection, self.object);
    end;
end;

function EnterAsPassengerEvent.sendEvent(vehicle, passenger, place, noEventSend)
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(EnterAsPassengerEvent:new(vehicle, passenger, place), nil, nil, vehicle);
		else
			g_client:getServerConnection():sendEvent(EnterAsPassengerEvent:new(vehicle, passenger, place));
		end;
	end;
end;


LeaveAsPassengerEvent = {};
LeaveAsPassengerEvent_mt = Class(LeaveAsPassengerEvent, Event);

InitEventClass(LeaveAsPassengerEvent, "LeaveAsPassengerEvent");

function LeaveAsPassengerEvent:emptyNew()
    local self = Event:new(LeaveAsPassengerEvent_mt);
    self.className="LeaveAsPassengerEvent";
    return self;
end;

function LeaveAsPassengerEvent:new(object, passenger, place)
    local self = LeaveAsPassengerEvent:emptyNew()
    self.object = object;
	self.passenger = passenger;
	self.place = place;
    return self;
end;

function LeaveAsPassengerEvent:readStream(streamId, connection)
	self.object = networkGetObject(streamReadInt32(streamId));
	self.passenger = networkGetObject(streamReadInt32(streamId));
	self.place = streamReadInt8(streamId);
    
    self:run(connection);
end;

function LeaveAsPassengerEvent:writeStream(streamId, connection)
    streamWriteInt32(streamId, networkGetObjectId(self.object));
	streamWriteInt32(streamId, networkGetObjectId(self.passenger));
	streamWriteInt8(streamId, self.place);
end;

function LeaveAsPassengerEvent:run(connection)
    self.object:leaveAsPassenger(self.passenger, self.place, true);
    if not connection:getIsServer() then
        g_server:broadcastEvent(LeaveAsPassengerEvent:new(self.object, self.passenger, self.place), nil, connection, self.object);
    end;
end;

function LeaveAsPassengerEvent.sendEvent(vehicle, passenger, place, noEventSend)
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(LeaveAsPassengerEvent:new(vehicle, passenger, place), nil, nil, vehicle);
		else
			g_client:getServerConnection():sendEvent(LeaveAsPassengerEvent:new(vehicle, passenger, place));
		end;
	end;
end;
