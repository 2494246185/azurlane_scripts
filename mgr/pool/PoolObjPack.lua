local PoolObjPack = class("PoolObjPack")

function PoolObjPack:Ctor(arg_1_1, arg_1_2)
	self.key = arg_1_1
	self.ab = arg_1_2
	self.items = {}
	self.typeDic = {}
end

function PoolObjPack:Get(arg_2_1, arg_2_2)
	local var_2_0 = arg_2_1
	local var_2_1 = true

	if HXSet.isHx() and var_2_0 ~= "" then
		var_2_0 = var_2_0 .. "_hx"
		var_2_1 = table.contains(self.ab:GetAllAssetNames(), (self.ab:ChangeAssetName(var_2_0)))
	end

	var_2_0 = var_2_1 and var_2_0 or arg_2_1

	if not self.items[var_2_0] then
		self.items[var_2_0] = self.ab:LoadAssetSync(var_2_0, arg_2_2, false, false)
		self.typeDic[var_2_0] = arg_2_2
	end

	return self.items[var_2_0]
end

function PoolObjPack:Remove(arg_3_1)
	return table.removebykey(self.items, arg_3_1)
end

function PoolObjPack:GetAmount()
	return table.getCount(self.items)
end

function PoolObjPack:Clear()
	self.items = nil
	self.typeDic = nil

	self.ab:Dispose()

	self.ab = nil
end

return PoolObjPack
