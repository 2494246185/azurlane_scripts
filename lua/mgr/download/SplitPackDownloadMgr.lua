pg = pg or {}
pg.SplitPackDownloadMgr = singletonClass("SplitPackDownloadMgr")

local var_0_0 = pg.SplitPackDownloadMgr

pg.SplitPackDownloadMgr.State = {
	Success = 2,
	Fail = 3,
	None = 1
}

function pg.SplitPackDownloadMgr.Init(arg_1_0)
	arg_1_0.isDownloading = false
	arg_1_0.state = var_0_0.State.None
	arg_1_0.hasShownTip = false
	arg_1_0.message = ""
	arg_1_0.progress = {
		curSize = 0,
		successCount = 0,
		failCount = 0,
		speed = "",
		totalSize = 0,
		totalCount = 0
	}
end

function pg.SplitPackDownloadMgr:StartMainDownload()
	if not SplitPackHelper.Inst:IsSplitPackMode() then
		return
	end

	if self.progress == nil then
		self:Init()
	end

	if self.isDownloading then
		return
	end

	self.isDownloading = true
	self.state = var_0_0.State.None
	self.message = ""

	local var_2_0 = BundleWizardUpdater.Inst:GetFileList({
		GroupMainHelper.DefaultGroupName
	})

	self.progress.successCount = 0
	self.progress.failCount = 0
	self.progress.totalCount = var_2_0.Count
	self.progress.curSize = 0
	self.progress.totalSize = GroupHelper.GetGroupSize(GroupMainHelper.DefaultGroupName)
	self.progress.speed = ""

	BundleWizardUpdater.Inst:StartUpdate((BundleWizardUpdater.Inst:CreateListInfo(GroupMainHelper.DefaultGroupName, var_2_0, nil, function(arg_3_0, arg_3_1)
		self.isDownloading = false

		if arg_3_0 then
			self.state = var_0_0.State.Success or var_0_0.State.Fail
		end

		self.message = arg_3_1 or ""
	end, function(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5)
		self.isDownloading = true
		self.progress.successCount = arg_4_0
		self.progress.failCount = arg_4_1
		self.progress.totalCount = arg_4_2
		self.progress.curSize = arg_4_3
		self.progress.totalSize = arg_4_4
		self.progress.speed = arg_4_5 or ""
	end)))
end

function pg.SplitPackDownloadMgr:IsDownloading()
	return self.isDownloading
end

function pg.SplitPackDownloadMgr:GetState()
	return self.state
end

function pg.SplitPackDownloadMgr:GetProgress()
	return self.progress
end

function pg.SplitPackDownloadMgr:GetTotalSize()
	return (self.progress or nil) and (self.progress.totalSize or 0)
end

function pg.SplitPackDownloadMgr:ShouldShowTip()
	return self.isDownloading and not self.hasShownTip
end

function pg.SplitPackDownloadMgr.MarkTipShown(arg_10_0)
	arg_10_0.hasShownTip = true
end
