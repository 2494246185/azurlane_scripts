local NewBackYardShopLayer = class("NewBackYardShopLayer", import("...base.BaseUI"))
local var_0_1 = 1
local var_0_2 = 2
local var_0_3 = 3
local var_0_4 = 4
local var_0_5 = 5
local var_0_6 = 6
local var_0_7 = 7
local var_0_8 = {
	"word_theme",
	"word_wallpaper",
	"word_floorpaper",
	"word_furniture",
	"word_shipskin",
	"word_decorate",
	"word_wall"
}

local function var_0_10(arg_2_0, arg_2_1, arg_2_2)
	local function var_2_0(arg_3_0, arg_3_1)
		setActive(arg_3_0:Find("sel"), arg_3_1)
		setActive(arg_3_0:Find("unsel"), not arg_3_1)
	end

	onButton(arg_2_0, arg_2_1, function()
		if not arg_2_2() then
			return
		end

		if arg_2_0.btn then
			var_2_0(arg_2_0.btn, false)
		end

		var_2_0(arg_2_1, true)

		arg_2_0.btn = arg_2_1
	end, SFX_PANEL)
	var_2_0(arg_2_1, false)
end

function NewBackYardShopLayer:forceGC()
	return true
end

function NewBackYardShopLayer:getUIName()
	return "NewBackYardShopUI"
end

function NewBackYardShopLayer:SetDorm(arg_7_1)
	self.dorm = arg_7_1
end

function NewBackYardShopLayer:SetPlayer(arg_8_1)
	self.player = arg_8_1
end

function NewBackYardShopLayer:PlayerUpdated(arg_9_1)
	self:SetPlayer(arg_9_1)
	self:UpdateRes()

	if self.pageType then
		self.pages[self.pageType]:ExecuteAction("PlayerUpdated", arg_9_1)
	end
end

function NewBackYardShopLayer:DormUpdated(arg_10_1)
	self:SetDorm(arg_10_1)

	if self.pageType then
		self.pages[self.pageType]:ExecuteAction("DormUpdated", arg_10_1)
	end
end

function NewBackYardShopLayer:FurnituresUpdated(arg_11_1)
	if self.pageType then
		self.pages[self.pageType]:ExecuteAction("FurnituresUpdated", arg_11_1)
	end
end

function NewBackYardShopLayer:init()
	self.pageContainer = self._tf:Find("pages")
	self.adpter = self._tf:Find("adpter")
	self.btnTpl = self._tf:Find("adpter/tag/list/tpl")
	self.btnContainer = self._tf:Find("adpter/tag/list")
	self.backBtn = self._tf:Find("adpter/top/fanhui")
	self.goldTxt = self._tf:Find("adpter/top/res_gold/Text"):GetComponent(typeof(Text))
	self.gemTxt = self._tf:Find("adpter/top/res_gem/Text"):GetComponent(typeof(Text))
	self.goldAddBtn = self._tf:Find("adpter/top/res_gold/jiahao")
	self.gemAddBtn = self._tf:Find("adpter/top/res_gem/jiahao")
	self.help = self._tf:Find("adpter/top/help")
	self.themePage = BackYardThemePage.New(self.pageContainer, self.event, self.contextData)
	self.furniturePage = BackYardFurniturePage.New(self.pageContainer, self.event, self.contextData)
	self.contextData.filterPanel = BackYardShopFilterPanel.New(self._tf, self.event, self.contextData)
	self.pages = {
		[var_0_1] = self.themePage,
		[var_0_2] = self.furniturePage,
		[var_0_3] = self.furniturePage,
		[var_0_4] = self.furniturePage,
		[var_0_5] = self.furniturePage,
		[var_0_6] = self.furniturePage,
		[var_0_7] = self.furniturePage
	}
	self.contextData.furnitureMsgBox = BackYardFurnitureMsgBoxPage.New(self._tf, self.event)
	self.contextData.themeMsgBox = BackYardThemeMsgBoxPage.New(self._tf, self.event)
	self.contextData.themeAllMsgBox = BackYardThemeMsgBoxForAllPage.New(self._tf, self.event)
end

function NewBackYardShopLayer:didEnter()
	onButton(self, self.backBtn, function()
		if self.contextData.onDeattch then
			self.contextData.onDeattch()
		end

		self:emit(NewBackYardShopLayer.ON_CLOSE)
	end, SFX_CANCEL)
	onButton(self, self.help, function()
		self:emit(NewBackYardShopLayer.ON_HOME)
	end, SFX_PANEL)
	onButton(self, self.goldAddBtn, function()
		self:emit(NewBackYardShopMediator.ON_CHARGE, PlayerConst.ResDormMoney)
	end, SFX_PANEL)
	onButton(self, self.gemAddBtn, function()
		self:emit(NewBackYardShopMediator.ON_CHARGE, PlayerConst.ResDiamond)
	end, SFX_PANEL)
	self:InitPageFooter()
	self:UpdateRes()
	triggerButton(self.btns[self.contextData.page or var_0_1])

	if self.contextData.topLayer then
		local var_13_0 = GetOrAddComponent(self._tf, typeof(Canvas))

		var_13_0.overrideSorting = true
		var_13_0.sortingOrder = 900

		GetOrAddComponent(self._tf, typeof(GraphicRaycaster))
	end

	getProxy(SettingsProxy):UpdateNewThemeValue()
end

function NewBackYardShopLayer:UpdateRes()
	self.goldTxt.text = self.player:getResource(PlayerConst.ResDormMoney)
	self.gemTxt.text = self.player:getTotalGem()
end

local var_0_11 = {
	"0",
	"1",
	"4",
	"2",
	"8",
	"3",
	"6",
	"7"
}

function NewBackYardShopLayer:InitPageFooter()
	self.btns = {}

	for iter_19_0, iter_19_1 in ipairs(self.pages) do
		local var_19_0 = cloneTplTo(self.btnTpl, self.btnContainer)
		local var_19_1 = var_19_0:Find("unsel"):GetComponent(typeof(Image))

		var_19_1.sprite = GetSpriteFromAtlas("ui/NewBackYardShopUI_atlas", "text_tag" .. iter_19_0 - 1)

		var_19_1:SetNativeSize()

		local var_19_2 = var_19_0:Find("sel/Text"):GetComponent(typeof(Image))

		var_19_2.sprite = GetSpriteFromAtlas("ui/NewBackYardShopUI_atlas", "text_tag" .. iter_19_0 - 1)

		var_19_2:SetNativeSize()

		local var_19_3 = var_19_0:Find("sel/icon"):GetComponent(typeof(Image))

		LoadSpriteAtlasAsync("ui/CourtyardUI_atlas", "icon_" .. var_0_11[iter_19_0], function(arg_20_0)
			if self.exited then
				return
			end

			var_19_3.sprite = arg_20_0
		end)
		var_0_10(self, var_19_0, function()
			if self.pageType == iter_19_0 then
				return
			end

			if self.pageType and not self.pages[self.pageType]:GetLoaded() then
				return
			end

			if self.pageType and self.pages[self.pageType] ~= iter_19_1 then
				self.pages[self.pageType]:Hide()
			end

			iter_19_1:ExecuteAction("SetUp", iter_19_0, self.dorm, self.player, function()
				return
			end)

			self.pageType = iter_19_0

			if iter_19_0 == 5 then
				getProxy(SettingsProxy):UpdateNewGemFurnitureValue()
				self:UpdateSpecialPageFooter()
			end

			return true
		end)

		self.btns[iter_19_0] = var_19_0
	end

	self:UpdateSpecialPageFooter()
	setActive(self.btnTpl, false)
end

function NewBackYardShopLayer:getResource()
	local var_23_0 = NewBackYardShopLayer.super.getResource(self)
	local var_23_1 = {}

	for iter_23_0, iter_23_1 in ipairs(var_23_0) do
		var_23_1[iter_23_1] = true
	end

	for iter_23_2, iter_23_3 in ipairs(pg.furniture_shop_template.all) do
		if pg.TimeMgr.GetInstance():inTime(pg.furniture_shop_template[iter_23_3].time) then
			if "furnitureicon/" .. pg.furniture_data_template[iter_23_3].icon ~= "furnitureicon/" and not var_23_1["furnitureicon/" .. pg.furniture_data_template[iter_23_3].icon] then
				var_23_1["furnitureicon/" .. pg.furniture_data_template[iter_23_3].icon] = true

				table.insert(var_23_0, "furnitureicon/" .. pg.furniture_data_template[iter_23_3].icon)
			end

			if "furnitrues/" .. pg.furniture_data_template[iter_23_3].picture == "furnitrues/" then
				-- block empty
			elseif pg.furniture_data_template[iter_23_3].type == 1 and pg.furniture_data_template[iter_23_3].tag == 3 then
				for iter_23_4 = 1, 4 do
					if not var_23_1[("furnitrues/" .. pg.furniture_data_template[iter_23_3].picture) .. iter_23_4] then
						var_23_1[("furnitrues/" .. pg.furniture_data_template[iter_23_3].picture) .. iter_23_4] = true

						table.insert(var_23_0, ("furnitrues/" .. pg.furniture_data_template[iter_23_3].picture) .. iter_23_4)
					end
				end
			elseif pg.furniture_data_template[iter_23_3].spine and pg.furniture_data_template[iter_23_3].spine ~= "" then
				local var_23_2
				local var_23_3

				if pg.furniture_data_template[iter_23_3].spine[1] and #pg.furniture_data_template[iter_23_3].spine[1] > 0 and type(pg.furniture_data_template[iter_23_3].spine[1][1]) == "string" then
					var_23_2 = "sfurniture/" .. pg.furniture_data_template[iter_23_3].spine[1][1]
				end

				if pg.furniture_data_template[iter_23_3].spine[2] and #pg.furniture_data_template[iter_23_3].spine[2] > 0 and type(pg.furniture_data_template[iter_23_3].spine[2][1]) == "string" then
					var_23_3 = "sfurniture/" .. pg.furniture_data_template[iter_23_3].spine[2][1]
				end

				if var_23_2 and not var_23_1[var_23_2] then
					var_23_1[var_23_2] = true

					table.insert(var_23_0, var_23_2)
				end

				if var_23_3 and not var_23_1[var_23_3] then
					var_23_1[var_23_3] = true

					table.insert(var_23_0, var_23_3)
				end
			elseif not var_23_1["furnitrues/" .. pg.furniture_data_template[iter_23_3].picture] then
				var_23_1["furnitrues/" .. pg.furniture_data_template[iter_23_3].picture] = true

				table.insert(var_23_0, "furnitrues/" .. pg.furniture_data_template[iter_23_3].picture)
			end
		end
	end

	for iter_23_5, iter_23_6 in ipairs((getProxy(DormProxy):GetSystemThemes())) do
		if iter_23_6:getConfig("is_view") == 1 and not iter_23_6:IsOverTime() then
			if not var_23_1["furnitureicon/" .. pg.backyard_theme_template[iter_23_6.id].icon] then
				var_23_1["furnitureicon/" .. pg.backyard_theme_template[iter_23_6.id].icon] = true

				table.insert(var_23_0, "furnitureicon/" .. pg.backyard_theme_template[iter_23_6.id].icon)
			end

			local var_23_4 = "backyardtheme/theme_" .. iter_23_6.id

			if not var_23_1["backyardtheme/theme_" .. iter_23_6.id] then
				var_23_1[var_23_4] = true

				table.insert(var_23_0, var_23_4)
			end

			local var_23_5 = "backyardtheme/" .. iter_23_6.id

			if not var_23_1["backyardtheme/" .. iter_23_6.id] then
				var_23_1[var_23_5] = true

				table.insert(var_23_0, var_23_5)
			end
		end
	end

	return var_23_0
end

function NewBackYardShopLayer:UpdateSpecialPageFooter()
	setActive(self.btns[5]:Find("new"), getProxy(SettingsProxy):IsTipNewGemFurniture())
end

function NewBackYardShopLayer:willExit()
	self.isOverlay = false

	self.contextData.filterPanel:Destroy()
	self.themePage:Destroy()
	self.furniturePage:Destroy()
	self.contextData.furnitureMsgBox:Destroy()

	self.contextData.furnitureMsgBox = nil

	self.contextData.themeMsgBox:Destroy()

	self.contextData.themeMsgBox = nil
end

return NewBackYardShopLayer
