local CarWashScene = class("CarWashScene", import("view.dorm3d.Core.Dorm3dBaseScene"))

function CarWashScene:getUIName()
	return "Dorm3dCarWashUI"
end

function CarWashScene:getResource()
	local var_2_0 = CarWashScene.super.getResource(self)

	for iter_2_0, iter_2_1 in ipairs(Dorm3dHxHelper.GetMaterialResources(self.contextData.groupId)) do
		table.insert(var_2_0, iter_2_1)
	end

	return var_2_0
end

function CarWashScene:forceGC()
	return true
end

function CarWashScene.GetDefaultSystemClasses()
	return CarWashConst.GetDefaultSystemClasses()
end

function CarWashScene:loadingQueue()
	return function(arg_6_0)
		pg.SceneAnimMgr.GetInstance():Dorm3DSceneChange(function(arg_7_0)
			return arg_6_0(arg_7_0)
		end)
	end
end

function CarWashScene:preload(arg_8_1)
	self.sceneInfo = {
		{
			name = "map_carwash_01",
			path = "dorm3d/scenesres/scenes/carwash/map_carwash_01_scene"
		},
		{
			name = "carwash_gameplay",
			path = "dorm3d/scenesres/scenes/carwash/carwash_gameplay_scene"
		}
	}
	self.loader = AutoLoader.New()
	self.hxHelper = Dorm3dHxHelper.New(self.loader)

	seriesAsync({
		function(arg_9_0)
			self.hxHelper:LoadMaterials(self.contextData.groupId, arg_9_0)
		end,
		function(arg_10_0)
			SceneOpMgr.Inst:LoadSceneAsync(self.sceneInfo[1].path, self.sceneInfo[1].name, LoadSceneMode.Additive, function(arg_11_0, arg_11_1)
				SceneManager.SetActiveScene(arg_11_0)
				arg_10_0()
			end)
		end,
		function(arg_12_0)
			SceneOpMgr.Inst:LoadSceneAsync(self.sceneInfo[2].path, self.sceneInfo[2].name, LoadSceneMode.Additive, function(arg_13_0, arg_13_1)
				arg_12_0()
			end)
		end,
		function(arg_14_0)
			self.loader:GetPrefab(pg.dorm3d_carwash[self.contextData.groupId].character_prefab, "", function(arg_15_0)
				self.ladyGO = arg_15_0

				arg_14_0()
			end)
		end
	}, arg_8_1)
end

function CarWashScene:willExit()
	CarWashScene.super.willExit(self)

	if self.updateHandler then
		UpdateBeat:RemoveListener(self.updateHandler)

		self.updateHandler = nil
	end

	self.loader:Clear()

	self.hxHelper = nil

	seriesAsync(underscore.map(self.sceneInfo, function(arg_17_0)
		return function(arg_18_0)
			SceneOpMgr.Inst:UnloadSceneAsync(arg_17_0.path, arg_17_0.name, arg_18_0)
		end
	end), function()
		return
	end)
end

function CarWashScene:init()
	self:InitSceneRefs()
	self:InitExtraSystem({
		CarWashGameFlowSystem
	})
	self:InitPage()
	self:InitExtraSystem(CarWashConst.GetGameplaySystemClasses())
	self:InitHX()
end

function CarWashScene:InitHX()
	self.holyLightRoot = self._tf:Find("HolyLightRoot")

	self.hxHelper:Apply(self.ladyGO.transform)
	Dorm3dHxHelper.HideCharacterPart(self.ladyGO.transform, nil, true)
	Dorm3dHxHelper.ShowHolyLight({
		self.ladyGO.transform
	}, self.holyLightRoot, true)
end

function CarWashScene:InitPage()
	self.mainPage = CarWashMainPage.New(self._tf, self.event, self.contextData)
	self.gamePage = CarWashGamePage.New(self._tf:Find("game"), self.event, self.contextData)
	self.phase2Page = CarWashPhase2Page.New(self._tf:Find("phase2"), self.event, self.contextData)
	self.endPage = CarWashEndPage.New(self._tf:Find("end"), self.event, self.contextData)
end

function CarWashScene:InitSceneRefs()
	setActive(GameObject.Find("Camera"), false)

	self.mainCameraGO = GameObject.Find("BackYardMainCamera")
	self.mainCameraTF = self.mainCameraGO.transform
	self.mainCamera = self.mainCameraGO:GetComponent(typeof(Camera))
	self.cameraRoot = GameObject.Find("CM Cameras").transform
	self.raycastCamera = self.mainCameraTF:Find("CameraForRaycast"):GetComponent(typeof(Camera))
	self.sceneRaycaster = self.raycastCamera:GetComponent(typeof(UnityEngine.EventSystems.PhysicsRaycaster))
end

function CarWashScene:didEnter()
	self:emit(CarWashGameFlowSystem.START_GAME, function()
		self:StartUpdate()
	end)
end

function CarWashScene:StartUpdate()
	if self.updateHandler then
		return
	end

	self.updateHandler = UpdateBeat:CreateListener(function()
		xpcall(function()
			self:Update()
		end, function(...)
			errorMsg(debug.traceback(...))
		end)
	end)

	UpdateBeat:AddListener(self.updateHandler)
end

function CarWashScene:Update()
	if self.exited then
		return
	end

	if self.systemManager then
		self.systemManager:Update(Time.deltaTime)
	end
end

return CarWashScene
