--[[
    This library implements network queues
    You can send >64kb data over network with them.
    Only updated data is send

    !! You can not destroy the queue completely

    For now sending to specific player or server is only supported
]]


NetQueue = {}

NetQueue.NETWORK_TARGET_SERVER = 0 -- Special constant for server sender/receiver

local MAX_SIZE = 8 * 64 * 1024 -- In bits
local OBJECT_COUNT_BITS = 12
local MAX_OBJECT_COUNT = 4096 -- 2^12

--[[
msgTypeCfg = {
    TypeBits = 8, -- Amount of bits for message type field
    [1] = {
        SendFn = function(data) net.WriteXXX() end, -- Data sender function
        SendLengthFn = funcion(data) return 8+8+XXX end, -- Message length in bits
        RecvFn = function() return { A = net.ReadXXX() } end  -- Data reciever function
    }
}
]]


local NETRECV = {}

function NetQueue.CreateRecv(msgName, msgTypeCfg)
    assert(util.NetworkStringToID(msgName), tostring(msgName) .. " is not a network message name!")

    local netrecv = setmetatable({}, {__index = NETRECV})
    netrecv.MessageName = msgName
    netrecv.TypeConfig = msgTypeCfg
    netrecv.RecievedObjects = {}

    if CLIENT then
        netrecv.RecievedObjects[NetQueue.NETWORK_TARGET_SERVER] = {}
    end

    net.Receive(msgName, function(len, sender) RecvOnReceive(netrecv, len, sender or NetQueue.NETWORK_TARGET_SERVER) end)

    return netrecv
end

local function RecvOnReceive(self, len, sender)
    local objects_buffer = self.RecievedObjects[sender] or {}

    local data = {}
    local type_bits = self.TypeConfig.TypeBits

    local objectsCount = net.ReadUInt(OBJECT_COUNT_BITS) + 1 -- No more than 4096 objects per message, no less than 15 bytes per object (including type)

    for i = 0, objectCount do
        local objectType = net.ReadUInt(type_bits) + 1
        objects_buffer[#objects_buffer + 1] = self.TypeConfig[objectType].RecvFn()
    end

    self.RecievedObjects[sender] = objects_buffer
end

-- Returns all the currently stored objects
-- Optionally clears stored objects buffer
function NETRECV:GetAll(sender, remove_from_buffer)
    if self.RecievedObjects[sender] == nil then
        return {}
    end

    local recv = self.RecievedObjects[sender]

    if remove_from_buffer then
        self.RecievedObjects[sender] = nil
    end

    return recv
end

local NETSEND = {}

function NetQueue.CreateSend(msgName, msgTypeCfg)
    assert(util.NetworkStringToID(msgName), tostring(msgName) .. " is not a network message name!")

    local netsend = setmetatable({}, {__index = NETSEND})
    netsend.MessageName = msgName
    netsend.TypeConfig = msgTypeCfg
    netsend.PendingSendObjects = {}

    if CLIENT then
        netsend.PendingSendObjects[NetQueue.NETWORK_TARGET_SERVER] = {}
    end

    return netsend
end

function NETSEND:AddToQueue(object_type, object, receiver)
    local objects_buffer = self.PendingSendObjects[receiver] or {}

    local did_emplaced = false

    for i, v in ipairs(objects_buffer) do -- Try reusing allocated buffer slots first
        if v.NeedsSend == false then
            v.NeedsSend = true
            v.Type = object_type
            v.Data = object
            did_emplaced = true
            break
        end
    end

    if not did_emplaced then -- If no free slots, create one
        objects_buffer[#objects_buffer + 1] = { NeedsSend = true, Type = object_type, Data = object}
    end

    self.PendingSendObjects[receiver] = objects_buffer
end



function NETSEND:SendOnce(receiver)
    local pending_objects = self.PendingSendObjects[receiver]

    if pending_objects == nil then return end

    local send_indices = {}
    local cur_size = OBJECT_COUNT_BITS

    local type_bits = self.TypeConfig.TypeBits
    
    for i, v in ipairs(pending_objects) do
        local this_type = self.TypeConfig[v.Type]
        local this_size = this_type.SendLengthFn(v.Data)

        local new_size = cur_size + type_bits + this_size

        if new_size >= MAX_SIZE or i > MAX_OBJECT_COUNT then break end
        cur_size = new_size

        send_indices[#send_indices + 1] = i
    end

    net.Start(self.MessageName)
    net.WriteUInt(#send_indices - 1, OBJECT_COUNT_BITS)
    for _, i in ipairs(send_indices) do
        local object = pending_objects[i]
        net.WriteUInt(object.Type - 1, type_bits)
        self.TypeConfig[object.Type].SendFn(object)
    end

    if receiver == NetQueue.NETWORK_TARGET_SERVER then
        net.SendToServer()
    else
        net.Send(receiver)
    end
end