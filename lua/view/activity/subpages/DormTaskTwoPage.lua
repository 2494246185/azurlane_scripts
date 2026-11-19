local DormTaskTwoPage = class("DormTaskTwoPage", import("view.activity.subPages.DormTaskPage"))

function DormTaskTwoPage:getResource()
	return {
		"ui/activityuipage/dormtasktwopage_atlas"
	}
end

function DormTaskTwoPage:GetBgParams()
	return self.bg, "ui/activityuipage/dormtasktwopage_atlas", "bg"
end

return DormTaskTwoPage
