ys = ys or {}

local var_0_0 = ys.Battle.BattleDataFunction
local var_0_1 = ys.Battle.BattleConst
local var_0_3 = ys.Battle.BattleAttr
local BattleMinionUnit = class("BattleMinionUnit", ys.Battle.BattleEnemyUnit)

ys.Battle.BattleMinionUnit = BattleMinionUnit
BattleMinionUnit.__name = "BattleMinionUnit"

function BattleMinionUnit:Ctor(arg_1_1, arg_1_2)
	BattleMinionUnit.super.Ctor(self, arg_1_1, arg_1_2)
end

function BattleMinionUnit:GetUnitType()
	return var_0_1.UnitType.MINION_UNIT
end

function BattleMinionUnit:SetMaster(arg_3_1)
	self._master = arg_3_1
end

function BattleMinionUnit:InheritMasterAttr()
	var_0_3.SetMinionAttr(self)
	var_0_3.InitDOTAttr(self._attr, self._tmpData)
	self:setStandardLabelTag()
end

function BattleMinionUnit:SetTemplate(arg_5_1, arg_5_2)
	self._tmpID = arg_5_1
	self._tmpData = var_0_0.GetMonsterTmpDataFromID(self._tmpID)

	self:configWeaponQueueParallel()
	self:InitCldComponent()
end

function BattleMinionUnit:IsShowHPBar()
	return false
end

function BattleMinionUnit:GetMaster()
	return self._master
end

function BattleMinionUnit:DispatchVoice()
	return
end

function BattleMinionUnit:Retreat()
	BattleMinionUnit.super.Retreat(self)
	self:SetDeathReason(var_0_1.UnitDeathReason.LEAVE)
	self:DeacActionClear()
	self._battleProxy:KillUnit(self:GetUniqueID())
end
