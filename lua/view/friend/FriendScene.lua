local FriendScene = class("FriendScene", import("..base.BaseUI"))

FriendScene.FRIEND_PAGE = 1
FriendScene.SEARCH_PAGE = 2
FriendScene.REQUEST_PAGE = 3
FriendScene.BLACKLIST_PAGE = 4

function FriendScene:getUIName()
	return "FriendUI"
end

function FriendScene:getResource()
	local var_2_0 = {}

	local function var_2_1(arg_3_0)
		local var_3_0

		if not arg_3_0 then
			do return end

			var_3_0 = arg_3_0.id == getProxy(PlayerProxy):getRawData().id
		end

		local var_3_1 = AttireFrame.attireFrameRes(arg_3_0, var_3_0, AttireConst.TYPE_ICON_FRAME, arg_3_0.propose)

		if var_3_1 and var_3_1 ~= "" then
			table.insert(var_2_0, "IconFrame/" .. var_3_1)
		end

		if arg_3_0.score and arg_3_0.rank then
			local var_3_2 = SeasonInfo.getEmblem(arg_3_0.score, arg_3_0.rank)

			table.insert(var_2_0, "emblem/" .. var_3_2)
			table.insert(var_2_0, "emblem/n_" .. var_3_2)
		end
	end

	local var_2_2 = getProxy(FriendProxy):getAllFriends()

	var_2_2 = var_2_2 or {}

	for iter_2_0, iter_2_1 in ipairs(var_2_2) do
		var_2_1(iter_2_1)
	end

	local var_2_3 = getProxy(NotificationProxy):getRequests()

	var_2_3 = var_2_3 or {}

	for iter_2_2, iter_2_3 in ipairs(var_2_3) do
		var_2_1(iter_2_3.player)
	end

	local var_2_4 = getProxy(FriendProxy):getBlackList()

	var_2_4 = var_2_4 or {}

	for iter_2_4, iter_2_5 in pairs(var_2_4) do
		var_2_1(iter_2_5)
	end

	return ResPathSupport.UniqueLuaArr(ResPathSupport.MergeLuaArr(FriendScene.super.getResource(self), {
		"ui/friendsui_atlas"
	}, var_2_0))
end

function FriendScene:setFriendVOs(arg_4_1)
	self.friendVOs = arg_4_1
end

function FriendScene:setPlayer(arg_5_1)
	self.playerVO = arg_5_1
end

function FriendScene:setRequests(arg_6_1)
	self.requestVOs = arg_6_1
end

function FriendScene:setSearchResult(arg_7_1)
	self.searchResultVOs = arg_7_1
end

function FriendScene:removeSearchResult(arg_8_1)
	self:setSearchResult((_.select(self.searchResultVOs, function(arg_9_0)
		return arg_9_0.id ~= arg_8_1
	end)))
end

function FriendScene:setBlackList(arg_10_1)
	if arg_10_1 then
		self.blackVOs = {}

		for iter_10_0, iter_10_1 in pairs(arg_10_1 or {}) do
			table.insert(self.blackVOs, iter_10_1)
		end
	end
end

function FriendScene:init()
	self.pages = self._tf:Find("pages")
	self.togglesTF = self._tf:Find("blur_panel/adapt/left_length/frame/tagRoot")
	self.pages = {
		FriendListPage.New(self.pages, self.event, self.contextData),
		FriendSearchPage.New(self.pages, self.event),
		FriendRequestPage.New(self.pages, self.event),
		FriendBlackListPage.New(self.pages, self.event)
	}
	self.toggles = {}

	for iter_11_0 = 1, self.togglesTF.childCount do
		self.toggles[iter_11_0] = self.togglesTF:GetChild(iter_11_0 - 1)

		onToggle(self, self.toggles[iter_11_0], function(arg_12_0)
			if arg_12_0 then
				self:switchPage(iter_11_0)
			end
		end, SFX_PANEL)
	end

	self.chatTipContainer = self.toggles[1]:Find("count")
	self.chatTip = self.toggles[1]:Find("count/Text"):GetComponent(typeof(Text))
	self.listEmptyTF = self._tf:Find("empty")

	setActive(self.listEmptyTF, false)

	self.listEmptyTxt = self.listEmptyTF:Find("Text")
end

function FriendScene:didEnter()
	onButton(self, self._tf:Find("blur_panel/adapt/top/back_btn"), function()
		self:emit(FriendScene.ON_BACK)
	end, SOUND_BACK)
	triggerToggle(self.toggles[self.contextData.initPage or 1], true)
	self:updateRequestTip()
end

function FriendScene:wrapData()
	return {
		friendVOs = self.friendVOs,
		requestVOs = self.requestVOs,
		searchResults = self.searchResultVOs,
		blackVOs = self.blackVOs,
		playerVO = self.playerVO
	}
end

function FriendScene:updateEmpty(arg_16_1, arg_16_2)
	local var_16_0 = {}
	local var_16_1 = ""

	if arg_16_1 == FriendScene.FRIEND_PAGE then
		var_16_0 = arg_16_2.friendVOs
		var_16_1 = i18n("list_empty_tip_friendui")
	elseif arg_16_1 == FriendScene.SEARCH_PAGE then
		var_16_0 = arg_16_2.searchResults
		var_16_1 = i18n("list_empty_tip_friendui_search")
	elseif arg_16_1 == FriendScene.REQUEST_PAGE then
		var_16_0 = arg_16_2.requestVOs
		var_16_1 = i18n("list_empty_tip_friendui_request")
	elseif arg_16_1 == FriendScene.BLACKLIST_PAGE then
		var_16_0 = arg_16_2.blackVOs
		var_16_1 = i18n("list_empty_tip_friendui_black")
	end

	setActive(self.listEmptyTF, not var_16_0 or #var_16_0 <= 0)
	setText(self.listEmptyTxt, var_16_1)
end

function FriendScene:switchPage(arg_17_1)
	if self.page then
		self.page:ExecuteAction("Hide")
	end

	local var_17_0 = self.pages[arg_17_1]
	local var_17_1 = self:wrapData()

	self.pages[arg_17_1]:ExecuteAction("Show")
	var_17_0:ExecuteAction("UpdateData", var_17_1)

	self.page = var_17_0

	self:updateEmpty(arg_17_1, var_17_1)
end

function FriendScene:updatePage(arg_18_1)
	if self.page and self.pages[arg_18_1] == self.page then
		local var_18_0 = self:wrapData()

		self.page:ExecuteAction("UpdateData", var_18_0)
		self:updateEmpty(arg_18_1, var_18_0)
	end
end

function FriendScene:updateChatNotification(arg_19_1)
	setActive(self.chatTipContainer, arg_19_1 > 0)

	self.chatTip.text = arg_19_1
end

function FriendScene:updateRequestTip()
	setActive(self.toggles[3]:Find("tip"), #self.requestVOs > 0)
end

function FriendScene:closeInfromPanel()
	if not self.pages[3] then
		return
	end

	self.pages[3]:closeInfromPanel()
end

function FriendScene:willExit()
	for iter_22_0, iter_22_1 in ipairs(self.pages) do
		iter_22_1:Destroy()
	end
end

return FriendScene
