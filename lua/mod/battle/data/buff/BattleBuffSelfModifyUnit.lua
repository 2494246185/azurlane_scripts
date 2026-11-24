ys = ys or {}

local BattleBuffSelfModifyUnit = class("BattleBuffSelfModifyUnit", ys.Battle.BattleBuffUnit)

ys.Battle.BattleBuffSelfModifyUnit = BattleBuffSelfModifyUnit
BattleBuffSelfModifyUnit.__name = "BattleBuffSelfModifyUnit"

function BattleBuffSelfModifyUnit:Ctor(arg_1_1, arg_1_2, arg_1_3, arg_1_4)
	self._selfModifyTempData = arg_1_4

	BattleBuffSelfModifyUnit.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3, arg_1_4)
end

function BattleBuffSelfModifyUnit:SetTemplate()
	self._tempData = self._selfModifyTempData
end
