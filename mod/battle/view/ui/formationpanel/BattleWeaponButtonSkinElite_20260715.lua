ys = ys or {}

local BattleWeaponButtonSkinElite_20260715 = class("BattleWeaponButtonSkinElite_20260715", ys.Battle.BattleWeaponButtonSkinElite_20250327)

ys.Battle.BattleWeaponButtonSkinElite_20260715 = BattleWeaponButtonSkinElite_20260715
BattleWeaponButtonSkinElite_20260715.__name = "BattleWeaponButtonSkinElite_20260715"

function BattleWeaponButtonSkinElite_20260715:OnTotalChange(arg_1_1)
	BattleWeaponButtonSkinElite_20260715.super.OnTotalChange(self, arg_1_1)
	SetActive(self._glowEff, self._progressInfo:GetTotal() > 0)
	SetActive(self._gizmosXue, self._progressInfo:GetTotal() > 0)
end

function BattleWeaponButtonSkinElite_20260715:ConfigSkin(arg_2_1)
	BattleWeaponButtonSkinElite_20260715.super.ConfigSkin(self, arg_2_1)

	self._glowEff = self._btn:Find("gizmos_1")
end

function BattleWeaponButtonSkinElite_20260715:OnCountChange()
	BattleWeaponButtonSkinElite_20260715.super.OnCountChange(self)
	SetActive(self._glowEff, self._progressInfo:GetCount() > 0)
	SetActive(self._gizmosXue, self._progressInfo:GetCount() > 0)
end

function BattleWeaponButtonSkinElite_20260715:updateProgressBar()
	local var_4_0 = self._progressInfo:GetCurrent() / self._progressInfo:GetMax()

	self._progressBar.fillAmount = var_4_0
	self._bgEff:GetComponent(typeof(CanvasGroup)).alpha = self._progressInfo.GetCount and self._progressInfo:GetCount() > 0 and 1 or var_4_0
end
