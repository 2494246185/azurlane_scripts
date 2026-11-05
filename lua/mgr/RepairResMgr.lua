pg = pg or {}
pg.RepairResMgr = singletonClass("RepairResMgr")

local var_0_0 = pg.RepairResMgr

pg.RepairResMgr.OPTION_LIST = {
	{
		textKey = "resource_repair_op1",
		name = "default",
		group = "DEFAULT_RES",
		hashFile = "hashes.csv"
	},
	{
		textKey = "resource_repair_op2",
		name = "live2d",
		group = "L2D",
		hashFile = "hashes-live2d.csv"
	},
	{
		textKey = "resource_repair_op3",
		name = "painting",
		group = "PAINTING",
		hashFile = "hashes-painting.csv"
	},
	{
		textKey = "resource_repair_op4",
		name = "cipher",
		group = "CIPHER",
		hashFile = "hashes-cipher.csv"
	},
	{
		textKey = "resource_repair_op5",
		name = "cv",
		group = "CV",
		hashFile = "hashes-cv.csv"
	}
}

function pg.RepairResMgr.Init(arg_1_0, arg_1_1)
	LoadAndInstantiateAsync("ui", "RepairNewUI", function(arg_2_0)
		arg_1_0:InitUI(arg_2_0)
		arg_1_1()
	end, true, true)
end

function pg.RepairResMgr:InitRes()
	self.iconSpriteMap = {}

	local var_3_0 = self._tf:Find("Res")

	for iter_3_0, iter_3_1 in ipairs(var_0_0.OPTION_LIST) do
		local var_3_1 = string.format("icon_res_type_%s_normal", iter_3_1.name)
		local var_3_2 = string.format("icon_res_type_%s_selected", iter_3_1.name)

		print(var_3_1, var_3_2)

		local var_3_3 = var_3_0:Find(var_3_1)
		local var_3_4 = var_3_0:Find(var_3_2)

		self.iconSpriteMap[iter_3_1.name] = {
			var_3_3:GetComponent(typeof(Image)).sprite,
			var_3_4:GetComponent(typeof(Image)).sprite
		}
	end
end

function pg.RepairResMgr:InitUIText()
	setText(self._tf:Find("window/top/title"), i18n("msgbox_repair_title"))
	setText(self._tf:Find("window/top/title/title_en"), "REPAIR")
	setText(self._tf:Find("window/content/TextPanel/Text_1"), i18n("resource_repair_tips1"))
	setText(self._tf:Find("window/content/TextPanel/Text_2"), i18n("resource_repair_tips2"))
	setText(self.repairTF:Find("top/title"), i18n("msgbox_repair_title"))
	setText(self.repairTF:Find("top/title/title_en"), "REPAIR")
end

function pg.RepairResMgr:InitBtnList()
	self.uiItemList:make(function(arg_6_0, arg_6_1, arg_6_2)
		if arg_6_0 == UIItemList.EventUpdate then
			self:InitBtn(arg_6_1 + 1, arg_6_2)
		end
	end)
	self.uiItemList:align(#var_0_0.OPTION_LIST)
end

function pg.RepairResMgr:InitBtn(arg_7_1, arg_7_2)
	setImageSprite(arg_7_2:Find("Normal"):Find("Icon"), self.iconSpriteMap[var_0_0.OPTION_LIST[arg_7_1].name][1])
	setImageSprite(arg_7_2:Find("Selected"):Find("Icon"), self.iconSpriteMap[var_0_0.OPTION_LIST[arg_7_1].name][2])
	setText(arg_7_2:Find("Text"), i18n(var_0_0.OPTION_LIST[arg_7_1].textKey))
end

function pg.RepairResMgr:InitToggles()
	self.toggleList = {}

	for iter_8_0 = 1, #var_0_0.OPTION_LIST do
		self.toggleList[iter_8_0] = self.containerTF:GetChild(iter_8_0 - 1):GetComponent(typeof(Toggle))
	end
end

function pg.RepairResMgr:InitUI(arg_9_1)
	self._go = arg_9_1
	self._tf = self._go.transform

	self._go:SetActive(false)

	self.parentTr = pg.UIMgr.GetInstance().OverlayToast

	self._go.transform:SetParent(self.parentTr, false)

	self.tpl = self._tf:Find("Tpl")
	self.containerTF = self._tf:Find("window/content/SelectPanel")
	self.uiItemList = UIItemList.New(self.containerTF, self.tpl)
	self.windowTF = self._tf:Find("window")
	self.repairTF = self._tf:Find("Repair")

	self:InitUIText()
	self:InitRes()
	self:InitBtnList()

	self.closeBtn = self._tf:Find("window/top/btnBack")
	self.cancelBtn = self._tf:Find("window/buttons/custom_button_1")
	self.confirmBtn = self._tf:Find("window/buttons/custom_button_2")
	self.repairText = self.repairTF:Find("content/Text")

	self:InitToggles()
end

function pg.RepairResMgr:SetToggleValue(arg_10_1, arg_10_2)
	self.toggleList[arg_10_1].isOn = arg_10_2

	setActive(self.toggleList[arg_10_1].transform:Find("Selected"), arg_10_2)
end

function pg.RepairResMgr:GetSelectedOptions()
	local var_11_0 = {}

	for iter_11_0, iter_11_1 in ipairs(var_0_0.OPTION_LIST) do
		if self.toggleList[iter_11_0].isOn then
			table.insert(var_11_0, iter_11_1)
		end
	end

	return var_11_0
end

function pg.RepairResMgr:GetCurLabel()
	return i18n(self.curOption.textKey)
end

function pg.RepairResMgr:GetQueueProgress()
	return tostring(self.queueIndex) .. "/" .. tostring(#self.queue)
end

function pg.RepairResMgr.GetOptionNames(arg_14_0, arg_14_1)
	local var_14_0 = {}

	for iter_14_0, iter_14_1 in ipairs(arg_14_1) do
		table.insert(var_14_0, i18n(iter_14_1.textKey))
	end

	return table.concat(var_14_0, "、")
end

function pg.RepairResMgr:SetStatus(arg_15_1)
	setText(self.repairText, arg_15_1)
end

function pg.RepairResMgr:ShowRepairPanel(arg_16_1)
	setActive(self.windowTF, not arg_16_1)
	setActive(self.repairTF, arg_16_1)
end

function pg.RepairResMgr:Repair()
	if self.busy then
		return
	end

	self:ShowRepairPanel(false)
	pg.DelegateInfo.New(self)
	self._go:SetActive(true)
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
	onButton(self, self._tf, function()
		self:Hide()
	end, SFX_PANEL)
	onButton(self, self.closeBtn, function()
		self:Hide()
	end, SFX_PANEL)
	onButton(self, self.cancelBtn, function()
		self:Hide()
	end, SFX_PANEL)
	onButton(self, self.confirmBtn, function()
		self:OnConfirm()
	end, SFX_PANEL)
end

function pg.RepairResMgr:OnConfirm()
	if self.busy then
		return
	end

	local var_22_0 = self:GetSelectedOptions()

	if #var_22_0 == 0 then
		pg.TipsMgr.GetInstance():ShowTips(i18n("resource_repair_tips3"))

		return
	end

	self:StartRepairQueue(var_22_0)
end

function pg.RepairResMgr:StartRepairQueue(arg_23_1)
	self.busy = true
	self.queue = arg_23_1
	self.queueIndex = 0
	self.repairedList = {}
	self.failedList = {}
	self.noBrokenList = {}

	self:SetStatus("")
	self:ShowRepairPanel(true)
	self:RepairNext()
end

function pg.RepairResMgr:RepairNext()
	self.queueIndex = self.queueIndex + 1

	if self.queue[self.queueIndex] == nil then
		self:OnQueueFinished()

		return
	end

	local var_24_0 = BundleWizard.Inst:GetGroupMgr(self.queue[self.queueIndex].group)

	if var_24_0 == nil or not PathMgr.FileExists(Application.persistentDataPath .. "/" .. self.queue[self.queueIndex].hashFile) then
		self:RepairNext()

		return
	end

	self.curOption = self.queue[self.queueIndex]
	self.curGroup = var_24_0

	var_24_0:StartVerify(function(arg_25_0)
		self:OnCheckProgress(arg_25_0)
	end, function()
		self:OnGroupUnbroken()
	end, function(arg_27_0)
		self:OnGroupBroken(arg_27_0)
	end, function()
		self:OnFixProgress()
	end, function()
		self:OnGroupFixComplete()
	end)
end

function pg.RepairResMgr:OnCheckProgress(arg_30_1)
	self:SetStatus(i18n("resource_repair_check", self:GetCurLabel(), self:GetQueueProgress(), tostring(math.floor(arg_30_1))))
end

function pg.RepairResMgr:OnGroupUnbroken()
	table.insert(self.noBrokenList, self.curOption)
	self:RepairNext()
end

function pg.RepairResMgr.OnGroupBroken(arg_32_0, arg_32_1)
	arg_32_1:DynamicInvoke(true)
end

function pg.RepairResMgr:OnFixProgress()
	self:SetStatus(i18n("resource_repairing", self:GetCurLabel(), self:GetQueueProgress(), tostring((self.curGroup.downloadTotal > 0 or nil) and math.floor(self.curGroup.downloadCount * 100 / self.curGroup.downloadTotal))))
end

function pg.RepairResMgr:OnGroupFixComplete()
	if self.curGroup.state == DownloadState.UpdateSuccess then
		table.insert(self.repairedList, self.curOption)
	else
		table.insert(self.failedList, self.curOption)
	end

	self:RepairNext()
end

function pg.RepairResMgr:BuildResultText()
	local var_35_0 = {}

	if #self.noBrokenList > 0 then
		table.insert(var_35_0, i18n("resource_repair_report1", self:GetOptionNames(self.noBrokenList)))
	end

	if #self.repairedList > 0 then
		table.insert(var_35_0, i18n("resource_repair_report2", self:GetOptionNames(self.repairedList)))
	end

	if #self.failedList > 0 then
		table.insert(var_35_0, i18n("resource_repair_report3", self:GetOptionNames(self.failedList)))
	end

	return table.concat(var_35_0, "\n")
end

function pg.RepairResMgr:OnQueueFinished()
	self.busy = false

	self:ShowRepairPanel(false)

	local var_36_0 = self:BuildResultText()

	if var_36_0 == "" then
		pg.TipsMgr.GetInstance():ShowTips(i18n("word_no_cache"))
	else
		local function var_36_1()
			if #self.repairedList > 0 then
				local function var_37_0()
					Application.Quit()
				end

				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					hideNo = true,
					content = i18n("resource_repair_finish_tips"),
					onYes = var_37_0,
					onNo = var_37_0
				})
			end
		end

		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			hideNo = true,
			content = var_36_0,
			onYes = var_36_1,
			onNo = var_36_1
		})
	end

	self:Hide()
end

function pg.RepairResMgr:Hide()
	if self.busy then
		return
	end

	pg.DelegateInfo.Dispose(self)
	self._go:SetActive(false)
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, self.parentTr)
end
