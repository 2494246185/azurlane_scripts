local GuildMainScene = class("GuildMainScene", import("..base.BaseUI"))

function GuildMainScene:forceGC()
	return true
end

function GuildMainScene:getUIName()
	return "GuildMainUI"
end

function GuildMainScene:getGroupName()
	return "group_GuildMainUI"
end

function GuildMainScene:setGuildVO(arg_4_1)
	self.guildVO = arg_4_1

	if self.guildRes and self.guildRes:GetLoaded() then
		self.guildRes:Update(self.playerVO, arg_4_1)
	end

	if self.themePage and self.themePage:GetLoaded() then
		self.themePage:UpdateGuild(self.guildVO)
	end
end

function GuildMainScene:setPlayerVO(arg_5_1)
	self.playerVO = arg_5_1
end

function GuildMainScene:setChatMsgs(arg_6_1)
	self.chatMsgs = arg_6_1
end

function GuildMainScene:setActivity(arg_7_1)
	self.activity = arg_7_1
end

function GuildMainScene:setGuildEvent(arg_8_1)
	self.guildEvent = arg_8_1
end

function GuildMainScene:UpdateRes()
	if self.guildRes and self.guildRes:GetLoaded() then
		self.guildRes:Update(self.playerVO, self.guildVO)
	end
end

function GuildMainScene:OnReportUpdated()
	if self.themePage and self.themePage:GetLoaded() then
		self.themePage:RefreshReportBtn()
	end
end

local var_0_1 = "main"
local var_0_2 = "member"
local var_0_3 = "apply"
local var_0_4 = "office"
local var_0_5 = "technology"
local var_0_6 = "battle"
local var_0_7 = {}

var_0_7[1] = "main"
var_0_7[2] = "member"
var_0_7[3] = "apply"
var_0_7[4] = "office"
var_0_7[5] = "technology"
var_0_7[6] = "battle"
GuildMainScene.TOGGLE_TAG = var_0_7
GuildMainScene.NOTIFY_TYPE_ALL = 0
GuildMainScene.NOTIFY_TYPE_MAIN = 1
GuildMainScene.NOTIFY_TYPE_APPLY = 2
GuildMainScene.NOTIFY_TYPE_OFFICE = 3
GuildMainScene.NOTIFY_TYPE_BATTLE = 4
GuildMainScene.NOTIFY_TYPE_TECH = 5

function GuildMainScene:init()
	self._bg = self._tf:Find("bg")

	pg.GuildPaintingMgr.GetInstance():Enter(self._bg:Find("painting"))

	self._playerResOb = self._tf:Find("blur_panel/adapt/top/res")
	self.guildRes = GuildResPage.New(self._playerResOb, self.event)
	self.toggleRoot = self._tf:Find("blur_panel/adapt/left_length/frame/scroll_rect/tagRoot")
	self.mainTip = self.toggleRoot:Find("main/tip")
	self.applyTip = self.toggleRoot:Find("apply/tip")
	self.officeTip = self.toggleRoot:Find("office/tip")
	self.techTip = self.toggleRoot:Find("technology/tip")
	self.battleTip = self.toggleRoot:Find("battle/tip")
	self.back = self._tf:Find("blur_panel/adapt/top/back")
	self.blurPanel = self._tf:Find("blur_panel")
	self.mainTF = self._tf:Find("main")
	self.eyeTF = self._tf:Find("blur_panel/adapt/eye")
	self._leftLength = findTF(self.blurPanel, "adapt/left_length")
	self._topPanel = findTF(self.blurPanel, "adapt/top")
	self.topBg = self._tf:Find("blur_panel/top_bg")
	self.topBgWidth = self.topBg.rect.height
	self.topWidth = self._topPanel.rect.height
	self.letfWidth = -1 * (self._leftLength.rect.width + 300)
	self.logPage = GuildOfficeLogPage.New(self._tf, self.event)
	self.dynamicBg = GuildDynamicBG.New(self._tf:Find("dynamic_bg"))
	Input.multiTouchEnabled = false
end

function GuildMainScene:preload(arg_12_1)
	seriesAsync({
		function(arg_13_0)
			pg.m02:sendNotification(GAME.GET_GUILD_REPORT, {
				callback = arg_13_0
			})
		end,
		function(arg_14_0)
			local var_14_0 = getProxy(GuildProxy):getRawData():GetActiveEvent()

			if not var_14_0 then
				pg.m02:sendNotification(GAME.GUILD_GET_ACTIVATION_EVENT, {
					force = false,
					callback = arg_14_0
				})
			elseif var_14_0 and var_14_0:IsExpired() then
				pg.m02:sendNotification(GAME.GUILD_GET_ACTIVATION_EVENT, {
					force = true,
					callback = arg_14_0
				})
			else
				arg_14_0()
			end
		end
	}, arg_12_1)
end

function GuildMainScene:getResource()
	local var_15_0 = GuildMainScene.super.getResource(self)
	local var_15_1 = {
		"ui/GuildResPanel",
		"furnitrues/guild/chair",
		"furnitrues/guild/chair1",
		"ui/guildmainui_atlas",
		"dutyicon",
		"guildpainting/guild_office_blue",
		"guildpainting/guild_office_red",
		"guildpainting/guild_event_boss_2",
		"guildpainting/guild_event_boss_3",
		"guildpainting/guild_event_boss_4",
		"guildtechnology",
		"ui/guildtechnologyredui_atlas",
		"ui/guildtechnologyblueui_atlas",
		"ui/guildtechnologyui_atlas",
		"commonbg/guild_event_bg",
		"guildevent/1",
		"guildevent/2",
		"guildevent/3",
		"guildevent/4",
		"guildevent/5",
		"guildevent/0_0",
		"guildevent/0",
		"guildevent/i_1",
		"guildevent/i_2",
		"guildevent/i_3",
		"guildevent/i_4",
		"guildevent/i_5",
		"ui/guildeventui_atlas",
		"guildeventicon",
		"ui/guildmissionui_atlas",
		"guildmission/midway",
		"guildmission/1_4"
	}

	local function var_15_2(arg_16_0)
		if noEmptyStr(arg_16_0) and not table.contains(var_15_1, arg_16_0) then
			table.insert(var_15_1, arg_16_0)
		end
	end

	local var_15_3 = getProxy(GuildProxy):getRawData()

	if var_15_3 then
		var_15_2(var_15_3:getBgName())

		local var_15_4 = getProxy(SettingsProxy):IsMellowStyle()
		local var_15_5 = var_15_3:getFaction()

		if var_15_5 == GuildConst.FACTION_TYPE_BLHX then
			var_15_2(var_15_4 and "ui/GuildThemeBlueUI4Mellow" or "ui/GuildThemeBlueUI")
		elseif var_15_5 == GuildConst.FACTION_TYPE_CSZZ then
			var_15_2(var_15_4 and "ui/GuildThemeRedUI4Mellow" or "ui/GuildThemeRedUI")
		end
	end

	for iter_15_0, iter_15_1 in ipairs(pg.item_data_frame.all) do
		var_15_2("iconframe/" .. pg.item_data_frame[iter_15_1].id)
	end

	self.memberShips = self.memberShips or getProxy(GuildProxy):getData():GetMemberShips(GuildConst.MAX_DISPLAY_MEMBER_SHIP)

	if self.memberShips and #self.memberShips > 0 then
		for iter_15_2, iter_15_3 in ipairs(self.memberShips) do
			var_15_2("char/" .. iter_15_3:getPainting())
		end
	end

	for iter_15_4, iter_15_5 in ipairs(var_15_1) do
		if not table.contains(var_15_0, iter_15_5) then
			table.insert(var_15_0, iter_15_5)
		end
	end

	return var_15_0
end

function GuildMainScene:didEnter()
	onButton(self, self.back, function()
		self:emit(GuildMainMediator.ON_BACK)
	end, SOUND_BACK)

	self.hideFlag = false

	onButton(self, self.eyeTF, function()
		self.hideFlag = not self.hideFlag

		self:EnterOrExitPreView()
	end, SFX_PANEL)
	self.guildRes:ExecuteAction("Update", self.playerVO, self.guildVO)
	self:initToggles()
	self:UpdateRes()
	pg.GuildLayerMgr.GetInstance():BlurTopPanel(self.blurPanel)

	if self.guildVO:shouldRefreshCaptial() then
		self:emit(GuildMainMediator.ON_FETCH_CAPITAL)
	end

	self.memberShips = self.memberShips or self.guildVO:GetMemberShips(GuildConst.MAX_DISPLAY_MEMBER_SHIP)

	self.dynamicBg:Init(self.memberShips)
	self:UpdateNotices(GuildMainScene.NOTIFY_TYPE_ALL)
end

function GuildMainScene:OnDeleteMember(arg_20_1)
	self.dynamicBg:ExitShip(arg_20_1:GetShip().name)
end

function GuildMainScene:OnAddMember(arg_21_1)
	self.dynamicBg:AddShip(arg_21_1:GetShip(), function()
		return
	end)
end

function GuildMainScene:EnterOrExitPreView()
	if LeanTween.isTweening(go(self._topPanel)) or LeanTween.isTweening(go(self._leftLength)) or LeanTween.isTweening(go(self.topBg)) then
		return
	end

	if self.themePage and self.themePage:GetLoaded() then
		self.themePage:EnterOrExitPreView(self.hideFlag)
	end

	local var_23_0 = self.hideFlag and {
		0,
		self.topWidth
	} or {
		self.topWidth,
		0
	}

	LeanTween.value(go(self._topPanel), var_23_0[1], var_23_0[2], 0.3):setOnUpdate(System.Action_float(function(arg_24_0)
		setAnchoredPosition(self._topPanel, {
			y = arg_24_0
		})
	end))

	local var_23_1 = self.hideFlag and {
		0,
		self.letfWidth
	} or {
		self.letfWidth,
		0
	}

	LeanTween.value(go(self._leftLength), var_23_1[1], var_23_1[2], 0.3):setOnUpdate(System.Action_float(function(arg_25_0)
		setAnchoredPosition(self._leftLength, {
			x = arg_25_0
		})
	end))

	local var_23_2 = self.hideFlag and {
		0,
		self.topBgWidth
	} or {
		self.topBgWidth,
		0
	}

	LeanTween.value(go(self.topBg), var_23_2[1], var_23_2[2], 0.3):setOnUpdate(System.Action_float(function(arg_26_0)
		setAnchoredPosition(self.topBg, {
			y = arg_26_0
		})
	end))
end

function GuildMainScene:UpdateBg()
	local var_27_0 = self.guildVO:getBgName()

	if self.bgName ~= var_27_0 then
		GetSpriteFromAtlasAsync(var_27_0, "", function(arg_28_0)
			if not IsNil(self._tf) then
				setImageSprite(self._bg, arg_28_0, false)
			end
		end)

		self.bgName = var_27_0
	end
end

function GuildMainScene:UpdateNotices(arg_29_1)
	local var_29_0 = getProxy(GuildProxy)
	local var_29_1 = self.guildVO

	if arg_29_1 == GuildMainScene.NOTIFY_TYPE_ALL or arg_29_1 == GuildMainScene.NOTIFY_TYPE_MAIN then
		setActive(self.mainTip, var_29_0:ShouldShowMainTip())
	end

	if arg_29_1 == GuildMainScene.NOTIFY_TYPE_ALL or arg_29_1 == GuildMainScene.NOTIFY_TYPE_APPLY then
		setActive(self.applyTip, var_29_0:ShouldShowApplyTip())
	end

	if arg_29_1 == GuildMainScene.NOTIFY_TYPE_ALL or arg_29_1 == GuildMainScene.NOTIFY_TYPE_OFFICE then
		setActive(self.officeTip, var_29_1:ShouldShowOfficeTip())
	end

	if arg_29_1 == GuildMainScene.NOTIFY_TYPE_ALL or arg_29_1 == GuildMainScene.NOTIFY_TYPE_BATTLE then
		setActive(self.battleTip, var_29_0:ShouldShowBattleTip())
	end

	if arg_29_1 == GuildMainScene.NOTIFY_TYPE_ALL or arg_29_1 == GuildMainScene.NOTIFY_TYPE_TECH then
		setActive(self.techTip, var_29_1:ShouldShowTechTip())
	end
end

function GuildMainScene:initTheme()
	local var_30_0 = self.guildVO:getFaction()

	if not self.faction or self.faction ~= var_30_0 then
		if self.themePage then
			self.themePage:Destroy()
		end

		self.themePage = GuildThemePage.New(self.mainTF, self.event, self.contextData)

		self.themePage:ExecuteAction("Update", self.guildVO, self.playerVO, self.chatMsgs)

		self.faction = var_30_0
	else
		self.themePage:ActionInvoke("Update", self.guildVO, self.playerVO, self.chatMsgs)
	end
end

function GuildMainScene:OpenMainPage()
	if not self.themePage or not self.themePage:GetLoaded() then
		self:initTheme()
	else
		self.themePage:Show()
	end
end

function GuildMainScene:initToggles()
	self.contextData.toggles = {}

	for iter_32_0, iter_32_1 in ipairs(GuildMainScene.TOGGLE_TAG) do
		self.contextData.toggles[iter_32_1] = self.toggleRoot:Find(iter_32_1)

		assert(self.contextData.toggles[iter_32_1], "transform canot be nil" .. iter_32_1)
		onToggle(self, self.contextData.toggles[iter_32_1], function(arg_33_0)
			if arg_33_0 then
				self:openPage(iter_32_1)
				setActive(self._bg, iter_32_1 ~= var_0_1)
			else
				self:closePage(iter_32_1)
			end
		end, SFX_PANEL)
	end

	if LOCK_GUILD_BATTLE then
		setActive(self.contextData.toggles[var_0_6], false)
	end

	local var_32_0 = self.guildVO:getDutyByMemberId(self.playerVO.id)

	setActive(self.contextData.toggles[var_0_3], var_32_0 == GuildConst.DUTY_COMMANDER or var_32_0 == GuildConst.DUTY_DEPUTY_COMMANDER)

	local var_32_1 = self.contextData.page or var_0_1

	self.contextData.page = nil

	assert(self.contextData.toggles[var_32_1])
	triggerToggle(self.contextData.toggles[var_32_1], true)
end

function GuildMainScene:TriggerOfficePage()
	triggerToggle(self.contextData.toggles[var_0_4], true)
end

function GuildMainScene:openPage(arg_35_1)
	setActive(self.eyeTF, arg_35_1 == var_0_1)

	if arg_35_1 == var_0_4 or arg_35_1 == var_0_5 then
		self.guildRes:Show()
	elseif arg_35_1 == var_0_6 or arg_35_1 == var_0_3 or arg_35_1 == var_0_2 then
		self.guildRes:Hide()
	else
		self.guildRes:Hide()
	end

	if self.themePage and self.themePage:GetLoaded() and self.themePage.isShowChatWindow then
		self.themePage:ShowOrHideChatWindow(false)
	end

	if self.contextData.page == arg_35_1 then
		return
	end

	if arg_35_1 == var_0_1 then
		self:OpenMainPage()
		self:emit(GuildMainMediator.OPEN_MAIN)
	elseif arg_35_1 == var_0_2 then
		self:emit(GuildMainMediator.OPEN_MEMBER)
	elseif arg_35_1 == var_0_3 then
		self:emit(GuildMainMediator.OPEN_APPLY)
	elseif arg_35_1 == var_0_4 then
		self:emit(GuildMainMediator.OPEN_OFFICE)
	elseif arg_35_1 == var_0_5 then
		self:emit(GuildMainMediator.OPEN_TECH)
	elseif arg_35_1 == var_0_6 then
		self:emit(GuildMainMediator.OPEN_BATTLE)
	end

	self:UpdateBg()

	self.contextData.page = arg_35_1
end

function GuildMainScene:closePage(arg_36_1)
	if arg_36_1 == var_0_1 then
		if self.themePage then
			self.themePage:ExecuteAction("Hide")
		end
	elseif arg_36_1 == var_0_2 then
		self:emit(GuildMainMediator.CLOSE_MEMBER)
	elseif arg_36_1 == var_0_3 then
		self:emit(GuildMainMediator.CLOSE_APPLY)
	elseif arg_36_1 == var_0_4 then
		self:emit(GuildMainMediator.CLOSE_OFFICE)
	elseif arg_36_1 == var_0_5 then
		self:emit(GuildMainMediator.CLOSE_TECH)
	elseif arg_36_1 == var_0_6 then
		self:emit(GuildMainMediator.CLOSE_BATTLE)
	end
end

function GuildMainScene:BlurView(arg_37_1)
	pg.UIMgr.GetInstance():OverlayPanel(arg_37_1, {
		pbList = {
			arg_37_1:Find("Image1/Image1")
		}
	})
end

function GuildMainScene:UnBlurView(arg_38_1, arg_38_2)
	pg.UIMgr.GetInstance():UnOverlayPanel(arg_38_1, arg_38_2)
end

function GuildMainScene:Append(arg_39_1, arg_39_2)
	if self.themePage and self.themePage:GetLoaded() then
		self.themePage:Append(arg_39_1, arg_39_2)
	end
end

function GuildMainScene:UpdateAllChat(arg_40_1)
	if self.themePage and self.themePage:GetLoaded() then
		self.themePage:UpdateAllChat(arg_40_1)
	end
end

function GuildMainScene:UpdateAllLog(arg_41_1)
	if self.themePage and self.themePage:GetLoaded() then
		self.themePage:UpdateAllChat(arg_41_1)
	end
end

function GuildMainScene:AppendLog(arg_42_1, arg_42_2)
	if self.themePage and self.themePage:GetLoaded() then
		self.themePage:AppendLog(arg_42_1, arg_42_2)
	end
end

function GuildMainScene:openResourceLog()
	self.logPage:ExecuteAction("Show", self.guildVO)
end

function GuildMainScene:willExit()
	self.dynamicBg:Dispose()
	self.logPage:Destroy()
	self.guildRes:Destroy()

	if self.themePage then
		self.themePage:Destroy()
	end

	pg.GuildLayerMgr.GetInstance():Clear()
	pg.GuildPaintingMgr.GetInstance():Exit()

	if self.contextData.page then
		self:closePage(self.contextData.page)
	end

	Input.multiTouchEnabled = true
end

function GuildMainScene:insertEmojiToInputText(arg_45_1)
	if self.themePage then
		self.themePage:InsertEmojiToInputText(arg_45_1)
	end
end

return GuildMainScene
