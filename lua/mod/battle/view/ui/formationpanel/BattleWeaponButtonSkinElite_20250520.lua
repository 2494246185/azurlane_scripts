ys = ys or {}

local BattleWeaponButtonSkinElite_20250520 = class("BattleWeaponButtonSkinElite_20250520", ys.Battle.BattleWeaponButtonSkinNormal_20250227)

ys.Battle.BattleWeaponButtonSkinElite_20250520 = BattleWeaponButtonSkinElite_20250520
BattleWeaponButtonSkinElite_20250520.__name = "BattleWeaponButtonSkinElite_20250520"

function BattleWeaponButtonSkinElite_20250520:OnTotalChange(arg_1_1)
	if self._progressInfo:GetTotal() <= 0 then
		self._block:SetActive(true)

		self._progressBar.fillAmount = 0
		self._bgEff:GetComponent(typeof(CanvasGroup)).alpha = 1
		self._text:GetComponent(typeof(Text)).text = "0/0"

		self:SetControllerActive(false)
		SetActive(self._glowEff, false)
		self:OnUnfill()
		self:OnUnSelect()
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

function BattleWeaponButtonSkinElite_20250520:OnCountChange()
	BattleWeaponButtonSkinElite_20250520.super.OnCountChange(self)
	SetActive(self._gizmos1, self._progressInfo:GetCount() > 0)
end

function BattleWeaponButtonSkinElite_20250520:OnOverLoadChange(arg_3_1)
	if self._progressInfo:IsOverLoad() then
		self._block:SetActive(true)
		self:OnUnfill()
	else
		self._block:SetActive(false)
		self:OnFilled()
	end

	if self._progressInfo:GetCount() >= 1 and arg_3_1 and arg_3_1.Data then
		if arg_3_1.Data.preCast then
			if arg_3_1.Data.preCast == 0 then
				quickCheckAndPlayAnimator(self._skin, "weapon_button_progress_filled")
			elseif arg_3_1.Data.preCast > 0 then
				quickCheckAndPlayAnimator(self._skin, "weapon_button_progress_charge")
			end
		end
	end

	if arg_3_1 and arg_3_1.Data and arg_3_1.Data.postCast then
		quickCheckAndPlayAnimator(self._skin, "weapon_button_progress_use")
	end

	if self._progressInfo:GetTotal() > 0 then
		self:updateProgressBar()
	end
end

function BattleWeaponButtonSkinElite_20250520:SetToCombatUIPreview(arg_4_1)
	local var_4_0 = CombatUIPreviewer.WeaponButtonPreviewMode

	switch(arg_4_1, {
		[CombatUIPreviewer.WeaponButtonPreviewMode.UNFILLED] = function()
			SetActive(self._unfill, true)
			SetActive(self._filled, false)

			self._progressBar.fillAmount = 0

			if self._bgEff then
				self._skin:Find("ActCtl/bg_eff"):GetComponent(typeof(CanvasGroup)).alpha = 1
			end

			self._countTxt.text = "0/0"

			if self._gizmos1 then
				SetActive(self._gizmos1, false)
				SetActive(self._gizmosXue, false)
			end
		end,
		[CombatUIPreviewer.WeaponButtonPreviewMode.FILLED] = function()
			SetActive(self._filled, true)
			SetActive(self._unfill, false)

			self._progressBar.fillAmount = 1

			if self._bgEff then
				self._skin:Find("ActCtl/bg_eff"):GetComponent(typeof(CanvasGroup)).alpha = 0
			end

			self._countTxt.text = "1/1"

			if self._gizmos1 then
				SetActive(self._gizmos1, true)
				SetActive(self._gizmosXue, true)
			end
		end,
		[CombatUIPreviewer.WeaponButtonPreviewMode.LOOP] = function()
			self:SetToCombatUIPreview(var_4_0.FILLED)
		end,
		[CombatUIPreviewer.WeaponButtonPreviewMode.USABLE] = function()
			local var_8_0 = self:GetProgressFaker(1)

			var_8_0.current = var_8_0.max
			var_8_0.count = 1
			self._progressInfo = var_8_0

			self:OnCountChange()
			self:OnOverLoadChange()
		end
	})
end
