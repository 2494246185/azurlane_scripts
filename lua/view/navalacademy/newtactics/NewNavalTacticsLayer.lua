local NewNavalTacticsLayer = class("NewNavalTacticsLayer", import("...base.BaseUI"))

NewNavalTacticsLayer.ON_UNLOCK = "NewNavalTacticsLayer:ON_UNLOCK"
NewNavalTacticsLayer.ON_ADD_STUDENT = "NewNavalTacticsLayer:ON_ADD_STUDENT"
NewNavalTacticsLayer.ON_SKILL_SELECTED = "NewNavalTacticsLayer:ON_SKILL_SELECTED"
NewNavalTacticsLayer.ON_RESEL_SKILL = "NewNavalTacticsLayer:ON_RESEL_SKILL"
NewNavalTacticsLayer.ON_LESSON_SELECTED = "NewNavalTacticsLayer:ON_LESSON_SELECTED"
NewNavalTacticsLayer.ON_CANCEL_ADD_STUDENT = "NewNavalTacticsLayer:ON_CANCEL_ADD_STUDENT"

function NewNavalTacticsLayer:getUIName()
	return "NewNavalTacticsUI"
end

function NewNavalTacticsLayer:getResource()
	local function var_2_0(arg_3_0, arg_3_1)
		if noEmptyStr(arg_3_1) and not table.contains(arg_3_0, arg_3_1) then
			table.insert(arg_3_0, arg_3_1)
		end
	end

	return ResPathSupport.MergeLuaArr(NewNavalTacticsLayer.super.getResource(self), {
		"ui/newnavaltacticsui"
	}, ((function()
		local var_4_0 = {}

		local function var_4_1(arg_5_0)
			for iter_5_0, iter_5_1 in ipairs(arg_5_0:getSkillList() or {}) do
				var_2_0(var_4_0, "skillicon/" .. ShipSkill.New(arg_5_0.skills[iter_5_1], arg_5_0.id):GetIcon())
			end
		end

		local function var_4_2(arg_6_0)
			var_2_0(var_4_0, Item.getConfigData(arg_6_0.id).icon)
		end

		local var_4_3 = getProxy(BayProxy)

		for iter_4_0, iter_4_1 in pairs(getProxy(NavalAcademyProxy):RawGetStudentList() or {}) do
			local var_4_4 = var_4_3:RawGetShipById(iter_4_1.shipId)

			if var_4_4 then
				var_4_1(var_4_4)
				table.insertto(var_4_0, ResPathSupport.GetPaintingShipYardIconListByPaintingName(var_4_4:getPainting()))
				table.insert(var_4_0, string.format(ResPathSupport.ConstPath.BG.ShipCard, var_4_4:rarity2bgPrint()))
			end
		end

		for iter_4_2, iter_4_3 in pairs(var_4_3:getRawData() or {}) do
			var_4_1(iter_4_3)
		end

		local var_4_5 = getProxy(BagProxy):getItemsByType(Item.LESSON_TYPE)

		var_4_5 = var_4_5 or {}

		for iter_4_4, iter_4_5 in ipairs(var_4_5) do
			var_4_2(iter_4_5)
		end

		var_2_0(var_4_0, "template/shipcardtpl")
		var_2_0(var_4_0, "clutter/class_painting")

		return var_4_0
	end)()))
end

function NewNavalTacticsLayer:OnUnlockSlot()
	if self.studentsPage:GetLoaded() then
		self.studentsPage:OnUnlockSlot()
	end
end

function NewNavalTacticsLayer:OnAddStudent()
	if self.studentsPage:GetLoaded() then
		self.studentsPage:OnAddStudent()
	end

	if self.selLessonPage:GetLoaded() and self.selLessonPage:isShowing() then
		self.selLessonPage:Hide()
	end
end

function NewNavalTacticsLayer:ResendCancelOp(arg_9_1)
	self.inAddStudentProcess = false

	for iter_9_0, iter_9_1 in ipairs(arg_9_1) do
		self:emit(NewNavalTacticsMediator.ON_CANCEL, iter_9_1[1], iter_9_1[2])
	end
end

function NewNavalTacticsLayer:OnExitStudent()
	if self.studentsPage:GetLoaded() then
		self.studentsPage:OnExitStudent()
	end
end

function NewNavalTacticsLayer:BlockEvents()
	GetOrAddComponent(self._tf, typeof(CanvasGroup)).blocksRaycasts = false
end

function NewNavalTacticsLayer:UnblockEvents()
	GetOrAddComponent(self._tf, typeof(CanvasGroup)).blocksRaycasts = true
end

function NewNavalTacticsLayer:IsInAddStudentProcess()
	return self.inAddStudentProcess
end

function NewNavalTacticsLayer:OnUpdateMetaSkillPanel(arg_14_1)
	if self.metaSkillPage then
		self.metaSkillPage:reUpdate()
	end
end

function NewNavalTacticsLayer:SetStudents(arg_15_1)
	self.students = arg_15_1
end

function NewNavalTacticsLayer:init()
	self.painting = self._tf:Find("painting"):GetComponent(typeof(Image))
	self.backBtn = self._tf:Find("adpter/frame/btnBack")
	self.option = self._tf:Find("adpter/frame/option")
	self.stampBtn = self._tf:Find("stamp")
	self.quickFinishPanel = self._tf:Find("painting/quick_finish")
	self.quickFinishText = self._tf:Find("painting/quick_finish/Text")
	self.studentsPage = NewNavalTacticsStudentsPage.New(self._tf:Find("adpter"), self.event)
	self.unlockPage = NewNavalTacticsUnlockSlotPage.New(self._tf, self.event)
	self.selSkillPage = NewNavalTacticsSelSkillsPage.New(self._tf, self.event, self.contextData)
	self.selLessonPage = NewNavalTacticsSelLessonPage.New(self._tf, self.event)
	self.finishLessonUtil = NewNavalTacticsFinishLessonUtil.New(self.studentsPage, self.selLessonPage, self.selSkillPage)
end

function NewNavalTacticsLayer:didEnter()
	self:bind(NewNavalTacticsLayer.ON_UNLOCK, function(arg_18_0, arg_18_1)
		self.unlockPage:ExecuteAction("Show", arg_18_1, function()
			self:emit(NewNavalTacticsMediator.ON_SHOPPING, arg_18_1)
		end)
	end)
	self:bind(NewNavalTacticsLayer.ON_ADD_STUDENT, function(arg_20_0, arg_20_1)
		if not getProxy(BagProxy):ExitTypeItems(Item.LESSON_TYPE) then
			if not ItemTipPanel.ShowItemTipbyID(16001, i18n("item_lack_title", i18n("ship_book"), i18n("ship_book"))) then
				pg.TipsMgr.GetInstance():ShowTips(i18n("tactics_no_lesson"))
			end

			return
		end

		self:emit(NewNavalTacticsMediator.ON_SELECT_SHIP, arg_20_1)
	end)
	self:bind(NewNavalTacticsLayer.ON_SKILL_SELECTED, function(arg_21_0, arg_21_1)
		self.selLessonPage:ExecuteAction("Show", arg_21_1)
		self.selSkillPage:Hide()
	end)
	self:bind(NewNavalTacticsLayer.ON_RESEL_SKILL, function(arg_22_0, arg_22_1)
		self.selLessonPage:Hide()
		self.selSkillPage:Show(arg_22_1)
	end)
	self:bind(NewNavalTacticsLayer.ON_LESSON_SELECTED, function(arg_23_0, arg_23_1)
		self:AddStudentFinish(arg_23_1)
	end)
	setActive(self.stampBtn, getProxy(TaskProxy):mingshiTouchFlagEnabled())

	if LOCK_CLICK_MINGSHI then
		setActive(self.stampBtn, false)
	end

	onButton(self, self.stampBtn, function()
		getProxy(TaskProxy):dealMingshiTouchFlag(3)
	end, SFX_CONFIRM)
	onButton(self, self.backBtn, function()
		self:closeView()
	end, SFX_CANCEL)
	onButton(self, self.option, function()
		self:emit(NewNavalTacticsLayer.ON_HOME)
	end, SFX_PANEL)
	self:SetPainting()
	self:Init()
	self:OnUpdateQuickFinishPanel()
	self.studentsPage:ExecuteAction("Show", self.students)
end

function NewNavalTacticsLayer:Init()
	if self.contextData.shipToLesson then
		self.inAddStudentProcess = true

		self:AddStudent(self.contextData.shipToLesson.shipId, self.contextData.shipToLesson.index, self.contextData.shipToLesson.skillIndex)

		self.contextData.shipToLesson = nil
	elseif self.contextData.metaShipID then
		self.inAddStudentProcess = true

		self:ShowMetaShipSkill(self.contextData.metaShipID)

		self.contextData.metaShipID = nil
	end
end

function NewNavalTacticsLayer:OnUpdateQuickFinishPanel()
	local var_28_0 = getProxy(NavalAcademyProxy):getDailyFinishCnt()

	setActive(self.quickFinishPanel, var_28_0 > 0)
	setText(self.quickFinishText, i18n("skill_learn_tip", var_28_0))
end

function NewNavalTacticsLayer:SetPainting()
	ResourceMgr.Inst:getAssetAsync("Clutter/class_painting", "", typeof(Sprite), UnityEngine.Events.UnityAction_UnityEngine_Object(function(arg_30_0)
		self.painting.sprite = arg_30_0

		self.painting:SetNativeSize()
	end), true, true)
end

function NewNavalTacticsLayer:ShowMetaShipSkill(arg_31_1)
	self.metaSkillPage = NavalTacticsMetaSkillsView.New(self._tf, self.event)

	self.metaSkillPage:Reset()
	self.metaSkillPage:Load()
	self.metaSkillPage:setData(arg_31_1, function()
		self.inAddStudentProcess = false

		self.metaSkillPage:Destroy()

		self.metaSkillPage = nil
	end)
end

function NewNavalTacticsLayer:AddStudent(arg_33_1, arg_33_2, arg_33_3)
	self.selSkillPage:ExecuteAction("Show", Student.New({
		id = arg_33_2,
		ship_id = arg_33_1
	}), arg_33_3)
end

function NewNavalTacticsLayer:AddStudentFinish(arg_34_1)
	local var_34_0 = getProxy(BayProxy):RawGetShipById(arg_34_1.shipId)

	if var_34_0:isActivityNpc() then
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			content = i18n("npc_learn_skill_tip"),
			onYes = function()
				self:StartLesson(arg_34_1, var_34_0)
			end
		})
	else
		self:StartLesson(arg_34_1, var_34_0)
	end
end

function NewNavalTacticsLayer:StartLesson(arg_36_1, arg_36_2)
	local var_36_0 = ShipSkill.New(arg_36_2.skills[arg_36_1:getSkillId(arg_36_2)], arg_36_2.id)

	pg.MsgboxMgr.GetInstance():ShowMsgBox({
		content = i18n("tactics_lesson_start_tip", Item.getConfigData(arg_36_1.lessonId).name, arg_36_2:getName(), (var_36_0:GetName())),
		onYes = function()
			if var_36_0:IsMaxLevel() then
				pg.TipsMgr.GetInstance():ShowTips(i18n("tactics_max_level"))

				return
			end

			self:emit(NewNavalTacticsMediator.ON_START, {
				shipId = arg_36_1.shipId,
				skillPos = arg_36_1:getSkillId(arg_36_2),
				lessonId = arg_36_1.lessonId,
				roomId = arg_36_1.id
			})
		end
	})
end

function NewNavalTacticsLayer:onBackPressed()
	if self.finishLessonUtil:IsWorking() then
		return
	end

	NewNavalTacticsLayer.super.onBackPressed(self)
end

function NewNavalTacticsLayer:willExit()
	if self.studentsPage then
		self.studentsPage:Destroy()

		self.studentsPage = nil
	end

	if self.unlockPage then
		self.unlockPage:Destroy()

		self.unlockPage = nil
	end

	if self.selSkillPage then
		self.selSkillPage:Destroy()

		self.selSkillPage = nil
	end

	if self.selLessonPage then
		self.selLessonPage:Destroy()

		self.selLessonPage = nil
	end

	if self.finishLessonUtil then
		self.finishLessonUtil:Dispose()

		self.finishLessonUtil = nil
	end

	if self.metaSkillPage then
		self.metaSkillPage:Destroy()

		self.metaSkillPage = nil
	end
end

return NewNavalTacticsLayer
