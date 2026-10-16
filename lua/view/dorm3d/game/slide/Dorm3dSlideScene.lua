local Dorm3dSlideScene = class("Dorm3dSlideScene", import("view.dorm3d.Game.Dorm3dGameTemplate"))

function Dorm3dSlideScene:getUIName()
	return "Dorm3dSlideUI"
end

function Dorm3dSlideScene:preload(arg_2_1)
	self.gameConfig = pg.dorm3d_minigame_slide[self.contextData.groupId]

	self:SetApartment(getProxy(ApartmentProxy):getApartment(self.contextData.groupId))

	self.sceneInfo = {
		{
			path = self.gameConfig.peform_scene_info[1],
			name = self.gameConfig.peform_scene_info[2]
		},
		{
			path = self.gameConfig.perform_timeline_info[1],
			name = self.gameConfig.perform_timeline_info[2]
		}
	}

	seriesAsync({
		function(arg_3_0)
			SceneOpMgr.Inst:LoadSceneAsync(self.sceneInfo[1].path, self.sceneInfo[1].name, LoadSceneMode.Additive, function(arg_4_0, arg_4_1)
				SceneManager.SetActiveScene(arg_4_0)
				arg_3_0()
			end)
		end,
		function(arg_5_0)
			SceneOpMgr.Inst:LoadSceneAsync(self.sceneInfo[2].path, self.sceneInfo[2].name, LoadSceneMode.Additive, function(arg_6_0, arg_6_1)
				arg_5_0()
			end)
		end
	}, arg_2_1)
end

function Dorm3dSlideScene:getResource()
	local var_7_0 = Dorm3dSlideScene.super.getResource(self)

	self.gameConfig = pg.dorm3d_minigame_slide[self.contextData.groupId]

	for iter_7_0, iter_7_1 in ipairs({
		self.gameConfig.peform_scene_info[1],
		self.gameConfig.peform_scene_info[2]
	}) do
		if not table.contains(var_7_0, iter_7_1) then
			table.insert(var_7_0, iter_7_1)
		end
	end

	return var_7_0
end

function Dorm3dSlideScene:init()
	self:InitScene()
	self:InitUI()

	local var_8_0 = Dorm3dHxHelper.GetTimelineMainCharacter()

	Dorm3dHxHelper.ReplaceCharacterParts(var_8_0)
	Dorm3dHxHelper.HideCharacterPart(var_8_0, nil, true)
	Dorm3dHxHelper.ShowHolyLight({
		var_8_0
	}, self.holyLightRoot)
end

function Dorm3dSlideScene:InitUI()
	onButton(self, self._tf:Find("GameUI/Title/BackBtn"), function()
		self:emit(Dorm3dSlideScene.ON_BACK)
	end, SFX_DORM_CLICK)

	self.qteTF = self._tf:Find("GameUI/QTE")

	setActive(self.qteTF, false)

	self.countTF = self._tf:Find("GameUI/Count")

	setActive(self.countTF, false)
	self.countTF:GetComponent(typeof(DftAniEvent)):SetEndEvent(function()
		setActive(self.countTF, false)
	end)

	self.endUI = self._tf:Find("EndUI")

	setText(self._tf:Find("GameUI/Title/Text"), i18n("3ddorm_beach_slide_tip7"))

	self.ltList = {}
	self.timerList = {}
	self.holyLightRoot = self._tf:Find("HolyLightRoot")
end

function Dorm3dSlideScene:InitScene()
	table.IpairsCArray(SceneManager.GetSceneByName(self.sceneInfo[1].name):GetRootGameObjects(), function(arg_13_0, arg_13_1)
		return
	end)

	self.timelineDic = {}

	table.IpairsCArray(SceneManager.GetSceneByName(self.sceneInfo[2].name):GetRootGameObjects(), function(arg_14_0, arg_14_1)
		local var_14_0 = arg_14_1.transform:Find("[sequence]")

		if var_14_0 then
			local var_14_1 = var_14_0:GetComponent(typeof(UnityEngine.Playables.PlayableDirector))

			self.timelineDic[arg_14_1.name] = {
				obj = arg_14_1,
				seq = var_14_0,
				director = var_14_1
			}

			TimelineSupport.DisablePlayOnAwake(var_14_1)
			setActive(arg_14_1, true)
		end
	end)

	self.speedComp = GetOrAddComponent(self.timelineDic[self.gameConfig.perform_catch].seq, typeof(TimelineSpeed))
end

function Dorm3dSlideScene:didEnter()
	self:StartGame()
end

function Dorm3dSlideScene:ShowCountDown()
	setActive(self.countTF, true)
end

function Dorm3dSlideScene:StartQTE()
	local var_17_0 = {}

	self.resultList = {}

	for iter_17_0 = 1, SlideConst.QTE_COUNT do
		table.insert(var_17_0, function(arg_18_0)
			local var_18_0 = cloneTplTo(self.qteTF, self._tf:Find("GameUI"))

			setLocalScale(var_18_0:Find("animroot/Perfect"), Vector3((SlideConst.QTE_TIME - SlideConst.QTE_SUCCESS_RANGE[1]) / SlideConst.QTE_TIME, (SlideConst.QTE_TIME - SlideConst.QTE_SUCCESS_RANGE[1]) / SlideConst.QTE_TIME, (SlideConst.QTE_TIME - SlideConst.QTE_SUCCESS_RANGE[1]) / SlideConst.QTE_TIME))
			setLocalScale(var_18_0:Find("animroot/Centres"), Vector3((SlideConst.QTE_TIME - SlideConst.QTE_SUCCESS_RANGE[2]) / SlideConst.QTE_TIME, (SlideConst.QTE_TIME - SlideConst.QTE_SUCCESS_RANGE[2]) / SlideConst.QTE_TIME, (SlideConst.QTE_TIME - SlideConst.QTE_SUCCESS_RANGE[2]) / SlideConst.QTE_TIME))
			setAnchoredPosition(var_18_0, {
				x = self.gameConfig.qte_position[iter_17_0][1],
				y = self.gameConfig.qte_position[iter_17_0][2]
			})
			setActive(var_18_0, true)

			local var_18_1 = var_18_0:Find("animroot/Trigger")
			local var_18_2 = 0
			local var_18_3 = Timer.New(function()
				if var_18_2 >= SlideConst.QTE_TIME then
					self.timerList[iter_17_0]:Stop()
					setActive(var_18_0, false)

					return
				end

				var_18_2 = var_18_2 + 0.016666666666666666
				var_18_1.localScale = Vector3.Lerp(Vector3(1, 1, 1), Vector3(0, 0, 0), var_18_2 / SlideConst.QTE_TIME)
			end, 0.016666666666666666, -1)

			var_18_3:Start()

			self.timerList[iter_17_0] = var_18_3

			onButton(self, var_18_0, function()
				self.timerList[iter_17_0]:Stop()

				if var_18_2 >= SlideConst.QTE_SUCCESS_RANGE[1] and var_18_2 <= SlideConst.QTE_SUCCESS_RANGE[2] then
					self.resultList[iter_17_0] = true

					setActive(var_18_0:Find("animroot/Result/Hit"), true)
				else
					self.resultList[iter_17_0] = false

					setActive(var_18_0:Find("animroot/Result/Miss"), true)
				end
			end)
			table.insert(self.ltList, LeanTween.delayedCall((iter_17_0 == SlideConst.QTE_COUNT or nil) and (SlideConst.QTE_TIME or SlideConst.QTE_INTERVAL), System.Action(arg_18_0)).uniqueId)
		end)
	end

	seriesAsync(var_17_0, function()
		self:EndQTE()
	end)
	self.speedComp:SetTimelineSpeed(SlideConst.QTE_SLOW_SPEED)
end

function Dorm3dSlideScene:EndQTE()
	self.speedComp:SetTimelineSpeed(1)

	self.catchSuccess = true

	for iter_22_0 = 1, SlideConst.QTE_COUNT do
		if not self.resultList[iter_22_0] then
			self.catchSuccess = false

			break
		end
	end

	setActive(self.endUI, true)
	setActive(self.endUI:Find("Title/Victory"), self.catchSuccess)
	setActive(self.endUI:Find("Title/Defeat"), not self.catchSuccess)
	onDelayTick(function()
		quickPlayAnimation(self.endUI, "Anim_Dorm3d_volleyball_end_out")
		onDelayTick(function()
			setActive(self.endUI, false)
		end, 0.1)
	end, 1.167)
end

function Dorm3dSlideScene:StartGame()
	seriesAsync({
		function(arg_26_0)
			self:PlayTimeline(self.gameConfig.perform_ready, arg_26_0)
		end,
		function(arg_27_0)
			self:PlayTimeline(self.gameConfig.perform_down, arg_27_0)
		end,
		function(arg_28_0)
			self:PlayTimeline(self.gameConfig.perform_catch, arg_28_0)
		end,
		function(arg_29_0)
			if self.catchSuccess then
				self:PlayTimeline(self.gameConfig.perform_success, arg_29_0)
			else
				self:PlayTimeline(self.gameConfig.perform_fail, arg_29_0)
			end
		end
	}, function()
		self:emit(Dorm3dSlideScene.ON_BACK)
	end)
end

function Dorm3dSlideScene:PlayTimeline(arg_31_1, arg_31_2)
	local var_31_0 = self.timelineDic[arg_31_1].director

	GetOrAddComponent(self.timelineDic[arg_31_1].seq, "DftCommonSignalReceiver"):SetCommonEvent(function(arg_32_0)
		switch(arg_32_0.stringParameter, {
			PrepareQTE = function()
				self:ShowCountDown()
			end,
			StartQTE = function()
				self:StartQTE()
			end,
			TimelineEnd = function()
				var_31_0:Stop()
				existCall(arg_31_2)
			end,
			Vibrate = function()
				return
			end
		}, function()
			warning("other event trigger:" .. arg_32_0.stringParameter)
		end)
	end)
	self.timelineDic[arg_31_1].director:Play()
end

function Dorm3dSlideScene:willExit()
	for iter_38_0, iter_38_1 in ipairs(self.ltList) do
		if LeanTween.isTweening(iter_38_1) then
			LeanTween.cancel(iter_38_1)
		end
	end

	for iter_38_2, iter_38_3 in pairs(self.timerList) do
		iter_38_3:Stop()
	end

	seriesAsync(underscore.map(self.sceneInfo, function(arg_39_0)
		return function(arg_40_0)
			SceneOpMgr.Inst:UnloadSceneAsync(arg_39_0.path, arg_39_0.name, arg_40_0)
		end
	end), function()
		return
	end)
end

return Dorm3dSlideScene
