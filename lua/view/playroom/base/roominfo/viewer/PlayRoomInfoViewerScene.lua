local PlayRoomInfoViewerScene = class("PlayRoomInfoViewerScene", import("view.base.BaseUI"))

function PlayRoomInfoViewerScene:getUIName()
	return "IslandPlayRoomInfoViewerUI"
end

function PlayRoomInfoViewerScene:init()
	self:OverlayPanel(self._tf, {
		pbList = {
			self._tf:Find("bg")
		}
	})
	onButton(self, self.uiCloseBtn, function()
		self:closeView()
	end, SFX_PANEL)
	onButton(self, self.uiSwitchBtn, function()
		local var_4_0 = PlayRoomTools.GetUnfullTeamIndex()

		if var_4_0 == nil then
			return
		end

		self:emit(PlayRoomInfoViewerMediator.ON_CLICK_SWITCH, {
			teamIndex = var_4_0
		})
	end, SFX_PANEL)

	self.uiScrollView = LuaList.New(self, handler(self, self.IndexItem), self.uiList, PlayRoomInfoViewerItem)
end

function PlayRoomInfoViewerScene:didEnter()
	self.playRoomProxy = getProxy(PlayRoomProxy)
	self.roomData = self.playRoomProxy:GetRoomData()

	self:RefreshUI()
end

function PlayRoomInfoViewerScene:willExit()
	self:UnOverlayPanel(self._tf)
	self.uiScrollView:Dispose()

	self.uiScrollView = nil
end

function PlayRoomInfoViewerScene:RefreshUI()
	self:RefreshBtn()
	self:RefreshPlayerList()
end

function PlayRoomInfoViewerScene:RefreshPlayerList()
	self.viewerList = Clone(self.roomData.viewerList)

	local var_8_0 = getProxy(PlayerProxy):getPlayerId()

	table.sort(self.viewerList, function(arg_9_0, arg_9_1)
		return arg_9_0 == var_8_0
	end)
	self.uiScrollView:StartScroll(#self.viewerList)
end

function PlayRoomInfoViewerScene:RefreshBtn()
	if PlayRoomTools.IsViewer() then
		setText(self.uiBtnText, i18n("play_room_switch_viewer"))
		setButtonEnabled(self.uiSwitchBtn, not PlayRoomTools.IsPlayerFull())
	else
		setText(self.uiBtnText, i18n("play_room_switch_player"))
		setButtonEnabled(self.uiSwitchBtn, not PlayRoomTools.IsViewerFull())
	end
end

function PlayRoomInfoViewerScene:IndexItem(arg_11_1, arg_11_2)
	arg_11_2:didEnter(self.roomData.playerDataList[self.viewerList[arg_11_1]], PlayRoomTools.GetHostID() == getProxy(PlayerProxy):getPlayerId())
end

return PlayRoomInfoViewerScene
