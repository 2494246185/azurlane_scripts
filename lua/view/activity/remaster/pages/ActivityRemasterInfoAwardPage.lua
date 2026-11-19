local ActivityRemasterInfoAwardPage = class("ActivityRemasterInfoAwardPage", import("view.base.BaseSubView"))

ActivityRemasterInfoAwardPage.ON_SKIP_ACT = "ActivityRemasterCoreActivityAdaptUI"

function ActivityRemasterInfoAwardPage:getUIName()
	return "ActivityRemasterInfoAwardPage"
end

function ActivityRemasterInfoAwardPage:OnLoaded()
	self.itemTr = self._tf:Find("window/middle/award")
	self.nameTxt = self._tf:Find("window/middle/name")
	self.descTxt = self._tf:Find("window/middle/desc")
	self.ownTxt = self._tf:Find("window/middle/own")
	self.boxSrcContent = self._tf:Find("window/middle/ways")
	self.boxSrcTpl = self._tf:Find("window/middle/ways/tpl")
end

function ActivityRemasterInfoAwardPage:OnInit()
	self:CommonSetting({
		title = i18n("word_obtain_way")
	})
end

function ActivityRemasterInfoAwardPage:CommonSetting(arg_4_1)
	setText(self._tf:Find("window/top/title"), arg_4_1.title or i18n("words_information"))

	function self.hideCall()
		self.hideCall = nil

		existCall(arg_4_1.onClose)
	end

	onButton(self, self._tf:Find("bg"), function()
		existCall(self.hideCall)
		self:Hide()
	end, SFX_CANCEL)
	onButton(self, self._tf:Find("window/top/btn_close"), function()
		existCall(self.hideCall)
		self:Hide()
	end, SFX_CANCEL)

	function self.confirmCall()
		self.confirmCall = nil

		existCall(self.onConfirm)
	end

	local var_4_1 = arg_4_1.btnList or {
		{
			type = pg.NewStyleMsgboxMgr.BUTTON_TYPE.cancel,
			name = i18n("msgbox_text_cancel"),
			func = function()
				existCall(self.hideCall)
			end,
			sound = SFX_CANCEL
		},
		{
			type = pg.NewStyleMsgboxMgr.BUTTON_TYPE.confirm,
			name = i18n("msgbox_text_confirm"),
			func = function()
				existCall(self.confirmCall)
			end,
			sound = SFX_CONFIRM
		}
	}
	local var_4_2 = self._tf:Find("window/bottom/button_container")

	eachChild(var_4_2, function(arg_11_0)
		setActive(arg_11_0, false)
	end)

	for iter_4_0, iter_4_1 in ipairs(var_4_1) do
		local var_4_3 = var_4_2:Find(iter_4_1.type)

		if var_4_3:GetSiblingIndex() < var_4_2.childCount - iter_4_0 + 1 then
			var_4_3:SetAsLastSibling()
			setActive(var_4_3, true)
		else
			var_4_3 = cloneTplTo(var_4_3, var_4_2, var_4_3.name)
		end

		setText(var_4_3:Find("Text"), iter_4_1.name)
		onButton(self, var_4_3, function()
			existCall(iter_4_1.func)
			self:Hide()
		end, iter_4_1.sound or SFX_CONFIRM)
	end
end

function ActivityRemasterInfoAwardPage:Show(arg_13_1)
	ActivityRemasterInfoAwardPage.super.Show(self)

	local var_13_0 = arg_13_1:GetDrop()

	updateDrop(self.itemTr, var_13_0)
	changeToScrollText(self.nameTxt, var_13_0:getName())
	setText(self.descTxt, string.gsub(var_13_0.desc or "", "#92fc63", "#39bfff") or "")

	local var_13_1 = var_13_0:getCount()

	setText(self.ownTxt, i18n("ActivityRemasterCore_award_own_desc", arg_13_1:GetOwnedCount() .. ((var_13_1 > 0 or nil) and ("/" .. var_13_1 or ""))))
	self:UpdateWays(arg_13_1:GetWays())
end

function ActivityRemasterInfoAwardPage:UpdateWays(arg_14_1)
	UIItemList.StaticAlign(self.boxSrcContent, self.boxSrcTpl, #arg_14_1, function(arg_15_0, arg_15_1, arg_15_2)
		if arg_15_0 == UIItemList.EventUpdate then
			local var_15_0 = arg_14_1[arg_15_1 + 1][1]
			local var_15_1 = arg_14_1[arg_15_1 + 1][2]

			changeToScrollText(arg_15_2:Find("Text"), arg_14_1[arg_15_1 + 1][3])

			local var_15_2 = arg_15_2:Find("go")

			setText(var_15_2:Find("Text"), i18n("brs_reward_tip_2"))
			onButton(self, var_15_2, function()
				self:DoSkip(var_15_0, var_15_1)
				self:Hide()
			end, SFX_PANEL)
		end
	end)
end

function ActivityRemasterInfoAwardPage:DoSkip(arg_17_1, arg_17_2)
	if arg_17_1 == Msgbox4LinkCollectGuide.SKIP_TYPE_SCENE then
		pg.m02:sendNotification(GAME.GO_SCENE, arg_17_2[1], arg_17_2[2] or {})
	elseif arg_17_1 == Msgbox4LinkCollectGuide.SKIP_TYPE_ACTIVITY then
		self:emit(ActivityRemasterInfoAwardPage.ON_SKIP_ACT, arg_17_2)
		pg.m02:sendNotification(GAME.GO_SCENE, SCENE.ACTIVITY, {
			id = arg_17_2
		})
	end
end

function ActivityRemasterInfoAwardPage:OnDestroy()
	return
end

return ActivityRemasterInfoAwardPage
