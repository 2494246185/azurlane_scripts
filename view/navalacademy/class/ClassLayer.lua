local ClassLayer = class("ClassLayer", import("...base.BaseUI"))

function ClassLayer:getUIName()
	return "ClassUI"
end

function ClassLayer:getResource()
	return {
		"ui/classui"
	}
end

function ClassLayer:SetStudents(arg_3_1)
	self.shipGroups = arg_3_1
end

function ClassLayer:SetCourse(arg_4_1)
	self.course = arg_4_1
end

function ClassLayer:SetClass(arg_5_1)
	self.resClass = arg_5_1
end

function ClassLayer:OnUpdateResField(arg_6_1)
	if not isa(arg_6_1, ClassResourceField) then
		return
	end

	self:SetClass(arg_6_1)
	self:InitClassInfo()

	if self.resFieldPage:GetLoaded() and self.resFieldPage:isShowing() then
		self.resFieldPage:Update(arg_6_1)
	end
end

function ClassLayer:init()
	self.backBtn = self._tf:Find("blur_panel/adapt/top/back")
	self.lessonTxt = self._tf:Find("blur_panel/adapt/bottom/lesson/mask/Text"):GetComponent("ScrollText")
	self.tranSpeedTxt = self._tf:Find("blur_panel/adapt/bottom/progress/proficiency/value"):GetComponent(typeof(Text))
	self.proficiencyProgressTxt = self._tf:Find("blur_panel/adapt/bottom/progress/proficiency/Text"):GetComponent(typeof(Text))
	self.proficiencyProgress = self._tf:Find("blur_panel/adapt/bottom/progress/proficiency/slider/Image")
	self.tranProgressTxt = self._tf:Find("blur_panel/adapt/bottom/progress/book/Text/value"):GetComponent(typeof(Text))
	self.tranProgress = self._tf:Find("blur_panel/adapt/bottom/progress/book/slider/Image")
	self.exp2ProficiencyRatioTxt = self._tf:Find("blur_panel/adapt/top/proficiency/Text"):GetComponent(typeof(Text))
	self.exp2ProficiencyRatio = self._tf:Find("blur_panel/adapt/top/proficiency")
	self.chatProficiency = self._tf:Find("blur_panel/adapt/top/proficiency/chat")
	self.chatProficiencyTxt = self.chatProficiency:Find("Text"):GetComponent(typeof(Text))
	self.helpBtn = self._tf:Find("blur_panel/adapt/top/btn_help")
	self.upgradeBtn = self._tf:Find("blur_panel/adapt/bottom/upgarde")
	self.teacherSeat = self._tf:Find("scene/desk0")
	self.studentSeats = {
		self._tf:Find("scene/desk1"),
		self._tf:Find("scene/desk2"),
		self._tf:Find("scene/desk3"),
		self._tf:Find("scene/desk4"),
		self._tf:Find("scene/desk5")
	}

	setText(self._tf:Find("blur_panel/adapt/bottom/progress/book/Text/label"), i18n("class_label_gen"))
	setText(self._tf:Find("blur_panel/adapt/bottom/progress/proficiency/label"), i18n("class_label_tran"))
	setText(self._tf:Find("blur_panel/adapt/bottom/upgarde/Text"), i18n("word_levelup"))

	self.chars = {}
	self.resFieldPage = ClassResourcePage.New(self._tf, self.event)
end

function ClassLayer:didEnter()
	onButton(self, self.backBtn, function()
		self:emit(BaseUI.ON_BACK)
	end, SFX_CANCEL)
	onButton(self, self.helpBtn, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = i18n("course_class_help")
		})
	end, SFX_PANEL)
	onButton(self, self.upgradeBtn, function()
		self.resFieldPage:ExecuteAction("Flush", self.resClass)
	end, SFX_PANEL)
	onButton(self, self.exp2ProficiencyRatio, function()
		self.chatProficiencyTxt.text = i18n("course_proficiency_tip", pg.gameset.level_get_proficency.key_value, self.resClass:GetExp2ProficiencyRatio() * self.course:getExtraRate())

		self:DisplayChatContent()
	end, SFX_PANEL)

	self.students = self:FilterStudents()

	self:InitClassInfo()
	self:DownloadClassRoomResList(function()
		self:LoadClassRoom()
	end)
end

function ClassLayer:DisplayChatContent()
	setActive(self.chatProficiency, true)
	setButtonEnabled(self.exp2ProficiencyRatio, false)
	LeanTween.scale(rtf(self.chatProficiency), Vector3(1.5, 1.5, 1), 0.3):setFrom(Vector3.zero):setOnComplete(System.Action(function()
		LeanTween.scale(rtf(self.chatProficiency), Vector3(0, 0, 0), 0.2):setDelay(2):setOnComplete(System.Action(function()
			if not IsNil(self.exp2ProficiencyRatio) then
				setButtonEnabled(self.exp2ProficiencyRatio, true)
				setActive(self.chatProficiency, false)
			end
		end))
	end))
end

function ClassLayer:FilterStudents()
	local var_17_0 = {}
	local var_17_1 = self.course:getConfig("type")

	for iter_17_0, iter_17_1 in pairs(self.shipGroups) do
		if table.contains(var_17_1, iter_17_1.shipConfig.type) then
			table.insert(var_17_0, iter_17_1)
		end
	end

	if #var_17_0 > #self.studentSeats then
		shuffle(var_17_0)
	end

	return var_17_0
end

function ClassLayer:GetClassRoomResList()
	local var_18_0 = {}
	local var_18_1 = self.students or {}

	for iter_18_0 = 1, math.min(#var_18_1, #self.studentSeats) do
		local var_18_2 = var_18_1[iter_18_0]:GetSkin()

		if var_18_2 then
			self:InsertClassRoomCharRes(var_18_0, var_18_2.prefab)
		end
	end

	if self.course then
		self:InsertClassRoomCharRes(var_18_0, Ship.New({
			configId = self.course:getConfig("id")
		}):getPrefab())
	end

	return var_18_0
end

function ClassLayer:InsertClassRoomCharRes(arg_19_1, arg_19_2)
	if not arg_19_2 or arg_19_2 == "" then
		return
	end

	for iter_19_0, iter_19_1 in ipairs({
		"char/" .. arg_19_2,
		"char/" .. arg_19_2 .. "_hx"
	}) do
		iter_19_1 = string.lower(iter_19_1)

		if not table.contains(arg_19_1, iter_19_1) then
			table.insert(arg_19_1, iter_19_1)
		end
	end
end

function ClassLayer:DownloadClassRoomResList(arg_20_1)
	SplitPackConst.DownloadByLuaArr(self:GetClassRoomResList(), function()
		if self.exited then
			return
		end

		arg_20_1()
	end)
end

function ClassLayer:InitClassInfo()
	self.lessonTxt:SetText(i18n("course_class_name", self.course:getConfig("name_show")))

	self.tranSpeedTxt.text = "-" .. self.resClass:GetTranValuePreHour() .. "/h"

	local var_22_0 = self.course:GetProficiency()
	local var_22_1 = self.resClass:GetMaxProficiency()

	self.proficiencyProgressTxt.text = var_22_0 .. "/" .. var_22_1

	setFillAmount(self.proficiencyProgress, var_22_0 / var_22_1)

	local var_22_2 = self.resClass:GetTarget()
	local var_22_3 = self.resClass:GetPlayerRes() % var_22_2

	self.tranProgressTxt.text = " <color=#92FC63FF>" .. var_22_3 .. "</color>/" .. var_22_2

	setFillAmount(self.tranProgress, var_22_3 / var_22_2)

	self.exp2ProficiencyRatioTxt.text = self.resClass:GetExp2ProficiencyRatio() * self.course:getExtraRate() .. "%"
end

function ClassLayer:LoadClassRoom()
	local var_23_0 = {}

	for iter_23_0 = 1, math.min(#self.students, #self.studentSeats) do
		table.insert(var_23_0, function(arg_24_0)
			self:LoadChar(self.students[iter_23_0]:GetSkin().prefab, function(arg_25_0)
				self:AddStudent(arg_25_0, self.studentSeats[iter_23_0])
				arg_24_0()
			end)
		end)
	end

	table.insert(var_23_0, function(arg_26_0)
		self:LoadChar(Ship.New({
			configId = self.course:getConfig("id")
		}):getPrefab(), function(arg_27_0)
			self:AddTeacher(arg_27_0, self.teacherSeat)
			arg_26_0()
		end)
	end)
	pg.UIMgr.GetInstance():LoadingOn()
	seriesAsync(var_23_0, function()
		pg.UIMgr.GetInstance():LoadingOff()
	end)
end

function ClassLayer:AddStudent(arg_29_1, arg_29_2)
	arg_29_1:SetLocalScale(Vector3(-0.9, 0.9, 1))
	arg_29_1:SetLocalPosition(Vector3(37, 62, 0))
	arg_29_1:SetParent(arg_29_2)
	setActive(arg_29_2:Find("icon"), true)
	arg_29_1:SetAction("sit", 0)
	arg_29_1:SetSiblingIndex(0)
end

function ClassLayer:AddTeacher(arg_30_1, arg_30_2)
	arg_30_1:SetLocalScale(Vector3(0.9, 0.9, 1))
	arg_30_1:SetLocalPosition(Vector3(0, 0, 0))
	arg_30_1:SetParent(arg_30_2)
	arg_30_1:SetAction("stand2", 0)
end

function ClassLayer:willExit()
	self:ClearChars()
	self.resFieldPage:Destroy()

	self.resFieldPage = nil
end

function ClassLayer:LoadChar(arg_32_1, arg_32_2)
	local var_32_0 = SpineAnimChar.New()

	var_32_0:SetPaint(arg_32_1)
	var_32_0:Load(true, function(arg_33_0)
		if self.exited then
			arg_33_0:Dispose()

			return
		end

		arg_33_0:SetLayer(Layer.UI)

		self.chars[arg_32_1] = arg_33_0

		arg_32_2(arg_33_0)
	end)
end

function ClassLayer:ClearChars()
	for iter_34_0, iter_34_1 in pairs(self.chars) do
		iter_34_1:Dispose()
	end

	self.chars = {}
end

function ClassLayer:onBackPressed()
	if self.resFieldPage and self.resFieldPage:GetLoaded() and self.resFieldPage:isShowing() then
		self.resFieldPage:Hide()

		return
	end

	ClassLayer.super.onBackPressed(self)
end

return ClassLayer
