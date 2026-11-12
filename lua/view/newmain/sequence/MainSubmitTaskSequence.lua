local MainSubmitTaskSequence = class("MainSubmitTaskSequence")

function MainSubmitTaskSequence:Execute(arg_1_1)
	getProxy(TaskProxy):pushAutoSubmitTask()
	arg_1_1()
end

return MainSubmitTaskSequence
