ys = ys or {}

local BattleSkillRemoveAllWeapon = class("BattleSkillRemoveAllWeapon", ys.Battle.BattleSkillEffect)

ys.Battle.BattleSkillRemoveAllWeapon = BattleSkillRemoveAllWeapon
BattleSkillRemoveAllWeapon.__name = "BattleSkillRemoveAllWeapon"

function BattleSkillRemoveAllWeapon:Ctor(arg_1_1)
	BattleSkillRemoveAllWeapon.super.Ctor(self, arg_1_1, lv)
end

function BattleSkillRemoveAllWeapon:DoDataEffect(arg_2_1)
	self:doRemove(arg_2_1)
end

function BattleSkillRemoveAllWeapon:DoDataEffectWithoutTarget(arg_3_1)
	self:doRemove(arg_3_1)
end

function BattleSkillRemoveAllWeapon:doRemove(arg_4_1)
	arg_4_1:RemoveAllAutoWeapon()
end
