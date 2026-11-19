ys = ys or {}

local BattleWeaponButtonSkinElite_20250912 = class("BattleWeaponButtonSkinElite_20250912", ys.Battle.BattleWeaponButtonSkinElite_20250520)

ys.Battle.BattleWeaponButtonSkinElite_20250912 = BattleWeaponButtonSkinElite_20250912
BattleWeaponButtonSkinElite_20250912.__name = "BattleWeaponButtonSkinElite_20250912"

function BattleWeaponButtonSkinElite_20250912:SetToCombatUIPreview(arg_1_1)
	local var_1_0 = CombatUIPreviewer.WeaponButtonPreviewMode

	switch(arg_1_1, {
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
			self:SetToCombatUIPreview(var_1_0.FILLED)
		end,
		[CombatUIPreviewer.WeaponButtonPreviewMode.USABLE] = function()
			local var_5_0 = self:GetProgressFaker(1)

			var_5_0.current = var_5_0.max
			var_5_0.count = 1
			self._progressInfo = var_5_0

			self:OnCountChange()
			self:OnOverLoadChange()
		end
	})
end
