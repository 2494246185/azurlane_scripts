local OreMiniGameView = class("OreMiniGameView", import("view.miniGame.MiniGameTemplateView"))

function OreMiniGameView:getUIName()
	return "OreMiniGameUI"
end

function OreMiniGameView:getGameController()
	return OreMiniGameController
end

function OreMiniGameView:getShowSide()
	return false
end

function OreMiniGameView:initPageUI()
	OreMiniGameView.super.initPageUI(self)
	onButton(self, self.rtTitlePage:Find("main/btn_help"), function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.ore_minigame_help.tip
		})
	end, SFX_PANEL)
	onButton(self, self.rtTitlePage:Find("result/window/btn_finish"), function()
		self:openUI("main")
		self.gameController:ResetGame()
	end, SFX_CONFIRM)

	local var_4_0 = self.rtTitlePage:Find("main/res_bar")

	LoadImageSpriteAsync(Item.getConfigData(pg.activity_template[ActivityConst.ISLAND_GAME_ID].config_client.item_id).icon, var_4_0:Find("icon"), true)
	setText(var_4_0:Find("num"), self:GetMGHubData().count)
	onButton(self, var_4_0, function()
		self:emit(BaseMiniGameMediator.OPEN_SUB_LAYER, {
			mediator = IslandGameLimitMediator,
			viewComponent = IslandGameLimitLayer
		})
	end, SFX_CANCEL)
end

function OreMiniGameView:updateMainUI()
	OreMiniGameView.super.updateMainUI(self)
	setText(self.rtTitlePage:Find("main/res_bar"):Find("num"), self:GetMGHubData().count)
end

function OreMiniGameView:willExit()
	self.gameController:willExit()
end

return OreMiniGameView
