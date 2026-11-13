local NetSalvageUpdate = class("NetSalvageUpdate", import("....BaseEntity"))

NetSalvageUpdate.Fields = {
	id = "number",
	list = "table",
	mapId = "number",
	step = "number"
}

function NetSalvageUpdate:Setup(arg_1_1)
	self.id = arg_1_1.group_id
	self.step = arg_1_1.cmd_collection.progress
	self.list = underscore.to_array(arg_1_1.cmd_collection.progress_list)
	self.mapId = arg_1_1.cmd_collection.random_id
end

function NetSalvageUpdate:Dispose()
	self:Clear()
end

return NetSalvageUpdate
