-- Yeah this is a good start but I'm not sure...

local RecipeBook = {}

--[[
STRUCTURE:

RecipeBook = {
    MachineName = {
        {
            Ingredients = {"item1","item2"},
            OutputGroup = "MeatGroup"
        },
        {
            Ingredients = {"itemA"},
            OutputGroup = "FishGroup"
        }
    }
}
]]

RecipeBook["Station1"] = {
	{
		Ingredients = {"Flour", "Egg"},
		OutputGroup = "Mixables"
	}
}

RecipeBook["Bakery"] = {
	{
		Ingredients = {"Dough"},
		OutputGroup = "Breads"
	},
	{
		Ingredients = {"ChocolateDough"},
		OutputGroup = "Breads"
	},
	{
		Ingredients = {"RainbowDough"},
		OutputGroup = "Breads"
	}
}

RecipeBook["BakeryMachine"] = {
	{
		Ingredients = {"flour", "egg", "milk"},
		OutputGroup = "PastryGroup"
	}
}

return RecipeBook
