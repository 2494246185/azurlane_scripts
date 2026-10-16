local Dorm3dARScene = class("Dorm3dARScene", import("view.base.BaseUI"))
local var_0_1 = "ARScene2|common/ar"

Dorm3dARScene.AR_FAIL_CODE = {
	[0] = "None",
	"Unsupported",
	"CheckingAvailability",
	"NeedsInstall",
	"Installing",
	[-1] = "pc editor"
}
Dorm3dARScene.AR_PASS_CODE = {
	5,
	6,
	7
}

function Dorm3dARScene:getUIName()
	return "Dorm3DARUI"
end

function Dorm3dARScene:getResource()
	local var_2_0 = Dorm3dARScene.super.getResource(self)
	local var_2_1, var_2_2 = unpack(string.split(var_0_1, "|"))

	table.insert(var_2_0, string.lower("dorm3d/scenesres/scenes/" .. var_2_2 .. "/" .. var_2_1 .. "_scene"))
	table.insert(var_2_0, string.lower(string.format("ui/dorm3dloading")))
	table.insert(var_2_0, string.lower(string.format("dorm3dholylight/eff_smoke_114")))

	local var_2_3 = getProxy(ApartmentProxy):getApartment(self.contextData.groupId)
	local var_2_4 = pg.dorm3d_resource[var_2_3:GetSkinModelID(getProxy(ApartmentProxy):getRoom(self.contextData.roomId):getConfig("tag"))].model_id

	assert(var_2_4)

	for iter_2_0, iter_2_1 in ipairs(Dorm3dHxHelper.GetMaterialResources(self.contextData.groupId)) do
		table.insert(var_2_0, iter_2_1)
	end

	table.insert(var_2_0, string.lower(string.format("dorm3d/character/%s/prefabs/%s", var_2_3:getConfig("asset_name"), var_2_4)))

	return var_2_0
end

function Dorm3dARScene:forceGC()
	return true
end

function Dorm3dARScene:loadingQueue()
	return function(arg_5_0)
		pg.SceneAnimMgr.GetInstance():Dorm3DSceneChange(function(arg_6_0)
			return arg_5_0(arg_6_0)
		end)
	end
end

function Dorm3dARScene:Ctor(...)
	Dorm3dARScene.super.Ctor(self, ...)

	self.loader = AutoLoader.New()
	self.hxHelper = Dorm3dHxHelper.New(self.loader)
end

function Dorm3dARScene:preload(arg_8_1)
	self.room = getProxy(ApartmentProxy):getRoom(self.contextData.roomId)

	local var_8_0, var_8_1 = unpack(string.split(var_0_1, "|"))

	seriesAsync({
		function(arg_9_0)
			SceneOpMgr.Inst:LoadSceneAsync(string.lower("dorm3d/scenesres/scenes/" .. var_8_1 .. "/" .. var_8_0 .. "_scene"), var_8_0, LoadSceneMode.Additive, function(arg_10_0, arg_10_1)
				arg_9_0()
			end)
		end,
		function(arg_11_0)
			self:LoadCharacter({
				self.contextData.groupId
			}, arg_11_0)
		end,
		function(arg_12_0)
			local var_12_0 = GameObject.Find("FakeAR/Main Camera")
			local var_12_1 = GameObject.Find("AR/XR Origin/Camera Offset/Main Camera")

			if var_12_0 then
				originalPrint("Fix Fake AR Camera Data")
				HotfixHelper.FixARCameraData(var_12_0)
			end

			if var_12_1 then
				originalPrint("Fix True AR Camera Data")
				HotfixHelper.FixARCameraData(var_12_1)
			end

			arg_12_0()
		end
	}, arg_8_1)
end

function Dorm3dARScene:LoadCharacter(arg_13_1, arg_13_2)
	self.ladyDict = {}
	self.skinDict = {}

	local var_13_0 = {}

	for iter_13_0, iter_13_1 in ipairs(arg_13_1) do
		local var_13_1 = self

		self.ladyDict[iter_13_1] = self

		local var_13_2 = getProxy(ApartmentProxy)
		local var_13_3 = var_13_2:getApartment(iter_13_1)
		local var_13_4 = var_13_3:getConfig("asset_name")
		local var_13_5 = var_13_3:GetSkinModelID(self.room:getConfig("tag"))
		local var_13_6 = pg.dorm3d_resource[var_13_2].model_id

		assert(pg.dorm3d_resource[var_13_2].model_id)
		table.insert(var_13_0, function(arg_14_0)
			self.hxHelper:LoadMaterials(iter_13_1, arg_14_0)
		end)

		self.skinId = var_13_5
		self.skinIdList = {
			var_13_5
		}

		table.insert(var_13_0, function(arg_15_0)
			self.loader:GetPrefab(string.format("dorm3d/character/%s/prefabs/%s", var_13_4, var_13_6), "", function(arg_16_0)
				var_13_1.ladyGameObject = arg_16_0

				setActive(arg_16_0.transform, false)

				self.skinDict[var_13_5] = {
					ladyGameObject = arg_16_0
				}

				arg_15_0()
			end)
		end)
	end

	parallelAsync(var_13_0, arg_13_2)
end

function Dorm3dARScene:InitCharacter(arg_17_1)
	self.lady = self.ladyGameObject.transform

	self.lady:SetParent(self.mainCameraTF)
	self.lady:SetParent(nil)
	setActive(self.lady, true)

	self.ladyAnimator = self.lady:GetComponent(typeof(Animator))
	self.ladyAnimBaseLayerIndex = self.ladyAnimator:GetLayerIndex("Base Layer")
	self.ladyAnimFaceLayerIndex = self.ladyAnimator:GetLayerIndex("Face")
	self.ladyBoneMaps = {}

	table.IpairsCArray(self.lady:GetComponentsInChildren(typeof(Transform), true), function(arg_18_0, arg_18_1)
		if arg_18_1.name == "BodyCollider" then
			self.ladyCollider = arg_18_1
		elseif arg_18_1.name == "Interest" then
			self.ladyInterestRoot = arg_18_1
		elseif arg_18_1.name == "Head Center" then
			self.ladyHeadCenter = arg_18_1
		end
	end)
	self:HXCharacter(self.lady, self.skinId)
	self.ladyAnimator:GetComponent("DftAniEvent"):SetCommonEvent(function(arg_19_0)
		if self.nowState and arg_19_0.animatorStateInfo:IsName(self.nowState) then
			existCall(self.stateCallback)

			return
		end

		local var_19_0 = arg_19_0.animatorStateInfo

		for iter_19_0, iter_19_1 in pairs(self.animCallbacks) do
			if var_19_0:IsName(iter_19_0) then
				warning("Active", iter_19_0)
				existCall((table.removebykey(self.animCallbacks, iter_19_0)))

				return
			end
		end

		if arg_19_0.stringParameter ~= "" then
			self:OnAnimationEvent(arg_19_0)
		end
	end)

	self.animEventCallbacks = {}
	self.animCallbacks = {}
end

function Dorm3dARScene:HXCharacter(arg_20_1, arg_20_2)
	if not HXSet.isHx() then
		return
	end

	Dorm3dHxHelper.ShowHolyLight({
		arg_20_1
	}, self.holyLightRoot)
	self.hxHelper:Apply(arg_20_1, arg_20_2)
end

function Dorm3dARScene:OnAnimationEvent(arg_21_1)
	if arg_21_1.animatorClipInfo.weight < 0.5 then
		return
	end

	existCall((table.removebykey(self.animEventCallbacks, arg_21_1.stringParameter)))
end

function Dorm3dARScene:init()
	self:findUI()
	self:addListener()
end

function Dorm3dARScene:PlaySingleAction(arg_23_1, arg_23_2)
	if tobool((string.find(arg_23_1, "^Face_"))) then
		self:PlayFaceAnim(arg_23_1, arg_23_2)

		return
	end

	self.animNameMap = self.animNameMap or {}
	self.animNameMap[self.ladyAnimator.StringToHash(arg_23_1)] = arg_23_1

	local var_23_0 = {}

	if not self.ladyAnimator:GetCurrentAnimatorStateInfo(self.ladyAnimBaseLayerIndex):IsName(arg_23_1) then
		table.insert(var_23_0, function(arg_24_0)
			self.nowState = arg_23_1
			self.stateCallback = arg_24_0

			self.ladyAnimator:CrossFadeInFixedTime(arg_23_1, 0.25, self.ladyAnimBaseLayerIndex)
		end)
		table.insert(var_23_0, function(arg_25_0)
			self.nowState = nil
			self.stateCallback = nil

			arg_25_0()
		end)
	end

	seriesAsync(var_23_0, arg_23_2)
end

function Dorm3dARScene:SwitchAnim(arg_26_1, arg_26_2)
	if tobool((string.find(arg_26_1, "^Face_"))) then
		self:PlayFaceAnim(arg_26_1, arg_26_2)

		return
	end

	self.animNameMap = self.animNameMap or {}
	self.animNameMap[self.ladyAnimator.StringToHash(arg_26_1)] = arg_26_1

	local var_26_0 = {}

	table.insert(var_26_0, function(arg_27_0)
		self.nowState = arg_26_1
		self.stateCallback = arg_27_0

		self.ladyAnimator:PlayInFixedTime(arg_26_1, self.ladyAnimBaseLayerIndex)
	end)
	table.insert(var_26_0, function(arg_28_0)
		self.nowState = nil
		self.stateCallback = nil

		arg_28_0()
	end)
	seriesAsync(var_26_0, arg_26_2)
end

function Dorm3dARScene:PlayFaceAnim(arg_29_1, arg_29_2)
	self.ladyAnimator:CrossFadeInFixedTime(arg_29_1, 0.2, self.ladyAnimFaceLayerIndex)
	existCall(arg_29_2)
end

function Dorm3dARScene:SetARUIActive(arg_30_1)
	setActive(self.backBtn, arg_30_1)
	setActive(self.menuListTF, arg_30_1)
	setActive(self.tipTextTF, arg_30_1)
end

function Dorm3dARScene:SetARUIActiveWhenInit(arg_31_1)
	setActive(self.resetBtn, false)
end

function Dorm3dARScene:ResetCharPos()
	if self.ARCheck then
		self.lady.localPosition = Vector3.zero
		self.lady.localRotation = Vector3(0, 180, 0)
	else
		self.lady.localPosition = Vector3(0, 0, 2)
		self.lady.localRotation = Vector3(0, 180, 0)
	end
end

function Dorm3dARScene:didEnter()
	self:emit(Dorm3dARMediator.IN_ITAR_PHOTO)
end

function Dorm3dARScene:SetARLite(arg_34_1)
	self.ARState = arg_34_1
	self.ARCheck = table.contains(Dorm3dARScene.AR_PASS_CODE, arg_34_1)

	if GraphApiHelper.IsUsingVulkan() then
		self.ARCheck = false

		warning("ar not allow on vulkan.")
	end
end

function Dorm3dARScene:InitARPlane()
	self._initState = true

	if self.lady then
		setActive(self.lady, false)
	end

	self:SetARUIActiveWhenInit(false)
	SetActive(GameObject.Find("AR"), self.ARCheck)
	SetActive(GameObject.Find("FakeAR"), not self.ARCheck)

	if self.ARCheck then
		originalPrint("AR CHECK SUCCESS, INIT AR")
		self.aiHelperSC:Init()
		self:emit(Dorm3dARMediator.INIT_AR_PLANE)
	else
		originalPrint("AR CHECK FAIL")
		self:InitARFinish()
		self:EnabledDrag()
	end

	if PLATFORM == PLATFORM_WINDOWSEDITOR then
		self:InitARFinish()
	end
end

function Dorm3dARScene:Reset()
	self._initState = true

	if self.lady then
		setActive(self.lady, false)
	end

	self:SetARUIActiveWhenInit(false)

	if self.ARCheck then
		self.aiHelperSC:ResetAll()
	end
end

function Dorm3dARScene:InitARFinish()
	setActive(self.tipsLabel, false)
	self:emit(Dorm3dARMediator.AR_INIT_FINISH)
	self:InitCharacter(self.contextData.groupId)

	if self.ARCheck then
		self.lady:SetParent(GameObject.Find("Tpl(Clone)").transform)
	else
		self.lady:SetParent(self.tpl)
	end

	self:ResetCharPos()
	self:SetARUIActiveWhenInit(true)

	self._initState = false
end

function Dorm3dARScene:willExit()
	self.loader:Clear()

	self.hxHelper = nil

	if self.ARCheck then
		self.aiHelperSC:ResetAll()
		self.aiHelperSC:Destroy()
	end

	local var_38_0 = GameObject.Find("Tpl(Clone)")

	if var_38_0 then
		Destroy(var_38_0)
	end

	local var_38_1, var_38_2 = unpack(string.split(var_0_1, "|"))

	SceneOpMgr.Inst:UnloadSceneAsync(string.lower("dorm3d/scenesres/scenes/" .. var_38_2 .. "/" .. var_38_1 .. "_scene"), var_38_1)

	if self.luHandle then
		LateUpdateBeat:RemoveListener(self.luHandle)
	end
end

function Dorm3dARScene:findUI()
	self.backBtn = self._tf:Find("BackBtn")
	self.menuListTF = self._tf:Find("MenuList")
	self.initARBtn = self.menuListTF:Find("InitARBtn")
	self.resetBtn = self.menuListTF:Find("ResetBtn")
	self.tipTextTF = self._tf:Find("TipText")
	self.tipsLabel = self.tipTextTF:Find("tipsText")
	self.tipsText = self.tipTextTF:Find("tipsText/text")

	setActive(self.tipsLabel, false)

	self.fakeARCanvas = GameObject.Find("FakeAR/Main Camera/ARCanvas").transform

	setSizeDelta(self.fakeARCanvas, Vector2(Screen.width, Screen.height))

	self.fakeARCamera = GameObject.Find("FakeAR/Main Camera"):GetComponent("Camera")
	self.drag = self._tf:Find("drag")
	self.aiHelperSC = GetComponent(GameObject.Find("ARScriptHandle"), "ARHelper")
	self.aiHelperSC.tplPrefab = GameObject.Find("Tpl")
	self.tpl = GameObject.Find("Tpl").transform
	self.holyLightRoot = self._tf:Find("HolyLightRoot")
end

function Dorm3dARScene:addListener()
	onButton(self, self.backBtn, function()
		self:closeView()
	end, SFX_PANEL)
	onButton(self, self.resetBtn, function()
		self:Reset()
	end, SFX_PANEL)

	function self.aiHelperSC.planeCountCB(arg_43_0, arg_43_1)
		if arg_43_0 <= 0 then
			setActive(self.tipsLabel, true)
			setText(self.tipsText, i18n("AR_plane_check"))
		elseif not arg_43_1 then
			setActive(self.tipsLabel, true)
			setText(self.tipsText, i18n("AR_plane_long_press_to_summon"))
		elseif self._initState then
			self:InitARFinish()
		end
	end

	function self.aiHelperSC.distanceCB(arg_44_0)
		if arg_44_0 < 0.3 then
			self.distanceFlag = true

			setActive(self.lady, false)
			setActive(self.tipsLabel, true)
			setText(self.tipsText, i18n("AR_plane_distance_near"))
		elseif self.distanceFlag then
			setActive(self.tipsLabel, false)
			setActive(self.lady, true)

			self.distanceFlag = false
		end
	end

	function self.aiHelperSC.insPrefabFailCB()
		warning("距离过近，呼出角色失败")
		pg.TipsMgr.GetInstance():ShowTips(i18n("AR_plane_summon_fail_by_near"))
	end

	function self.aiHelperSC.insPrefabSuccCB()
		setActive(self.tipsLabel, false)
		pg.TipsMgr.GetInstance():ShowTips(i18n("AR_plane_summon_success"))
		self.aiHelperSC:StopPlaneCheck()
	end
end

function Dorm3dARScene:EnabledDrag()
	self.lady.localScale = Vector3(5, 5, 5)

	local var_47_0 = LuaHelper.GetWorldCorners(self._tf:GetComponent("RectTransform"))

	self.widthRate = (var_47_0[2].x - var_47_0[0].x) / pg.CameraFixMgr.GetInstance().actualWidth
	self.heightRate = (var_47_0[2].y - var_47_0[0].y) / pg.CameraFixMgr.GetInstance().actualHeight
	self.halfWidth = (var_47_0[2].x - var_47_0[0].x) / 2
	self.halfHeight = (var_47_0[2].y - var_47_0[0].y) / 2
	self.isEnableDrag = true

	local var_47_1 = self.drag.gameObject

	GetOrAddComponent(self.drag.gameObject, typeof(Button))

	self.zoom = GetOrAddComponent(self._tf, typeof(PinchZoom))
	self.zoom.enabled = true

	local var_47_2 = GetOrAddComponent(self.drag.gameObject, typeof(EventTriggerListener))
	local var_47_3 = Vector3(0, 0, 0)

	var_47_2:AddBeginDragFunc(function(arg_48_0, arg_48_1)
		if Application.isEditor and Input.GetMouseButton(2) then
			return
		end

		if self.zoom.processing then
			return
		end

		setButtonEnabled(var_47_1, false)

		if Input.touchCount > 1 then
			return
		end

		var_47_3 = self.drag.localPosition - Dorm3dARScene.Screen2Local(var_47_1.transform.parent, arg_48_1.position)
	end)
	var_47_2:AddDragFunc(function(arg_49_0, arg_49_1)
		if Application.isEditor and Input.GetMouseButton(2) then
			return
		end

		if self.zoom.processing then
			return
		end

		if Input.touchCount > 1 then
			return
		end

		local var_49_0 = Dorm3dARScene.Screen2Local(var_47_1.transform.parent, arg_49_1.position)

		self.drag.localPosition = Vector3(var_49_0.x, var_49_0.y, 0) + var_47_3
		self.tpl.localPosition = self:GetUI2Char(arg_49_1.position)
	end)
	var_47_2:AddDragEndFunc(function()
		setButtonEnabled(var_47_1, true)
	end)

	var_47_2.enabled = true
	Input.multiTouchEnabled = true
	self.fakeARCamera.orthographicSize = 8
	self.fakeARCamera.orthographic = true
	self.luHandle = LateUpdateBeat:CreateListener(function()
		if self.zoom.processing then
			self.tpl.localScale = Vector3(self.drag.localScale.x, self.drag.localScale.x, self.drag.localScale.x)
		end
	end, self)

	LateUpdateBeat:AddListener(self.luHandle)
end

function Dorm3dARScene:GetUI2Char(arg_52_1)
	return Vector3(self.widthRate * arg_52_1.x - self.halfWidth, self.heightRate * arg_52_1.y - self.halfHeight, 2)
end

function Dorm3dARScene:Screen2Local(arg_53_1)
	local var_53_0 = GameObject.Find("UICamera")

	return Vector3(var_53_0.x, LuaHelper.ScreenToLocal(self:GetComponent("RectTransform"), arg_53_1, (var_53_0:GetComponent("Camera"))).y, 0)
end

return Dorm3dARScene
