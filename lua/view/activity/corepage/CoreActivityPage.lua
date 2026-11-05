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

function CoreActivityPage:Init()
	CoreActivityPage.super.Init(self)

	local var_5_0, var_5_1, var_5_2 = self:GetBgParams()

	if var_5_0 then
		GetImageSpriteFromAtlasAsync(var_5_1, var_5_2, var_5_0)
	end
end

function CoreActivityPage:Flush(arg_6_1)
	self.activity = arg_6_1

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

function CoreActivityPage:ShowOrHide(arg_8_1)
	SetActive(self._go, arg_8_1)

	if arg_8_1 then
		local var_8_0 = {}

		self:emit(ActivityMainScene.GET_PAGE_BGM, self.__cname, var_8_0)

		if var_8_0.bgm then
			pg.BgmMgr.GetInstance():Push(ActivityMainScene.__cname, var_8_0.bgm)
		end

		self:OnShowFlush()
	else
		self:OnHideFlush()
	end
end

function CoreActivityPage:BindPageLink()
	for iter_9_0, iter_9_1 in ipairs(self:GetPageLink()) do
		ActivityConst.PageIdLink[iter_9_1] = self.activity.id
	end
end

function CoreActivityPage:SwitchOut(arg_10_1)
	arg_10_1()
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

function CoreActivityPage:UseSecondPage(arg_19_1)
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

function CoreActivityPage:GetBgParams()
	return nil, nil, nil
end

return CoreActivityPage
