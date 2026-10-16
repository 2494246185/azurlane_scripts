local ActivityPermanentLayer = class("ActivityPermanentLayer", import("..base.BaseUI"))

function ActivityPermanentLayer:getResource()
	local var_1_0 = {}

	for iter_1_0, iter_1_1 in ipairs((getProxy(ActivityPermanentProxy):getActivityIdsByType(ActivityPermanentProxy.TYPE_NORMAL_ACTIVITY))) do
		table.insert(var_1_0, "activitybanner/" .. pg.activity_task_permanent[iter_1_1].banner_route)
	end

	table.insertto(var_1_0, ActivityPermanentLayer.super.getResource(self))

	return var_1_0
end

function ActivityPermanentLayer:getUIName()
	return "ActivitySelectUI"
end

function ActivityPermanentLayer:onBackPressed()
	self:closeView()
end

function ActivityPermanentLayer:onBackPressed()
	if isActive(self.rtMsgbox) then
		self:hideMsgbox()
	else
		ActivityPermanentLayer.super.onBackPressed(self)
	end
end

function ActivityPermanentLayer:init()
	self.bg = self._tf:Find("bg_back")

	onButton(self, self.bg, function()
		self:closeView()
	end, SFX_CANCEL)

	self.btnBack = self._tf:Find("window/inner/top/back")

	onButton(self, self.btnBack, function()
		self:closeView()
	end, SFX_CANCEL)
	setText(self._tf:Find("window/inner/top/back/Text"), i18n("activity_permanent_total"))

	self.btnHelp = self._tf:Find("window/inner/top/help")

	onButton(self, self.btnHelp, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = i18n("activity_permanent_help")
		})
	end, SFX_PANEL)

	self.content = self._tf:Find("window/inner/content/scroll_rect")
	self.itemList = UIItemList.New(self.content, self.content:Find("item"))

	local var_5_0 = getProxy(ActivityPermanentProxy)

	self.itemList:make(function(arg_9_0, arg_9_1, arg_9_2)
		arg_9_1 = arg_9_1 + 1

		if arg_9_0 == UIItemList.EventUpdate then
			local var_9_0 = self.ids[arg_9_1]

			setText(arg_9_2:Find("main/word/Text"), pg.activity_task_permanent[self.ids[arg_9_1]].gametip)
			setText(arg_9_2:Find("main/Image/tip/Text"), pg.activity_task_permanent[self.ids[arg_9_1]].gametip_extra)
			GetImageSpriteFromAtlasAsync("activitybanner/" .. pg.activity_task_permanent[self.ids[arg_9_1]].banner_route, "", arg_9_2:Find("main/Image"))
			onButton(self, arg_9_2:Find("main"), function()
				self:showMsgbox(var_9_0)
			end, SFX_PANEL)

			local var_9_1 = arg_9_2:Find("finish")
			local var_9_2 = GetOrAddComponent(var_9_1, typeof(CanvasGroup))

			if var_9_0 == self.contextData.finishId then
				self.childFinish = arg_9_2
				var_9_2.alpha = 0
			else
				var_9_2.alpha = 1
			end

			setText(var_9_1:Find("Image/Text"), i18n("activity_permanent_finished"))
			setActive(var_9_1, var_5_0:isActivityFinish(var_9_0))
		end
	end)

	self.rtMsgbox = self._tf:Find("Msgbox")

	onButton(self, self.rtMsgbox:Find("bg"), function()
		self:hideMsgbox()
	end, SFX_CANCEL)
	onButton(self, self.rtMsgbox:Find("window/top/btnBack"), function()
		self:hideMsgbox()
	end, SFX_CANCEL)
	onButton(self, self.rtMsgbox:Find("window/button_container/custom_button_2"), function()
		self:hideMsgbox()
	end, SFX_CANCEL)
end

function ActivityPermanentLayer:didEnter()
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
	self.itemList:align(#self.ids)

	if self.childFinish then
		scrollTo(self.content, nil, math.clamp(self.childFinish.anchoredPosition.y / (self.content.rect.height - self.content:GetComponent(typeof(ScrollRect)).viewport.rect.height), 0, 1))
		self:doFinishAnim(self.childFinish)

		self.childFinish = nil
	end

	if PlayerPrefs.GetInt("permanent_select", 0) ~= 1 then
		PlayerPrefs.SetInt("permanent_select", 1)
		triggerButton(self.btnHelp)
	end
end

function ActivityPermanentLayer:willExit()
	if isActive(self.rtMsgbox) then
		self:hideMsgbox()
	end

	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)

	if self.ltId then
		LeanTween.cancel(self.ltId)

		self.ltId = nil
	end
end

function ActivityPermanentLayer:setActivitys(arg_16_1)
	self.ids = arg_16_1

	local var_16_0 = getProxy(ActivityPermanentProxy)

	table.sort(self.ids, function(arg_17_0, arg_17_1)
		local var_17_0 = var_16_0:isActivityFinish(arg_17_1)

		if var_16_0:isActivityFinish(arg_17_0) == var_17_0 then
			return arg_17_0 < arg_17_1
		else
			return var_17_0
		end
	end)
end

function ActivityPermanentLayer:doFinishAnim(arg_18_1)
	self.ltId = LeanTween.alphaCanvas(GetOrAddComponent(arg_18_1:Find("finish"), typeof(CanvasGroup)), 1, 1).uniqueId
end

function ActivityPermanentLayer:showMsgbox(arg_19_1)
	setText(self.rtMsgbox:Find("window/button_container/custom_button_1/pic"), i18n("msgbox_text_confirm"))
	setText(self.rtMsgbox:Find("window/button_container/custom_button_2/pic"), i18n("msgbox_text_cancel"))
	setText(self.rtMsgbox:Find("window/top/bg/infomation/title"), i18n("words_information"))
	setText(self.rtMsgbox:Find("window/msg_panel/content"), i18n("activity_permanent_tips1", pg.activity_task_permanent[arg_19_1].activity_name))
	setText(self.rtMsgbox:Find("window/msg_panel/Text"), i18n("activity_permanent_tips4"))
	onButton(self, self.rtMsgbox:Find("window/button_container/custom_button_1"), function()
		self:hideMsgbox()
		self:emit(ActivityPermanentMediator.START_SELECT, arg_19_1)
	end, SFX_CONFIRM)
	setActive(self.rtMsgbox, true)
	pg.UIMgr.GetInstance():BlurPanel(self.rtMsgbox)
end

function ActivityPermanentLayer:hideMsgbox()
	setActive(self.rtMsgbox, false)
	pg.UIMgr.GetInstance():UnOverlayPanel(self.rtMsgbox)
end

return ActivityPermanentLayer
