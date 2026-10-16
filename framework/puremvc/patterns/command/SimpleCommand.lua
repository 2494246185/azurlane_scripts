local SimpleCommand = class("SimpleCommand", (import("..observer.Notifier")))

function SimpleCommand:Ctor()
	SimpleCommand.super.Ctor(self)
end

function SimpleCommand:execute(arg_2_1)
	return
end

return SimpleCommand
