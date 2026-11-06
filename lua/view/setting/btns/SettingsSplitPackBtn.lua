local SettingsSplitPackBtn = class("SettingsSplitPackBtn")

function SettingsSplitPackBtn:Ctor(arg_1_1)
	pg.DelegateInfo.New(self)

	self.mgr = pg.SplitPackDownloadMgr.GetInstance()

	self:findUI(arg_1_1)
	self:addListener()
	self:check()
end

function SettingsSplitPackBtn:Dispose()
	pg.DelegateInfo.Dispose(self)
	self:stopTimer()
end

function SettingsSplitPackBtn:findUI(arg_3_1)
	self._tf = arg_3_1

	local var_3_0 = findTF(self._tf, "MainGroup/Content")

	self.progressBar = findTF(var_3_0, "Progress")
	self.btn = findTF(var_3_0, "Btn")
	self.btnText = findTF(self.btn, "Text")
	self.loadingIcon = findTF(var_3_0, "Status/Loading")
	self.newIcon = findTF(var_3_0, "Status/New")
	self.finishIcon = findTF(var_3_0, "Status/Finish")

	setText(findTF(self._tf, "Title/Text"), i18n("setting_download_basic_assets"))
	setText(findTF(var_3_0, "Title"), i18n("setting_download_basic_assets"))
end

function SettingsSplitPackBtn:addListener()
	onButton(self, self._tf, function()
		if self.mgr:GetState() == pg.SplitPackDownloadMgr.State.Fail then
			self.mgr:StartMainDownload()
			self:updateUI()
		end
	end, SFX_PANEL)
end

function SettingsSplitPackBtn:check()
	self.timer = Timer.New(function()
		self:updateUI()
	end, 0.5, -1)

	self.timer:Start()
	self:updateUI()
end

function SettingsSplitPackBtn:stopTimer()
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

function SettingsSplitPackBtn:updateUI()
	local var_9_0 = self.mgr:GetState()
	local var_9_1 = self.mgr:IsDownloading()
	local var_9_2 = var_9_0 == pg.SplitPackDownloadMgr.State.Success
	local var_9_3 = self.mgr:GetProgress()
	local var_9_4

	if var_9_3 then
		var_9_4 = var_9_3.successCount or 0

		local var_9_5

		if var_9_3 then
			var_9_5 = var_9_3.totalCount or 0
		end
	end

	setActive(self.loadingIcon, var_9_1)
	setActive(self.newIcon, false)
	setActive(self.finishIcon, var_9_2)

	if var_9_5 > 0 then
		setSlider(self.progressBar, 0, var_9_5, var_9_2 and var_9_5 or var_9_4)
		setText(self.btnText, (var_9_2 and var_9_5 or var_9_4) .. "/" .. var_9_5)
	else
		setSlider(self.progressBar, 0, 1, var_9_2 and 1 or 0)
		setText(self.btnText, (var_9_2 and 1 or 0) .. "/" .. 1)
	end

	if var_9_0 == pg.SplitPackDownloadMgr.State.Fail then
		setText(self.btnText, i18n("setting_restart_download_btn"))
	elseif var_9_0 == pg.SplitPackDownloadMgr.State.Success then
		setText(self.btnText, i18n("word_maingroup_updatesuccess"))
	end

	if var_9_2 then
		self:stopTimer()
	end
end

return SettingsSplitPackBtn
