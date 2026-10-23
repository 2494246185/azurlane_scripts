local CoreActivityPage = class("CoreActivityPage", import("view.base.BaseSubView"))

function CoreActivityPage:SetShareData(arg_1_1)
	self.shareData = arg_1_1
end

function CoreActivityPage:SetCoreActivityUI(arg_2_1)
	self.coreActivityUI = arg_2_1
end

function CoreActivityPage:SetUIName(arg_3_1)
	self._uiName = arg_3_1
end

function CoreActivityPage:getUIName()
	return self._uiName
end

function CoreActivityPage:Flush(arg_5_1)
	self.activity = arg_5_1

	if self:OnDataSetting() then
		return
	end

	if defaultValue(self.isFirst, true) then
		self.isFirst = false

		self:BindPageLink()
		self:OnFirstFlush()
	end

	self:OnUpdateFlush()
end

function CoreActivityPage:GetAwardPreviewPos()
	if not self.activity then
		return nil
	end

	return self.activity:getConfig("config_client").AwardPreviewPos
end

function CoreActivityPage:ShowOrHide(arg_7_1)
	SetActive(self._go, arg_7_1)

	if arg_7_1 then
		local var_7_0 = {}

		self:emit(ActivityMainScene.GET_PAGE_BGM, self.__cname, var_7_0)

		if var_7_0.bgm then
			pg.BgmMgr.GetInstance():Push(ActivityMainScene.__cname, var_7_0.bgm)
		end

		self:OnShowFlush()
	else
		self:OnHideFlush()
	end
end

function CoreActivityPage:BindPageLink()
	for iter_8_0, iter_8_1 in ipairs(self:GetPageLink()) do
		ActivityConst.PageIdLink[iter_8_1] = self.activity.id
	end
end

function CoreActivityPage:SwitchOut(arg_9_1)
	arg_9_1()
end

function CoreActivityPage:OnInit()
	return
end

function CoreActivityPage:OnDataSetting()
	return
end

function CoreActivityPage:GetPageLink()
	return {}
end

function CoreActivityPage:OnFirstFlush()
	return
end

function CoreActivityPage:OnUpdateFlush()
	return
end

function CoreActivityPage:OnHideFlush()
	return
end

function CoreActivityPage:OnShowFlush()
	return
end

function CoreActivityPage:OnDestroy()
	return
end

function CoreActivityPage:UseSecondPage(arg_18_1)
	return false
end

function CoreActivityPage:IsShowingPopWindow()
	return false
end

function CoreActivityPage:ClosePopWindow()
	return
end

function CoreActivityPage:IsShowReminder()
	return nil
end

return CoreActivityPage
