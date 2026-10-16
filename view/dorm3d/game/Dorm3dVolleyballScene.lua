local Dorm3dVolleyballScene = class("Dorm3dVolleyballScene", import("view.dorm3d.Game.Dorm3dGameTemplate"))
local var_0_1 = "ui-dorm_countdown"
local var_0_2 = "ui-dorm_qte_appear"
local var_0_3 = "ui-dorm_qte_hit"
local var_0_4 = "ui-dorm_qte_citical"
local var_0_5 = "ui-dorm_qte_miss"
local var_0_6 = "ui-dorm_scoring"
local var_0_7 = "ui-dorm_victory"
local var_0_8 = "ui-dorm_pop_up"

Dorm3dVolleyballScene.QTE_RESULT = {
	MISS = "Miss",
	PERFECT = "Critical",
	HIT = "Hit"
}
Dorm3dVolleyballScene.ROUND_RESULT = {
	OUR_WIN = 1,
	OTHER_WIN = 2
}
Dorm3dVolleyballScene.GAME_RESULT = {
	DEFEAT = 2,
	VICTORY = 1
}
Dorm3dVolleyballScene.hitRadiusMax = 231
Dorm3dVolleyballScene.hitRadiusMin = 50
Dorm3dVolleyballScene.perfectRadiusMax = 139
Dorm3dVolleyballScene.perfectRadiusMin = 85
Dorm3dVolleyballScene.perfectScaleRandoms = {
	0.7,
	1.7
}
Dorm3dVolleyballScene.triggerRadius = 255
Dorm3dVolleyballScene.endScore = 6
Dorm3dVolleyballScene.BallInitPos = Vector3(22, 4.5, -22.4)
Dorm3dVolleyballScene.BallSpeed = 0.1
Dorm3dVolleyballScene.BallQTESpeed = 0.01
Dorm3dVolleyballScene.BallRandomDelat = {
	Top = 300,
	Left = 300,
	Bottom = 300,
	Right = 300
}

function Dorm3dVolleyballScene:getUIName()
	return "Dorm3dVolleyballUI"
end

function Dorm3dVolleyballScene:getResource()
	local var_2_0 = Dorm3dVolleyballScene.super.getResource(self)

	table.insert(var_2_0, string.lower("dorm3d/scenesres/scenes/" .. "beach" .. "/" .. "map_beach_01" .. "_scene"))
	table.insert(var_2_0, string.lower("dorm3d/character/" .. pg.dorm3d_dorm_template[self.contextData.groupId].asset_name .. "/timeline/" .. pg.dorm3d_volleyball[self.contextData.groupId].scene_name .. "/" .. pg.dorm3d_volleyball[self.contextData.groupId].scene_name .. "_scene"))

	return var_2_0
end

function Dorm3dVolleyballScene:Ctor(...)
	Dorm3dVolleyballScene.super.Ctor(self, ...)

	self.loader = AutoLoader.New()
end

function Dorm3dVolleyballScene:preload(arg_4_1)
	self:SetApartment(getProxy(ApartmentProxy):getApartment(self.contextData.groupId))

	self.volleyballCfg = pg.dorm3d_volleyball[self.contextData.groupId]
	self.sceneRootName = "beach"
	self.sceneName = "map_beach_01"
	self.timelineSceneRootName = pg.dorm3d_dorm_template[self.contextData.groupId].asset_name
	self.timelineSceneName = self.volleyballCfg.scene_name

	seriesAsync({
		function(arg_5_0)
			SceneOpMgr.Inst:LoadSceneAsync(string.lower("dorm3d/scenesres/scenes/" .. self.sceneRootName .. "/" .. self.sceneName .. "_scene"), self.sceneName, LoadSceneMode.Additive, function(arg_6_0, arg_6_1)
				self:InitGameParam()
				SceneManager.SetActiveScene(arg_6_0)
				arg_5_0()
			end)
		end,
		function(arg_7_0)
			SceneOpMgr.Inst:LoadSceneAsync(string.lower("dorm3d/character/" .. self.timelineSceneRootName .. "/timeline/" .. self.timelineSceneName .. "/" .. self.timelineSceneName .. "_scene"), self.timelineSceneName, LoadSceneMode.Additive, function(arg_8_0, arg_8_1)
				arg_7_0()
			end)
		end
	}, arg_4_1)
end

function Dorm3dVolleyballScene:InitGameParam()
	Dorm3dVolleyballScene.BallSpeed = self.volleyballCfg.BallSpeedParam[1]
	Dorm3dVolleyballScene.BallQTESpeed = self.volleyballCfg.BallSpeedParam[2]
	Dorm3dVolleyballScene.endScore = self.volleyballCfg.endScore
end

function Dorm3dVolleyballScene:init()
	self:initUI()
	self:initScene()
	self:BindEvent()

	local var_10_0 = Dorm3dHxHelper.GetTimelineMainCharacter()

	Dorm3dHxHelper.ReplaceCharacterParts(var_10_0)
	Dorm3dHxHelper.HideCharacterPart(var_10_0, nil, true)
	Dorm3dHxHelper.ShowHolyLight({
		var_10_0
	}, self.holyLightRoot)
end

function Dorm3dVolleyballScene:initUI()
	self.skipUI = self._tf:Find("SkipUI")

	setActive(self.skipUI, false)

	self.gameUI = self._tf:Find("GameUI")

	setText(self.gameUI:Find("Title/Text"), i18n("dorm3d_volleyball_title"))

	self.ourScoreTF = self.gameUI:Find("Score/Content/Left")
	self.otherScoreTF = self.gameUI:Find("Score/Content/Right")
	self.qteTF = self.gameUI:Find("QTE")
	self.qteTriggerTF = self.gameUI:Find("QTE/animroot/Trigger")

	setActive(self.qteTF, false)
	setActive(self.gameUI, false)
	self.gameUI:Find("Count"):GetComponent(typeof(DftAniEvent)):SetEndEvent(function()
		if not self.isStartGame then
			return
		end

		self.isStartGame = false

		setActive(self.gameUI:Find("Count"), false)
		self:StartOneRound()
		setActive(self.gameUI:Find("Score"), true)
	end)

	self.scoreUI = self._tf:Find("ScoreUI")

	setActive(self.scoreUI, false)

	self.endUI = self._tf:Find("EndUI")

	setActive(self.endUI, false)

	self.resultUI = self._tf:Find("ResultUI")

	setActive(self.resultUI, false)
	setText(self.resultUI:Find("AgainBtn/Text"), i18n("dorm3d_minigame_again"))
	setText(self.resultUI:Find("CloseBtn/Text"), i18n("dorm3d_minigame_close"))
	self.scoreUI:GetComponent(typeof(DftAniEvent)):SetEndEvent(function()
		if not self.isEndOneRound then
			return
		end

		self.isEndOneRound = false

		quickPlayAnimation(self.scoreUI, "Anim_Dorm3d_volleyball_score_out")
		onDelayTick(function()
			setActive(self.scoreUI, false)
		end, 0.1)

		if self:CheckEndGame() then
			self:EndGame()
		else
			setActive(self.gameUI, true)
			self:StartOneRound()
		end
	end)

	local var_11_0 = self._tf:Find("Debug")

	setActive(var_11_0, false)

	self.debugTimelineName = var_11_0:Find("Timeline"):GetComponent(typeof(Text))
	self.debugTrackName = var_11_0:Find("Track"):GetComponent(typeof(Text))
	self.holyLightRoot = self._tf:Find("HolyLightRoot")
end

function Dorm3dVolleyballScene:BindEvent()
	onButton(self, self.gameUI:Find("Title/BackBtn"), function()
		self:onBackPressed()
	end, SFX_CANCEL)
	onButton(self, self.gameUI, function()
		if not self.startQTEUI then
			return
		end

		self:EndQTE()
	end)
	onButton(self, self.skipUI:Find("SkipBtn"), function()
		setActive(self.skipUI, false)
		self:StopPlayingTimeline()
		self:StartGame()
	end, SFX_PANEL)
	onButton(self, self.endUI, function()
		self:emit(Dorm3dGameMediatorTemplate.TRIGGER_FAVOR, self.apartment.configId)
	end, SFX_PANEL)
	onButton(self, self.resultUI:Find("AgainBtn"), function()
		setActive(self.resultUI, false)
		self:StartGame()
	end, SFX_PANEL)
	onButton(self, self.resultUI:Find("CloseBtn"), function()
		self:closeView()
	end, SFX_CANCEL)
end

function Dorm3dVolleyballScene:initScene()
	table.IpairsCArray(SceneManager.GetSceneByName(self.sceneName):GetRootGameObjects(), function(arg_23_0, arg_23_1)
		if arg_23_1.name == "[MainBlock]" then
			self.modelRoot = tf(arg_23_1):Find("[Model]/scene_root")
			self.ballTF = self.modelRoot:Find("fbx/litmap05/pre_db_sportinggoods03")
			self.ballTF.position = Dorm3dVolleyballScene.BallInitPos

			setActive(self.ballTF, false)
		elseif arg_23_1.name == "MainCamera" then
			self.mainCamera = arg_23_1.transform

			setActive(self.mainCamera, false)
		elseif arg_23_1.name == "PlayerCamera" then
			self.ballCamera = arg_23_1.transform
			self.ballCameraComp = self.ballCamera:GetComponent(typeof(Camera))

			setActive(self.ballCamera, false)
		elseif arg_23_1.name == "TriggerPlane" then
			setActive(arg_23_1, false)

			local var_23_0 = tf(arg_23_1):Find("BallCreate")
			local var_23_1 = var_23_0:GetComponent(typeof(UnityEngine.MeshCollider)).sharedMesh

			self.ballCreatePlane = Plane.New(var_23_1.normals[0], -Vector3.Dot(var_23_0.position, var_23_1.normals[0]))

			local var_23_2 = tf(arg_23_1):Find("BallQte")

			setLocalPosition(var_23_2, Vector3(self.volleyballCfg.BallQtePlane[1][1], self.volleyballCfg.BallQtePlane[1][2], self.volleyballCfg.BallQtePlane[1][3]))
			setLocalEulerAngles(var_23_2, Vector3(self.volleyballCfg.BallQtePlane[2][1], self.volleyballCfg.BallQtePlane[2][2], self.volleyballCfg.BallQtePlane[2][3]))

			local var_23_3 = var_23_2:GetComponent(typeof(UnityEngine.MeshCollider)).sharedMesh

			self.ballQtePlane = Plane.New(var_23_3.normals[0], -Vector3.Dot(var_23_2.position, var_23_3.normals[0]))

			local var_23_4 = tf(arg_23_1):Find("BallMiss")

			setLocalPosition(var_23_4, Vector3(self.volleyballCfg.BallMissPlane[1][1], self.volleyballCfg.BallMissPlane[1][2], self.volleyballCfg.BallMissPlane[1][3]))
			setLocalEulerAngles(var_23_4, Vector3(self.volleyballCfg.BallMissPlane[2][1], self.volleyballCfg.BallMissPlane[2][2], self.volleyballCfg.BallMissPlane[2][3]))

			local var_23_5 = var_23_4:GetComponent(typeof(UnityEngine.MeshCollider)).sharedMesh

			self.ballMissPlane = Plane.New(var_23_5.normals[0], -Vector3.Dot(var_23_4.position, var_23_5.normals[0]))
		end
	end)
	self:InitLightSettings()

	self.totalDirectorList = {}

	table.IpairsCArray(SceneManager.GetSceneByName(self.timelineSceneName):GetRootGameObjects(), function(arg_24_0, arg_24_1)
		local var_24_0 = tf(arg_24_1):Find("[sequence]")

		if IsNil(var_24_0) then
			return
		end

		local var_24_1 = var_24_0:GetComponent(typeof(UnityEngine.Playables.PlayableDirector))

		var_24_1.playOnAwake = false

		var_24_1:Stop()

		for iter_24_0, iter_24_1 in ipairs((var_24_0:GetComponentsInChildren(typeof(UnityEngine.Playables.PlayableDirector)):ToTable())) do
			iter_24_1.playOnAwake = false

			iter_24_1:Stop()
		end

		table.insert(self.totalDirectorList, {
			name = arg_24_1.name,
			director = var_24_1
		})
		setActive(arg_24_1, false)
	end)
end

function Dorm3dVolleyballScene:InitLightSettings()
	self.globalVolume = GameObject.Find("GlobalVolume")
	self.characterLight = GameObject.Find("CharacterLight")

	table.IpairsCArray(GameObject.Find("[Lighting]").transform:GetComponentsInChildren(typeof(Light)), function(arg_26_0, arg_26_1)
		arg_26_1.shadows = UnityEngine.LightShadows.None
	end)
end

function Dorm3dVolleyballScene:didEnter()
	self:InitData()
	setActive(self.skipUI, true)
	self:PlayTimeline({
		name = self:GetWeightTimeline("jinchang")
	}, function()
		if not self.playingFlag then
			setActive(self.skipUI, false)
			self:StartGame()
		end
	end)
end

function Dorm3dVolleyballScene:InitData()
	return
end

function Dorm3dVolleyballScene:PlayTimeline(arg_30_1, arg_30_2)
	local var_30_0 = arg_30_1.name
	local var_30_2 = _.detect(self.totalDirectorList, function(arg_31_0)
		return arg_31_0.name == var_30_0
	end)

	assert(var_30_2, "Missing director " .. arg_30_1.name)
	self:StopPlayingTimeline(tobool(var_30_2))

	if not var_30_2 then
		existCall(arg_30_2)

		return
	end

	local var_30_3 = {}

	self.playingDirector = var_30_2.director

	local var_30_4 = self.playingDirector.transform

	self.debugTimelineName.text = self.playingDirector.transform.parent.name

	table.insert(var_30_3, function(arg_32_0)
		if arg_30_1.time then
			self.playingDirector.time = math.clamp(arg_30_1.time, 0, self.playingDirector.duration)
		end

		TimelineSupport.InitTimeline(self.playingDirector)

		local var_32_0 = {}

		GetOrAddComponent(var_30_4, "DftCommonSignalReceiver"):SetCommonEvent(function(arg_33_0)
			switch(arg_33_0.stringParameter, {
				TimelineRandomTrack = function()
					self:DoTimelineRandomTrack(self.playingDirector)
				end,
				TimelineLoop = function()
					self.playingDirector.time = arg_33_0.floatParameter
				end,
				TimelineEnd = function()
					var_32_0.finish = true

					self.playingDirector:Stop()
					setActive(tf(self.playingDirector).parent, false)
				end
			}, function()
				warning("other event trigger:" .. arg_33_0.stringParameter)
			end)

			if var_32_0.finish then
				self.timelineMark = var_32_0
				self.debugTimelineName.text = ""
				self.debugTrackName.text = ""

				arg_32_0()
			end
		end)
		self.playingDirector:Evaluate()
		self:DoTimelineRandomTrack(self.playingDirector)
		setActive(tf(self.playingDirector).parent, true)
		self.playingDirector:Play()
		setActive(self.mainCamera, false)

		if self.activeDirectorInfo then
			self.lastDirectorInfo = self.activeDirectorInfo
		end

		self.activeDirectorInfo = var_30_2
	end)
	seriesAsync(var_30_3, function()
		setActive(self.mainCamera, true)

		self.playingDirector = nil
		self.timelineMark = nil

		existCall(arg_30_2, self.timelineMark)
	end)
end

function Dorm3dVolleyballScene:StopPlayingTimeline(arg_39_1)
	if self.playingDirector then
		self.playingDirector:Stop()
		setActive(tf(self.playingDirector).parent, false)

		self.debugTimelineName.text = ""
		self.debugTrackName.text = ""
		self.playingDirector = nil

		if not arg_39_1 then
			setActive(self.mainCamera, true)
		end
	end
end

function Dorm3dVolleyballScene:StartGame()
	setActive(self.mainCamera, true)

	self.playingFlag = true
	self.gameResult = nil
	self.ourScore, self.otherScore = 0, 0

	setActive(self.gameUI, true)
	setActive(self.gameUI:Find("Score"), false)
	setActive(self.gameUI:Find("Count"), true)

	self.isStartGame = true

	pg.CriMgr.GetInstance():PlaySE_V3(var_0_1)
end

function Dorm3dVolleyballScene:UpdateGameScore()
	setText(self.ourScoreTF, self.ourScore)
	setText(self.otherScoreTF, self.otherScore)
end

function Dorm3dVolleyballScene:UpdateScoreTpl(arg_42_1)
	setText(arg_42_1:Find("Left/Tens/Text"), 0)
	setText(arg_42_1:Find("Left/Units/Text"), self.ourScore % 10)
	setText(arg_42_1:Find("Right/Tens/Text"), 0)
	setText(arg_42_1:Find("Right/Units/Text"), self.otherScore % 10)
end

function Dorm3dVolleyballScene:StartOneRound()
	self:UpdateGameScore()

	self.roundEndFlag = false
	self.roundResult = nil

	seriesAsync({
		function(arg_44_0)
			self:FaQiuOP(arg_44_0)
		end,
		function(arg_45_0)
			self:OneQTE()
		end
	})
end

function Dorm3dVolleyballScene:OneQTE()
	seriesAsync({
		function(arg_47_0)
			self:StartQTE(arg_47_0)
		end,
		function(arg_48_0)
			switch(self.qteResult, {
				[Dorm3dVolleyballScene.QTE_RESULT.MISS] = function()
					self:QteMissOP(function()
						self.roundEndFlag = true
						self.roundResult = Dorm3dVolleyballScene.ROUND_RESULT.OTHER_WIN

						arg_48_0()
					end)
				end,
				[Dorm3dVolleyballScene.QTE_RESULT.HIT] = function()
					self:QteHitOP(arg_48_0)
				end,
				[Dorm3dVolleyballScene.QTE_RESULT.PERFECT] = function()
					self:QtePerfectOP(function()
						self.roundEndFlag = true
						self.roundResult = Dorm3dVolleyballScene.ROUND_RESULT.OUR_WIN

						arg_48_0()
					end)
				end
			}, function()
				assert(false, "unknow qte result" .. self.qteResult)
			end)
		end
	}, function()
		if not self.roundEndFlag then
			self:OneQTE()
		else
			self:EndOneRound()
		end
	end)
end

function Dorm3dVolleyballScene:EndOneRound()
	pg.CriMgr.GetInstance():PlaySE_V3(var_0_6)

	self.isEndOneRound = true

	setActive(self.gameUI, false)
	self:UpdateScoreTpl(self.scoreUI:Find("ScoreTpl"))
	setText(self.scoreUI:Find("ScoreTpl/Left/Units/new/newText"), self.ourScore % 10)
	setText(self.scoreUI:Find("ScoreTpl/Right/Units/new/newText"), self.otherScore % 10)
	switch(self.roundResult, {
		[Dorm3dVolleyballScene.ROUND_RESULT.OUR_WIN] = function()
			self.ourScore = self.ourScore + 1

			setText(self.scoreUI:Find("ScoreTpl/Left/Units/new/newText"), self.ourScore % 10)
			setActive(self.scoreUI, true)
			quickPlayAnimation(self.scoreUI, "Anim_Dorm3d_volleyball_score_leftin")
		end,
		[Dorm3dVolleyballScene.ROUND_RESULT.OTHER_WIN] = function()
			self.otherScore = self.otherScore + 1

			setText(self.scoreUI:Find("ScoreTpl/Right/Units/new/newText"), self.otherScore % 10)
			setActive(self.scoreUI, true)
			quickPlayAnimation(self.scoreUI, "Anim_Dorm3d_volleyball_score_rightin")
		end
	}, function()
		assert(false, "unknow round result" .. self.roundResult)
	end)
end

function Dorm3dVolleyballScene:CheckEndGame()
	if self.ourScore >= Dorm3dVolleyballScene.endScore then
		self.gameResult = Dorm3dVolleyballScene.GAME_RESULT.VICTORY

		return true
	end

	if self.otherScore >= Dorm3dVolleyballScene.endScore then
		self.gameResult = Dorm3dVolleyballScene.GAME_RESULT.DEFEAT

		return true
	end

	return false
end

function Dorm3dVolleyballScene:EndGame()
	if self.gameResult == Dorm3dVolleyballScene.GAME_RESULT.VICTORY then
		pg.CriMgr.GetInstance():PlaySE_V3(var_0_7)
	end

	seriesAsync({
		function(arg_62_0)
			self:PlayTimeline({
				name = self:GetWeightTimeline(self.gameResult == Dorm3dVolleyballScene.GAME_RESULT.VICTORY and "shibai" or "shengli")
			}, arg_62_0)
		end
	}, function()
		self:PlayTimeline({
			name = self:GetWeightTimeline("daiji")
		}, function()
			return
		end)
		setActive(self.endUI, true)
		setActive(self.endUI:Find("Title/Victory"), self.gameResult == Dorm3dVolleyballScene.GAME_RESULT.VICTORY)
		setActive(self.endUI:Find("Title/Defeat"), self.gameResult == Dorm3dVolleyballScene.GAME_RESULT.DEFEAT)
		self:UpdateScoreTpl(self.endUI:Find("ScoreTpl"))
	end)
end

function Dorm3dVolleyballScene:ShowResultUI(arg_65_1)
	(function()
		pg.m02:sendNotification(GAME.APARTMENT_TRACK, Dorm3dTrackCommand.BuildDataRoom(self.contextData.roomId, 8, table.concat(self.contextData.groupIds or {
			self.contextData.groupId
		}, ","), self.ourScore .. ":" .. self.otherScore))
	end)()
	pg.CriMgr.GetInstance():PlaySE_V3(var_0_8)
	seriesAsync({
		function(arg_67_0)
			quickPlayAnimation(self.endUI, "Anim_Dorm3d_volleyball_end_out")
			onDelayTick(function()
				setActive(self.endUI, false)
			end, 0.1)

			if self.gameResult == Dorm3dVolleyballScene.GAME_RESULT.VICTORY then
				self:PlayTimeline({
					name = self:GetWeightTimeline("jiangli")
				}, arg_67_0)
			else
				self:StopPlayingTimeline()
				arg_67_0()
			end
		end
	}, function()
		setActive(self.resultUI, true)
		setText(self.resultUI:Find("Panel/Text"), i18n("volleyball_end_tip", self.apartment:getConfig("name")))

		if arg_65_1 and arg_65_1.cost > 0 then
			setActive(self.resultUI:Find("Panel/Award"), true)
			setText(self.resultUI:Find("Panel/Award/Text"), i18n("volleyball_end_award", self.apartment:getConfig("name")))
		else
			setActive(self.resultUI:Find("Panel/Award"), false)
		end

		gcAll()
	end)
end

function Dorm3dVolleyballScene:FaQiuOP(arg_70_1)
	self:PlayTimeline({
		name = self:GetWeightTimeline("faqiu")
	}, arg_70_1)
end

function Dorm3dVolleyballScene:StartQTE(arg_71_1)
	self.qteCallback = arg_71_1

	setActive(self.ballCamera, true)
	setActive(self.mainCamera, false)

	self.randomScreenPos = Vector2(math.random(Dorm3dVolleyballScene.BallRandomDelat.Left, Screen.width - Dorm3dVolleyballScene.BallRandomDelat.Right), math.random(Dorm3dVolleyballScene.BallRandomDelat.Bottom, Screen.height - Dorm3dVolleyballScene.BallRandomDelat.Top))

	local var_71_0 = self.ballCameraComp:ScreenPointToRay(self.randomScreenPos)

	self.randomScale = math.random(Dorm3dVolleyballScene.perfectScaleRandoms[1] * 10, self.perfectScaleRandoms[2] * 10) / 10

	local var_71_1, var_71_2 = Plane.New(self.ballQtePlane.normal, self.ballQtePlane.distance + (self.ballMissPlane.distance - self.ballQtePlane.distance) * (1 - (Dorm3dVolleyballScene.perfectRadiusMax + Dorm3dVolleyballScene.perfectRadiusMin) / 2 * self.randomScale / Dorm3dVolleyballScene.triggerRadius)):Raycast(var_71_0)

	assert(var_71_1, "retPerfect plane not in view")

	self.ballDir = (var_71_0:GetPoint(var_71_2) - Dorm3dVolleyballScene.BallInitPos):Normalize()

	local var_71_3 = Ray.New(self.ballDir, Dorm3dVolleyballScene.BallInitPos)
	local var_71_4, var_71_5 = self.ballQtePlane:Raycast(var_71_3)

	assert(var_71_4, "qte plane not in view")

	local var_71_6, var_71_7 = self.ballMissPlane:Raycast(var_71_3)

	assert(var_71_6, "miss plane not in view")

	local var_71_8 = 0

	self.qteUITime = (var_71_3:GetPoint(var_71_5) - var_71_3:GetPoint(var_71_7)):Magnitude() / Dorm3dVolleyballScene.BallQTESpeed
	self.ballTimer = Timer.New(function()
		if var_71_8 >= var_71_7 then
			self.ballTimer:Stop()

			self.ballTimer = nil

			setActive(self.ballTF, false)

			self.ballTF.position = Dorm3dVolleyballScene.BallInitPos

			if self.startQTEUI then
				setLocalScale(self.qteTriggerTF, {
					x = 0,
					y = 0
				})
				self:EndQTE(Dorm3dVolleyballScene.QTE_RESULT.MISS)
			end
		elseif var_71_8 >= var_71_5 then
			var_71_8 = var_71_8 + Dorm3dVolleyballScene.BallQTESpeed
			self.ballTF.position = var_71_3:GetPoint(var_71_8)

			if not self.startQTEUI then
				self:StartQTEUI()
			end

			self.curScale = self.curScale - 1 / self.qteUITime

			setLocalScale(self.qteTriggerTF, {
				x = self.curScale,
				y = self.curScale
			})

			self.curRadius = Dorm3dVolleyballScene.triggerRadius * self.curScale

			if self.curScale < 0 then
				self:EndQTE()
			end
		else
			var_71_8 = var_71_8 + Dorm3dVolleyballScene.BallSpeed
			self.ballTF.position = var_71_3:GetPoint(var_71_8)
		end
	end, 0.016666666666666666, -1)

	setActive(self.ballTF, true)
	self.ballTimer:Start()
end

function Dorm3dVolleyballScene:StartQTEUI()
	pg.CriMgr.GetInstance():PlaySE_V3(var_0_2)
	setLocalScale(self.qteTriggerTF, {
		x = 1,
		y = 1
	})
	eachChild(self.qteTF:Find("animroot/Result"), function(arg_74_0)
		setActive(arg_74_0, false)
	end)

	self.qteResult = nil
	self.curRadius = Dorm3dVolleyballScene.triggerRadius
	self.curPerfectRadiusMax = Dorm3dVolleyballScene.perfectRadiusMax * self.randomScale
	self.curPerfectRadiusMin = Dorm3dVolleyballScene.perfectRadiusMin * self.randomScale

	setLocalScale(self.qteTF:Find("animroot/Perfect"), {
		x = self.randomScale,
		y = self.randomScale
	})

	self.curScale = 1

	setLocalPosition(self.qteTF, LuaHelper.ScreenToLocal(self.qteTF.parent, self.randomScreenPos, pg.UIMgr.GetInstance().uiCameraComp))
	setActive(self.qteTF, true)

	self.startQTEUI = true
end

function Dorm3dVolleyballScene:EndQTE(arg_75_1)
	self.startQTEUI = nil

	setActive(self.mainCamera, true)
	setActive(self.ballCamera, false)

	self.qteResult = arg_75_1 and arg_75_1 or (self.curRadius < Dorm3dVolleyballScene.hitRadiusMin or self.curRadius > Dorm3dVolleyballScene.hitRadiusMax) and Dorm3dVolleyballScene.QTE_RESULT.MISS or self.curRadius <= self.curPerfectRadiusMax and self.curRadius >= self.curPerfectRadiusMin and Dorm3dVolleyballScene.QTE_RESULT.PERFECT or Dorm3dVolleyballScene.QTE_RESULT.HIT

	eachChild(self.qteTF:Find("animroot/Result"), function(arg_76_0)
		setActive(arg_76_0, arg_76_0.name == self.qteResult)
	end)

	if self.ballTimer then
		self.ballTimer:Stop()

		self.ballTimer = nil

		setActive(self.ballTF, false)

		self.ballTF.position = Dorm3dVolleyballScene.BallInitPos
	end

	if self.qteCallback then
		self.qteCallback()

		self.qteCallback = nil
	end

	onDelayTick(function()
		setActive(self.qteTF, false)
	end, 1)
end

function Dorm3dVolleyballScene:QteMissOP(arg_78_1)
	pg.CriMgr.GetInstance():PlaySE_V3(var_0_5)
	self:PlayTimeline({
		name = self:GetWeightTimeline("shiqiu")
	}, arg_78_1)
end

function Dorm3dVolleyballScene:QteHitOP(arg_79_1)
	pg.CriMgr.GetInstance():PlaySE_V3(var_0_3)
	seriesAsync({
		function(arg_80_0)
			self:PlayTimeline({
				name = self:GetWeightTimeline("fly")
			}, arg_80_0)
		end,
		function(arg_81_0)
			self:PlayTimeline({
				name = self:GetWeightTimeline("jieqiu")
			}, arg_81_0)
		end
	}, arg_79_1)
end

function Dorm3dVolleyballScene:QtePerfectOP(arg_82_1)
	pg.CriMgr.GetInstance():PlaySE_V3(var_0_4)
	seriesAsync({
		function(arg_83_0)
			self:PlayTimeline({
				name = self:GetWeightTimeline("max_fly")
			}, arg_83_0)
		end,
		function(arg_84_0)
			self:PlayTimeline({
				name = self:GetWeightTimeline("shouji")
			}, arg_84_0)
		end
	}, arg_82_1)
end

function Dorm3dVolleyballScene:GetWeightTimeline(arg_85_1)
	local var_85_0 = self.volleyballCfg[arg_85_1]

	assert(self.volleyballCfg[arg_85_1] ~= "", "volleyball cfg is empty string" .. arg_85_1)
	assert(#var_85_0 ~= 0, "volleyball cfg is empty table:" .. arg_85_1)

	local var_85_1 = math.random() * underscore.reduce(var_85_0, 0, function(arg_86_0, arg_86_1)
		return arg_86_0 + arg_86_1[2]
	end)
	local var_85_2 = 0

	for iter_85_0, iter_85_1 in ipairs(var_85_0) do
		var_85_2 = var_85_2 + iter_85_1[2]

		if var_85_1 <= var_85_2 then
			return iter_85_1[1]
		end
	end
end

function Dorm3dVolleyballScene:DoTimelineRandomTrack(arg_87_1)
	local var_87_0 = {}

	for iter_87_0, iter_87_1 in ipairs(TimelineHelper.GetTimelineTracks(arg_87_1):ToTable()) do
		if iter_87_1.name ~= "Markers" then
			iter_87_1.muted = true

			table.insert(var_87_0, iter_87_1)
		end
	end

	if #var_87_0 > 0 then
		local var_87_1 = var_87_0[math.random(#var_87_0)]

		underscore.each(var_87_0, function(arg_88_0)
			if arg_88_0.name == var_87_1.name then
				arg_88_0.muted = false
			end
		end)

		self.debugTrackName.text = var_87_1.name
	else
		self.debugTrackName.text = "track cnt 0"
	end
end

function Dorm3dVolleyballScene:OnPause()
	if self.ballTimer then
		self.ballTimer:Stop()
	end

	if self.playingDirector then
		self.playingDirector:Pause()
	end
end

function Dorm3dVolleyballScene:OnResume()
	if self.ballTimer then
		self.ballTimer:Start()
	end

	if self.playingDirector then
		self.playingDirector:Play()
	end
end

function Dorm3dVolleyballScene:onBackPressed()
	if not self.playingFlag or isActive(self.gameUI:Find("Count")) or isActive(self.endUI) then
		return
	end

	self:OnPause()
	pg.NewStyleMsgboxMgr.GetInstance():Show(pg.NewStyleMsgboxMgr.TYPE_MSGBOX, {
		contentText = i18n("sure_exit_volleyball"),
		onConfirm = function()
			self:emit(Dorm3dVolleyballScene.ON_BACK)
		end,
		onClose = function()
			self:OnResume()
		end
	})
end

function Dorm3dVolleyballScene:willExit()
	self.loader:Clear()

	if self.ballTimer then
		self.ballTimer:Stop()

		self.ballTimer = nil
	end

	seriesAsync(underscore.map({
		{
			path = string.lower("dorm3d/character/" .. self.timelineSceneRootName .. "/timeline/" .. self.timelineSceneName .. "/" .. self.timelineSceneName .. "_scene"),
			name = self.timelineSceneName
		},
		{
			path = string.lower("dorm3d/scenesres/scenes/common/" .. self.sceneRootName .. "/" .. self.sceneName .. "_scene"),
			name = self.sceneName
		}
	}, function(arg_95_0)
		return function(arg_96_0)
			SceneOpMgr.Inst:UnloadSceneAsync(arg_95_0.path, arg_95_0.name, arg_96_0)
		end
	end), function()
		ReflectionHelp.RefSetProperty(typeof("UnityEngine.LightmapSettings"), "lightmaps", nil, nil)
	end)
end

return Dorm3dVolleyballScene
