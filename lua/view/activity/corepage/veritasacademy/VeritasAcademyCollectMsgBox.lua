local VeritasAcademyCollectMsgBox = class("VeritasAcademyCollectMsgBox", import("view.activity.CorePage.DOA.DOACoreActivityMsgBox"))

function VeritasAcademyCollectMsgBox:getUIName()
	return "VeritasAcademyCollectMsgBox"
end

function VeritasAcademyCollectMsgBox:OnInit()
	self.window = self._tf:Find("window")
	self.page = self._tf:Find("window/page")
	self.title = self.page:Find("name_mask/name")
	self.owner = self.page:Find("owner")

	setText(self.owner:Find("title"), i18n("collect_page_got"))

	self.ownerLimit = self.page:Find("owner_limit")

	setText(self.ownerLimit:Find("title"), i18n("collect_page_got"))

	self.iconTF = self.page:Find("left/IconTpl")
	self.ownTF = self.page:Find("left/own")
	self.detailTF = self.page:Find("left/detail")
	self.desc = self.page:Find("content/desc")
	self.list = self.window:Find("skipable_list")
	self.tpl = self.list:Find("tpl")
end

function VeritasAcademyCollectMsgBox:setWindowSize(arg_3_1)
	return
end

return VeritasAcademyCollectMsgBox
