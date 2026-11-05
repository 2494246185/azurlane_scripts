local CarWashPhase2Page = class("CarWashPhase2Page", import("view.dorm3d.Game.Dorm3dGameBaseSubView"))

function CarWashPhase2Page:Init()
	self:InitConfig()
	self:InitUI()
	self:BindEvent()
	self:Hide()
end

function CarWashPhase2Page:InitConfig()
	self.posConfig = pg.dorm3d_carwash_pos[self.contextData.gameConfig.pos_phase2]

	assert(self.posConfig, "CarWash phase2 pos config not found: " .. tostring(self.contextData.gameConfig.pos_phase2))

	self.tipInfos = {}
	self.displayTipInfos = {}
	self.carTipInfo = nil
	self.clickedTips = {}
end

function CarWashPhase2Page:InitUI()
	self.tipContainer = self._tf:Find("tips")
	self.tipList = UIItemList.New(self.tipContainer, self._tf:Find("tips/tpl"))

	self.tipList:make(function(arg_4_0, arg_4_1, arg_4_2)
		arg_4_1 = arg_4_1 + 1

		if arg_4_0 == UIItemList.EventInit then
			onButton(self, arg_4_2, function()
				if not self.displayTipInfos[arg_4_1] then
					return
				end

				if self.displayTipInfos[arg_4_1].isCar then
					self:emit(CarWashCarSystem.PLAY_PHASE2_REACTION)

					return
				end

				if self.clickedTips[self.displayTipInfos[arg_4_1].animId] then
					return
				end

				self:emit(CarWashGameFlowSystem.PLAY_PHASE2_REACTION, {
					animId = self.displayTipInfos[arg_4_1].animId
				})
			end)
		elseif arg_4_0 == UIItemList.EventUpdate then
			self:UpdateTipItem(arg_4_1, arg_4_2)
		end
	end)
end

function CarWashPhase2Page:BindEvent()
	self:bind(CarWashGameFlowSystem.UPDATE_GAME_STATE, function(arg_7_0, arg_7_1)
		if arg_7_1.newValue == CarWashConst.GAME_STATE.PHASE_2 then
			self:Show()
			self:ResetTips()
			self:Flush()
		elseif arg_7_1.newValue == CarWashConst.GAME_STATE.PHASE_1 or arg_7_1.newValue == CarWashConst.GAME_STATE.END then
			self:Hide()
		end
	end)
	self:bind(CarWashLadySystem.UPDATE_PHASE2_TIPS, function(arg_8_0, arg_8_1)
		if self.contextData.gameStatus.currentState ~= CarWashConst.GAME_STATE.PHASE_2 then
			return
		end

		self.tipInfos = arg_8_1 or {}

		self:Flush()
	end)
	self:bind(CarWashCarSystem.UPDATE_PHASE2_TIP, function(arg_9_0, arg_9_1)
		if self.contextData.gameStatus.currentState ~= CarWashConst.GAME_STATE.PHASE_2 then
			return
		end

		self.carTipInfo = arg_9_1

		self:Flush()
	end)
	self:bind(CarWashGameFlowSystem.UPDATE_PHASE2_REACTION_PROGRESS, function(arg_10_0, arg_10_1)
		self.clickedTips[arg_10_1.animId] = true

		self:Flush()
	end)
end

function CarWashPhase2Page:Flush()
	self.displayTipInfos = {}

	for iter_11_0, iter_11_1 in ipairs(self.tipInfos) do
		table.insert(self.displayTipInfos, iter_11_1)
	end

	if self.carTipInfo then
		table.insert(self.displayTipInfos, self.carTipInfo)
	end

	self.tipList:align(#self.displayTipInfos)
end

function CarWashPhase2Page:UpdateTipItem(arg_12_1, arg_12_2)
	assert(self.displayTipInfos[arg_12_1], "CarWash phase2 tip info not found: " .. tostring(arg_12_1))
	setActive(arg_12_2, self.displayTipInfos[arg_12_1].visible)

	if self.displayTipInfos[arg_12_1].visible then
		setLocalPosition(arg_12_2, LuaHelper.ScreenToLocal(self.tipContainer, self.displayTipInfos[arg_12_1].screenPosition, pg.UIMgr.GetInstance().uiCameraComp))
	end
end

function CarWashPhase2Page:ResetTips()
	self.tipInfos = {}
	self.displayTipInfos = {}
	self.carTipInfo = nil
	self.clickedTips = {}
end

return CarWashPhase2Page
