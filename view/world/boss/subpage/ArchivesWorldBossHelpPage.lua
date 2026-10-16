local ArchivesWorldBossHelpPage = class("ArchivesWorldBossHelpPage", import(".WorldBossHelpPage"))

function ArchivesWorldBossHelpPage:OnLoaded()
	ArchivesWorldBossHelpPage.super.OnLoaded(self)
	setActive(self.worldBtn, false)
end

return ArchivesWorldBossHelpPage
