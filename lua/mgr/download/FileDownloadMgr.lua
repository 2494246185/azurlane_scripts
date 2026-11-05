pg = pg or {}

local var_0_0 = pg

pg.FileDownloadMgr = singletonClass("FileDownloadMgr")

local var_0_1 = pg.FileDownloadMgr

function pg.FileDownloadMgr.Init(arg_1_0, arg_1_1)
	print("initializing filedownloadmgr manager...")
	LoadAndInstantiateAsync("ui", "FileDownloadUI", function(arg_2_0)
		arg_1_0._go = arg_2_0

		arg_1_0._go:SetActive(false)

		arg_1_0._tf = arg_1_0._go.transform

		arg_1_0._tf:SetParent(var_0_0.UIMgr.GetInstance().OverlayMain, false)
		arg_1_0:initUI()
		arg_1_0:initUITextTips()
		arg_1_1()
	end, true, true)
end

function pg.FileDownloadMgr:Main(arg_3_1)
	self.requestQueue = self.requestQueue or {}

	table.insert(self.requestQueue, arg_3_1)
	self:processNext()
end

function pg.FileDownloadMgr:processNext()
	if self.currentRequest then
		return
	end

	self.requestQueue = self.requestQueue or {}

	local var_4_0 = table.remove(self.requestQueue, 1)

	if not var_4_0 then
		self:hide()

		return
	end

	self.currentRequest = var_4_0

	self:setData(var_4_0)
	self:startDownload()
end

function pg.FileDownloadMgr:IsRunning()
	local var_5_1

	if self.currentRequest == nil then
		if #(self.requestQueue or {}) <= 0 then
			var_5_1 = isActive(self._go)

			goto label_5_0
		end
	end

	::label_5_0::

	return true
end

pg.FileDownloadMgr.KEY_STOP_REMIND = "File_Download_Remind_Time"

function pg.FileDownloadMgr.SetRemind(arg_6_0, arg_6_1)
	arg_6_0.isStopRemind = arg_6_1
end

function pg.FileDownloadMgr:IsNeedRemind()
	if self.isStopRemind == true then
		return false
	else
		return true
	end
end

function pg.FileDownloadMgr:show()
	setActive(self.maskTF, self.showMask)
	self._go:SetActive(true)
end

function pg.FileDownloadMgr:hide()
	self._go:SetActive(false)
end

function pg.FileDownloadMgr:initUI()
	self.mainTF = self._tf:Find("Main")
	self.maskTF = self._tf:Find("Mask")
	self.titleText = self.mainTF:Find("Title")
	self.progressText = self.mainTF:Find("ProgressText")
	self.progressBar = self.mainTF:Find("ProgressBar")

	setActive(self.maskTF, false)
end

function pg.FileDownloadMgr:initUITextTips()
	setText(self.titleText, i18n("file_down_mgr_title"))
end

function pg.FileDownloadMgr.initData(arg_12_0)
	arg_12_0.curGroupIndex = 0
	arg_12_0.curGroupMgr = nil
	arg_12_0.dataList = nil
	arg_12_0.onFinish = nil
	arg_12_0.showMask = false
end

function pg.FileDownloadMgr.setData(arg_13_0, arg_13_1)
	arg_13_0.dataList = arg_13_1.dataList
	arg_13_0.onFinish = arg_13_1.onFinish
	arg_13_0.showMask = arg_13_1.showMask == true
end

function pg.FileDownloadMgr:fileProgress(arg_14_1, arg_14_2)
	setText(self.progressText, i18n("file_down_mgr_progress", HashUtil.BytesToString(arg_14_1), (HashUtil.BytesToString(arg_14_2))))
	setSlider(self.progressBar, 0, tonumber(tostring(arg_14_2)), tonumber(tostring(arg_14_1)))
end

function pg.FileDownloadMgr:allComplete(arg_15_1)
	local var_15_0 = arg_15_1 or self.onFinish

	self:initData()

	self.currentRequest = nil

	self:hide()

	if var_15_0 then
		var_15_0()
	end

	self:processNext()
end

function pg.FileDownloadMgr:error(arg_16_1, arg_16_2)
	local function var_16_0()
		Application.Quit()
	end

	self:hide()
	var_0_0.MsgboxMgr.GetInstance():ShowMsgBox({
		modal = true,
		locked = true,
		content = i18n("file_down_mgr_error", arg_16_1, arg_16_2),
		onYes = function()
			self:startDownload()
		end,
		onNo = var_16_0,
		onClose = var_16_0
	})
end

function pg.FileDownloadMgr:download()
	local var_19_0 = self.onFinish

	BundleWizardUpdater.Inst:StartUpdate(self.info, nil, function(arg_21_0, arg_21_1)
		if arg_21_0 then
			self:allComplete(var_19_0)
		else
			self:error("", "")
		end
	end, function(arg_20_0, arg_20_1, arg_20_2, arg_20_3, arg_20_4, arg_20_5)
		self:fileProgress(arg_20_3, arg_20_4)
	end)
end

function pg.FileDownloadMgr:startDownload()
	if self:verifyValidData() then
		self:show()
		self:download()
	else
		self:allComplete()
	end
end

function pg.FileDownloadMgr:verifyValidData()
	self.info = var_0_1.createDownloadFileInfo(self.dataList)

	return BundleWizardUpdater.Inst:GetFileList(self.info).Count > 0
end

function pg.FileDownloadMgr.createDownloadFileInfo(arg_24_0)
	local var_24_0 = BundleWizardUpdateInfo.New()
	local var_24_1 = {}

	for iter_24_0, iter_24_1 in ipairs(arg_24_0) do
		var_24_0:AddGroup(iter_24_1.groupName, iter_24_1.fileNameList)
		table.insert(var_24_1, iter_24_1.groupName)
	end

	var_24_0.infoName = table.concat(var_24_1, "_")

	return var_24_0
end
