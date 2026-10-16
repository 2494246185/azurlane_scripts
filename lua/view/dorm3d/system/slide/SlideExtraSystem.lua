local SlideExtraSystem = class("SlideExtraSystem", import("view.dorm3d.Core.BaseSystem"))

SlideExtraSystem.SHOW_INTERACTION = "SlideExtraSystem.SHOW_INTERACTION"
SlideExtraSystem.HIDE_INTERACTION = "SlideExtraSystem.HIDE_INTERACTION"
SlideExtraSystem.SHOW_PERFORMANCE = "SlideExtraSystem.SHOW_PERFORMANCE"
SlideExtraSystem.HIDE_PERFORMANCE = "SlideExtraSystem.HIDE_PERFORMANCE"

function SlideExtraSystem:OnInit()
	self:RegisterNodeCanvas()
	self:InitScene()
	self:InitData()
	self:InitSlide()
	self:Emit(Dorm3dRoomMediator.ADD_EXTRA_SYSTEM_FURNITURE_SLIDE)

	self.pickTimer = Timer.New(function()
		self:OnPick()
	end, SlideConst.TIMER_INTERVAL, -1)

	self.pickTimer:Start()
	self:OnPick()
end

function SlideExtraSystem:RegisterEvents()
	self:Bind(FurnitureSystem.REFRESH_DONE, function()
		self:InitSlide()
	end)
end

function SlideExtraSystem:OnUpdate(arg_5_1)
	for iter_5_0, iter_5_1 in pairs(self.ladyDic) do
		iter_5_1:OnUpdate()
	end
end

function SlideExtraSystem:OnDispose()
	if self.pickTimer then
		self.pickTimer:Stop()

		self.pickTimer = nil
	end

	for iter_6_0, iter_6_1 in pairs(self.ladyDic) do
		self:RemoveLadySlide(iter_6_0)
	end

	self:Emit(Dorm3dRoomTemplateScene.EXTRA_CHANGE_PLAYER_POSITION)

	if self.slideTreeOwner then
		self.slideTreeOwner.enabled = false
	end

	if self.performanceTreeOwner then
		self.performanceTreeOwner.enabled = false
	end

	pg.NodeCanvasMgr.GetInstance():UnregisterFunc("Slide.ShowInteraction")
	pg.NodeCanvasMgr.GetInstance():UnregisterFunc("Slide.HideInteraction")
	pg.NodeCanvasMgr.GetInstance():UnregisterFunc("Slide.ShowPerformance")
	pg.NodeCanvasMgr.GetInstance():UnregisterFunc("Slide.HidePerformance")
	self:Emit(Dorm3dRoomMediator.REMOVE_EXTRA_SYSTEM, FurnitureSlideExtraMediator)
end

function SlideExtraSystem:OnHandleNotification(arg_7_1, arg_7_2)
	if arg_7_1 == ApartmentProxy.UPDATE_SLIDE_INVITE_LIST then
		self:UpdateSlideInviteList(arg_7_2.addIds, arg_7_2.removeIds)
	end
end

function SlideExtraSystem.GetInterests()
	return {
		ApartmentProxy.UPDATE_SLIDE_INVITE_LIST
	}
end

function SlideExtraSystem:IsOpen()
	return self:GetConfigID() == SlideConst.ROOM_ID and self:IsFurnitureSetIn(SlideConst.FURNITURE_ID)
end

function SlideExtraSystem:RegisterNodeCanvas()
	pg.NodeCanvasMgr.GetInstance():RegisterFunc("Slide.ShowInteraction", function()
		pg.m02:sendNotification(SlideExtraSystem.SHOW_INTERACTION)
	end)
	pg.NodeCanvasMgr.GetInstance():RegisterFunc("Slide.HideInteraction", function()
		pg.m02:sendNotification(SlideExtraSystem.HIDE_INTERACTION)
	end)
	pg.NodeCanvasMgr.GetInstance():RegisterFunc("Slide.ShowPerformance", function()
		pg.m02:sendNotification(SlideExtraSystem.SHOW_PERFORMANCE)
	end)
	pg.NodeCanvasMgr.GetInstance():RegisterFunc("Slide.HidePerformance", function()
		pg.m02:sendNotification(SlideExtraSystem.HIDE_PERFORMANCE)
	end)
end

function SlideExtraSystem:InitScene()
	self.sceneSlideConfigs = GameObject.Find("SlideConfigs").transform
	self.movePointsRoot = self.sceneSlideConfigs:Find("MovePoints")
	self.defaultPointsRoot = self.sceneSlideConfigs:Find("DefaultPoints")
end

function SlideExtraSystem:InitSlide()
	warning("SystemInitSlide")

	if self.slideInited then
		return
	end

	self.slideInited = true
	self.slideGo = self:GetSceneItem("FurnitureSlots/140101/Slide(Clone)")

	if not self.slideGo then
		self.slideInited = nil

		return
	end

	warning("InitSlide Done")

	self.slideTreeOwner = GetOrAddComponent(self.slideGo, typeof(NodeCanvas.BehaviourTrees.BehaviourTreeOwner))

	self.slideTreeOwner.graph.blackboard:AddVariable("_player", go(self:GetPlayer()))

	self.slideTreeOwner.enabled = true
	self.performanceTreeOwner = GetOrAddComponent(self.slideGo:Find("performance_interact_point"), typeof(NodeCanvas.BehaviourTrees.BehaviourTreeOwner))

	self.performanceTreeOwner.graph.blackboard:AddVariable("_player", go(self:GetPlayer()))

	self.performanceTreeOwner.enabled = true
end

function SlideExtraSystem:InitData()
	self.commandConfigDic = {}
	self.defaultPoints = {}

	_.each(pg.dorm3d_minigame_slide.all, function(arg_18_0)
		self.commandConfigDic[arg_18_0] = {}

		_.each(pg.dorm3d_minigame_slide[arg_18_0].slide_command, function(arg_19_0)
			table.insert(self.commandConfigDic[arg_18_0], SlideCommand.New(arg_19_0, self.movePointsRoot))
		end)

		self.defaultPoints[arg_18_0] = self.defaultPointsRoot:Find(pg.dorm3d_minigame_slide[arg_18_0].slide_zone)
	end)

	self.inviteList = getProxy(ApartmentProxy):GetSlideInviteList()
	self.randomList = Clone(self.inviteList)
	self.ladyDic = {}

	_.each(self.inviteList, function(arg_20_0)
		self:AddLadySlide(arg_20_0)
	end)
end

function SlideExtraSystem:AddLadySlide(arg_21_1)
	self.ladyDic[arg_21_1] = LadySlide.New(arg_21_1, self:GetLadyDict()[arg_21_1], self.commandConfigDic[arg_21_1], self.defaultPoints[arg_21_1], function(arg_22_0)
		self:PlayVFX(arg_22_0)
	end)

	self.ladyDic[arg_21_1]:Reset()
end

function SlideExtraSystem:RemoveLadySlide(arg_23_1)
	if self.ladyDic[arg_23_1] then
		self:Emit(Dorm3dRoomTemplateScene.EXTRA_CHANGE_CHARACTER_POSITION, self.ladyDic[arg_23_1].ladyEnv)
		self.ladyDic[arg_23_1].ladyEnv:PlaySingleAction(SlideConst.IDLE_ANIM)
		self.ladyDic[arg_23_1]:Dispose()

		self.ladyDic[arg_23_1] = nil
	end
end

function SlideExtraSystem:OnPick()
	if #self.inviteList == 0 then
		return
	end

	self.currentGroupId = self:RandomPick()

	if self.ladyDic[self.currentGroupId].ladyEnv:GetBlackboardValue("inWatchMode") then
		if #self.inviteList > 1 then
			self:OnPick()
		end

		return
	end

	self.ladyDic[self.currentGroupId]:StartMove()
end

function SlideExtraSystem:RandomPick()
	if not self.randomList or #self.randomList == 0 then
		self.randomList = Clone(self.inviteList)
	end

	local var_25_0 = math.random(1, #self.randomList)

	table.remove(self.randomList, var_25_0)

	return self.randomList[var_25_0]
end

function SlideExtraSystem:TestMove()
	for iter_26_0, iter_26_1 in pairs(self.ladyDic) do
		iter_26_1:EndMove()
		iter_26_1:StartMove()

		self.currentGroupId = iter_26_1.id

		return
	end
end

function SlideExtraSystem:UpdateSlideInviteList(arg_27_1, arg_27_2)
	if table.contains(arg_27_2, self.currentGroupId) then
		self.ladyDic[self.currentGroupId]:EndMove()
	end

	_.each(arg_27_2, function(arg_28_0)
		self:RemoveLadySlide(arg_28_0)
		table.removebyvalue(self.inviteList, arg_28_0)
		table.removebyvalue(self.randomList, arg_28_0)
	end)
	_.each(arg_27_1, function(arg_29_0)
		if not table.contains(self.inviteList, arg_29_0) then
			table.insert(self.inviteList, arg_29_0)
			self:AddLadySlide(arg_29_0)
		end

		if not table.contains(self.randomList, arg_29_0) then
			table.insert(self.randomList, arg_29_0)
		end
	end)
end

function SlideExtraSystem:PlayVFX(arg_30_1)
	local var_30_0 = self.sceneSlideConfigs:Find("vfx/" .. arg_30_1)

	setActive(var_30_0, false)
	onNextTick(function()
		setActive(var_30_0, true)
	end)
end

return SlideExtraSystem
