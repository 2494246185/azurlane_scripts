local MainBasePainting = class("MainBasePainting", import("view.base.BaseEventLogic"))
local var_0_1 = 1
local var_0_2 = 2
local var_0_3 = 3
local var_0_4 = 4
local var_0_5

function MainBasePainting:Ctor(arg_1_1, arg_1_2)
	MainBasePainting.super.Ctor(self, arg_1_2)
	pg.DelegateInfo.New(self)

	self.container = arg_1_1
	self.state = var_0_1
	var_0_5 = pg.AssistantInfo
	self.wordPosition = arg_1_1:Find("live2d")
	self.cvLoader = MainCVLoader.New()
	self.longPressEvent = arg_1_1:GetComponent("UILongPressTrigger").onLongPressed
	self.replaceWord = false
	self._asmrFlag = false
end

function MainBasePainting:IsUnload()
	return self.state == var_0_4
end

function MainBasePainting:GetCenterPos()
	return self.wordPosition.position
end

function MainBasePainting:IsLoading()
	return self.state == var_0_2
end

function MainBasePainting:IsLoaded()
	return self.state == var_0_3
end

function MainBasePainting:SetOnceLoadedCall(arg_6_1)
	return
end

function MainBasePainting:Load(arg_7_1)
	self.isPuase = false
	self.isExited = false
	self.state = var_0_2
	self.ship = arg_7_1
	self.paintingName = arg_7_1:getPainting()

	self:OnLoad(function()
		self.state = var_0_3

		if self.triggerWhenLoaded then
			self:TriggerEventAtFirstTime()
		else
			self:TriggerNextEventAuto()
		end

		self:InitClickEvent()
		self:emit(NewMainScene.PAINTING_LOAD_COMPLETE)
	end)
end

function MainBasePainting:Unload()
	if self.state == var_0_4 then
		return
	end

	self.state = var_0_4

	removeOnButton(self.container)
	self.longPressEvent:RemoveAllListeners()
	self:StopChatAnimtion()
	self.cvLoader:Stop()
	self:RemoveTimer()
	self:OnUnload()

	self.paintingName = nil

	LeanTween.cancel(self.container.gameObject)
end

function MainBasePainting:UnloadOnlyPainting()
	self.state = var_0_4

	removeOnButton(self.container)
	self.longPressEvent:RemoveAllListeners()
	self:RemoveTimer()
	self:OnUnload()

	self.paintingName = nil
end

function MainBasePainting:InitClickEvent()
	onButton(self, self.container, function()
		self:OnClick()
		self:TriggerPersonalTask(self.ship.groupId)
	end)
	self.longPressEvent:RemoveAllListeners()
	self.longPressEvent:AddListener(function()
		if self._asmrFlag then
			return
		end

		if getProxy(ContextProxy):getCurrentContext().viewComponent.__cname == "NewMainScene" then
			self:OnLongPress()
		end
	end)
end

function MainBasePainting:TriggerPersonalTask(arg_14_1)
	if self.isFoldState then
		return
	end

	self:TriggerInterActionTask()

	local var_14_0 = getProxy(TaskProxy)

	for iter_14_0, iter_14_1 in ipairs(pg.task_data_trigger.all) do
		if pg.task_data_trigger[iter_14_1].group_id == arg_14_1 then
			local var_14_1 = pg.task_data_trigger[iter_14_1].task_id

			if not var_14_0:getFinishTaskById(pg.task_data_trigger[iter_14_1].task_id) then
				self:CheckStoryDownload(pg.task_data_trigger[iter_14_1].task_id, function()
					pg.m02:sendNotification(GAME.TRIGGER_TASK, var_14_1)
				end)

				break
			end
		end
	end
end

function MainBasePainting:TriggerInterActionTask()
	local var_16_0 = getProxy(TaskProxy):GetFlagShipInterActionTaskList()

	if var_16_0 and #var_16_0 > 0 then
		for iter_16_0, iter_16_1 in ipairs(var_16_0) do
			pg.m02:sendNotification(GAME.UPDATE_TASK_PROGRESS, {
				taskId = iter_16_1.id
			})
		end
	end
end

function MainBasePainting:CheckStoryDownload(arg_17_1, arg_17_2)
	local var_17_0 = {}
	local var_17_1 = arg_17_1

	while true do
		if pg.task_data_template[arg_17_1].story_id ~= "" then
			table.insert(var_17_0, pg.task_data_template[arg_17_1].story_id)
		end

		if pg.task_data_template[arg_17_1].next_task == "" or pg.task_data_template[arg_17_1].next_task == "0" then
			break
		end

		var_17_1 = arg_17_1 + 1
	end

	local var_17_2 = pg.NewStoryMgr.GetInstance()

	PaintingGroupConst.PaintingDownload({
		isShowBox = true,
		paintingNameList = _.map(var_17_2:GetStoryPaintingsByNameList(var_17_0), function(arg_18_0)
			return "painting/" .. arg_18_0
		end),
		finishFunc = arg_17_2
	})
end

function MainBasePainting:TriggerEventAtFirstTime()
	if not self:IsLoaded() then
		self.triggerWhenLoaded = true

		return
	end

	self.triggerWhenLoaded = false

	self:OnFirstTimeTriggerEvent()
end

function MainBasePainting:OnFirstTimeTriggerEvent()
	self._loginAction = getProxy(PlayerProxy):getFlag("login")
	self._battleAction = getProxy(PlayerProxy):getFlag("battle")

	getProxy(PlayerProxy):setFlag("login", false)
	getProxy(PlayerProxy):setFlag("battle", false)

	local function var_20_0(arg_21_0)
		self:PrepareTriggerAction(arg_21_0)
	end

	if self._loginAction then
		self._loginAction = false

		var_20_0("event_login")
	elseif self._battleAction then
		self._battleAction = false

		var_20_0("home")
	else
		self:TriggerNextEventAuto()
	end
end

function MainBasePainting:PrepareTriggerAction(arg_22_1)
	self:TryToTriggerEvent(arg_22_1)
end

function MainBasePainting:TryToTriggerEvent(arg_23_1)
	self:_TriggerEvent(arg_23_1)
end

function MainBasePainting:_TriggerEvent(arg_24_1)
	local var_24_0 = pg.AssistantInfo.GetAssistantEvents(arg_24_1)

	if var_24_0.dialog ~= "" then
		self:DisplayWord(var_24_0.dialog)
	else
		self:TriggerNextEventAuto()
	end
end

function MainBasePainting:SetShift(arg_25_1)
	self._shift = arg_25_1
end

function MainBasePainting:TriggerEvent(arg_26_1)
	if self.isDragAndZoomState then
		return
	end

	if self.chatting then
		return
	end

	self:RemoveTimer()
	self:PrepareTriggerAction(arg_26_1)
	self:OnTriggerEvent()
end

function MainBasePainting:TriggerNextEventAuto()
	if self.isPuase or self.isExited and self._asmrFlag then
		return
	end

	self:OnEndChatting()
	self:RemoveTimer()

	self.timer = Timer.New(function()
		self:OnTimerTriggerEvent()
	end, 30, 1, true)

	self.timer:Start()
end

function MainBasePainting:OnTimerTriggerEvent()
	if self:OnEnableTimerEvent() then
		local var_29_0 = self:CollectIdleEvents(self.lastChatEvent)

		self.lastChatEvent = var_29_0[math.ceil(math.random(#var_29_0))]

		self:PrepareTriggerAction(self.lastChatEvent)
		self:OnTriggerEventAuto()
		self:RemoveTimer()
	end
end

function MainBasePainting:SetTargetContainer(arg_30_1)
	self._renderTargetContainer = arg_30_1
end

function MainBasePainting:GetTargetContainer()
	return (self._renderTargetContainer or nil) and (self._renderTargetContainer or self.container)
end

function MainBasePainting:OnEnableTimerEvent()
	return true
end

function MainBasePainting:OnStartChatting()
	self.chatting = true
end

function MainBasePainting:OnEndChatting()
	self.chatting = false
end

function MainBasePainting:GetWordAndCv(arg_35_1, arg_35_2)
	local var_35_0, var_35_1, var_35_2, var_35_3, var_35_4, var_35_5 = ShipWordHelper.GetCvDataForShip(self.ship, arg_35_2)

	return var_35_0, var_35_1, var_35_2, var_35_3, var_35_4, var_35_5
end

function MainBasePainting:DisplayWord(arg_36_1)
	self:OnStartChatting()

	local var_36_0, var_36_1, var_36_2, var_36_3, var_36_4, var_36_5 = self:GetWordAndCv(self.ship, arg_36_1)

	if not var_36_2 or var_36_2 == nil or var_36_2 == "" or var_36_2 == "nil" then
		self:OnEndChatting()
		self:OnDisplayWordEnd()

		return
	end

	self:OnDisplayWorld(arg_36_1)

	if self._asmrFlag then
		self:emit(MainAsmrChatView.SET_CONTENT, arg_36_1, var_36_2)
	else
		self:emit(MainWordView.SET_CONTENT, arg_36_1, var_36_2)
	end

	self:PlayCvAndAnimation(var_36_4, var_36_3, var_36_1)
end

function MainBasePainting:PlayCvAndAnimation(arg_37_1, arg_37_2, arg_37_3)
	if getProxy(ContextProxy):getContextByMediator(NewShipMediator) then
		self:OnEndChatting()

		return
	end

	local var_37_0 = -1

	seriesAsync({
		function(arg_38_0)
			if arg_37_3 then
				if not not pg.NewStoryMgr.GetInstance():IsRunning() then
					arg_38_0()

					return
				end
			end

			self:PlayCV(arg_37_1, arg_37_2, arg_37_3, function(arg_39_0)
				var_37_0 = arg_39_0

				arg_38_0()
			end)
		end,
		function(arg_40_0)
			self:StartChatAnimtion(var_37_0, arg_40_0)
		end
	}, function()
		self:OnDisplayWordEnd()
	end)
end

function MainBasePainting:OnDisplayWordEnd()
	self:TriggerNextEventAuto()
end

function MainBasePainting:PlayCV(arg_43_1, arg_43_2, arg_43_3, arg_43_4)
	self.cvLoader:Load(pg.CriMgr.GetCVBankName((ShipWordHelper.RawGetCVKey(self.ship:getSkinId()))), arg_43_3, 0, arg_43_4)
end

function MainBasePainting:preloadCv(arg_44_1)
	self.cvLoader:preloadCv(pg.CriMgr.GetCVBankName((ShipWordHelper.RawGetCVKey(self.ship:getSkinId()))), arg_44_1)
end

function MainBasePainting:OnAsmrTurnning(arg_45_1)
	self._asmrFlag = arg_45_1
end

function MainBasePainting:setReplaceWord(arg_46_1)
	self.replaceWord = arg_46_1
end

function MainBasePainting:getReplaceWord()
	return self.replaceWord
end

function MainBasePainting:StartChatAnimtion(arg_48_1, arg_48_2)
	local var_48_0 = arg_48_1 > 0 and arg_48_1 or 3

	if self._asmrFlag then
		self:emit(MainAsmrChatView.START_CHAT, 0.3, var_48_0)
	else
		self:emit(MainWordView.START_ANIMATION, 0.3, var_48_0)
	end

	self:AddCharTimer(function()
		if self:IsUnload() then
			return
		end

		arg_48_2()
	end, 0.3 * 3 + var_48_0)
end

function MainBasePainting:AddCharTimer(arg_50_1, arg_50_2)
	self:RemoveChatTimer()

	self.chatTimer = Timer.New(arg_50_1, arg_50_2, 1)

	self.chatTimer:Start()
end

function MainBasePainting:RemoveChatTimer()
	if self.chatTimer then
		self.chatTimer:Stop()

		self.chatTimer = nil
	end
end

function MainBasePainting:StopChatAnimtion()
	if not self._asmrFlag then
		self:emit(MainWordView.STOP_ANIMATION)
	end

	self:OnEndChatting()
end

function MainBasePainting:OnStopVoice()
	self.cvLoader:Stop()
end

function MainBasePainting:CollectIdleEvents(arg_54_1)
	local var_54_0 = {}

	if getProxy(EventProxy):hasFinishState() and arg_54_1 ~= "event_complete" then
		table.insert(var_54_0, "event_complete")
	else
		if getProxy(TaskProxy):getCanReceiveCount() > 0 and arg_54_1 ~= "mission_complete" then
			table.insert(var_54_0, "mission_complete")
		end

		if getProxy(MailProxy):GetUnreadCount() > 0 and arg_54_1 ~= "mail" then
			table.insert(var_54_0, "mail")
		end

		if #var_54_0 == 0 then
			var_54_0 = var_0_5.GetShipMainEvents(self.ship:getSkinId(), self.ship:getCVIntimacy())

			if getProxy(TaskProxy):getNotFinishCount() then
				if getProxy(TaskProxy):getNotFinishCount() > 0 and arg_54_1 ~= "mission" then
					table.insert(var_54_0, "mission")
				end
			end
		end
	end

	return var_54_0
end

function MainBasePainting:CollectTouchEvents()
	local var_55_0 = self.ship:getCVIntimacy()

	return (var_0_5.filterAssistantEvents(var_0_5.GetShipTouchEvents(self.ship:getSkinId(), var_55_0), self.ship:getSkinId(), var_55_0))
end

function MainBasePainting:GetTouchEvent(arg_56_1)
	local var_56_0 = self.ship:getCVIntimacy()

	return (var_0_5.filterAssistantEvents(var_0_5.getAssistantTouchEvents(arg_56_1, self.ship:getSkinId()), self.ship:getSkinId(), 0))
end

function MainBasePainting:GetIdleEvents()
	local var_57_0 = self.ship:getCVIntimacy()

	return (var_0_5.filterAssistantEvents(var_0_5.GetShipMainEvents(self.ship:getSkinId(), 0), self.ship:getSkinId(), 0))
end

function MainBasePainting:GetEventConfig(arg_58_1)
	return pg.AssistantInfo.GetAssistantEvents(arg_58_1)
end

function MainBasePainting:GetSpecialTouchEvent(arg_59_1)
	return var_0_5.getPaintingTouchEvents(arg_59_1)
end

function MainBasePainting:RemoveTimer()
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

function MainBasePainting:IsExited()
	return self.isExited
end

function MainBasePainting:Fold(arg_62_1, arg_62_2)
	self.isFoldState = arg_62_1

	self:RemoveMoveTimer()
	self:OnFold(arg_62_1)
end

function MainBasePainting:RemoveMoveTimer()
	if self.moveTimer then
		self.moveTimer:Stop()

		self.moveTimer = nil
	end
end

function MainBasePainting:EnableOrDisableMove(arg_64_1)
	self.isDragAndZoomState = arg_64_1

	self:RemoveMoveTimer()

	if arg_64_1 then
		self:StopChatAnimtion()
		self:RemoveTimer()
		self.cvLoader:Stop()
	else
		self:TriggerNextEventAuto()
	end

	self:OnEnableOrDisableDragAndZoom(arg_64_1)
end

function MainBasePainting:GetOffset()
	return 0
end

function MainBasePainting:UpdateBound()
	return
end

function MainBasePainting:IslimitYPos()
	return false
end

function MainBasePainting:PlayChangeSkinActionIn(arg_68_1)
	return
end

function MainBasePainting:PlayChangeSkinActionOut(arg_69_1)
	return
end

function MainBasePainting:PauseForSilent()
	if SettingsMainScenePanel.IsEnableFlagShipInteraction() then
		return
	end

	if self:IsLoaded() then
		self:_Pause()
	end
end

function MainBasePainting:_Pause()
	self.isPuase = true

	self:RemoveMoveTimer()
	self:StopChatAnimtion()
	self:RemoveChatTimer()
	self:RemoveTimer()
	self.cvLoader:Stop()
end

function MainBasePainting:Pause()
	self:_Pause()
	self:OnPause()
end

function MainBasePainting:ResumeForSilent()
	if SettingsMainScenePanel.IsEnableFlagShipInteraction() then
		return
	end

	if self:IsLoaded() then
		self:_Resume()
	end
end

function MainBasePainting:_Resume()
	self.isPuase = false

	self:TriggerNextEventAuto()
end

function MainBasePainting:Resume()
	self:_Resume()
	self:OnResume()
end

function MainBasePainting:updateShip(arg_76_1)
	if arg_76_1 and self.ship.id == arg_76_1.id then
		self.ship = arg_76_1
	end

	self:OnUpdateShip(arg_76_1)
end

function MainBasePainting:OnUpdateShip(arg_77_1)
	return
end

function MainBasePainting:OnPaintingFade(arg_78_1)
	return
end

function MainBasePainting:InitScalePart()
	local var_79_0 = self:GetPartScaleData()

	if var_79_0 and #var_79_0 > 0 then
		self.partScaleList = {}
		self.partScaleSelectList = {}

		local var_79_1 = self:GetPaintingTransform()

		if var_79_1 then
			for iter_79_0, iter_79_1 in ipairs(var_79_0) do
				local var_79_2 = findTF(var_79_1, iter_79_1)

				if var_79_2 then
					local var_79_3 = GetOrAddComponent(var_79_2, typeof(PinchZoom))

					var_79_3.enabled = false

					PoolMgr.GetInstance():GetUI("mainuiscalepart", false, function(arg_80_0)
						SetParent(arg_80_0, var_79_2)
						setActive(arg_80_0, false)
						table.insert(self.partScaleSelectList, {
							tf = tf(arg_80_0),
							name = iter_79_1
						})
					end)
					onButton(self._event, var_79_2, function()
						if self.partScaleFlag then
							self.selectPartName = iter_79_1

							self:updateSelectPartScale()
						end
					end)
					self:ResetPartScale(true)
					table.insert(self.partScaleList, {
						name = iter_79_1,
						tf = var_79_2,
						com = var_79_3
					})
				end
			end
		end
	end
end

function MainBasePainting:updatePartCotent(arg_82_1)
	for iter_82_0 = 1, #self.partScaleSelectList do
		if arg_82_1 then
			self:emit(NewMainScene.SET_SCALE_PART_CONTENT, self.partScaleSelectList[iter_82_0].tf)
		else
			setParent(self.partScaleSelectList[iter_82_0].tf, self:GetPaintingTransform(), true)
		end
	end
end

function MainBasePainting:updateSelectPartScale()
	for iter_83_0 = 1, #self.partScaleList do
		self.partScaleList[iter_83_0].com.enabled = self.partScaleFlag and self.partScaleList[iter_83_0].name == self.selectPartName

		setActive(self.partScaleSelectList[iter_83_0].tf, self.partScaleFlag and self.partScaleSelectList[iter_83_0].name == self.selectPartName)
	end
end

function MainBasePainting:ClearScalePart()
	if self.partScaleList and #self.partScaleList > 0 then
		for iter_84_0 = 1, #self.partScaleList do
			if self.partScaleList[iter_84_0].tf then
				removeOnButton(self.partScaleList[iter_84_0].tf)
			end
		end

		self.partScaleList = nil
	end

	if self.partScaleSelectList and #self.partScaleSelectList > 0 then
		for iter_84_1 = 1, #self.partScaleSelectList do
			if self.partScaleSelectList[iter_84_1].tf then
				PoolMgr.GetInstance():ReturnUI("mainuiscalepart", go(self.partScaleSelectList[iter_84_1].tf))
			end
		end

		self.partScaleSelectList = nil
	end
end

function MainBasePainting:OnEnablePartScale(arg_85_1)
	if self.partScaleList then
		self.partScaleFlag = arg_85_1
		self.selectPartName = nil

		for iter_85_0 = 1, #self.partScaleList do
			GetOrAddComponent(self.partScaleList[iter_85_0].tf, typeof(CanvasGroup)).blocksRaycasts = arg_85_1
		end

		self:updateSelectPartScale()
		self:updatePartCotent(arg_85_1)

		if not arg_85_1 then
			self:ResetPartScale(true)
		end
	end
end

function MainBasePainting:ResetPartScale(arg_86_1)
	if self.partScaleList and #self.partScaleList > 0 then
		for iter_86_0 = 1, #self.partScaleList do
			local var_86_0 = self.partScaleList[iter_86_0].tf
			local var_86_1

			if arg_86_1 then
				var_86_1 = getProxy(SettingsProxy):getSkinScaleSetting(self.ship, self:GetPartStateType(), self.partScaleList[iter_86_0].name) or 1
			end

			var_86_0.localScale = Vector3(var_86_1, var_86_1, var_86_1)
		end
	end
end

function MainBasePainting:SavePartScaleData()
	if not self.partScaleList or #self.partScaleList == 0 then
		return
	end

	if not self.ship then
		return
	end

	for iter_87_0 = 1, #self.partScaleList do
		getProxy(SettingsProxy):setSkinScaleSetting(self.ship, self:GetPartStateType(), self.partScaleList[iter_87_0].name, self.partScaleList[iter_87_0].tf.localScale.x)
	end
end

function MainBasePainting:GetPaintingTransform()
	return nil
end

function MainBasePainting:GetPartScaleData()
	return nil
end

function MainBasePainting:GetPartStateType()
	return
end

function MainBasePainting:Dispose()
	self._renderTargetContainer = nil

	self:disposeEvent()

	self.isExited = true

	pg.DelegateInfo.Dispose(self)

	if self.state == var_0_3 then
		self:UnLoad()
	end

	self.cvLoader:Dispose()

	self.cvLoader = nil
	self.triggerWhenLoaded = false

	self:RemoveTimer()
	self:RemoveMoveTimer()
	self:RemoveChatTimer()
	self:ClearScalePart()
end

function MainBasePainting:OnLoad(arg_92_1)
	arg_92_1()
end

function MainBasePainting:OnUnload()
	return
end

function MainBasePainting:OnClick()
	return
end

function MainBasePainting:OnLongPress()
	return
end

function MainBasePainting:OnTriggerEvent()
	return
end

function MainBasePainting:OnTriggerEventAuto()
	return
end

function MainBasePainting:OnDisplayWorld(arg_98_1)
	return
end

function MainBasePainting:OnFold(arg_99_1)
	return
end

function MainBasePainting:OnEnableOrDisableDragAndZoom(arg_100_1)
	return
end

function MainBasePainting:OnPause()
	return
end

function MainBasePainting:OnResume()
	return
end

return MainBasePainting
