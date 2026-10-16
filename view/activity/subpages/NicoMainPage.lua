local NicoMainPage = class("NicoMainPage", import(".TemplatePage.PreviewTemplatePage"))

function NicoMainPage:OnInit()
	NicoMainPage.super.OnInit(self)

	self.progress = self.bg:Find("progress")
end

function NicoMainPage:OnDataSetting()
	self.taskProxy = getProxy(TaskProxy)
	self.taskGroup = self.activity:getConfig("config_data")

	return updateActivityTaskStatus(self.activity)
end

function NicoMainPage:OnUpdateFlush()
	self.nday = self.activity.data3

	local var_3_0, var_3_1 = self:getColor()
	local var_3_2 = #self.taskGroup

	setText(self.progress, (var_3_0 and setColorStr(self.nday, var_3_0) or self.nday) .. (var_3_1 and setColorStr("/" .. var_3_2, var_3_1) or var_3_2))
	self:PlayStory()
end

function NicoMainPage:getColor()
	return "#ac8c9f", "#FF6767"
end

function NicoMainPage:PlayStory()
	local var_5_0 = self.activity:getConfig("config_client").story

	if checkExist(var_5_0, {
		self.nday
	}, {
		1
	}) then
		pg.NewStoryMgr.GetInstance():Play(var_5_0[self.nday][1], function()
			if checkExist(var_5_0, {
				self.nday
			}, {
				2
			}) then
				pg.NewStoryMgr.GetInstance():Play(var_5_0[self.nday][2])
			end
		end)
	end
end

return NicoMainPage
