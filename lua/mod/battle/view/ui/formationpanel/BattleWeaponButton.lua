ys = ys or {}

local var_0_0 = ys
local BattleWeaponButton = class("BattleWeaponButton")

ys.Battle.BattleWeaponButton = BattleWeaponButton
BattleWeaponButton.__name = "BattleWeaponButton"
BattleWeaponButton.ICON_BY_INDEX = {
	"cannon",
	"torpedo",
	"aircraft",
	"submarine",
	"dive",
	"rise",
	"boost",
	"switch",
	"special",
	"aamissile",
	"meteor",
	"pointairstrike"
}

function BattleWeaponButton:Ctor()
	var_0_0.EventListener.AttachEventListener(self)

	self.eventTriggers = {}
end

function BattleWeaponButton:ConfigCallback(arg_2_1, arg_2_2, arg_2_3, arg_2_4)
	self._downFunc = arg_2_1
	self._upFunc = arg_2_2
	self._cancelFunc = arg_2_3
	self._emptyFunc = arg_2_4
end

function BattleWeaponButton:SetActive(arg_3_1)
	SetActive(self._skin, arg_3_1)
end

function BattleWeaponButton:SetJam(arg_4_1)
	SetActive(self._jam, arg_4_1)
	SetActive(self._icon, not arg_4_1)
	SetActive(self._progress, not arg_4_1)
end

function BattleWeaponButton:SwitchIcon(arg_5_1, arg_5_2)
	self._iconIndex = arg_5_1

	local var_5_0 = arg_5_2 or var_0_0.Battle.BattleState.GetCombatSkinKey()

	if var_5_0 ~= "Standard" then
		var_5_0 = ""
	end

	setImageSprite(self._unfill, LoadSprite("ui/CombatUI" .. var_5_0 .. "_atlas", "weapon_unfill_" .. BattleWeaponButton.ICON_BY_INDEX[arg_5_1]))
	setImageSprite(self._filled, LoadSprite("ui/CombatUI" .. var_5_0 .. "_atlas", "filled_combined_" .. BattleWeaponButton.ICON_BY_INDEX[arg_5_1]))

	return var_5_0, BattleWeaponButton.ICON_BY_INDEX[arg_5_1]
end

function BattleWeaponButton:SwitchIconEffect(arg_6_1, arg_6_2)
	local var_6_0 = arg_6_2 or var_0_0.Battle.BattleState.GetCombatSkinKey()

	if var_6_0 ~= "Standard" then
		var_6_0 = ""
	end

	setImageSprite(self._filledEffect, LoadSprite("ui/CombatUI" .. var_6_0 .. "_atlas", "filled_effect_" .. BattleWeaponButton.ICON_BY_INDEX[arg_6_1]), true)
	setImageSprite(self._jam, LoadSprite("ui/CombatUI" .. var_6_0 .. "_atlas", "skill_jam_" .. BattleWeaponButton.ICON_BY_INDEX[arg_6_1]), true)
end

function BattleWeaponButton:ConfigSkin(arg_7_1)
	self._skin = arg_7_1
	self._btn = arg_7_1:Find("ActCtl")
	self._block = arg_7_1:Find("ActCtl/block").gameObject
	self._progress = arg_7_1:Find("ActCtl/skill_progress")
	self._progressBar = self._progress:GetComponent(typeof(Image))
	self._icon = arg_7_1:Find("ActCtl/skill_icon")
	self._filled = self._icon:Find("filled")
	self._unfill = self._icon:Find("unfill")
	self._count = arg_7_1:Find("ActCtl/Count")
	self._text = self._count:Find("CountText")
	self._selected = arg_7_1:Find("ActCtl/selected")
	self._unSelect = arg_7_1:Find("ActCtl/unselect")
	self._filledEffect = arg_7_1:Find("ActCtl/filledEffect")
	self._jam = arg_7_1:Find("ActCtl/jam")
	self._countTxt = self._text:GetComponent(typeof(Text))

	arg_7_1.gameObject:SetActive(true)
	self._block:SetActive(false)
	self._progress.gameObject:SetActive(true)
	self._filledEffect.gameObject:SetActive(false)
	self._filledEffect.gameObject:GetComponent("DftAniEvent"):SetEndEvent(function(arg_8_0)
		SetActive(self._filledEffect, false)
	end)

	self._animtor = arg_7_1:GetComponent(typeof(Animator))
	self._bgEff = arg_7_1:Find("ActCtl/bg_eff")
	self._gizmos1 = arg_7_1:Find("ActCtl/gizmos_1")
	self._gizmosXue = arg_7_1:Find("ActCtl/gizmos_xue")
end

function BattleWeaponButton:GetSkin()
	return self._skin
end

function BattleWeaponButton:Enabled(arg_10_1)
	local var_10_0 = GetComponent(self._btn, "EventTriggerListener")
	local var_10_1 = GetComponent(self._block, "EventTriggerListener")

	self.eventTriggers[var_10_0] = true
	self.eventTriggers[var_10_1] = true
	var_10_0.enabled = arg_10_1
	var_10_1.enabled = arg_10_1
end

function BattleWeaponButton:Disable()
	if self._cancelFunc then
		self._cancelFunc()
	end

	self:OnUnSelect()

	GetComponent(self._btn, "EventTriggerListener").enabled = false
	GetComponent(self._block, "EventTriggerListener").enabled = false
end

function BattleWeaponButton:OnSelected()
	SetActive(self._unSelect, false)
	SetActive(self._selected, true)
end

function BattleWeaponButton:OnUnSelect()
	SetActive(self._selected, false)
	SetActive(self._unSelect, true)
end

function BattleWeaponButton:OnFilled()
	SetActive(self._filled, true)
	SetActive(self._unfill, false)
end

function BattleWeaponButton:OnUnfill()
	SetActive(self._filled, false)
	SetActive(self._unfill, true)
end

function BattleWeaponButton:OnfilledEffect()
	SetActive(self._filledEffect, true)
end

function BattleWeaponButton:OnOverLoadChange(arg_17_1)
	if self._progressInfo:IsOverLoad() then
		self._block:SetActive(true)
		self:OnUnfill()
	else
		self._block:SetActive(false)
		self:OnFilled()

		if arg_17_1 and arg_17_1.Data then
			if arg_17_1.Data.preCast then
				if arg_17_1.Data.preCast == 0 then
					quickCheckAndPlayAnimator(self._skin, "weapon_button_progress_filled")
				elseif arg_17_1.Data.preCast > 0 then
					quickCheckAndPlayAnimator(self._skin, "weapon_button_progress_charge")
				end
			end
		end
	end

	if arg_17_1 and arg_17_1.Data and arg_17_1.Data.postCast then
		quickCheckAndPlayAnimator(self._skin, "weapon_button_progress_use")
	end

	if self._progressInfo:GetTotal() > 0 then
		self:updateProgressBar()
	end
end

function BattleWeaponButton:SetProgressActive(arg_18_1)
	self._progress.gameObject:SetActive(arg_18_1)
end

function BattleWeaponButton:SetTextActive(arg_19_1)
	SetActive(self._count, arg_19_1)
end

function BattleWeaponButton:SetProgressInfo(arg_20_1)
	self._progressInfo = arg_20_1

	self._progressInfo:RegisterEventListener(self, var_0_0.Battle.BattleEvent.WEAPON_TOTAL_CHANGE, self.OnTotalChange)
	self._progressInfo:RegisterEventListener(self, var_0_0.Battle.BattleEvent.WEAPON_COUNT_PLUS, self.OnfilledEffect)
	self._progressInfo:RegisterEventListener(self, var_0_0.Battle.BattleEvent.OVER_LOAD_CHANGE, self.OnOverLoadChange)
	self._progressInfo:RegisterEventListener(self, var_0_0.Battle.BattleEvent.COUNT_CHANGE, self.OnCountChange)
	self:OnTotalChange()
	self:OnOverLoadChange()
end

function BattleWeaponButton:OnCountChange()
	local var_21_0 = self._progressInfo:GetCount()
	local var_21_1 = self._progressInfo:GetTotal()

	self._countTxt.text = string.format("%d/%d", var_21_0, var_21_1)

	local var_21_2 = self._progressInfo:GetCurrentWeaponIconIndex()

	if var_21_2 ~= self._iconIndex then
		self:SwitchIcon(var_21_2)
		self:SwitchIconEffect(var_21_2)
	end

	if self._gizmos1 then
		SetActive(self._gizmos1, var_21_0 > 0)
		SetActive(self._gizmosXue, var_21_0 == var_21_1)
	end
end

function BattleWeaponButton:OnTotalChange(arg_22_1)
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

		if arg_22_1 then
			if arg_22_1.Data.index and arg_22_1.Data.index == 1 then
				self:OnUnSelect()
			end
		end
	end
end

function BattleWeaponButton:SetControllerActive(arg_23_1)
	if self._isActive == arg_23_1 then
		return
	end

	self._isActive = arg_23_1

	local var_23_0 = GetComponent(self._btn, "EventTriggerListener")
	local var_23_1 = GetComponent(self._block, "EventTriggerListener")

	if arg_23_1 then
		local var_23_2

		if self._downFunc ~= nil then
			var_23_0:AddPointDownFunc(function()
				var_23_2 = true

				self._downFunc()
				self:OnSelected()
			end)
		end

		if self._upFunc ~= nil then
			var_23_0:AddPointUpFunc(function()
				if var_23_2 then
					var_23_2 = false

					self._upFunc()
					self:OnUnSelect()
				end
			end)
		end

		if self._cancelFunc ~= nil then
			var_23_0:AddPointExitFunc(function()
				if var_23_2 then
					var_23_2 = false

					self._cancelFunc()
					self:OnUnSelect()
				end
			end)
		end

		var_23_1:RemovePointDownFunc()
	else
		var_23_1:AddPointDownFunc(self._emptyFunc)
		var_23_0:RemovePointDownFunc()
		var_23_0:RemovePointUpFunc()
		var_23_0:RemovePointExitFunc()
	end
end

function BattleWeaponButton:InitialAnima(arg_27_1)
	SetActive(self._btn, false)

	self._leanID = LeanTween.delayedCall(arg_27_1, System.Action(function()
		self._skin:GetComponent("Animator").enabled = true
		self._leanID = nil
	end))
end

function BattleWeaponButton:Update()
	if self._progressInfo:GetTotal() > 0 and self._progressInfo:GetCurrent() < self._progressInfo:GetMax() then
		self:updateProgressBar()
	end
end

function BattleWeaponButton:SetToCombatUIPreview(arg_30_1)
	local var_30_0 = CombatUIPreviewer.WeaponButtonPreviewMode

	switch(arg_30_1, {
		[CombatUIPreviewer.WeaponButtonPreviewMode.UNFILLED] = function()
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
		end,
		[CombatUIPreviewer.WeaponButtonPreviewMode.FILLED] = function()
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
		end,
		[CombatUIPreviewer.WeaponButtonPreviewMode.LOOP] = function()
			self:SetToCombatUIPreview(var_30_0.FILLED)
		end,
		[CombatUIPreviewer.WeaponButtonPreviewMode.USABLE] = function()
			local var_34_0 = self:GetProgressFaker(1)

			var_34_0.current = var_34_0.max
			var_34_0.count = 1
			self._progressInfo = var_34_0

			self:OnCountChange()
			self:OnOverLoadChange()
		end
	})
end

BattleWeaponButton.PREVIEW_LOOP_CONFIG = {
	usableDuration = 2,
	useInterval = 1.5,
	restartDelay = 1.5,
	chargeDurations = {
		4,
		2
	}
}

local var_0_2 = 0.033
local var_0_3 = {
	CHARGE = 1,
	USE = 3,
	USABLE = 2
}

function BattleWeaponButton:getPreviewGCD()
	if self.PREVIEW_LOOP_CONFIG.gcd then
		return self.PREVIEW_LOOP_CONFIG.gcd
	end

	return ({
		var_0_0.Battle.BattleConfig.ChargeWeaponConfig.GCD,
		var_0_0.Battle.BattleConfig.TorpedoCFG.GCD,
		var_0_0.Battle.BattleConfig.AirAssistCFG.GCD
	})[self._iconIndex] or var_0_0.Battle.BattleConfig.TorpedoCFG.GCD
end

function BattleWeaponButton:GetProgressFaker(arg_36_1)
	local var_36_0 = {
		current = 0,
		count = 0,
		max = 1,
		total = arg_36_1 or 1
	}

	function var_36_0.GetCurrent()
		return var_36_0.current
	end

	function var_36_0.GetMax()
		return var_36_0.max
	end

	function var_36_0.GetCount()
		return var_36_0.count
	end

	function var_36_0.GetTotal()
		return var_36_0.total
	end

	function var_36_0.IsOverLoad()
		return var_36_0.current < var_36_0.max or var_36_0.count < 1
	end

	function var_36_0.GetCurrentWeaponIconIndex()
		return self._iconIndex
	end

	function var_36_0.RegisterEventListener()
		return
	end

	function var_36_0.UnregisterEventListener()
		return
	end

	return var_36_0
end

function BattleWeaponButton:StartCombatUIPreviewLoop()
	local var_45_0 = self:GetProgressFaker(#self.PREVIEW_LOOP_CONFIG.chargeDurations)

	self._progressInfo = var_45_0
	self._previewProgress = var_45_0

	self:enterCombatUIPreviewStep(var_0_3.CHARGE)
end

function BattleWeaponButton:StopCombatUIPreviewLoop()
	self._previewStep = nil
	self._previewElapsed = nil
	self._previewProgress = nil
end

function BattleWeaponButton:previewPlus()
	self._previewProgress.count = self._previewProgress.count + 1
	self._previewProgress.current = 1
	self._previewProgress.max = 1

	self:OnCountChange()
	self:OnfilledEffect()
	self:OnOverLoadChange({
		Data = {
			preCast = self._previewProgress.count
		}
	})
end

function BattleWeaponButton:previewDeduct()
	self._previewProgress.count = math.max(self._previewProgress.count - 1, 0)

	if self._previewProgress.count > 0 then
		self._previewProgress.max = self:getPreviewGCD()
	end

	self._previewProgress.current = 0

	self:OnCountChange()
	self:OnOverLoadChange({
		Data = {
			postCast = true
		}
	})
end

function BattleWeaponButton:updatePreviewGCD(arg_49_1)
	if self._previewProgress.count <= 0 or self._previewProgress.current >= self._previewProgress.max then
		return
	end

	self._previewProgress.current = self._previewProgress.current + arg_49_1

	if self._previewProgress.current >= self._previewProgress.max then
		self._previewProgress.current = self._previewProgress.max

		self:OnOverLoadChange()
	else
		self:updateProgressBar()
	end
end

function BattleWeaponButton:enterCombatUIPreviewStep(arg_50_1)
	local var_50_0 = self._previewProgress

	self._previewStep = arg_50_1
	self._previewElapsed = 0

	switch(arg_50_1, {
		[var_0_3.CHARGE] = function()
			var_50_0.count = 0
			var_50_0.current = 0
			var_50_0.max = self.PREVIEW_LOOP_CONFIG.chargeDurations[1]
			self._previewLayer = 1

			self:OnCountChange()
			self:OnOverLoadChange()
		end,
		[var_0_3.USABLE] = function()
			return
		end,
		[var_0_3.USE] = function()
			self._previewUseTimes = 1

			self:previewDeduct()
		end
	})
end

function BattleWeaponButton:UpdateCombatUIPreviewLoop(arg_54_1)
	if not self._previewStep then
		return
	end

	arg_54_1 = arg_54_1 or var_0_2

	local var_54_0 = self.PREVIEW_LOOP_CONFIG
	local var_54_1 = self._previewProgress

	self._previewElapsed = self._previewElapsed + arg_54_1

	switch(self._previewStep, {
		[var_0_3.CHARGE] = function()
			if var_54_1.count == 0 then
				var_54_1.current = math.min(self._previewElapsed, var_54_1.max)

				self:updateProgressBar()
			end

			if var_54_0.chargeDurations[self._previewLayer] <= self._previewElapsed then
				self._previewElapsed = self._previewElapsed - var_54_0.chargeDurations[self._previewLayer]
				self._previewLayer = self._previewLayer + 1

				self:previewPlus()

				if var_54_1.count >= var_54_1.total then
					self:enterCombatUIPreviewStep(var_0_3.USABLE)
				end
			end
		end,
		[var_0_3.USABLE] = function()
			if self._previewElapsed >= var_54_0.usableDuration then
				self:enterCombatUIPreviewStep(var_0_3.USE)
			end
		end,
		[var_0_3.USE] = function()
			self:updatePreviewGCD(arg_54_1)

			if self._previewUseTimes < var_54_1.total then
				if self._previewElapsed >= var_54_0.useInterval then
					self._previewElapsed = self._previewElapsed - var_54_0.useInterval
					self._previewUseTimes = self._previewUseTimes + 1

					self:previewDeduct()
				end
			elseif self._previewElapsed >= var_54_0.restartDelay then
				self:enterCombatUIPreviewStep(var_0_3.CHARGE)
			end
		end
	})
end

function BattleWeaponButton:updateProgressBar()
	local var_58_0 = self._progressInfo:GetCurrent() / self._progressInfo:GetMax()

	self._progressBar.fillAmount = var_58_0

	if self._bgEff then
		self._bgEff:GetComponent(typeof(CanvasGroup)).alpha = self._progressInfo.GetCount and self._progressInfo:GetCount() > 0 and 1 or var_58_0
	end
end

function BattleWeaponButton:Dispose()
	if self.eventTriggers then
		for iter_59_0, iter_59_1 in pairs(self.eventTriggers) do
			ClearEventTrigger(iter_59_0)
		end

		self.eventTriggers = nil
	end

	self._progress = nil
	self._progressBar = nil

	self._progressInfo:UnregisterEventListener(self, var_0_0.Battle.BattleEvent.OVER_LOAD_CHANGE)
	self._progressInfo:UnregisterEventListener(self, var_0_0.Battle.BattleEvent.WEAPON_TOTAL_CHANGE)
	self._progressInfo:UnregisterEventListener(self, var_0_0.Battle.BattleEvent.WEAPON_COUNT_PLUS)
	self._progressInfo:UnregisterEventListener(self, var_0_0.Battle.BattleEvent.COUNT_CHANGE)
	var_0_0.EventListener.DetachEventListener(self)
end
