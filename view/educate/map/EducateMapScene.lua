local EducateMapScene = class("EducateMapScene", import("..base.EducateBaseUI"))

function EducateMapScene:getUIName()
	return "EducateMapUI"
end

function EducateMapScene:preload(arg_2_1)
	if getProxy(EducateProxy):NeedRequestOptsData() then
		pg.m02:sendNotification(GAME.EDUCATE_REQUEST_OPTION, {
			callback = arg_2_1
		})
	else
		arg_2_1()
	end
end

function EducateMapScene:getResource()
	local var_3_0 = EducateMapScene.super.getResource(self)
	local var_3_1 = {
		"ui/EducateDatePanel",
		"ui/EducateResPanel",
		"ui/EducateTopPanel",
		"ui/EducateTargetPanel",
		"ui/EducateArchivePanel",
		"ui/EducateSiteDetailUI",
		"ui/educatecommonui_atlas"
	}

	local function var_3_2(arg_4_0)
		if noEmptyStr(arg_4_0) and not table.contains(var_3_1, arg_4_0) then
			table.insert(var_3_1, arg_4_0)
		end
	end

	local var_3_3 = getProxy(EducateProxy)

	for iter_3_0, iter_3_1 in ipairs(var_3_3 and var_3_3:GetShowSiteIds() or {}) do
		if pg.child_site[iter_3_1] then
			var_3_2("educatesite/" .. pg.child_site[iter_3_1].icon)
			var_3_2("educatesite/" .. pg.child_site[iter_3_1].name_pic)
			var_3_2("educatesite/" .. pg.child_site[iter_3_1].pic)

			for iter_3_2, iter_3_3 in ipairs(pg.child_site[iter_3_1].option or {}) do
				if pg.child_site_option[iter_3_3] and pg.child_site_option[iter_3_3].type == EducateSiteOption.TYPE_SITE then
					if pg.child_site[pg.child_site_option[iter_3_3].param[1]] then
						var_3_2("educatesite/" .. pg.child_site[pg.child_site_option[iter_3_3].param[1]].pic)
					end
				end
			end
		end
	end

	for iter_3_4, iter_3_5 in ipairs(var_3_1) do
		if not table.contains(var_3_0, iter_3_5) then
			table.insert(var_3_0, iter_3_5)
		end
	end

	return var_3_0
end

function EducateMapScene:init()
	self:initData()
	self:findUI()
	self:addListener()
end

function EducateMapScene:initData()
	self.config = pg.child_site
	self.siteIdList = getProxy(EducateProxy):GetShowSiteIds()
end

function EducateMapScene:findUI()
	self.topTF = self._tf:Find("ui/top")
	self.homeBtn = self._tf:Find("ui/home_btn/home_btn")

	setText(self.homeBtn:Find("Text"), i18n("child_btn_home"))
	setActive(self.homeBtn, false)

	self.mapTF = self._tf:Find("map")
	self.mapContent = self.mapTF:Find("content")
	self.mapSiteTpl = self.mapTF:Find("site_tpl")

	setText(self.mapSiteTpl:Find("limit/Text"), i18n("child_option_limit"))
	setActive(self.mapSiteTpl, false)

	self.siteUIList = UIItemList.New(self.mapContent, self.mapSiteTpl)
	self.datePanel = EducateDatePanel.New(self.topTF:Find("date"), self.event)

	self.datePanel:RegisterView(self)
	self.datePanel:Load()

	self.resPanel = EducateResPanel.New(self.topTF:Find("res"), self.event, {
		showBg = true
	})

	self.resPanel:RegisterView(self)
	self.resPanel:Load()

	self.topPanel = EducateTopPanel.New(self.topTF:Find("top_right"), self.event)

	self.topPanel:RegisterView(self)
	self.topPanel:Load()

	self.targetPanel = EducateTargetPanel.New(self._tf:Find("ui/target"), self.event)

	self.targetPanel:RegisterView(self)
	self.targetPanel:Load()

	self.archivePanel = EducateArchivePanel.New(self._tf:Find("ui/archive_panel"), self.event)

	self.archivePanel:RegisterView(self)
	self.archivePanel:Load()

	self.detailPanel = EducateSiteDetailPanel.New(self._tf:Find("ui/detail_panel"), self.event, {
		onEnter = function()
			self:MoveTargetPanelLeft()
		end,
		onExit = function()
			self:MoveTargetPanelRight()
		end
	})

	self.detailPanel:RegisterView(self)
	self.detailPanel:Load()
end

function EducateMapScene:addListener()
	onButton(self, self.homeBtn, function()
		self:emit(EducateBaseUI.EDUCATE_CHANGE_SCENE, SCENE.EDUCATE)
	end, SFX_PANEL)
end

function EducateMapScene:didEnter()
	self:OverlayPanel(self.topTF)
	self.siteUIList:make(function(arg_13_0, arg_13_1, arg_13_2)
		if arg_13_0 == UIItemList.EventUpdate then
			self:updateSiteItem(arg_13_1, arg_13_2)
		end
	end)
	self.siteUIList:align(#self.siteIdList)
	self:playAnim()
	self:CheckTips(function()
		self.siteUIList:align(#self.siteIdList)
	end)
end

function EducateMapScene:playAnim()
	self.siteUIList:each(function(arg_16_0, arg_16_1)
		setActive(arg_16_1, false)
	end)

	local var_15_0 = {}

	table.insert(var_15_0, function(arg_17_0)
		self:managedTween(LeanTween.delayedCall, function()
			arg_17_0()
		end, 0.165, nil)
	end)

	for iter_15_0 = 1, #self.siteIdList do
		table.insert(var_15_0, function(arg_19_0)
			setActive(self.siteUIList.container:GetChild(iter_15_0 - 1), true)
			self:managedTween(LeanTween.delayedCall, function()
				arg_19_0()
			end, 0.033, nil)
		end)
	end

	seriesAsync(var_15_0, function()
		return
	end)
end

function EducateMapScene:CheckTips(arg_22_1)
	local var_22_1 = EducateTipHelper.GetSiteUnlockTipIds()

	if #var_22_1 > 0 then
		self:emit(EducateMapScene.EDUCATE_ON_UNLOCK_TIP, {
			type = EducateUnlockTipLayer.UNLOCK_TYPE_SITE,
			list = var_22_1,
			onExit = arg_22_1
		})
	end
end

function EducateMapScene:updateSiteItem(arg_23_1, arg_23_2)
	local var_23_0 = self.config[self.siteIdList[arg_23_1 + 1]]

	arg_23_2.name = self.config[self.siteIdList[arg_23_1 + 1]].id

	LoadImageSpriteAsync("educatesite/" .. self.config[self.siteIdList[arg_23_1 + 1]].icon, arg_23_2:Find("icon"), true)
	LoadImageSpriteAsync("educatesite/" .. self.config[self.siteIdList[arg_23_1 + 1]].name_pic, arg_23_2:Find("name"), true)
	setActive(arg_23_2:Find("limit"), (underscore.any(getProxy(EducateProxy):GetOptionsBySiteId(self.config[self.siteIdList[arg_23_1 + 1]].id), function(arg_24_0)
		return arg_24_0:IsShowLimit()
	end)))
	setActive(arg_23_2:Find("new"), EducateTipHelper.IsShowNewTip(EducateTipHelper.NEW_SITE, self.config[self.siteIdList[arg_23_1 + 1]].id))
	setAnchoredPosition(arg_23_2, {
		x = self.config[self.siteIdList[arg_23_1 + 1]].coordinate[1],
		y = self.config[self.siteIdList[arg_23_1 + 1]].coordinate[2]
	})
	onButton(self, arg_23_2, function()
		self.detailPanel:Show(var_23_0.id)
	end, SFX_PANEL)
end

function EducateMapScene:clearNewTip(arg_26_1)
	eachChild(self.mapContent, function(arg_27_0)
		if tonumber(arg_27_0.name) == arg_26_1 then
			setActive(arg_27_0:Find("new"), false)
		end
	end)
end

function EducateMapScene:updateRes()
	self.resPanel:Flush()
end

function EducateMapScene:updateAttrs()
	self.archivePanel:Flush()
end

function EducateMapScene:updateTime()
	self.siteUIList:align(#self.siteIdList)
	self.datePanel:Flush()
end

function EducateMapScene:updateTarget()
	self.targetPanel:Flush()
end

function EducateMapScene:updateTimeWeekDay(arg_32_1)
	self.datePanel:UpdateWeekDay(arg_32_1)
end

function EducateMapScene:MoveTargetPanelLeft()
	self.targetPanel:SetPosLeft()
end

function EducateMapScene:MoveTargetPanelRight()
	self.targetPanel:SetPosRight()
end

function EducateMapScene:ShowSpecEvent(arg_35_1, arg_35_2, arg_35_3, arg_35_4)
	self.detailPanel:showSpecEvent(arg_35_1, arg_35_2, arg_35_3, arg_35_4)
end

function EducateMapScene:ShowSitePerform(arg_36_1, arg_36_2, arg_36_3, arg_36_4, arg_36_5)
	self.detailPanel:showSitePerform(arg_36_1, arg_36_2, arg_36_3, arg_36_4, arg_36_5)
end

function EducateMapScene:onBackPressed()
	if self.detailPanel:isShowing() then
		self.detailPanel:onClose()
	else
		self:emit(EducateMapScene.ON_BACK_PRESSED)
	end
end

function EducateMapScene:willExit()
	self:UnOverlayPanel(self.topTF, self._tf:Find("ui"))
	self.datePanel:Destroy()

	self.datePanel = nil

	self.resPanel:Destroy()

	self.resPanel = nil

	self.topPanel:Destroy()

	self.topPanel = nil

	self.targetPanel:Destroy()

	self.targetPanel = nil

	self.archivePanel:Destroy()

	self.archivePanel = nil

	self.detailPanel:Destroy()

	self.detailPanel = nil
end

return EducateMapScene
