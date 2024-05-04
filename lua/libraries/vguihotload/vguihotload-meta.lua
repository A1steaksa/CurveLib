---@meta

---@class VGUIHotload
vguihotload = {}

---@alias UniqueId string|number

---@class RegisteredFrame
---@field InitFunction function The function that will be called to create and return the DFrame when it needs to be created or recreated.
---@field Frame DFrame The DFrame that was created by the InitFunction.
---@field HotloadTime number The time at which the DFrame was last hotloaded.

---@type table<UniqueId, RegisteredFrame>
RegisteredFrames = {}

-- Registers the initializer function for a DFrame to be hotloaded with the system.  
-- The function should create the DFrame, set it up, and return it.  
-- It will be closed and recreated in the same position and at the same size whenever the code is hotloaded.  
--- **Note:** This will immediately call the function and create the DFrame.
---@param id UniqueId The unique ID for this frame.
---@param vguiCreateFunction function The function that will be called to create and return the DFrame when it needs to be created or recreated.
function vguihotload.Register( id, vguiCreateFunction ) end

-- Checks if a given ID corresponds to a registered function.
---@private
---@param id UniqueId The unique ID for the frame.
---@return boolean `true` if the ID corresponds to a valid frame registration
function vguihotload.IsIdValid( id ) end

-- Hotloads a given unique ID's corresponding DFrame.  
-- Practically, this closes the existing DFrame, uses the initializer function to create a new one,  
-- and sets the new DFrame's position and size to match the one that was just closed.
---@param id UniqueId The unique ID for this frame.
function vguihotload.HandleHotload( id ) end