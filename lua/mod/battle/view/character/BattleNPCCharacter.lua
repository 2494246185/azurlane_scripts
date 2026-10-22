ys = ys or {}
ys.Battle.BattleNPCCharacter = class("BattleNPCCharacter", ys.Battle.BattleEnemyCharacter)
ys.Battle.BattleNPCCharacter.__name = "BattleNPCCharacter"

local var_0_1 = ys.Battle.BattleNPCCharacter

function ys.Battle.BattleNPCCharacter.Ctor(arg_1_0)
	var_0_1.super.Ctor(arg_1_0)

	arg_1_0._preCastBound = false
end

function ys.Battle.BattleNPCCharacter.SetHPColor(arg_2_0, arg_2_1)
	arg_2_0._HPColor = arg_2_1
end

function ys.Battle.BattleNPCCharacter:GetHPColor()
	return self._HPColor
end

function ys.Battle.BattleNPCCharacter.SetModleID(arg_4_0, arg_4_1)
	arg_4_0._prefab = arg_4_1
end

function ys.Battle.BattleNPCCharacter:GetModleID()
	if self._prefab then
		return self._prefab
	else
		return self._unitData:GetTemplate().prefab
	end
end

function ys.Battle.BattleNPCCharacter.SetUnvisible(arg_6_0)
	arg_6_0._isUnvisible = true
end

function ys.Battle.BattleNPCCharacter:MakeVisible()
	if self._isUnvisible then
		self._go:SetActive(false)
		self._HPBar:SetActive(false)
		self._buffBar:SetActive(false)
	end
end
