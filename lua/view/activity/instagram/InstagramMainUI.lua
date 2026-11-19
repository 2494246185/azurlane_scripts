local InstagramMainUI = class("InstagramMainUI", import("...base.BaseUI"))

function InstagramMainUI:getUIName()
	return "InstagramMainUI"
end

function InstagramMainUI:getResource()
	local var_2_0 = {
		"ui/InstagramChatBackgrounds_atlas"
	}

	for iter_2_0, iter_2_1 in ipairs(getProxy(InstagramChatProxy):GetChatList()) do
		if iter_2_1.type == 1 then
			local var_2_1 = "unknown"

			if iter_2_1.skinId == 0 then
				var_2_1 = iter_2_1:GetPainting()
			else
				for iter_2_2, iter_2_3 in ipairs(iter_2_1.skins) do
					if iter_2_3.id == iter_2_1.skinId then
						var_2_1 = iter_2_3.painting
					end
				end
			end

			table.insert(var_2_0, "painting/" .. var_2_1)
			table.insert(var_2_0, "paintingface/" .. var_2_1)
		end
	end

	table.insertto(var_2_0, InstagramMainUI.super.getResource(self))

	return var_2_0
end

function InstagramMainUI:preload(arg_3_1)
	pg.m02:sendNotification(GAME.REQ_OLD_INSTAGRAM_DATA, {
		callback = function()
			arg_3_1()
		end
	})
end

function InstagramMainUI:init()
	self.bg = self._tf:Find("bg")
	self.helpBtn = self._tf:Find("mainPanel/helpBtn")
	self.chatBtn = self._tf:Find("mainPanel/left/chatBtn")
	self.juusBtn = self._tf:Find("mainPanel/left/juusBtn")
	self.musicPlayerView = MainMusicPlayerView.New(self._tf, self.event)

	self.musicPlayerView:Load(self._tf:Find("MusicPlayer").gameObject)
	self.musicPlayerView:ActionInvoke("Hide")
	self:ChangeChatTip()
	self:ChangeJuusTip()
	self:BlurPanel(self._tf)
end

function InstagramMainUI:didEnter()
	self:SetUp()
	self:FlushMusicPlayer()

	if self.contextData.current then
		SetActive(self.chatBtn:Find("choose"), self.contextData.current == "chat")
		SetActive(self.juusBtn:Find("choose"), self.contextData.current == "juus")
	else
		triggerButton(self.chatBtn)
	end
end

function InstagramMainUI:FlushMusicPlayer()
	local var_7_0 = pg.BgmMgr.GetInstance():GetNow() == "MainMusicPlayer"

	if tobool(self.musicPlayerView:isShowing()) ~= var_7_0 then
		if var_7_0 then
			self.musicPlayerView:ExecuteAction("Show", false)
		else
			self.musicPlayerView:ExecuteAction("Hide")
		end
	end
end

function InstagramMainUI:SetUp()
	onButton(self, self.bg, function()
		self:OnClose()
	end, SFX_PANEL)
	onButton(self, self.helpBtn, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.music_juus.tip
		})
	end, SFX_PANEL)
	onButton(self, self.chatBtn, function()
		self.contextData.current = "chat"

		if isActive(self.juusBtn:Find("choose")) then
			self:emit(InstagramMainMediator.CLOSE_JUUS_DETAIL)
		end

		SetActive(self.chatBtn:Find("choose"), self.contextData.current == "chat")
		SetActive(self.juusBtn:Find("choose"), self.contextData.current == "juus")
		self:emit(InstagramMainMediator.OPEN_CHAT)
		self:emit(InstagramMainMediator.CLOSE_JUUS)
	end, SFX_PANEL)
	onButton(self, self.juusBtn, function()
		self.contextData.current = "juus"

		SetActive(self.chatBtn:Find("choose"), self.contextData.current == "chat")
		SetActive(self.juusBtn:Find("choose"), self.contextData.current == "juus")
		self:emit(InstagramMainMediator.OPEN_JUUS)
		self:emit(InstagramMainMediator.CLOSE_CHAT)
	end, SFX_PANEL)
end

function InstagramMainUI:OnClose()
	if isActive(self.juusBtn:Find("choose")) then
		self:emit(InstagramMainMediator.INS_BACK_PRESSED)
	else
		self:emit(InstagramMainMediator.JUUS_BACK_PRESSED)
	end
end

function InstagramMainUI:ChangeJuusTip()
	SetActive(self.juusBtn:Find("tip"), getProxy(InstagramProxy):ShouldShowTip())
end

function InstagramMainUI:ChangeChatTip()
	local var_15_0 = getProxy(InstagramChatProxy):ShouldShowTip()

	var_15_0 = var_15_0 and getProxy(InstagramProxy):ShouldShowOfficialAccountsTip()

	SetActive(self.chatBtn:Find("tip"), var_15_0)
end

function InstagramMainUI:willExit()
	self.musicPlayerView:Destroy()
end

return InstagramMainUI
