local TimelinePlayer = class("TimelinePlayer")

function TimelinePlayer:Ctor(arg_1_1, arg_1_2)
	self.comDirector = arg_1_1:GetComponent(typeof(UnityEngine.Playables.PlayableDirector))

	if GetComponent(arg_1_1, typeof(TimelineSpeed)) then
		self:SetSpeed(1)
	else
		GetOrAddComponent(arg_1_1, typeof(TimelineSpeed))
	end

	self.signalReceiver = GetOrAddComponent(arg_1_1, "DftCommonSignalReceiver")

	self.signalReceiver:SetCommonEvent(function(arg_2_0)
		self:TriggerEvent(arg_2_0)
	end)
	self.comDirector:Stop()

	self.comDirector.extrapolationMode = arg_1_2 or ReflectionHelp.RefGetField(typeof("UnityEngine.Playables.DirectorWrapMode"), "Hold", nil)

	TimelineSupport.InitTimeline(self.comDirector)
end

function TimelinePlayer:Register(arg_3_1, arg_3_2)
	if arg_3_1 then
		self.comDirector.time = math.clamp(arg_3_1, 0, self.comDirector.duration)
	end

	if arg_3_2 then
		self.triggerFunc = arg_3_2
	end
end

function TimelinePlayer:TriggerEvent(arg_4_1)
	assert(self.triggerFunc)
	self:triggerFunc(arg_4_1, self.mark)
end

function TimelinePlayer:Start()
	self.mark = {}

	self:Play()
end

function TimelinePlayer:Play()
	self.comDirector:Play()
end

function TimelinePlayer:Pause()
	self.comDirector:Pause()
end

function TimelinePlayer:Stop()
	self.comDirector:Stop()
end

function TimelinePlayer:Resume()
	self.comDirector:Resume()
end

function TimelinePlayer:SetSpeed(arg_10_1)
	setDirectorSpeed(self.comDirector, arg_10_1)
end

function TimelinePlayer:GetTime()
	return self.comDirector.time
end

function TimelinePlayer:SetTime(arg_12_1)
	self.comDirector.time = arg_12_1

	self.comDirector:RebuildGraph()
end

function TimelinePlayer:RawSetTime(arg_13_1)
	self.comDirector.time = arg_13_1

	self.comDirector:Evaluate()
end

function TimelinePlayer:Dispose()
	return
end

return TimelinePlayer
