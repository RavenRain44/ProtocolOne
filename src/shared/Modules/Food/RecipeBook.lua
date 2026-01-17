-- Yeah this is a good start but I'm not sure...

local RecipeBook = {}

-- This is to define output types for recipes 
-- FoodType = Multiplier/Rarity 
local FoodType = {
	Vegetable = 1,
	Fruit = 1.2,
	BakedGood = 2,
	Sweets = 4,
	Meat = 8,
	Seafood = 16,
}

-- Define the structure of ingredients in the recipe book
type Ingredient = {
	Name: string, 
	Amount: number, 
	Weight: number,
}

-- Helper function to create a new ingredient
function newIngredient(name: string, amount: number, weight: number): Ingredient
	return {
		Name = name,
		Amount = amount,
		Weight = weight
	}
end

--[[
STRUCTURE:

RecipeBook = 
	"Dough" = {
		FoodGroup = FoodType.BakedGood,
		Recipe = { 
			newIngredient("Flour", 2, 0.7), (name, amount, weight) **THE WEIGHTS HAVE TO ADD UP TO ONE**
			newIngredient("Egg", 1, 0.3),
		}
	}
}

]]

RecipeBook = {
	Dough = {
		FoodGroup = FoodType.BakedGood,
		Recipe = {
			newIngredient("Flour", 2, 0.7),
			newIngredient("Egg", 1, 0.3),
		},
		Rarity = {
			Dough = 1.0, -- Bland
		}
	},

	Bread = {
		FoodGroup = FoodType.BakedGood,
		Recipe = {
			newIngredient("Dough", 1, 1.0),
		},
		Rarity = {
			White_Bread = 0.7, -- Bland
			BrownBread = 0.29, -- Flavorful
			Crescent = 0.01, -- Divine
		}
	},
}

return RecipeBook
