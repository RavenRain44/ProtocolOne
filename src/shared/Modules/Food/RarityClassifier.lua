local RarityClassifier = {}

-- ChanceDenominator = the "2350" in 1/2350
-- These are LABEL ranges only

RarityClassifier.Ranges = {
	Common = {
		Min = 1,
		Max = 30
	},

	Rare = {
		Min = 31,
		Max = 60
	},

	Epic = {
		Min = 61,
		Max = 500
	},

	Legendary = {
		Min = 501,
		Max = 5000
	}
}

-- Returns rarity name based on chance denominator
function RarityClassifier:GetRarityFromChance(chanceDenominator)
	for rarity, data in pairs(self.Ranges) do
		if chanceDenominator >= data.Min and chanceDenominator <= data.Max then
			return rarity
		end
	end

	return "Unknown"
end

return RarityClassifier
