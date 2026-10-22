local VoteFunRaceRankPage = class("VoteFunRaceRankPage", import("..FinalsRece.VoteFinalsRaceRankPage"))

function VoteFunRaceRankPage:getUIName()
	if self.contextData.voteGroup:IsFunMetaRace() then
		return "FinalsRaceRankForMeta"
	elseif self.contextData.voteGroup:IsFunSireRace() then
		return "FinalsRaceRankForSire"
	elseif self.contextData.voteGroup:IsFunKidRace() then
		return "FinalsRaceRankForKid"
	else
		assert(false)
	end
end

return VoteFunRaceRankPage
