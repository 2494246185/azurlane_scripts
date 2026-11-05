local Settings3DPage = class("Settings3DPage", import("...base.BaseSubView"))

function Settings3DPage:getUIName()
	return "SettingsCombinationPage"
end

function Settings3DPage:OnLoaded()
	self:OnBindEvent()

	self.panelContainer = self._tf:Find("content")
	self.panels = {}

	for iter_2_0, iter_2_1 in ipairs((self:GetPanels())) do
		table.insert(self.panels, iter_2_1.New(self.panelContainer))
	end

	self.contentSizeFitter = self.panelContainer:GetComponent(typeof(ContentSizeFitter))
	self.cg = self._tf:GetComponent(typeof(CanvasGroup))
	self.scrollrect = self.panelContainer:GetComponent(typeof(ScrollRect))

	self:InitPanels()
	setActive(self._tf, true)
end

function Settings3DPage:OnBindEvent()
	self:bind(SettingsOtherGraphicsPanle.EVT_UPDTAE, function()
		local var_4_0 = self:GetPanel(SettingsOtherGraphicsPanle)

		if var_4_0 then
			var_4_0:RefreshPanelByGraphcLevel()
			self:RebuildLayout(function()
				return
			end)
		end
	end)
	self:bind(SettingsGraphicsPanle.EVT_UPDTAE, function()
		local var_6_0 = self:GetPanel(SettingsGraphicsPanle)

		if var_6_0 then
			var_6_0:OnUpdate()
		end
	end)
end

function Settings3DPage:GetPanels()
	local var_7_0 = {
		SettingsGraphicsPanle,
		SettingsOtherGraphicsPanle
	}

	if self:NeedAdjustScreen() then
		table.insert(var_7_0, 1, SettingsAdjustScreenPanle)
	end

	return var_7_0
end

function Settings3DPage:NeedAdjustScreen()
	return Screen.width / Screen.height - 0.001 > ADAPT_NOTICE
end

function Settings3DPage:GetPanel(arg_9_1)
	if not self.panels then
		return nil
	end

	return _.detect(self.panels, function(arg_10_0)
		return isa(arg_10_0, arg_9_1)
	end)
end

function Settings3DPage:InitPanels()
	local var_11_0 = {}
	local var_11_1 = GetOrAddComponent(self.contentSizeFitter, typeof(CanvasGroup))

	self.scrollrect.enabled = false

	for iter_11_0, iter_11_1 in ipairs(self.panels) do
		table.insert(var_11_0, function(arg_12_0)
			iter_11_1:Init(arg_12_0)
		end)
	end

	seriesAsync(var_11_0, function()
		self.scrollrect.enabled = true

		self:OnInitPanle()
	end)
end

function Settings3DPage:RebuildLayout(arg_14_1)
	onDelayTick(function()
		self.contentSizeFitter.enabled = false
		self.contentSizeFitter.enabled = true

		arg_14_1()
	end, 0.05)
end

function Settings3DPage:OnInitPanle()
	if self.contextData.scroll then
		local var_16_0 = self:GetPanel(self.contextData.scroll)

		if var_16_0 then
			self:RebuildLayout(function()
				self:ScrollToPanel(var_16_0)
			end)
		end
	end
end

function Settings3DPage:ScrollToPanel(arg_18_1)
	setAnchoredPosition(self.panelContainer, {
		y = -self.panelContainer:InverseTransformPoint(arg_18_1._tf.position).y
	})
end

function Settings3DPage:OnDestroy()
	for iter_19_0, iter_19_1 in ipairs(self.panels) do
		iter_19_1:Dispose()
	end

	self.panels = nil
end

function Settings3DPage:Show()
	self.cg.blocksRaycasts = true
	self.cg.alpha = 1
end

function Settings3DPage:Hide()
	self.cg.blocksRaycasts = false
	self.cg.alpha = 0
end

return Settings3DPage
