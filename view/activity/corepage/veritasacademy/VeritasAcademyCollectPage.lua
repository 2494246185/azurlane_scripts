local VeritasAcademyCollectPage = class("VeritasAcademyCollectPage", import("view.activity.CorePage.EscapeManor.EscapeManorCollectPage"))

function VeritasAcademyCollectPage:OnInit()
	VeritasAcademyCollectPage.super.OnInit(self)

	self.msgBox = VeritasAcademyCollectMsgBox.New(self._tf, self.event)
end

return VeritasAcademyCollectPage
