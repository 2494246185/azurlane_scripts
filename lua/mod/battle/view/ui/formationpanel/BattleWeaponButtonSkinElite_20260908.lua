ys = ys or {}

local BattleWeaponButtonSkinElite_20260908 = class("BattleWeaponButtonSkinElite_20260908", ys.Battle.BattleWeaponButtonSkinElite_20251218)

ys.Battle.BattleWeaponButtonSkinElite_20260908 = BattleWeaponButtonSkinElite_20260908
BattleWeaponButtonSkinElite_20260908.__name = "BattleWeaponButtonSkinElite_20260908"

function BattleWeaponButtonSkinElite_20260908:ConfigSkin(arg_1_1)
	self._skin = arg_1_1
	self._btn = arg_1_1:Find("ActCtl")
	self._block = arg_1_1:Find("ActCtl/block").gameObject
	self._progress = arg_1_1:Find("ActCtl/skill_progress")
	self._progressBar = self._progress:GetComponent(typeof(Image))
	self._icon = arg_1_1:Find("ActCtl/skill_icon")
	self._filled = self._icon:Find("filled")
	self._unfill = self._icon:Find("unfill")
	self._count = arg_1_1:Find("ActCtl/Count")
	self._text = self._count:Find("CountText")
	self._selected = arg_1_1:Find("ActCtl/selected")
	self._unSelect = arg_1_1:Find("ActCtl/unselect")
	self._filledEffect = arg_1_1:Find("ActCtl/filledEffect")
	self._jam = arg_1_1:Find("ActCtl/jam")
	self._countTxt = self._text:GetComponent(typeof(Text))

	arg_1_1.gameObject:SetActive(true)
	self._block:SetActive(false)
	self._progress.gameObject:SetActive(true)
	self._filledEffect.gameObject:SetActive(false)
	self._filledEffect.gameObject:GetComponent("DftAniEvent"):SetEndEvent(function(arg_2_0)
		SetActive(self._filledEffect, false)
	end)

	self._animtor = arg_1_1:GetComponent(typeof(Animator))
	self._bgEff = arg_1_1:Find("ActCtl/bg_eff")
	self._gizmos1 = arg_1_1:Find("ActCtl/gizmos_1")
	self._gizmosXue = arg_1_1:Find("ActCtl/gizmos_xue")
end

function BattleWeaponButtonSkinElite_20260908:OnTotalChange(arg_3_1)
	if self._progressInfo:GetTotal() <= 0 then
		self._block:SetActive(true)

		self._progressBar.fillAmount = 0

		if self._bgEff then
			self._skin:Find("ActCtl/bg_eff"):GetComponent(typeof(CanvasGroup)).alpha = 0
		end

		self._text:GetComponent(typeof(Text)).text = "0/0"

		self:SetControllerActive(false)
		self:OnUnfill()
		self:OnUnSelect()
	else
		self:OnCountChange()
		self:SetControllerActive(true)

		if arg_3_1 then
			if arg_3_1.Data.index and arg_3_1.Data.index == 1 then
				self:OnUnSelect()
			end
		end
	end
end

function BattleWeaponButtonSkinElite_20260908:updateProgressBar()
	local var_4_0 = self._progressInfo:GetCurrent() / self._progressInfo:GetMax()

	self._progressBar.fillAmount = var_4_0
	self._bgEff:GetComponent(typeof(CanvasGroup)).alpha = self._progressInfo.GetCount and self._progressInfo:GetCount() > 0 and 1 or var_4_0
end

return BattleWeaponButtonSkinElite_20260908
