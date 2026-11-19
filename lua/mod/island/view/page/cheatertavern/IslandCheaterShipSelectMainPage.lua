local IslandCheaterShipSelectMainPage = class("IslandCheaterShipSelectMainPage", import("..ship.IslandShipMainPage"))

function IslandCheaterShipSelectMainPage:OnInit()
	IslandCheaterShipSelectMainPage.super.OnInit(self)
	onButton(self, self.backBtn, function()
		if self.childPage then
			self.childPage:CheckInReturn(function()
				if self.needLoadingUI then
					pg.SceneAnimMgr.GetInstance():CommonSceneChange("Dorm3DLoading", function(arg_4_0)
						self:Hide()

						self.childPage = nil

						arg_4_0()
					end)
				else
					self:Hide()
				end
			end)
		elseif self.needLoadingUI then
			pg.SceneAnimMgr.GetInstance():CommonSceneChange("Dorm3DLoading", function(arg_5_0)
				self:Hide()
				print("3333eeee")
				arg_5_0()
			end)
		else
			self:Hide()
		end
	end, SFX_PANEL)
end

function IslandCheaterShipSelectMainPage:AddListeners()
	IslandCheaterShipSelectMainPage.super.AddListeners(self)
	self:AddListener(CheaterTavernEvent.CLOSE_SHIP_SELECT_PAGE, self.SetNeedNotLoadingUI)
end

function IslandCheaterShipSelectMainPage:RemoveListeners()
	IslandCheaterShipSelectMainPage.super.RemoveListeners(self)
	self:RemoveListener(CheaterTavernEvent.CLOSE_SHIP_SELECT_PAGE, self.SetNeedNotLoadingUI)
end

function IslandCheaterShipSelectMainPage:Show(arg_8_1)
	self.changeDressType = arg_8_1

	IslandCheaterShipSelectMainPage.super.Show(self)
	setActive(self.togglePanel, false)

	self.needLoadingUI = true
end

function IslandCheaterShipSelectMainPage:FlushShips(arg_9_1)
	self.displays = {}
	self.displays = arg_9_1:GetUnlockOrCanUnlockShipConfigIds()

	local var_9_0

	if #self.displays > 0 then
		var_9_0 = arg_9_1:GetShipById(self.displays[1])
	end

	self.contextData.selectedId = self.contextData.selectedId or var_9_0 and var_9_0.configId

	for iter_9_0 = #self.displays, 1, -1 do
		if self.displays[iter_9_0] then
			if getProxy(IslandProxy):GetIsland():GetCharacterAgency():GetShipById(self.displays[iter_9_0]) == nil then
				table.remove(self.displays, iter_9_0)
			end
		end
	end

	self.shipRect:SetTotalCount(#self.displays)
end

function IslandCheaterShipSelectMainPage:UpdateMainView(arg_10_1)
	if self.contextData.selectedId == arg_10_1.configId then
		return
	end

	self.shipDressHelper = self.shipDressHelper or IslandShipDressHelperNew.New()

	self.shipDressHelper:SetShipId(arg_10_1.configId)
	self:LoadCharacter(arg_10_1:GetModel())

	self.contextData.selectedId = arg_10_1.configId

	self:TriggerPage(IslandShipMainPage.PAGE_DRESS)
end

function IslandCheaterShipSelectMainPage:SwitchPage(arg_11_1)
	if not self.contextData.selectedId then
		return
	end

	if self.page then
		self:ClosePage(self.page)

		self.page = nil
	end

	local var_11_0 = self.pages[arg_11_1]

	if arg_11_1 == 1 then
		self.childPage = self:OpenPage(var_11_0, self.contextData.selectedId, false, self.shipDressHelper, function(arg_12_0)
			self:SetObjInitRotaion(arg_12_0)
		end, self.changeDressType)
	else
		self:OpenPage(var_11_0, self.contextData.selectedId)

		self.childPage = nil
	end

	self.page = var_11_0
end

function IslandCheaterShipSelectMainPage:OnHide()
	IslandCheaterShipSelectMainPage.super.OnHide(self)
end

function IslandCheaterShipSelectMainPage:ClearCharacterScene(arg_14_1)
	if self.isLoadCharacterScene then
		if self.needLoadUI then
			self:ClearCharacterContainer()
			self:UnLoadCharacterScene(function()
				self:ActivityPlayerCamera()
				existCall(arg_14_1)
			end)
		else
			self:ClearCharacterContainer()
			self:UnLoadCharacterScene(function()
				self:ActivityPlayerCamera()
				existCall(arg_14_1)
			end)
		end

		self:ResetCameraMask()
		self:emitCore(ISLAND_EVT.REFRESH_WEATHER_SYSTEM)
	end

	self.isLoadCharacterScene = false
end

function IslandCheaterShipSelectMainPage:SetNeedNotLoadingUI()
	self.needLoadingUI = false
end

function IslandCheaterShipSelectMainPage:GetNeedHideUnlockShipFlag()
	return true
end

return IslandCheaterShipSelectMainPage
