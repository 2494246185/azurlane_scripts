local NewBattleResultScene = class("NewBattleResultScene", import("view.base.BaseUI"))

function NewBattleResultScene:getUIName()
	return "NewBattleResultEmptyUI"
end

function NewBattleResultScene:getGroupName()
	return "BattleScene"
end

function NewBattleResultScene:getResource()
	local var_3_0 = {
		"ui/battleresult_atlas",
		"battleresultitems/resulteffect",
		"ui/newbattleresultstatisticspage",
		"ui/zhandoujiesuan_xingxing",
		"battleresultitems/ship",
		"battleresultitems/mvpbg",
		"battleresultitems/ship",
		"battleresultitems/mvp",
		"battleresultitems/metabtn",
		"battleresultitems/levelup",
		"battleresultitems/bommander",
		"battleresultitems/failedpainting"
	}

	if NewBattleResultYumiaMaterialPage.NeedShowYumiaMaterailDrop(self.contextData.drops) then
		table.insertto(var_3_0, self:GetYumiaMaterialRes())
	else
		table.insertto(var_3_0, self:GetNormalRes())
	end

	table.insertto(var_3_0, NewBattleResultScene.super.getResource(self))

	return var_3_0
end

function NewBattleResultScene:GetYumiaMaterialRes()
	local var_4_0 = {}

	table.insertto(var_4_0, self:GetGradePageRes())
	table.insertto(var_4_0, self:GetDisplayAwardPageRes())
	table.insertto(var_4_0, self:GetDisplayPaintingsPageRes())
	table.insertto(var_4_0, self:GetStatisticsPageRes())
	table.insertto(var_4_0, self:GetYumiaMaterialPageRes())

	return var_4_0
end

function NewBattleResultScene:GetNormalRes()
	local var_5_0 = {}

	table.insertto(var_5_0, self:GetGradePageRes())
	table.insertto(var_5_0, self:GetDisplayAwardPageRes())
	table.insertto(var_5_0, self:GetDisplayPaintingsPageRes())
	table.insertto(var_5_0, self:GetStatisticsPageRes())

	return var_5_0
end

function NewBattleResultScene:GetGradePageRes()
	local var_6_0 = {
		"ui/newbattleresultgradepage",
		"battleresultitems/victory",
		"battleresultitems/failed"
	}
	local var_6_1 = {
		"d",
		"c",
		"b",
		"a",
		"s"
	}

	for iter_6_0, iter_6_1 in ipairs(var_6_1) do
		table.insert(var_6_0, "battlescore/battle_score_" .. iter_6_1 .. "/letter_" .. iter_6_1)
		table.insert(var_6_0, "battlescore/battle_score_" .. iter_6_1 .. "/label_" .. iter_6_1)
	end

	table.insert(var_6_0, "battlescore/battle_score_" .. var_6_1[2] .. "/label_" .. "flag_destroy")

	return var_6_0
end

function NewBattleResultScene:GetDisplayAwardPageRes()
	return {}
end

function NewBattleResultScene:GetDisplayPaintingsPageRes()
	local var_8_0 = {
		"ui/newbattleresultdisplaypaintingspages"
	}

	for iter_8_0, iter_8_1 in ipairs(self.contextData.oldMainShips) do
		local var_8_1 = iter_8_1:getPainting()

		table.insert(var_8_0, "painting/" .. var_8_1 .. "_n")
		table.insert(var_8_0, "paintingface/" .. var_8_1)
		table.insert(var_8_0, "squareicon/" .. var_8_1)
	end

	return var_8_0
end

function NewBattleResultScene:GetStatisticsPageRes()
	local var_9_0 = {
		"ui/newbattleresultstatisticspage",
		"battleresultitems/commander",
		"ui/BattleResultMetaExpUI"
	}

	for iter_9_0, iter_9_1 in ipairs(self.contextData.oldMainShips) do
		table.insert(var_9_0, "herohrzicon/" .. iter_9_1:getPainting())
	end

	local var_9_1 = self.contextData.commanderExps or {}
	local var_9_2 = var_9_1.surfaceCMD or var_9_1.submarineCMD or {}

	for iter_9_2 = 1, #var_9_2 do
		table.insert(var_9_0, "commandericon/" .. getProxy(CommanderProxy):getCommanderById(var_9_2[iter_9_2].commander_id):getPainting())
	end

	return var_9_0
end

function NewBattleResultScene:GetYumiaMaterialPageRes()
	return {
		"ui/newbattleresultyumiarewardpages"
	}
end

function NewBattleResultScene:didEnter()
	self._parentTf = self._tf.parent

	self:InitData()
	self:Adjustion()
	self:SetUp(self.pages)

	if self.contextData.needVibrate then
		self:Vibrate()
	end

	self:BlurPanel(self._tf, {
		staticBlur = true,
		lockGlobalBlur = true
	})
	onDelayTick(function()
		if self.contextData.needCloseCamera then
			self:CloseCamera()
		end
	end, 0.2)
end

function NewBattleResultScene:Adjustion()
	local var_13_0 = GetComponent(self._tf, typeof(AspectRatioFitter))

	var_13_0.enabled = true
	var_13_0.aspectRatio = pg.CameraFixMgr.GetInstance().targetRatio
	self.camEventId = pg.CameraFixMgr.GetInstance():bind(pg.CameraFixMgr.ASPECT_RATIO_UPDATE, function(arg_14_0, arg_14_1)
		var_13_0.aspectRatio = arg_14_1
	end)
end

local function var_0_1(arg_15_0)
	if getProxy(SettingsProxy):IsDisplayResultPainting() then
		return
	end

	for iter_15_0 = #arg_15_0, 1, -1 do
		if arg_15_0[iter_15_0] == NewBattleResultDisplayPaintingsPage then
			table.remove(arg_15_0, iter_15_0)
		end
	end
end

function NewBattleResultScene:InitData()
	if not NewBattleResultSystem2Pages[self.contextData.system] then
		self.pages = NewBattleResultYumiaMaterialPage.NeedShowYumiaMaterailDrop(self.contextData.drops) and {
			NewBattleResultGradePage,
			NewBattleResultDisplayAwardPage,
			NewBattleResultYumiaMaterialPage,
			NewBattleResultDisplayPaintingsPage,
			NewBattleResultStatisticsPage
		} or {
			NewBattleResultGradePage,
			NewBattleResultDisplayAwardPage,
			NewBattleResultDisplayPaintingsPage,
			NewBattleResultStatisticsPage
		}
	end

	var_0_1(self.pages)

	self.contextData.oldMainShips = NewBattleResultUtil.RemoveNonStatisticShips(self.contextData.oldMainShips, self.contextData.statistics)
	self.contextData.newMainShips = NewBattleResultDataExtender.GetNewMainShips(self.contextData)
	self.contextData.autoSkipFlag = NewBattleResultDataExtender.GetAutoSkipFlag(self.contextData, self.contextData.system)
	self.contextData.needVibrate = NewBattleResultDataExtender.NeedVibrate(self.contextData.autoSkipFlag)
	self.contextData.needCloseCamera = NewBattleResultDataExtender.NeedCloseCamera(self.contextData.system)
	self.contextData.needHelpMessage = NewBattleResultDataExtender.NeedHelpMessage(self.contextData.system, self.contextData.score)
	self.contextData.expBuff = NewBattleResultDataExtender.GetExpBuffs(self.contextData.system)
	self.contextData.buffShips = NewBattleResultDataExtender.GetShipBuffs(self.contextData.system)
end

function NewBattleResultScene:CloseCamera()
	ys.Battle.BattleCameraUtil.GetInstance().ActiveMainCamera(false)
end

function NewBattleResultScene:Vibrate()
	pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_AUTO_BATTLE)
	LuaHelper.Vibrate()
end

function NewBattleResultScene:SetUp(arg_19_1)
	local var_19_0 = {}

	self.history = {}

	for iter_19_0, iter_19_1 in ipairs(arg_19_1) do
		table.insert(var_19_0, function(arg_20_0)
			if self.exited then
				return
			end

			local var_20_0 = iter_19_1.New(self._tf, self.event, self.contextData)

			var_20_0:ExecuteAction("SetUp", arg_20_0, function()
				self:DestroyHistory()
			end)
			table.insert(self.history, var_20_0)
		end)
	end

	seriesAsync(var_19_0, function()
		self:GoBack()
	end)
end

function NewBattleResultScene:DestroyHistory()
	for iter_23_0, iter_23_1 in ipairs(self.history) do
		if not isa(iter_23_1, NewBattleResultStatisticsPage) then
			iter_23_1:Destroy()
		end
	end
end

function NewBattleResultScene:GoBack()
	local function var_24_0()
		self.backSceneHandler = NewBattleResultBackSceneHandler.New(self.contextData)

		self.backSceneHandler:Execute()
	end

	if self.contextData.needHelpMessage then
		self:emit(NewBattleResultMediator.OPEN_FIALED_HELP, var_24_0)
	else
		var_24_0()
	end
end

function NewBattleResultScene:onBackPressed()
	return
end

function NewBattleResultScene:willExit()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, self._parentTf)

	if self.camEventId then
		pg.CameraFixMgr.GetInstance():disconnect(self.camEventId)

		self.camEventId = nil
	end

	if self.backSceneHandler then
		self.backSceneHandler:Dispose()

		self.backSceneHandler = nil
	end

	if self.history then
		for iter_27_0, iter_27_1 in ipairs(self.history) do
			iter_27_1:Destroy()
		end

		self.history = nil
	end
end

return NewBattleResultScene
