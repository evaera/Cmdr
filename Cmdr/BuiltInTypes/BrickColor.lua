local Util = require(script.Parent.Parent.Shared.Util)

local brickColorNames = {
    "White", "Grey", "Light yellow", "Brick yellow", "Light green (Mint)", "Light reddish violet", "Pastel Blue",
    "Light orange brown", "Nougat", "Bright red", "Med. reddish violet", "Bright blue", "Bright yellow", "Earth orange",
    "Black", "Dark grey", "Dark green", "Medium green", "Lig. Yellowich orange", "Bright green", "Dark orange",
    "Light bluish violet", "Transparent", "Tr. Red", "Tr. Lg blue", "Tr. Blue", "Tr. Yellow", "Light blue",
    "Tr. Flu. Reddish orange", "Tr. Green", "Tr. Flu. Green", "Phosph. White", "Light red", "Medium red", "Medium blue",
    "Light grey", "Bright violet", "Br. yellowish orange", "Bright orange", "Bright bluish green", "Earth yellow",
    "Bright bluish violet", "Tr. Brown", "Medium bluish violet", "Tr. Medi. reddish violet", "Med. yellowish green",
    "Med. bluish green", "Light bluish green", "Br. yellowish green", "Lig. yellowish green", "Med. yellowish orange",
    "Br. reddish orange", "Bright reddish violet", "Light orange", "Tr. Bright bluish violet", "Gold", "Dark nougat",
    "Silver", "Neon orange", "Neon green", "Sand blue", "Sand violet", "Medium orange", "Sand yellow", "Earth blue",
    "Earth green", "Tr. Flu. Blue", "Sand blue metallic", "Sand violet metallic", "Sand yellow metallic",
    "Dark grey metallic", "Black metallic", "Light grey metallic", "Sand green", "Sand red", "Dark red",
    "Tr. Flu. Yellow", "Tr. Flu. Red", "Gun metallic", "Red flip/flop", "Yellow flip/flop", "Silver flip/flop", "Curry",
    "Fire Yellow", "Flame yellowish orange", "Reddish brown", "Flame reddish orange", "Medium stone grey", "Royal blue",
    "Dark Royal blue", "Bright reddish lilac", "Dark stone grey", "Lemon metalic", "Light stone grey", "Dark Curry",
    "Faded green", "Turquoise", "Light Royal blue", "Medium Royal blue", "Rust", "Brown", "Reddish lilac", "Lilac",
    "Light lilac", "Bright purple", "Light purple", "Light pink", "Light brick yellow", "Warm yellowish orange",
    "Cool yellow", "Dove blue", "Medium lilac", "Slime green", "Smoky grey", "Dark blue", "Parsley green", "Steel blue",
    "Storm blue", "Lapis", "Dark indigo", "Sea green", "Shamrock", "Fossil", "Mulberry", "Forest green", "Cadet blue",
    "Electric blue", "Eggplant", "Moss", "Artichoke", "Sage green", "Ghost grey", "Lilac", "Plum", "Olivine",
    "Laurel green", "Quill grey", "Crimson", "Mint", "Baby blue", "Carnation pink", "Persimmon", "Maroon", "Gold",
    "Daisy orange", "Pearl", "Fog", "Salmon", "Terra Cotta", "Cocoa", "Wheat", "Buttermilk", "Mauve", "Sunrise",
    "Tawny", "Rust", "Cashmere", "Khaki", "Lily white", "Seashell", "Burgundy", "Cork", "Burlap", "Beige", "Oyster",
    "Pine Cone", "Fawn brown", "Hurricane grey", "Cloudy grey", "Linen", "Copper", "Dirt brown", "Bronze", "Flint",
    "Dark taupe", "Burnt Sienna", "Institutional white", "Mid gray", "Really black", "Really red", "Deep orange",
    "Alder", "Dusty Rose", "Olive", "New Yeller", "Really blue", "Navy blue", "Deep blue", "Cyan", "CGA brown",
    "Magenta", "Pink", "Deep orange", "Teal", "Toothpaste", "Lime green", "Camo", "Grime", "Lavender",
    "Pastel light blue", "Pastel orange", "Pastel violet", "Pastel blue-green", "Pastel green", "Pastel yellow",
    "Pastel brown", "Royal purple", "Hot pink"
}

local brickColorFinder = Util.MakeFuzzyFinder(brickColorNames)

local brickColorType =  {
	Prefixes = "% teamColor";

    Transform = function(text)
        local brickColors = {}
        for i, name in pairs(brickColorFinder(text)) do
            brickColors[i] = BrickColor.new(name)
        end
        return brickColors
    end;

    Validate = function(brickColors)
        return #brickColors > 0, "No valid brick colors with that name could be found."
    end;

    Autocomplete = function(brickColors)
        return Util.GetNames(brickColors)
    end;

    Parse = function(brickColors)
        return brickColors[1]
    end;
}

local brickColor3Type = {
	Transform = brickColorType.Transform;
	Validate = brickColorType.Validate;
	Autocomplete = brickColorType.Autocomplete;

	Parse = function(brickColors)
		return brickColors[1].Color
	end;
}

return function(registry)
    registry:RegisterType("brickColor", brickColorType)
	registry:RegisterType("brickColors", Util.MakeListableType(brickColorType, {
		Prefixes = "% teamColors"
	}))

	registry:RegisterType("brickColor3", brickColor3Type)
    registry:RegisterType("brickColor3s", Util.MakeListableType(brickColor3Type))
end