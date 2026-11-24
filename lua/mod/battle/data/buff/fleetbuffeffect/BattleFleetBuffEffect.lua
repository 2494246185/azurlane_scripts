ys = ys or {}

local var_0_0 = ys

ys.Battle.BattleFleetBuffEffect = class("BattleFleetBuffEffect")
ys.Battle.BattleFleetBuffEffect.__name = "BattleFleetBuffEffect"

function ys.Battle.BattleFleetBuffEffect:Ctor(arg_1_1)
	self._tempData = Clone(arg_1_1)
	self._type = self._tempData.type

	self:SetActive()
end

function ys.Battle.BattleFleetBuffEffect.SetArgs(arg_2_0, arg_2_1, arg_2_2)
	arg_2_0._fleetVO = arg_2_1
	arg_2_0._fleetBuff = arg_2_2
end

function ys.Battle.BattleFleetBuffEffect:Trigger(arg_3_1, arg_3_2, arg_3_3, arg_3_4)
	self[arg_3_1](self, arg_3_2, arg_3_3, arg_3_4)
end

function ys.Battle.BattleFleetBuffEffect:onAttach(arg_4_1, arg_4_2)
	self:onTrigger(arg_4_1, arg_4_2)
end

function ys.Battle.BattleFleetBuffEffect:onRemove(arg_5_1, arg_5_2)
	self:onTrigger(arg_5_1, arg_5_2)
end

function ys.Battle.BattleFleetBuffEffect:onUpdate(arg_6_1, arg_6_2)
	self:onTrigger(arg_6_1, arg_6_2)
end

function ys.Battle.BattleFleetBuffEffect:onStack(arg_7_1, arg_7_2)
	self:onTrigger(arg_7_1, arg_7_2)
end

function ys.Battle.BattleFleetBuffEffect.getTargetList(arg_8_0, arg_8_1, arg_8_2, arg_8_3)
	local var_8_0
	local var_8_1 = arg_8_1:GetUnitList()[1]

	for iter_8_0, iter_8_1 in ipairs(arg_8_2) do
		var_8_0 = var_0_0.Battle.BattleTargetChoise[iter_8_1](var_8_1, arg_8_3, var_8_0)
	end

	return var_8_0
end

function ys.Battle.BattleFleetBuffEffect:IsActive()
	return self._isActive
end

function ys.Battle.BattleFleetBuffEffect.SetActive(arg_10_0)
	arg_10_0._isActive = true
end

function ys.Battle.BattleFleetBuffEffect.NotActive(arg_11_0)
	arg_11_0._isActive = false
end

function ys.Battle.BattleFleetBuffEffect.Clear(arg_12_0)
	return
end

function ys.Battle.BattleFleetBuffEffect.Dispose(arg_13_0)
	return
end
