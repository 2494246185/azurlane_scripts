ys = ys or {}

local var_0_0 = ys
local BattleSkillPlaySFX = class("BattleSkillPlaySFX", ys.Battle.BattleSkillEffect)

ys.Battle.BattleSkillPlaySFX = BattleSkillPlaySFX
BattleSkillPlaySFX.__name = "BattleSkillPlaySFX"

function BattleSkillPlaySFX:Ctor(arg_1_1, arg_1_2)
	BattleSkillPlaySFX.super.Ctor(self, arg_1_1, arg_1_2)

	self._SFXID = self._tempData.arg_list.sound_effect
end

function BattleSkillPlaySFX:DoDataEffect(arg_2_1, arg_2_2)
	self:playSound()
end

function BattleSkillPlaySFX:DoDataEffectWithoutTarget(arg_3_1)
	self:playSound()
end

function BattleSkillPlaySFX:playSound()
	var_0_0.Battle.PlayBattleSFX(self._SFXID)
end
