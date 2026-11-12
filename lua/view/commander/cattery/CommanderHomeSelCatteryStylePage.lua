local CommanderHomeSelCatteryStylePage = class("CommanderHomeSelCatteryStylePage", import("...base.BaseSubView"))

function CommanderHomeSelCatteryStylePage:getUIName()
	return "CommanderHomeSelCatteryStylePage"
end

function CommanderHomeSelCatteryStylePage:OnCatteryUpdate(arg_2_1)
	self.cattery = arg_2_1

	self:Update(self.home, arg_2_1)
end

function CommanderHomeSelCatteryStylePage:OnCatteryStyleUpdate(arg_3_1)
	self:OnCatteryUpdate(arg_3_1)
end

function CommanderHomeSelCatteryStylePage:OnLoaded()
	self.scrollrect = self._tf:Find("scrollrect"):GetComponent("LScrollRect")
	self.okBtn = self._tf:Find("ok_button")

	setActive(self._tf, true)
end

function CommanderHomeSelCatteryStylePage:OnInit()
	self.cards = {}

	function self.scrollrect.onInitItem(arg_6_0)
		self:OnInitItem(arg_6_0)
	end

	function self.scrollrect.onUpdateItem(arg_7_0, arg_7_1)
		self:OnUpdateItem(arg_7_0, arg_7_1)
	end

	onButton(self, self.okBtn, function()
		if self.selectedID then
			self:emit(CommanderHomeMediator.ON_CHANGE_STYLE, self.cattery.id, self.selectedID)
		end
	end, SFX_PANEL)
end

function CommanderHomeSelCatteryStylePage:OnInitItem(arg_9_1)
	local var_9_0 = CatteryStyleCard.New(arg_9_1)

	onButton(self, var_9_0._tf, function()
		if not var_9_0.style:IsOwn() then
			pg.TipsMgr.GetInstance():ShowTips(i18n("cathome_style_unlock"))

			return
		end

		self.selectedID = var_9_0.style.id

		self:emit(CatteryDescPage.CHANGE_STYLE, var_9_0.style.id)
	end, SFX_PANEL)

	self.cards[arg_9_1] = var_9_0
end

function CommanderHomeSelCatteryStylePage:OnUpdateItem(arg_11_1, arg_11_2)
	local var_11_0 = self.cards[arg_11_2]
	local var_11_1

	if not self.cards[arg_11_2] then
		self:OnInitItem(arg_11_2)

		var_11_0 = self.cards[arg_11_2]
		var_11_1 = self.cattery:GetStyle() == self.displays[arg_11_1 + 1].id
	end

	var_11_0:Update(self.displays[arg_11_1 + 1], var_11_1)
end

function CommanderHomeSelCatteryStylePage:Update(arg_12_1, arg_12_2)
	self:Show()

	self.home = arg_12_1
	self.cattery = arg_12_2
	self.displays = {}

	local var_12_0 = arg_12_1:GetOwnStyles()

	for iter_12_0, iter_12_1 in ipairs(pg.commander_home_style.all) do
		table.insert(self.displays, (CatteryStyle.New({
			id = iter_12_1,
			own = table.contains(var_12_0, iter_12_1)
		})))
	end

	self.scrollrect:SetTotalCount(#self.displays)
end

function CommanderHomeSelCatteryStylePage:OnDestroy()
	for iter_13_0, iter_13_1 in pairs(self.cards) do
		iter_13_1:Dispose()
	end
end

return CommanderHomeSelCatteryStylePage
