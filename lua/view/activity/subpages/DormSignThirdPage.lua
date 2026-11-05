local DormSignThirdPage = class("DormSignThirdPage", import("view.activity.subPages.DormSignTwoPage"))

function DormSignThirdPage:getResource()
	return {
		"ui/activityuipage/dormsignthirdpage_atlas"
	}
end

function DormSignThirdPage:getUIName()
	return "DormSignThirdPage"
end

function DormSignThirdPage:GetBgParams()
	return self.bg:Find("bg"), "ui/activityuipage/dormsignthirdpage_atlas", "bg"
end

return DormSignThirdPage
