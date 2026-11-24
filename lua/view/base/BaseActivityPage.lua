local BaseActivityPage = class("BaseActivityPage", import(".BaseSubView"))

function BaseActivityPage:SetShareData(arg_1_1)
	self.shareData = arg_1_1
end

function BaseActivityPage:SetUIName(arg_2_1)
	self._uiName = arg_2_1
end

function BaseActivityPage:getUIName()
	return self._uiName
end

function BaseActivityPage:Init()
	BaseActivityPage.super.Init(self)

	local var_4_0, var_4_1, var_4_2 = self:GetBgParams()

	if var_4_0 then
		GetImageSpriteFromAtlasAsync(var_4_1, var_4_2, var_4_0)
	end
end

function BaseActivityPage:Flush(arg_5_1)
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

function BaseActivityPage:ShowOrHide(arg_6_1)
	SetActive(self._go, arg_6_1)

	if arg_6_1 then
		local var_6_0 = {}

		self:emit(ActivityMainScene.GET_PAGE_BGM, self.__cname, var_6_0)

		if var_6_0.bgm then
			pg.BgmMgr.GetInstance():Push(ActivityMainScene.__cname, var_6_0.bgm)
		end

		self:OnShowFlush()
	else
		self:OnHideFlush()
	end
end

function BaseActivityPage:BindPageLink()
	for iter_7_0, iter_7_1 in ipairs(self:GetPageLink()) do
		ActivityConst.PageIdLink[iter_7_1] = self.activity.id
	end
end

function BaseActivityPage:SwitchOut(arg_8_1)
	arg_8_1()
end

function BaseActivityPage:getResource()
	local var_9_0 = {
		"ui/" .. self:getUIName()
	}
	local var_9_1 = {}

	self:emit(ActivityMainScene.GET_PAGE_BGM, self.__cname, var_9_1)

	if var_9_1.bgm then
		_.each(ResPathSupport.GetSoundResList(var_9_1.bgm), function(arg_10_0)
			table.insert(var_9_0, arg_10_0)
		end)
	end

	return var_9_0
end

function BaseActivityPage:OnInit()
	return
end

function BaseActivityPage:OnDataSetting()
	return
end

function BaseActivityPage:GetPageLink()
	return {}
end

function BaseActivityPage:OnFirstFlush()
	return
end

function BaseActivityPage:OnUpdateFlush()
	return
end

function BaseActivityPage:OnHideFlush()
	return
end

function BaseActivityPage:OnShowFlush()
	return
end

function BaseActivityPage:OnDestroy()
	return
end

function BaseActivityPage:UseSecondPage(arg_19_1)
	return false
end

function BaseActivityPage:GetBgParams()
	return nil, nil, nil
end

return BaseActivityPage
