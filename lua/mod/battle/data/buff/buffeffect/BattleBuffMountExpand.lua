ys = ys or {}

local BattleBuffMountExpand = class("BattleBuffMountExpand", ys.Battle.BattleBuffEffect)

ys.Battle.BattleBuffMountExpand = BattleBuffMountExpand
BattleBuffMountExpand.__name = "BattleBuffMountExpand"

function BattleBuffMountExpand:Ctor(arg_1_1)
	BattleBuffMountExpand.super.Ctor(self, arg_1_1)
end

function BattleBuffMountExpand:SetArgs(arg_2_1, arg_2_2)
	self._weaponIndex = self._tempData.arg_list.index
end

function BattleBuffMountExpand:onAttach(arg_3_1, arg_3_2)
	arg_3_1:ExpandWeaponMount(self._weaponIndex)
end
