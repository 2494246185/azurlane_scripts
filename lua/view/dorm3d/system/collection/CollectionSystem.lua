local CollectionSystem = class("CollectionSystem", import("view.dorm3d.Core.BaseSystem"))

CollectionSystem.TEMP_HIDE = "CollectionSystem.TEMP_HIDE"
CollectionSystem.UPDATE_CONTACT_STATE = "CollectionSystem.UPDATE_CONTACT_STATE"

function CollectionSystem:OnInit()
	self.contactStateDic = {}
	self.hideContactStateDic = {}
	self.contactInRangeDic = {}
	self.transRangeDic = {
		list = {}
	}
	self.uiHidden = false
	self.tempHidden = false
	self.contactTriggers = {}
	self.artSceneChanging = false
	self.artSceneBlocked = false

	self:UpdateContactState()
end

function CollectionSystem:RegisterEvents()
	self:Bind(CollectionSystem.UPDATE_CONTACT_STATE, function(arg_3_0, arg_3_1)
		self:UpdateContactState(arg_3_1)
	end)
	self:Bind(CollectionSystem.TEMP_HIDE, function(arg_4_0, arg_4_1)
		self.tempHidden = arg_4_1

		self:ActiveContact()
	end)
	self:Bind(FurnitureSystem.REFRESH_DONE, function()
		self:ActiveContact()
	end)
	self:Bind(Dorm3dRoomTemplateScene.ART_SCENE_WILL_CHANGE, function(arg_6_0, arg_6_1, arg_6_2)
		self.artSceneChanging = true
		self.artSceneBlocked = not arg_6_2

		self:ClearContactBindings()
	end)
	self:Bind(Dorm3dRoomTemplateScene.ART_SCENE_CHANGED, function(arg_7_0, arg_7_1, arg_7_2)
		self.artSceneChanging = false
		self.artSceneBlocked = not arg_7_2

		if arg_7_2 then
			self:UpdateContactState()
		end
	end)
end

function CollectionSystem:OnHandleNotification(arg_8_1, arg_8_2)
	if arg_8_1 == GAME.APARTMENT_COLLECTION_ITEM_DONE then
		self:UpdateContactState()
	elseif arg_8_1 == Dorm3dRoomScene.NOTIFY_UI_STATE then
		self.uiHidden = arg_8_2 ~= "base"

		self:ActiveContact()
	end
end

function CollectionSystem.GetInterests()
	return {
		GAME.APARTMENT_COLLECTION_ITEM_DONE,
		Dorm3dRoomScene.NOTIFY_UI_STATE
	}
end

function CollectionSystem:OnUpdate()
	if self.artSceneChanging or self.artSceneBlocked or not self.transformFilter or not self.contactInRangeDic then
		return
	end

	local var_10_0 = self.transformFilter:Execute():ToTable()

	for iter_10_0, iter_10_1 in pairs(self.contactInRangeDic) do
		local var_10_1 = false

		if self.transRangeDic[iter_10_0] then
			var_10_1 = underscore(var_10_0):chain():slice(unpack(self.transRangeDic[iter_10_0])):any(function(arg_11_0)
				return arg_11_0
			end):value()
		end

		if tobool(iter_10_1) ~= var_10_1 then
			self.contactInRangeDic[iter_10_0] = var_10_1

			self:UpdateContactDisplay(iter_10_0, self:GetDisplayState(iter_10_0))
		end
	end
end

function CollectionSystem:UpdateContactState(arg_12_1)
	if self.artSceneChanging or self.artSceneBlocked then
		return
	end

	local var_12_0 = self:GetRoom()

	if not var_12_0 then
		warning("CollectionSystem cannot update without room")

		return
	end

	arg_12_1 = arg_12_1 or self:GetTimeIndex()

	self:SetContactStateDic(var_12_0:getTriggerableCollectItemDic(arg_12_1))
end

function CollectionSystem:SetContactStateDic(arg_13_1)
	self.contactStateDic = arg_13_1 or {}
	self.hideContactStateDic = {}
	self.contactInRangeDic = {}
	self.transRangeDic = {
		list = {}
	}
	self.transformFilter = self.transformFilter or BLHX.Rendering.TransformFilter.New()

	local var_13_0 = self:GetModelRoot()

	for iter_13_0, iter_13_1 in pairs(self.contactStateDic) do
		self.hideContactStateDic[iter_13_0] = math.min(iter_13_1, ApartmentRoom.ITEM_UNLOCK)
		self.contactInRangeDic[iter_13_0] = false

		local var_13_1 = pg.dorm3d_collection_template[iter_13_0].vfx_prefab or {}

		self.transRangeDic[iter_13_0] = {
			#self.transRangeDic.list + 1,
			#self.transRangeDic.list + #var_13_1
		}

		table.insertto(self.transRangeDic.list, underscore.map(var_13_1, function(arg_14_0)
			return var_13_0:Find(arg_14_0)
		end))
	end

	self.transformFilter:Init(self:GetMainCameraTF(), self.transRangeDic.list, 2, 60)
	self:ActiveContact()
end

function CollectionSystem:GetDisplayState(arg_15_1)
	if self.contactInRangeDic[arg_15_1] and not self.uiHidden and not self.tempHidden then
		return self.contactStateDic[arg_15_1]
	end

	return self.hideContactStateDic[arg_15_1]
end

function CollectionSystem:ActiveContact()
	if self.artSceneChanging or self.artSceneBlocked then
		return
	end

	for iter_16_0 in pairs(self.contactInRangeDic) do
		self:UpdateContactDisplay(iter_16_0, self:GetDisplayState(iter_16_0))
	end
end

function CollectionSystem:UpdateContactDisplay(arg_17_1, arg_17_2)
	local var_17_0 = self:GetModelRoot()

	for iter_17_0, iter_17_1 in ipairs(pg.dorm3d_collection_template[arg_17_1].vfx_prefab or {}) do
		local var_17_1 = var_17_0:Find(iter_17_1)

		if self:IsModeInHidePending(iter_17_1) then
			-- block empty
		elseif not var_17_1 then
			warning("cannot find", arg_17_1, iter_17_1)
		else
			setActive(var_17_1, arg_17_2 == ApartmentRoom.ITEM_FIRST)
		end
	end

	for iter_17_2, iter_17_3 in ipairs(pg.dorm3d_collection_template[arg_17_1].model or {}) do
		local var_17_2 = var_17_0:Find(iter_17_3)

		if self:IsModeInHidePending(iter_17_3) then
			self:DisableContactTrigger(var_17_2)
		elseif not var_17_2 then
			warning("cannot find", arg_17_1, iter_17_3)
		elseif not self:CheckSceneItemActive(var_17_2) then
			self:DisableContactTrigger(var_17_2)
		else
			if arg_17_2 == ApartmentRoom.ITEM_FIRST then
				self:GetContactTrigger(var_17_2, arg_17_1).enabled = true
			else
				self:DisableContactTrigger(var_17_2)
			end

			setActive(var_17_2, arg_17_2 > ApartmentRoom.ITEM_LOCK)
		end
	end
end

function CollectionSystem:GetContactTrigger(arg_18_1, arg_18_2)
	if self.contactTriggers[arg_18_1] then
		return self.contactTriggers[arg_18_1]
	end

	local var_18_0 = GetComponent(arg_18_1, typeof(EventTriggerListener)) or GetOrAddComponent(arg_18_1, typeof(EventTriggerListener))

	var_18_0:AddPointClickFunc(function()
		self:OnContactClick(arg_18_2)
	end)

	self.contactTriggers[arg_18_1] = var_18_0

	return var_18_0
end

function CollectionSystem:DisableContactTrigger(arg_20_1)
	if not arg_20_1 then
		return
	end

	if self.contactTriggers[arg_20_1] then
		self.contactTriggers[arg_20_1].enabled = false
	end
end

function CollectionSystem:OnContactClick(arg_21_1)
	if self.uiHidden or self.tempHidden then
		return
	end

	local var_21_0 = self:GetRoom()

	if not var_21_0 then
		return
	end

	local var_21_1 = self:GetApartment()
	local var_21_2 = Dorm3dRoomMediator.COLLECTION_ITEM
	local var_21_3 = {
		itemId = arg_21_1,
		roomId = var_21_0:GetConfigID()
	}

	var_21_3.groupId = var_21_0:isPersonalRoom() and var_21_1:GetConfigID() or 0

	self:Emit(var_21_2, var_21_3)
end

function CollectionSystem:OnDispose()
	self:ClearContactBindings()

	self.artSceneChanging = true
	self.contactTriggers = nil
	self.transformFilter = nil
end

function CollectionSystem:ClearContactBindings()
	for iter_23_0, iter_23_1 in pairs(self.contactTriggers or {}) do
		iter_23_1.enabled = false

		iter_23_1:RemovePointClickFunc()
	end

	self.contactTriggers = {}
	self.transformFilter = nil
end

return CollectionSystem
