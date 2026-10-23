local GameHallScene = class("GameHallScene", import("..base.BaseUI"))

GameHallScene.open_with_list = false

function GameHallScene:getUIName()
	return "GameHallUI"
end

function GameHallScene:getResource()
	local var_2_0 = {
		"char/mingshi",
		"weaponframes"
	}

	local function var_2_1(arg_3_0)
		if noEmptyStr(arg_3_0) and not table.contains(var_2_0, arg_3_0) then
			table.insert(var_2_0, arg_3_0)
		end
	end

	if not self.charController then
		self:initContainer()
	end

	for iter_2_0, iter_2_1 in pairs(self.charController.shipNames or {}) do
		var_2_1("char/" .. iter_2_1)
	end

	local var_2_2 = pg.TimeMgr.GetInstance():GetServerTime()

	for iter_2_2, iter_2_3 in ipairs(pg.game_room_template.all) do
		if var_2_2 > pg.TimeMgr.GetInstance():Table2ServerTime({
			year = pg.game_room_template[iter_2_3].unlock_time[1][1],
			month = pg.game_room_template[iter_2_3].unlock_time[1][2],
			day = pg.game_room_template[iter_2_3].unlock_time[1][3],
			hour = pg.game_room_template[iter_2_3].unlock_time[2][1],
			min = pg.game_room_template[iter_2_3].unlock_time[2][2],
			sec = pg.game_room_template[iter_2_3].unlock_time[2][3]
		}) then
			var_2_1("gamehallicon/" .. pg.game_room_template[iter_2_3].icon)
		end
	end

	local var_2_3 = Item.getConfigData(pg.player_resource[GameRoomProxy.coin_res_id].itemid)

	if var_2_3 then
		var_2_1(var_2_3.icon)
	end

	return table.insertto(var_2_0, GameHallScene.super.getResource(self))
end

function GameHallScene:init()
	self:initContainer()
end

function GameHallScene:initContainer()
	self.charController = self.charController or GameHallContainerUI.New()
end

function GameHallScene:didEnter()
	self:initTopUI()
	self:initHomeUI()

	local var_6_0 = findTF(self._tf, "ad/container")

	self.charController:InitUI(var_6_0)

	self.freeCoinTf = findTF(var_6_0, "content/top/free")

	onButton(self, self.freeCoinTf, function()
		local var_7_0 = getProxy(GameRoomProxy)

		if var_7_0 == 0 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("game_icon_max_full"))
		elseif pg.gameset.game_coin_max.key_value - var_7_0:getCoin() < pg.gameset.game_coin_initial.key_value then
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				content = i18n("game_icon_max"),
				onYes = function()
					self:emit(GameHallMediator.GET_WEEKLY_COIN)
				end,
				onNo = function()
					return
				end
			})
		else
			self:emit(GameHallMediator.GET_WEEKLY_COIN)
		end
	end, SFX_CONFIRM)

	self.listPanelTf = findTF(self._tf, "ad/listPanel")
	self.listPanel = GameHallListPanel.New(self.listPanelTf, self)

	self.listPanel:setVisible(GameHallScene.open_with_list)

	GameHallScene.open_with_list = false
	self.exchangePanelTf = findTF(self._tf, "ad/exchangePanel")
	self.parentTf = findTF(self._tf, "ad")
	self.exchangePanel = GameHallExchangePanel.New(self.exchangePanelTf, self.parentTf, self)

	self:openExchangePanel(false)
	self:changeTitle(false)

	local var_6_1 = Application.targetFrameRate or 60

	if var_6_1 > 60 then
		var_6_1 = 60
	end

	self.timer = Timer.New(function()
		self:onTimer()
	end, 1 / var_6_1, -1)

	self.timer:Start()
	self:updateUI()
end

function GameHallScene:initTopUI()
	self.btnBack = findTF(self._tf, "ad/topPanel/btnBack")
	self.btnHome = findTF(self._tf, "ad/topPanel/btnHome")
	self.btnHelp = findTF(self._tf, "ad/topPanel/btnHelp")
	self.btnCoin = findTF(self._tf, "ad/topPanel/coin")
	self.textCoin = findTF(self._tf, "ad/topPanel/coin/text")
	self.coinMax = pg.gameset.game_coin_max.key_value
	self.textCoinMaxTF = findTF(self._tf, "ad/topPanel/coin/max")

	setText(self.textCoinMaxTF, "MAX:" .. self.coinMax)
	onButton(self, self.btnCoin, function()
		self:openExchangePanel(true)
	end)
	onButton(self, self.btnBack, function()
		if self.listPanel:getVisible() then
			self.listPanel:setVisible(false)
			self:changeTitle(false)
			pg.SystemGuideMgr.GetInstance():Play(self)

			return
		end

		self:closeView()
	end, SFX_CANCEL)
	onButton(self, self.btnHome, function()
		self:quickExitFunc()
	end, SFX_CANCEL)
	onButton(self, self.btnHelp, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.game_room_help.tip
		})
	end, SFX_CANCEL)
end

function GameHallScene:openExchangePanel(arg_16_1)
	self.exchangePanel:setVisible(arg_16_1)
end

function GameHallScene:ResUISettings()
	return {
		showType = bit.bor(PlayerResUI.TYPE_OIL, PlayerResUI.TYPE_GOLD)
	}
end

function GameHallScene:initHomeUI()
	self.btnShop = findTF(self._tf, "ad/adapt/btnShop")
	self.btnPlay = findTF(self._tf, "ad/adapt/btnPlay")

	onButton(self, self.btnPlay, function()
		self.listPanel:setVisible(true)
		self:changeTitle(true)
	end, SFX_CANCEL)
	onButton(self, self.btnShop, function()
		self:emit(GameHallMediator.OPEN_GAME_SHOP)
	end, SFX_CANCEL)

	self.topShop = findTF(self._tf, "ad/container/content/top/btnShop")
	self.topGame = findTF(self._tf, "ad/container/content/top/btnGameList")

	onButton(self, self.topGame, function()
		self.listPanel:setVisible(true)
		self:changeTitle(true)
	end, SFX_CANCEL)
	onButton(self, self.topShop, function()
		self:emit(GameHallMediator.OPEN_GAME_SHOP)
	end, SFX_CANCEL)
end

function GameHallScene:updateUI()
	setActive(self.freeCoinTf, (getProxy(GameRoomProxy):getWeekly()))
	setText(self.textCoin, (getProxy(GameRoomProxy):getCoin()))
end

function GameHallScene:onTimer()
	self.charController:step()
end

function GameHallScene:changeTitle(arg_25_1)
	setActive(findTF(self._tf, "ad/topPanel/title_list"), arg_25_1)
	setActive(findTF(self._tf, "ad/topPanel/title_main"), not arg_25_1)
end

function GameHallScene:onBackPressed()
	if self.listPanel:getVisible() then
		self.listPanel:setVisible(false)
		self:changeTitle(false)

		return
	end

	if self.exchangePanel:getVisible() then
		self.exchangePanel:setVisible(false)

		return
	end

	self:emit(GameHallScene.ON_BACK_PRESSED)
end

function GameHallScene:willExit()
	self.charController:Dispose()

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end

	if self.listPanel:getVisible() then
		GameHallScene.open_with_list = true
	end

	self.exchangePanel:dispose()
	self.listPanel:dispose()
end

return GameHallScene
