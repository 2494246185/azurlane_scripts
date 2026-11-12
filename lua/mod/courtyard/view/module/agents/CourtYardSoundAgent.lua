local CourtYardSoundAgent = class("CourtYardSoundAgent", import(".CourtYardAgent"))

function CourtYardSoundAgent:Play(arg_1_1)
	if not arg_1_1 then
		return
	end

	self:Stop()

	self.curVoiceKey = arg_1_1

	pg.CriMgr.GetInstance():PlaySoundEffect_V3(self.curVoiceKey)
end

function CourtYardSoundAgent:Stop()
	if self.curVoiceKey ~= nil then
		pg.CriMgr.GetInstance():UnloadSoundEffect_V3(self.curVoiceKey)
	end

	self.curVoiceKey = nil
end

function CourtYardSoundAgent:Clear()
	self:Stop()
end

function CourtYardSoundAgent:Dispose()
	self:Stop()
end

return CourtYardSoundAgent
