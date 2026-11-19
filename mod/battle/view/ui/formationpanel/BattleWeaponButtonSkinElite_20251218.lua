ys = ys or {}

local BattleWeaponButtonSkinElite_20251218 = class("BattleWeaponButtonSkinElite_20251218", ys.Battle.BattleWeaponButtonSkinElite_20250520)

ys.Battle.BattleWeaponButtonSkinElite_20251218 = BattleWeaponButtonSkinElite_20251218
BattleWeaponButtonSkinElite_20251218.__name = "BattleWeaponButtonSkinElite_20251218"

function BattleWeaponButtonSkinElite_20251218:OnTotalChange(arg_1_1)
	if self._progressInfo:GetTotal() <= 0 then
		self._block:SetActive(true)

		self._progressBar.fillAmount = 0
		self._bgEff:GetComponent(typeof(CanvasGroup)).alpha = 0
		self._text:GetComponent(typeof(Text)).text = "0/0"

		self:SetControllerActive(false)
		SetActive(self._glowEff, false)
		self:OnUnfill()
		self:OnUnSelect()
		SetActive(self._gizmos1, false)
		SetActive(self._gizmosXue, false)
	else
		if self._progressInfo:GetTotal() == self._progressInfo:GetCount() then
			SetActive(self._glowEff, true)
		end

		self:OnCountChange()
		self:SetControllerActive(true)

		if arg_1_1 then
			if arg_1_1.Data.index and arg_1_1.Data.index == 1 then
				self:OnUnSelect()
			end
		end
	end
end

function BattleWeaponButtonSkinElite_20251218:OnCountChange()
	BattleWeaponButtonSkinElite_20251218.super.OnCountChange(self)
	SetActive(self._gizmosXue, self._progressInfo:GetCount() > 0)
end

function BattleWeaponButtonSkinElite_20251218:updateProgressBar()
	local var_3_0 = self._progressInfo:GetCurrent() / self._progressInfo:GetMax()

	self._progressBar.fillAmount = var_3_0
	self._bgEff:GetComponent(typeof(CanvasGroup)).alpha = self._progressInfo.GetCount and self._progressInfo:GetCount() > 0 and 1 or var_3_0
end
