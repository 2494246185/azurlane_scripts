local ActivityRemasterInfoWithoutTextDisplayPage = class("ActivityRemasterInfoWithoutTextDisplayPage", import(".ActivityRemasterInfoDisplayPage"))

function ActivityRemasterInfoWithoutTextDisplayPage:getUIName()
	return "ActivityRemasterInfoWithoutTextDisplayPage"
end

function ActivityRemasterInfoWithoutTextDisplayPage:OpenDesc(arg_2_1)
	self.awardPage:ExecuteAction("Show", arg_2_1)
end

return ActivityRemasterInfoWithoutTextDisplayPage
