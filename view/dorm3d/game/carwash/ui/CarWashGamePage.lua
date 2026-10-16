local CarWashGamePage = class("CarWashGamePage", import("view.dorm3d.Game.Dorm3dGameBaseSubView"))

CarWashGamePage.GUN_COUNT = 3

function CarWashGamePage:Init()
	self:InitConfig()
	self:InitUI()
	self:BindEvent()
end

function CarWashGamePage:InitConfig()
	self.posConfig = _.map(self.contextData.gameConfig.pos, function(arg_3_0)
		return pg.dorm3d_carwash_pos[arg_3_0]
	end)
	self.selectPosIndex = 1
	self.posUnlock = _.map(self.posConfig, function(arg_4_0)
		return arg_4_0.mood_value <= self.contextData.gameStatus.heartBeatValue
	end)
	self.heartBeatDotVals = _.map(self.posConfig, function(arg_5_0)
		return arg_5_0.mood_value
	end)

	table.insert(self.heartBeatDotVals, 100)
end

function CarWashGamePage:InitUI()
	onButton(self, self._tf:Find("bottom/btn_shoot"), function()
		self:emit(CarWashGameFlowSystem.SWITCH_SHOOTING)
	end)

	self.gunList = UIItemList.New(self._tf:Find("bottom/guns"), self._tf:Find("bottom/guns/gun1"))

	self.gunList:make(function(arg_8_0, arg_8_1, arg_8_2)
		arg_8_1 = arg_8_1 + 1

		if arg_8_0 == UIItemList.EventInit then
			onButton(self, arg_8_2, function()
				if self.contextData.gameStatus.isShooting then
					return
				end

				if self.contextData.gameStatus.currentGunType == arg_8_1 then
					return
				end

				self:emit(CarWashGameFlowSystem.SWITCH_GUN_TYPE, arg_8_1)
			end)
		elseif arg_8_0 == UIItemList.EventUpdate then
			local var_8_0 = self.contextData.gameStatus.currentGunType == arg_8_1

			setActive(arg_8_2:Find("select"), self.contextData.gameStatus.currentGunType == arg_8_1)
			setActive(arg_8_2:Find("unselect"), not var_8_0)
		end
	end)
	self.gunList:align(CarWashGamePage.GUN_COUNT)

	self.camsList = UIItemList.New(self._tf:Find("left/cams"), self._tf:Find("left/cams/camTpl"))

	self.camsList:make(function(arg_10_0, arg_10_1, arg_10_2)
		arg_10_1 = arg_10_1 + 1

		if arg_10_0 == UIItemList.EventInit then
			onButton(self, arg_10_2, function()
				if self.posUnlock[arg_10_1] and self.selectPosIndex ~= arg_10_1 then
					self.selectPosIndex = arg_10_1

					self:Flush()
					self:emit(CarWashTimelineSystem.PLAY_TRANSITION, {
						waitHold = true,
						type = CarWashTimelineSystem.TRANSITION.BLACK,
						onHold = function(arg_12_0, arg_12_1)
							self:emit(CarWashGameFlowSystem.SWITCH_LADY_POS, self.posConfig[self.selectPosIndex].id)
							arg_12_0()
						end
					})
				end
			end)
		elseif arg_10_0 == UIItemList.EventUpdate then
			local var_10_0 = self.posUnlock[arg_10_1]
			local var_10_1 = self.selectPosIndex == arg_10_1

			setActive(arg_10_2:Find("lock"), not self.posUnlock[arg_10_1])
			setActive(arg_10_2:Find("normal"), var_10_0 and not var_10_1)
			setActive(arg_10_2:Find("select"), var_10_1)
		end
	end)
	self.camsList:align(#self.posConfig)

	self.favorList = UIItemList.New(self._tf:Find("left/favor/bar_root"), self._tf:Find("left/favor/bar_root/bar"))

	self.favorList:make(function(arg_13_0, arg_13_1, arg_13_2)
		arg_13_1 = arg_13_1 + 2

		if arg_13_0 == UIItemList.EventUpdate then
			local var_13_0 = self.heartBeatDotVals[arg_13_1] - self.heartBeatDotVals[arg_13_1 - 1]
			local var_13_1 = math.max(0, math.min(self.contextData.gameStatus.heartBeatValue - self.heartBeatDotVals[arg_13_1 - 1], self.heartBeatDotVals[arg_13_1] - self.heartBeatDotVals[arg_13_1 - 1]))
			local var_13_2 = var_13_1 / (self.heartBeatDotVals[arg_13_1] - self.heartBeatDotVals[arg_13_1 - 1])

			arg_13_2:GetComponent(typeof(Slider)).value = var_13_1 / (self.heartBeatDotVals[arg_13_1] - self.heartBeatDotVals[arg_13_1 - 1])

			setActive(arg_13_2:Find("dot/fill"), var_13_1 == var_13_0)
			setActive(arg_13_2:Find("mask/Vx_bar"), var_13_2 > 0 and var_13_2 < 1)
		end
	end)
	self.favorList:align(#self.heartBeatDotVals - 1)

	self.cleanPersentText = self._tf:Find("top/clean/clean_rate")
	self.cleanRank = self._tf:Find("top/clean/rank")
	self.timeText = self._tf:Find("top/clean/time")

	self:UpdateTimeText(CarWashConst.GAME_DURATION)
	setText(self._tf:Find("left/favor/text"), i18n("dorm3d_carwash_mood"))
	setText(self._tf:Find("top/clean/clean_text"), i18n("dorm3d_carwash_clean"))
end

function CarWashGamePage:BindEvent()
	self:bind(CarWashGameFlowSystem.GAME_RESET, function()
		self:InitConfig()
		self:Flush()

		self.needsRelock = true
	end)
	self:bind(CarWashGameFlowSystem.UPDATE_IS_SHOOTING, function()
		self:FlushShooting()
	end)
	self:bind(CarWashGameFlowSystem.UPDATE_COUNTDOWN, function(arg_17_0, arg_17_1)
		self:UpdateTimeText(arg_17_1.remainingSeconds)
	end)
	self:bind(CarWashGameFlowSystem.UPDATE_HEART_BEAT_VALUE, function(arg_18_0, arg_18_1)
		for iter_18_0, iter_18_1 in ipairs(self.posConfig) do
			if not self.posUnlock[iter_18_0] and iter_18_1.mood_value <= arg_18_1.newValue then
				self.posUnlock[iter_18_0] = true

				local var_18_0 = self._tf:Find("left/cams"):GetChild(iter_18_0 - 1)

				triggerButton(var_18_0)
				var_18_0:GetComponent(typeof(Animation)):Play("anim_Dorm3dCarWashUI_lock_out")
			end
		end

		self:Flush()
	end)
	self:bind(CarWashGameFlowSystem.UPDATE_STAINS_COUNT, function(arg_19_0, arg_19_1)
		self:FlushCleanPersent()
	end)
	self:bind(CarWashGameFlowSystem.UPDATE_CURRENT_GUN_TYPE, function(arg_20_0, arg_20_1)
		self:Flush()
	end)
	self:bind(CarWashGameFlowSystem.UPDATE_GAME_STATE, function(arg_21_0, arg_21_1)
		if arg_21_1.newValue == CarWashConst.GAME_STATE.PHASE_1 then
			self:Show()

			if self.needsRelock then
				self.needsRelock = false

				self:PlayRelockAnim()
			end
		elseif arg_21_1.newValue == CarWashConst.GAME_STATE.PHASE_2 or arg_21_1.newValue == CarWashConst.GAME_STATE.END then
			self:Hide()
		end
	end)
end

function CarWashGamePage:PlayRelockAnim()
	local var_22_0 = self._tf:Find("left/cams")

	for iter_22_0, iter_22_1 in ipairs(self.posUnlock) do
		if not iter_22_1 then
			var_22_0:GetChild(iter_22_0 - 1):GetComponent(typeof(Animation)):Play("anim_Dorm3dCarWashUI_relock")
		end
	end
end

function CarWashGamePage:UpdateTimeText(arg_23_1)
	setText(self.timeText, self:FormatTime(arg_23_1))
end

function CarWashGamePage:FormatTime(arg_24_1)
	arg_24_1 = math.max(arg_24_1 or 0, 0)

	return string.format("%02d:%02d", math.floor(arg_24_1 / 60), arg_24_1 % 60)
end

function CarWashGamePage:FlushShooting()
	setActive(self._tf:Find("bottom/btn_shoot/on"), self.contextData.gameStatus.isShooting)
	setActive(self._tf:Find("bottom/btn_shoot/off"), not self.contextData.gameStatus.isShooting)
end

function CarWashGamePage:Flush()
	self:FlushShooting()
	self.gunList:align(CarWashGamePage.GUN_COUNT)
	self.camsList:align(#self.posConfig)
	self.favorList:align(#self.heartBeatDotVals - 1)
	self:FlushCleanPersent()
end

function CarWashGamePage:FlushCleanPersent()
	local var_27_0 = self:GetCleanPersent()
	local var_27_1 = self:GetRank(var_27_0)

	setText(self.cleanPersentText, var_27_0 .. "%")
	eachChild(self.cleanRank, function(arg_28_0)
		setActive(arg_28_0, arg_28_0.name == var_27_1)
	end)
end

function CarWashGamePage:GetCleanPersent()
	if self.contextData.gameStatus.stainsCountMax == 0 then
		return 0
	end

	return (math.floor((1 - self.contextData.gameStatus.stainsCount / self.contextData.gameStatus.stainsCountMax) * 100))
end

function CarWashGamePage:GetRank(arg_30_1)
	return CarWashConst.GetScoreRank(arg_30_1)
end

return CarWashGamePage
