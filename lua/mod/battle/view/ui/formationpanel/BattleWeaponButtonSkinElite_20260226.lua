ys = ys or {}

local BattleWeaponButtonSkinElite_20260226 = class("BattleWeaponButtonSkinElite_20260226", ys.Battle.BattleWeaponButtonSkinElite_20250520)

ys.Battle.BattleWeaponButtonSkinElite_20260226 = BattleWeaponButtonSkinElite_20260226
BattleWeaponButtonSkinElite_20260226.__name = "BattleWeaponButtonSkinElite_20260226"

function BattleWeaponButtonSkinElite_20260226:ConfigSkin(arg_1_1)
	BattleWeaponButtonSkinElite_20260226.super.ConfigSkin(self, arg_1_1)

	self._books = self._selected:Find("usdfx/fx/up/book/book/book1")
	self._bookList = {}

	for iter_1_0 = 1, 4 do
		table.insert(self._bookList, self._books:Find("text_" .. iter_1_0))
	end
end

function BattleWeaponButtonSkinElite_20260226:OnCountChange()
	BattleWeaponButtonSkinElite_20260226.super.OnCountChange(self)
	SetActive(self._gizmos1, self._progressInfo:GetCount() > 0)
	SetActive(self._gizmosXue, self._progressInfo:GetCount() > 0)
end

function BattleWeaponButtonSkinElite_20260226:OnOverLoadChange(arg_3_1)
	if arg_3_1 and arg_3_1.Data and arg_3_1.Data.postCast then
		local var_3_0 = math.random(4)

		for iter_3_0, iter_3_1 in ipairs(self._bookList) do
			SetActive(iter_3_1, iter_3_0 == var_3_0)
		end
	end

	BattleWeaponButtonSkinElite_20260226.super.OnOverLoadChange(self, arg_3_1)
end

function BattleWeaponButtonSkinElite_20260226:updateProgressBar()
	local var_4_0 = self._progressInfo:GetCurrent() / self._progressInfo:GetMax()

	self._progressBar.fillAmount = var_4_0

	if self._bgEff then
		self._bgEff:GetComponent(typeof(CanvasGroup)).alpha = self._progressInfo.GetCount and self._progressInfo:GetCount() > 0 and 0 or 1 - var_4_0
	end
end

function BattleWeaponButtonSkinElite_20260226:SetToCombatUIPreview(arg_5_1)
	local var_5_0 = CombatUIPreviewer.WeaponButtonPreviewMode

	switch(arg_5_1, {
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
			self:SetToCombatUIPreview(var_5_0.FILLED)
		end,
		[CombatUIPreviewer.WeaponButtonPreviewMode.USABLE] = function()
			local var_9_0 = self:GetProgressFaker(1)

			var_9_0.current = var_9_0.max
			var_9_0.count = 1
			self._progressInfo = var_9_0

			self:OnCountChange()
			self:OnOverLoadChange()
		end
	})
end
