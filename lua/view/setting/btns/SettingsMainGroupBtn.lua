local SettingsMainGroupBtn = class("SettingsMainGroupBtn")

function SettingsMainGroupBtn:Ctor(arg_1_1)
	pg.DelegateInfo.New(self)
	self:initData()
	self:findUI(arg_1_1)
	self:addListener()
	self:check()
end

function SettingsMainGroupBtn:Dispose()
	pg.DelegateInfo.Dispose(self)

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

function SettingsMainGroupBtn:initData()
	self.mgr = pg.SettingsGroupMgr.GetInstance()
	self.infoName = PaintingGroupConst.PaintingGroupName
	self.groupNameList = {
		GroupMainHelper.DefaultGroupName,
		PaintingGroupConst.PaintingGroupName
	}
end

function SettingsMainGroupBtn:findUI(arg_4_1)
	self._tf = arg_4_1

	local var_4_0 = findTF(self._tf, "Content")

	self.titleText = findTF(var_4_0, "Title")
	self.progressBar = findTF(var_4_0, "Progress")
	self.btn = findTF(var_4_0, "Btn")
	self.btnText = findTF(self.btn, "Text")
	self.loadingIcon = findTF(var_4_0, "Status/Loading")
	self.newIcon = findTF(var_4_0, "Status/New")
	self.finishIcon = findTF(var_4_0, "Status/Finish")

	setText(self.titleText, i18n("setting_resdownload_title_main_group"))
end

function SettingsMainGroupBtn:addListener()
	onButton(self, self._tf, function()
		local var_6_0 = self.mgr:GetState(self.infoName)

		if var_6_0 ~= pg.SettingsGroupMgr.State.Updating and var_6_0 ~= pg.SettingsGroupMgr.State.Success then
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				type = MSGBOX_TYPE_NORMAL,
				content = string.format(i18n("main_group_msgbox_content", (HashUtil.BytesToString((self.mgr:GetTotalSize(self.groupNameList)))))),
				onYes = function()
					GroupMainHelper.SavePrefs(DMFileChecker.Prefs.Max)
					self.mgr:StartDownload(self.infoName, self.groupNameList)
				end
			})
		end
	end, SFX_PANEL)
end

function SettingsMainGroupBtn:check()
	self.timer = Timer.New(function()
		self:updateUI()
	end, 0.5, -1)

	self.timer:Start()
	self:updateUI()
end

function SettingsMainGroupBtn:updateUI()
	local var_10_0 = self.mgr:GetState(self.infoName)

	if var_10_0 == pg.SettingsGroupMgr.State.None then
		setText(self.btnText, i18n("word_maingroup_checktoupdate"))
		setActive(self.loadingIcon, false)
		setActive(self.newIcon, true)
		setActive(self.finishIcon, false)
	elseif var_10_0 == pg.SettingsGroupMgr.State.Updating then
		setText(self.btnText, i18n("word_maingroup_updating"))
		setActive(self.loadingIcon, true)
		setActive(self.newIcon, false)
		setActive(self.finishIcon, false)

		local var_10_1, var_10_2 = self.mgr:GetCountProgress(self.infoName)

		setSlider(self.progressBar, 0, var_10_2, var_10_1)
		setText(self.btnText, var_10_1 .. "/" .. var_10_2)
	elseif var_10_0 == pg.SettingsGroupMgr.State.Success then
		setText(self.btnText, i18n("word_maingroup_updatesuccess"))
		setActive(self.loadingIcon, false)
		setActive(self.newIcon, false)
		setActive(self.finishIcon, true)
	elseif var_10_0 == pg.SettingsGroupMgr.State.Fail then
		setText(self.btnText, i18n("word_maingroup_updatefailure"))
		setActive(self.loadingIcon, false)
		setActive(self.newIcon, false)
		setActive(self.finishIcon, false)
	end
end

return SettingsMainGroupBtn
