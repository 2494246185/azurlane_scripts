ys = ys or {}

local BattleWeaponButtonSkinElite_20261112 = class("BattleWeaponButtonSkinElite_20261112", ys.Battle.BattleWeaponButton)

ys.Battle.BattleWeaponButtonSkinElite_20261112 = BattleWeaponButtonSkinElite_20261112
BattleWeaponButtonSkinElite_20261112.__name = "BattleWeaponButtonSkinElite_20261112"

function BattleWeaponButtonSkinElite_20261112:ConfigSkin(arg_1_1)
	BattleWeaponButtonSkinElite_20261112.super.ConfigSkin(self, arg_1_1)

	self._glowEff = self._filled:Find("gizmos")
end

function BattleWeaponButtonSkinElite_20261112:SetToCombatUIPreview(arg_2_1)
	if arg_2_1 ~= CombatUIPreviewer.WeaponButtonPreviewMode.UNFILLED then
		SetActive(self._filled, true)
		SetActive(self._unfill, false)

		self._progressBar.fillAmount = 1

		if self._bgEff then
			self._skin:Find("ActCtl/bg_eff"):GetComponent(typeof(CanvasGroup)).alpha = 1
		end

		self._countTxt.text = "1/1"

		if self._gizmos1 then
			SetActive(self._gizmos1, true)
			SetActive(self._gizmosXue, true)
		end
	else
		SetActive(self._unfill, true)
		SetActive(self._filled, false)

		self._progressBar.fillAmount = 0

		if self._bgEff then
			self._skin:Find("ActCtl/bg_eff"):GetComponent(typeof(CanvasGroup)).alpha = 0
		end

		self._countTxt.text = "0/0"

		if self._gizmos1 then
			SetActive(self._gizmos1, false)
			SetActive(self._gizmosXue, false)
		end
	end
end

function BattleWeaponButtonSkinElite_20261112:OnTotalChange(arg_3_1)
	if self._progressInfo:GetTotal() <= 0 then
		self._block:SetActive(true)

		self._progressBar.fillAmount = 0
		self._bgEff:GetComponent(typeof(CanvasGroup)).alpha = 0
		self._text:GetComponent(typeof(Text)).text = "0/0"

		self:SetControllerActive(false)
		self:OnUnfill()
		self:OnUnSelect()
	else
		if self._progressInfo:GetTotal() == self._progressInfo:GetCount() then
			SetActive(self._glowEff, true)
		end

		self:OnCountChange()
		self:SetControllerActive(true)

		if arg_3_1 then
			if arg_3_1.Data.index and arg_3_1.Data.index == 1 then
				self:OnUnSelect()
			end
		end
	end
end

function BattleWeaponButtonSkinElite_20261112:OnFilled()
	SetActive(self._filled, true)
	SetActive(self._unfill, false)
	SetActive(self._gizmos1, true)
	SetActive(self._gizmosXue, true)
end

function BattleWeaponButtonSkinElite_20261112:OnUnfill()
	SetActive(self._filled, false)
	SetActive(self._unfill, true)
	SetActive(self._gizmos1, false)
	SetActive(self._gizmosXue, false)
end

function BattleWeaponButtonSkinElite_20261112:OnCountChange()
	BattleWeaponButtonSkinElite_20261112.super.OnCountChange(self)
	SetActive(self._gizmosXue, self._progressInfo:GetTotal() > 0 and self._progressInfo:GetCount() > 0)
end

function BattleWeaponButtonSkinElite_20261112:OnOverLoadChange(arg_7_1)
	if self._progressInfo:IsOverLoad() then
		self._block:SetActive(true)
		self:OnUnfill()
	else
		self._block:SetActive(false)
		self:OnFilled()
	end

	if self._progressInfo:GetCount() >= 1 and arg_7_1 and arg_7_1.Data then
		if arg_7_1.Data.preCast then
			if arg_7_1.Data.preCast == 0 then
				quickCheckAndPlayAnimator(self._skin, "weapon_button_progress_filled")
			elseif arg_7_1.Data.preCast > 0 then
				quickCheckAndPlayAnimator(self._skin, "weapon_button_progress_charge")
			end
		end
	end

	if arg_7_1 and arg_7_1.Data and arg_7_1.Data.postCast then
		quickCheckAndPlayAnimator(self._skin, "weapon_button_progress_use")
	end

	if self._progressInfo:GetTotal() > 0 then
		self:updateProgressBar()
	end
end

function BattleWeaponButtonSkinElite_20261112:updateProgressBar()
	local var_8_0 = self._progressInfo:GetCurrent() / self._progressInfo:GetMax()

	self._progressBar.fillAmount = var_8_0
	self._bgEff:GetComponent(typeof(CanvasGroup)).alpha = self._progressInfo.GetCount and self._progressInfo:GetCount() > 0 and 1 or var_8_0
end

return BattleWeaponButtonSkinElite_20261112
