ys = ys or {}
ys.Battle.BattleBuffSetAttr = class("BattleBuffSetAttr", ys.Battle.BattleBuffEffect)
ys.Battle.BattleBuffSetAttr.__name = "BattleBuffSetAttr"

local var_0_0 = ys.Battle.BattleBuffSetAttr
local var_0_1 = ys.Battle.BattleAttr

function ys.Battle.BattleBuffSetAttr.Ctor(arg_1_0, arg_1_1)
	var_0_0.super.Ctor(arg_1_0, arg_1_1)
end

function ys.Battle.BattleBuffSetAttr:SetArgs(arg_2_1, arg_2_2)
	self._attr = self._tempData.arg_list.attr
	self._value = self._tempData.arg_list.value
end

function ys.Battle.BattleBuffSetAttr:onAttach(arg_3_1, arg_3_2)
	if self._attr == "TargetChoise" then
		var_0_1.AddTargetSelect(arg_3_1, self._value)
	else
		var_0_1.SetCurrent(arg_3_1, self._attr, self._value)
	end
end

function ys.Battle.BattleBuffSetAttr:onRemove(arg_4_1, arg_4_2)
	if self._attr == "TargetChoise" then
		var_0_1.RemoveTargetSelect(arg_4_1, self._value)
	else
		var_0_1.SetCurrent(arg_4_1, self._attr, 0)
	end
end
