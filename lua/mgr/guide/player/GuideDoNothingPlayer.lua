local GuideDoNothingPlayer = class("GuideDoNothingPlayer", import(".GuidePlayer"))

function GuideDoNothingPlayer:OnExecution(arg_1_1, arg_1_2)
	arg_1_2()
end

return GuideDoNothingPlayer
