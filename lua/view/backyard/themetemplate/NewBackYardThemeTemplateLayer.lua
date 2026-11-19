local NewBackYardThemeTemplateLayer = class("NewBackYardThemeTemplateLayer", import("...base.BaseUI"))

local function var_0_1(arg_1_0, arg_1_1, arg_1_2)
	local function var_1_0(arg_2_0, arg_2_1)
		setActive(arg_2_0:Find("sel"), arg_2_1)
		setActive(arg_2_0:Find("unsel"), not arg_2_1)
	end

	onButton(arg_1_0, arg_1_1, function()
		if not arg_1_2() then
			return
		end

		if arg_1_0.btn then
			var_1_0(arg_1_0.btn, false)
		end

		var_1_0(arg_1_1, true)

		arg_1_0.btn = arg_1_1
	end, SFX_PANEL)
	var_1_0(arg_1_1, false)
end

function NewBackYardThemeTemplateLayer:forceGC()
	return true
end

function NewBackYardThemeTemplateLayer:getUIName()
	return "NewBackYardTemplateUI"
end

function NewBackYardThemeTemplateLayer:getResource()
	local var_6_0 = NewBackYardThemeTemplateLayer.super.getResource(self)

	table.insert(var_6_0, "ui/BackYardMsgBox")

	return var_6_0
end

function NewBackYardThemeTemplateLayer:preload(arg_7_1)
	_backYardThemeTemplateMsgbox = BackyardMsgBoxMgr.New()

	_backYardThemeTemplateMsgbox:Init(self, arg_7_1)
end

function NewBackYardThemeTemplateLayer:init()
	self.tpl = self._tf:Find("adpter/tag/list/tpl")
	self.container = self._tf:Find("adpter/tag/list")
	self.pageContainer = self._tf:Find("pages")
	self.backBtn = self._tf:Find("adpter/top/fanhui")
	self.homeBtn = self._tf:Find("adpter/top/help")
	self.goldTxt = self._tf:Find("adpter/top/res_gold/Text"):GetComponent(typeof(Text))
	self.gemTxt = self._tf:Find("adpter/top/res_gem/Text"):GetComponent(typeof(Text))
	self.gemAddBtn = self._tf:Find("adpter/top/res_gem/jiahao")
	self.goldAddBtn = self._tf:Find("adpter/top/res_gold/jiahao")
	self.tags = {
		[BackYardConst.THEME_TEMPLATE_TYPE_SHOP] = i18n("backyard_theme_shop_title"),
		[BackYardConst.THEME_TEMPLATE_TYPE_CUSTOM] = i18n("backyard_theme_mine_title"),
		[BackYardConst.THEME_TEMPLATE_TYPE_COLLECTION] = i18n("backyard_theme_collection_title")
	}
	self.listPage = BackYardThemeTemplateListPage.New(self.pageContainer, self.event, self.contextData)
	self.contextData.msgBox = BackYardThemeTemplateMsgBox.New(self._tf, self.event, self.contextData)
end

function NewBackYardThemeTemplateLayer:SetShopThemeTemplate(arg_9_1)
	self.shopThemeTemplate = arg_9_1
end

function NewBackYardThemeTemplateLayer:ShopThemeTemplateUpdate(arg_10_1)
	for iter_10_0, iter_10_1 in pairs(self.shopThemeTemplate) do
		if iter_10_1.id == arg_10_1.id then
			self.shopThemeTemplate[iter_10_0] = arg_10_1

			break
		end
	end

	if self.pageType == BackYardConst.THEME_TEMPLATE_TYPE_SHOP then
		self.listPage:ExecuteAction("ThemeTemplateUpdate", arg_10_1)
	end
end

function NewBackYardThemeTemplateLayer:OnShopTemplatesUpdated(arg_11_1)
	self:SetShopThemeTemplate(arg_11_1)

	if self.pageType == BackYardConst.THEME_TEMPLATE_TYPE_SHOP then
		self.listPage:ExecuteAction("ThemeTemplatesUpdate", (self:GetDataForType(self.pageType)))
	end
end

function NewBackYardThemeTemplateLayer:OnShopTemplatesErro()
	if self.pageType == BackYardConst.THEME_TEMPLATE_TYPE_SHOP then
		self.listPage:ExecuteAction("ThemeTemplatesErro", (self:GetDataForType(self.pageType)))
	end
end

function NewBackYardThemeTemplateLayer:SetCustomThemeTemplate(arg_13_1)
	self.customThemeTemplate = arg_13_1
end

function NewBackYardThemeTemplateLayer:CustomThemeTemplateUpdate(arg_14_1)
	for iter_14_0, iter_14_1 in pairs(self.customThemeTemplate) do
		if iter_14_1.id == arg_14_1.id then
			self.customThemeTemplate[iter_14_0] = arg_14_1

			break
		end
	end

	if self.pageType == BackYardConst.THEME_TEMPLATE_TYPE_CUSTOM then
		self.listPage:ExecuteAction("ThemeTemplateUpdate", arg_14_1)
	end
end

function NewBackYardThemeTemplateLayer:SetCollectionThemeTemplate(arg_15_1)
	self.collectionThemeTemplate = arg_15_1
end

function NewBackYardThemeTemplateLayer:CollectionThemeTemplateUpdate(arg_16_1)
	for iter_16_0, iter_16_1 in pairs(self.collectionThemeTemplate) do
		if iter_16_1.id == arg_16_1.id then
			self.collectionThemeTemplate[iter_16_0] = arg_16_1

			break
		end
	end

	if self.pageType == BackYardConst.THEME_TEMPLATE_TYPE_COLLECTION then
		self.listPage:ExecuteAction("ThemeTemplateUpdate", arg_16_1)
	end
end

function NewBackYardThemeTemplateLayer:SetDorm(arg_17_1)
	self.dorm = arg_17_1
end

function NewBackYardThemeTemplateLayer:UpdateDorm(arg_18_1)
	self:SetDorm(arg_18_1)

	if self.pageType then
		self.listPage:ExecuteAction("UpdateDorm", arg_18_1)
	end
end

function NewBackYardThemeTemplateLayer:SetPlayer(arg_19_1)
	self.player = arg_19_1
end

function NewBackYardThemeTemplateLayer:PlayerUpdated(arg_20_1)
	self:SetPlayer(arg_20_1)
	self:UpdateRes()

	if self.pageType then
		self.listPage:ExecuteAction("PlayerUpdated", arg_20_1)
	end
end

function NewBackYardThemeTemplateLayer:FurnituresUpdated(arg_21_1)
	if self.pageType then
		self.listPage:ExecuteAction("FurnituresUpdated", arg_21_1)
	end
end

function NewBackYardThemeTemplateLayer:SearchKeyChange(arg_22_1)
	if self.pageType and (self.pageType == BackYardConst.THEME_TEMPLATE_TYPE_CUSTOM or self.pageType == BackYardConst.THEME_TEMPLATE_TYPE_COLLECTION) then
		self.listPage:ExecuteAction("SearchKeyChange", arg_22_1)
	end
end

function NewBackYardThemeTemplateLayer:ShopSearchKeyChange(arg_23_1)
	if self.pageType and self.pageType == BackYardConst.THEME_TEMPLATE_TYPE_SHOP then
		self.listPage:ExecuteAction("ShopSearchKeyChange", arg_23_1)
	end
end

function NewBackYardThemeTemplateLayer:ClearShopSearchKey()
	if self.pageType and self.pageType == BackYardConst.THEME_TEMPLATE_TYPE_SHOP then
		self.listPage:ExecuteAction("ClearShopSearchKey")
	end
end

function NewBackYardThemeTemplateLayer:DeleteCustomThemeTemplate(arg_25_1)
	if not self.customThemeTemplate then
		return
	end

	for iter_25_0, iter_25_1 in pairs(self.customThemeTemplate) do
		if iter_25_1.id == arg_25_1 then
			self.customThemeTemplate[iter_25_0] = nil

			break
		end
	end

	if self.pageType and self.pageType == BackYardConst.THEME_TEMPLATE_TYPE_CUSTOM then
		self.listPage:ExecuteAction("DeleteCustomThemeTemplate", arg_25_1)
	end
end

function NewBackYardThemeTemplateLayer:DeleteCollectionThemeTemplate(arg_26_1)
	if not self.collectionThemeTemplate then
		return
	end

	for iter_26_0, iter_26_1 in pairs(self.collectionThemeTemplate) do
		if iter_26_1.id == arg_26_1 then
			self.collectionThemeTemplate[iter_26_0] = nil

			break
		end
	end

	if self.pageType and self.pageType == BackYardConst.THEME_TEMPLATE_TYPE_COLLECTION then
		self.listPage:ExecuteAction("DeleteCollectionThemeTemplate", arg_26_1)
	end
end

function NewBackYardThemeTemplateLayer:DeleteShopThemeTemplate(arg_27_1)
	if not self.shopThemeTemplate then
		return
	end

	for iter_27_0, iter_27_1 in pairs(self.shopThemeTemplate) do
		if iter_27_1.id == arg_27_1 then
			self.shopThemeTemplate[iter_27_0] = nil

			break
		end
	end

	if self.pageType and self.pageType == BackYardConst.THEME_TEMPLATE_TYPE_SHOP then
		self.listPage:ExecuteAction("DeleteShopThemeTemplate", arg_27_1)
	end
end

function NewBackYardThemeTemplateLayer:AddCollectionThemeTemplate(arg_28_1)
	self.collectionThemeTemplate[arg_28_1.id] = arg_28_1

	if self.pageType and self.pageType == BackYardConst.THEME_TEMPLATE_TYPE_COLLECTION then
		self.listPage:ExecuteAction("AddCollectionThemeTemplate", arg_28_1.id)
	end
end

function NewBackYardThemeTemplateLayer:didEnter()
	onButton(self, self.backBtn, function()
		self:emit(NewBackYardThemeTemplateLayer.ON_BACK)
	end, SFX_CANCEL)
	onButton(self, self.homeBtn, function()
		self:emit(NewBackYardThemeTemplateLayer.ON_HOME)
	end, SFX_PANEL)
	onButton(self, self.gemAddBtn, function()
		self:emit(NewBackYardThemeTemplateMediator.ON_CHARGE, PlayerConst.ResDiamond)
	end, SFX_PANEL)
	onButton(self, self.goldAddBtn, function()
		self:emit(NewBackYardThemeTemplateMediator.ON_CHARGE, PlayerConst.ResDormMoney)
	end, SFX_PANEL)
	seriesAsync({
		function(arg_34_0)
			self:emit(NewBackYardThemeTemplateMediator.FETCH_ALL_THEME, arg_34_0)
		end
	}, function()
		self:InitPages()
		self:UpdateRes()
		self:ActiveDefaultPage()
	end)
end

function NewBackYardThemeTemplateLayer:InitPages()
	self.btns = {}

	for iter_36_0, iter_36_1 in pairs(self.tags) do
		local var_36_0 = cloneTplTo(self.tpl, self.container)
		local var_36_1 = var_36_0:Find("unsel"):GetComponent(typeof(Image))

		var_36_1.sprite = GetSpriteFromAtlas("ui/NewBackYardShopUI_atlas", "text_tp_" .. iter_36_0)

		var_36_1:SetNativeSize()

		local var_36_2 = var_36_0:Find("sel/Text"):GetComponent(typeof(Image))

		var_36_2.sprite = GetSpriteFromAtlas("ui/NewBackYardShopUI_atlas", "text_tp_" .. iter_36_0)

		var_36_2:SetNativeSize()
		setActive(var_36_0:Find("line"), iter_36_0 ~= BackYardConst.THEME_TEMPLATE_TYPE_COLLECTION)
		var_0_1(self, var_36_0, function()
			self.listPage:ExecuteAction("SetUp", iter_36_0, self:GetDataForType(iter_36_0), self.dorm, self.player)

			self.pageType = iter_36_0

			return true
		end)

		self.btns[iter_36_0] = var_36_0
	end

	setActive(self.tpl, false)
end

function NewBackYardThemeTemplateLayer:ActiveDefaultPage()
	triggerButton(self.btns[self.contextData.page or BackYardConst.THEME_TEMPLATE_TYPE_CUSTOM])
end

function NewBackYardThemeTemplateLayer:GetDataForType(arg_39_1)
	if arg_39_1 == BackYardConst.THEME_TEMPLATE_TYPE_SHOP then
		local var_39_0 = {}

		for iter_39_0, iter_39_1 in pairs(self.shopThemeTemplate) do
			table.insert(var_39_0, iter_39_1)
		end

		return var_39_0 or {}
	elseif arg_39_1 == BackYardConst.THEME_TEMPLATE_TYPE_CUSTOM then
		local var_39_1 = {}

		for iter_39_2, iter_39_3 in pairs(self.customThemeTemplate) do
			if iter_39_3:CanDispaly() then
				table.insert(var_39_1, iter_39_3)
			end
		end

		return var_39_1
	elseif arg_39_1 == BackYardConst.THEME_TEMPLATE_TYPE_COLLECTION then
		local var_39_2 = {}

		for iter_39_4, iter_39_5 in pairs(self.collectionThemeTemplate) do
			table.insert(var_39_2, iter_39_5)
		end

		return var_39_2 or {}
	end

	assert(false)
end

function NewBackYardThemeTemplateLayer:UpdateRes()
	self.goldTxt.text = self.player:getResource(PlayerConst.ResDormMoney)
	self.gemTxt.text = self.player:getTotalGem()
end

function NewBackYardThemeTemplateLayer:willExit()
	_backYardThemeTemplateMsgbox:Destroy()

	_backYardThemeTemplateMsgbox = nil

	self.listPage:Destroy()
	self.contextData.msgBox:Destroy()
	BackYardThemeTempalteUtil.ClearAllCache()
end

return NewBackYardThemeTemplateLayer
