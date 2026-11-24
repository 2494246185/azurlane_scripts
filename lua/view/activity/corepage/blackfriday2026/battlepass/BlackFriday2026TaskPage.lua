local BlackFriday2026TaskPage = class("BlackFriday2026TaskPage", import("view.activity.CorePage.PSS.Hei5.PSSHei5TaskPage"))

function BlackFriday2026TaskPage:getUIName()
	return "BlackFriday2026TaskPage"
end

function BlackFriday2026TaskPage:OnLoaded()
	self:initTplVar()
	self:UpdateActivity()

	local var_2_0 = self._tf:Find("frame")

	self.togglesTF = var_2_0:Find("week_list")
	self.toggleCount = self.togglesTF:Find("count")

	local var_2_1 = var_2_0:Find("view/content")
	local var_2_2 = var_2_1:Find("tpl")

	setText(var_2_2:Find("info/go/Text"), i18n(self.btnGoText))
	setText(var_2_2:Find("info/get/Text"), i18n(self.btnGetText))
	setText(var_2_2:Find("info/got/Image/Text"), i18n("task_got"))

	self.taskGroupItemList = UIItemList.New(var_2_1, var_2_2)
end

return BlackFriday2026TaskPage
