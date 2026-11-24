local MainForcePlayerNameModificationSequence = class("MainForcePlayerNameModificationSequence")

function MainForcePlayerNameModificationSequence:Execute(arg_1_1)
	if getProxy(PlayerProxy):getRawData():WhetherServerModifiesName() then
		self:ShowModityPlayerNameWindow(arg_1_1)
	else
		arg_1_1()
	end
end

function MainForcePlayerNameModificationSequence:ShowModityPlayerNameWindow(arg_2_1)
	self.renameWindow = self.renameWindow or ForcePlayerNameModificationPage.New(pg.UIMgr.GetInstance().OverlayMain)

	self.renameWindow:ExecuteAction("Show", function()
		self:Clear()
	end)
end

function MainForcePlayerNameModificationSequence:Clear()
	if self.renameWindow then
		self.renameWindow:Destroy()

		self.renameWindow = nil
	end
end

function MainForcePlayerNameModificationSequence:Dispose()
	self:Clear()
end

return MainForcePlayerNameModificationSequence
