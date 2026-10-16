local AnniversaryIsland2023Scene = class("AnniversaryIsland2023Scene", import("view.activity.BackHills.TemplateMV.BackHillTemplate"))

function AnniversaryIsland2023Scene:getUIName()
	return "AnniversaryIsland2023UI"
end

function AnniversaryIsland2023Scene:getResource()
	local var_2_0 = AnniversaryIsland2023Scene.super.getResource(self)

	table.insert(var_2_0, "ui/" .. self:getUIName() .. "_level" .. self:CalculateSceneLevel())

	return var_2_0
end

AnniversaryIsland2023Scene.edge2area = {
	default = "_SDPlace"
}
AnniversaryIsland2023Scene.Buildings = {
	[24] = "craft",
	[25] = "adventure",
	[26] = "dining",
	[23] = "living"
}

function AnniversaryIsland2023Scene:Ctor()
	AnniversaryIsland2023Scene.super.Ctor(self)

	self.loader = AutoLoader.New()
end

function AnniversaryIsland2023Scene:preload(arg_4_1)
	self.loader:LoadBundle("ui/" .. self:getUIName() .. "_level" .. self:CalculateSceneLevel(), arg_4_1)
end

function AnniversaryIsland2023Scene:init()
	self.top = self._tf:Find("top")
	self._bg = self._tf:Find("BG")
	self._map = self._tf:Find("map")

	for iter_5_0 = 0, self._map.childCount - 1 do
		local var_5_0 = self._map:GetChild(iter_5_0)

		self["map_" .. go(var_5_0).name] = var_5_0
	end

	self._upper = self._tf:Find("upper")

	for iter_5_1 = 0, self._upper.childCount - 1 do
		local var_5_1 = self._upper:GetChild(iter_5_1)

		self["upper_" .. go(var_5_1).name] = var_5_1
	end

	self._SDPlace = self._tf:Find("SDPlace")
	self.containers = {
		self._SDPlace
	}
	self._shipTpl = self._map:Find("ship")
	self.graphPath = GraphPath.New(import("GameCfg.BackHillGraphs.AnniversaryIsland2023Graph"))
end

function AnniversaryIsland2023Scene:didEnter()
	onButton(self, self._tf:Find("top/Back"), function()
		self:onBackPressed()
	end, SFX_CANCEL)
	onButton(self, self._tf:Find("top/Home"), function()
		self:emit(AnniversaryIsland2023Scene.ON_HOME)
	end, SFX_PANEL)
	onButton(self, self._tf:Find("top/Help"), function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.haidaojudian_help.tip
		})
	end, SFX_PANEL)

	local var_6_0 = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_BUILDING_BUFF_2)

	self:InitStudents(var_6_0 and var_6_0.id, 3, 4)

	for iter_6_0, iter_6_1 in pairs(self.Buildings) do
		self:InitFacilityCross(self._map, self._upper, iter_6_1, function()
			self:emit(BackHillMediatorTemplate.GO_SUBLAYER, Context.New({
				mediator = AnniversaryIslandBuildingUpgrade2023WindowMediator,
				viewComponent = AnniversaryIslandBuildingUpgrade2023Window,
				data = {
					buildingID = iter_6_0
				}
			}))
		end)
		eachChild(self._map:Find(iter_6_1), function(arg_11_0)
			GetComponent(arg_11_0, typeof(Image)).alphaHitTestMinimumThreshold = 0.5

			setActive(arg_11_0, false)
		end)
	end

	eachChild(self._map:Find("xianshijianzao"), function(arg_12_0)
		GetComponent(arg_12_0, typeof(Image)).alphaHitTestMinimumThreshold = 0.5
	end)
	eachChild(self._map:Find("huanzhuangshangdian"), function(arg_13_0)
		GetComponent(arg_13_0, typeof(Image)).alphaHitTestMinimumThreshold = 0.5
	end)
	eachChild(self._map:Find("taskboard"), function(arg_14_0)
		GetComponent(arg_14_0, typeof(Image)).alphaHitTestMinimumThreshold = 0.5
	end)

	GetComponent(self._map:Find("bigmap"), typeof(Image)).alphaHitTestMinimumThreshold = 0.5

	self:InitFacilityCross(self._map, self._upper, "craft", function()
		self:emit(BackHillMediatorTemplate.GO_SCENE, SCENE.ANNIVERSARY_ISLAND_WORKBENCH)
	end)
	self:InitFacilityCross(self._map, self._upper, "taskboard", function()
		local var_16_0 = Context.New()

		SCENE.SetSceneInfo(var_16_0, SCENE.ISLAND_TASK)
		self:emit(BackHillMediatorTemplate.GO_SUBLAYER, var_16_0)
	end)
	self:InitFacilityCross(self._map, self._upper, "bigmap", function()
		self:emit(BackHillMediatorTemplate.GO_SCENE, SCENE.ANNIVERSARY_ISLAND_SEA, {
			checkMain = true
		})
	end)
	self:InitFacilityCross(self._map, self._upper, "giftmake", function()
		self:emit(BackHillMediatorTemplate.GO_SCENE, SCENE.SCULPTURE)
	end)
	self:BindItemSkinShop()
	self:BindItemBuildShip()
	self:RegisterDataResponse()
	self:UpdateView()
end

function AnniversaryIsland2023Scene:UpdateActivity(arg_19_1)
	self:UpdateView()
end

function AnniversaryIsland2023Scene:RegisterDataResponse()
	self.Respones = ResponsableTree.CreateShell({})

	self.Respones:SetRawData("view", self)

	local var_20_0 = _.values(self.Buildings)

	for iter_20_0, iter_20_1 in ipairs(var_20_0) do
		self.Respones:AddRawListener({
			"view",
			iter_20_1
		}, function(arg_21_0, arg_21_1)
			if not arg_21_1 then
				return
			end

			setActive(arg_21_0["map_" .. iter_20_1]:Find(tostring(arg_21_1)), true)

			if arg_21_1 - 1 > 0 then
				setActive(arg_21_0["map_" .. iter_20_1]:Find(tostring(arg_21_1 - 1)), false)
			end

			local var_21_0 = arg_21_0["map_" .. iter_20_1]:Find(tostring(arg_21_1))

			arg_21_0.loader:GetSpriteQuiet("ui/" .. self:getUIName() .. "_atlas", iter_20_1 .. "_" .. arg_21_1, var_21_0, true)

			GetComponent(arg_21_0["map_" .. iter_20_1], typeof(Button)).targetGraphic = GetComponent(var_21_0, typeof(Image))

			if not arg_21_0["upper_" .. iter_20_1] or IsNil(arg_21_0["upper_" .. iter_20_1]:Find("Level")) then
				return
			end

			arg_21_0.loader:GetSpriteQuiet("ui/" .. self:getUIName() .. "_atlas", tostring(arg_21_1), arg_21_0["upper_" .. iter_20_1]:Find("Level"), true)
		end)
	end

	self.Respones:AddRawListener(_.values(self.Buildings), function(...)
		local var_22_0 = 0
		local var_22_1 = {
			...
		}

		for iter_22_0 = 1, table.getCount(self.Buildings) do
			var_22_0 = var_22_0 + (var_22_1[iter_22_0] or 1)
		end

		self.Respones.sceneLevel = math.floor(var_22_0 / 4)
	end)
	self.Respones:AddRawListener({
		"sceneLevel",
		"view"
	}, function(arg_23_0, arg_23_1, arg_23_2, arg_23_3)
		local var_23_0 = arg_23_1[1]
		local var_23_1 = arg_23_1[2]

		local function var_23_2(arg_24_0)
			setActive(var_23_1["map_" .. arg_24_0]:Find(tostring(var_23_0)), true)

			local var_24_0

			if arg_23_2[1] then
				setActive(var_23_1["map_" .. arg_24_0]:Find(tostring(arg_23_2[1])), false)

				var_24_0 = var_23_1["map_" .. arg_24_0]:Find(tostring(var_23_0))
			end

			var_23_1.loader:GetSpriteQuiet("ui/" .. self:getUIName() .. "_level" .. var_23_0, ({
				xianshijianzao = "buildship",
				huanzhuangshangdian = "skinshop",
				taskboard = "taskboard"
			})[arg_24_0], var_24_0, true)

			GetComponent(var_23_1["map_" .. arg_24_0], typeof(Button)).targetGraphic = GetComponent(var_24_0, typeof(Image))
		end

		var_23_2("xianshijianzao")
		var_23_2("huanzhuangshangdian")
		var_23_2("taskboard")
		arg_23_1[2].loader:GetSpriteQuiet("ui/" .. self:getUIName() .. "_atlas", "title_" .. arg_23_1[1], arg_23_1[2]._tf:Find("top/Title/Number"), true)
		arg_23_1[2].loader:GetSpriteQuiet("ui/" .. self:getUIName() .. "_level" .. arg_23_1[1], "bg", arg_23_1[2]._tf:Find("map"))
	end, {
		useOldRef = true
	})

	local var_20_1 = {
		"taskboard",
		"bigmap",
		"giftmake"
	}

	table.insertto(var_20_1, var_20_0)

	for iter_20_2, iter_20_3 in ipairs(var_20_1) do
		self.Respones:AddRawListener({
			"view",
			iter_20_3 .. "Tip"
		}, function(arg_25_0, arg_25_1)
			if not arg_25_0["upper_" .. iter_20_3] or IsNil(arg_25_0["upper_" .. iter_20_3]:Find("Tip")) then
				return
			end

			setActive(arg_25_0["upper_" .. iter_20_3]:Find("Tip"), arg_25_1)
		end)
	end

	self.Respones.hubData = {}

	self.Respones:AddRawListener({
		"view",
		"hubData"
	}, function(arg_26_0, arg_26_1)
		arg_26_0.gameCountTxt.text = "X " .. arg_26_1.count
	end, {
		strict = true
	})
	self.Respones:AddRawListener({
		"view",
		"materialCount"
	}, function(arg_27_0, arg_27_1)
		arg_27_0.materialTxt.text = arg_27_1
	end)
end

function AnniversaryIsland2023Scene.PlayStory()
	local var_28_0 = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_BUILDING_BUFF_2)
	local var_28_1 = var_28_0:GetTotalBuildingLevel()

	table.SerialIpairsAsync({
		false,
		var_28_0:getConfig("config_client").lv2Story,
		var_28_0:getConfig("config_client").lv3Story,
		var_28_0:getConfig("config_client").lv4Story
	}, function(arg_29_0, arg_29_1, arg_29_2)
		if arg_29_0 <= var_28_1 and arg_29_1 then
			pg.NewStoryMgr.GetInstance():Play(arg_29_1, arg_29_2)
		else
			arg_29_2()
		end
	end)
end

function AnniversaryIsland2023Scene:UpdateView()
	AnniversaryIsland2023Scene.PlayStory()

	local var_30_0 = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_BUILDING_BUFF_2)

	for iter_30_0, iter_30_1 in pairs(self.Buildings) do
		self.Respones[iter_30_1] = var_30_0.data1KeyValueList[2][iter_30_0] or 1
		self.Respones[iter_30_1 .. "Tip"] = self:UpdateBuildingTip(var_30_0, iter_30_0)
	end

	local var_30_1 = self.Respones.craftTip

	if not self.Respones.craftTip then
		var_30_1 = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_WORKBENCH):HasAvaliableFormula()
		var_30_1 = var_30_1 and getProxy(SettingsProxy):IsTipWorkbenchDaily()
	end

	self.Respones.craftTip = var_30_1
	self.Respones.bigmapTip = tobool((function()
		return Activity.IsActivityReady((getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_ISLAND)))
	end)())
	self.Respones.taskboardTip = tobool((function()
		return getProxy(ActivityTaskProxy):getActTaskTip(ActivityConst.ISLAND_TASK_ID)
	end)())
	self.Respones.giftmakeTip = tobool((function()
		return Activity.IsActivityReady((getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_SCULPTURE)))
	end)())
end

function AnniversaryIsland2023Scene:CalculateSceneLevel()
	return getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_BUILDING_BUFF_2):GetTotalBuildingLevel()
end

function AnniversaryIsland2023Scene:UpdateBuildingTip(arg_35_1, arg_35_2)
	local var_35_0 = AnniversaryIsland2023Scene.super.UpdateBuildingTip(self, arg_35_1, arg_35_2)

	if var_35_0 then
		var_35_0 = var_35_0 and (arg_35_1.data1KeyValueList[2][arg_35_2] or 1) <= arg_35_1:GetTotalBuildingLevel()
	end

	return var_35_0
end

function AnniversaryIsland2023Scene:willExit()
	self:clearStudents()
	AnniversaryIsland2023Scene.super.willExit(self)
end

function AnniversaryIsland2023Scene:IsShowMainTip()
	if self and not self:isEnd() then
		return (function()
			return Activity.IsActivityReady((getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_ISLAND)))
		end)() or (function()
			local var_39_0 = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_BUILDING_BUFF_2)

			for iter_39_0, iter_39_1 in ipairs(var_39_0:GetBuildingIds()) do
				if AnniversaryIsland2023Scene.UpdateBuildingTip(nil, var_39_0, iter_39_1) then
					return true
				end
			end

			if getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_WORKBENCH):HasAvaliableFormula() then
				if getProxy(SettingsProxy):IsTipWorkbenchDaily() then
					return true
				end
			end
		end)() or (function()
			return getProxy(ActivityTaskProxy):getActTaskTip(ActivityConst.ISLAND_TASK_ID)
		end)() or (function()
			return Activity.IsActivityReady((getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_SCULPTURE)))
		end)()
	end
end

return AnniversaryIsland2023Scene
