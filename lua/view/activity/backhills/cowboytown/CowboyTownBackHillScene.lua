local CowboyTownBackHillScene = class("CowboyTownBackHillScene", import("..TemplateMV.BackHillTemplate"))

function CowboyTownBackHillScene:getUIName()
	return "CowboyTownBackHillUI"
end

function CowboyTownBackHillScene:didEnter()
	onButton(self, self._tf:Find("top/btn_back"), function()
		self:emit(CowboyTownBackHillScene.ON_BACK)
	end)
	onButton(self, self._tf:Find("top/btn_home"), function()
		self:emit(CowboyTownBackHillScene.ON_HOME)
	end)
	onButton(self, self._tf:Find("top/info/btn_help"), function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip["0815_main_help"].tip
		})
	end, SFX_PANEL)
	onButton(self, self._tf:Find("btn/btn_game"), function()
		self:emit(CowboyTownMediator.MINI_GAME)
	end)
	onButton(self, self._tf:Find("btn/btn_skin"), function()
		self:emit(CowboyTownMediator.SKIN)
	end)
	onButton(self, self._tf:Find("btn/btn_expansion"), function()
		self:emit(CowboyTownMediator.EXPANSION)
	end)
	onButton(self, self._tf:Find("btn/btn_task"), function()
		self:emit(CowboyTownMediator.TASK)
	end)
	onButton(self, self._tf:Find("btn/btn_story"), function()
		self:emit(CowboyTownMediator.STORY)
	end)
	self:UpdateView()
end

function CowboyTownBackHillScene:UpdateView()
	setActive(self._tf:Find("btn/btn_game/tip"), CowboyTownBackHillScene.MiniGameTip())
	setActive(self._tf:Find("btn/btn_expansion/tip"), CowboyTownBackHillScene.ExpansionTips())
	self:UpdateTaskTips()
	self:UpdateStoryView()
end

function CowboyTownBackHillScene:IsShowMainTip()
	return CowboyTownBackHillScene.MiniGameTip() or CowboyTownBackHillScene.ExpansionTips() or SixYearUsTaskMediator.GetTaskRedTip() or CowboyTownBackHillScene.StoryTips()
end

function CowboyTownBackHillScene:UpdateStoryView()
	setActive(self._tf:Find("btn/btn_story/tip"), CowboyTownBackHillScene.StoryTips())
end

function CowboyTownBackHillScene:UpdateActivity(arg_14_1)
	return
end

function CowboyTownBackHillScene.MiniGameTip()
	return getProxy(MiniGameProxy):GetHubByGameId(CowboyTownMediator.MINI_GAME_ID).count > 0
end

function CowboyTownBackHillScene.ExpansionTips()
	return TownScene.ShowEntranceTip()
end

function CowboyTownBackHillScene:UpdateTaskTips()
	setActive(self._tf:Find("btn/btn_task/tip"), SixYearUsTaskMediator.GetTaskRedTip())
end

function CowboyTownBackHillScene.StoryTips()
	if getProxy(ActivityProxy):getActivityById(5535).data1 > 0 then
		return true
	end

	return false
end

return CowboyTownBackHillScene
