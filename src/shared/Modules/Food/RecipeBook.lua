-- Yeah this is a good start but I'm not sure...

local RecipeBook = {}

-- This is to define output types for recipes
-- TODO make all types and assign meaning to the numbers
local FoodType = {
	Meat = 0,
	Vegetable = 1,
	Fruit = 2,
	Candy = 3,
	BakedGood = 4,
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
	},

	Bread = {
		FoodGroup = FoodType.BakedGood,
		Recipe = {
			newIngredient("Dough", 1, 1.0),
		},
	},
}

return RecipeBook
