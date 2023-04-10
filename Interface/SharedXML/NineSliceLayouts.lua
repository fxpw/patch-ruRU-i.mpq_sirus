NineSliceLayouts =
{
	SimplePanelTemplate =
	{
		mirrorLayout = true,
		TopLeftCorner =	{ atlas = "UI-Frame-SimpleMetal-CornerTopLeft", x = -5, y = 0, },
		TopRightCorner = { atlas = "UI-Frame-SimpleMetal-CornerTopLeft", x = 2, y = 0, },
		BottomLeftCorner = { atlas = "UI-Frame-SimpleMetal-CornerTopLeft", x = -5, y = -3, },
		BottomRightCorner =	{ atlas = "UI-Frame-SimpleMetal-CornerTopLeft", x = 2, y = -3, },
		TopEdge = { atlas = "_UI-Frame-SimpleMetal-EdgeTop", },
		BottomEdge = { atlas = "_UI-Frame-SimpleMetal-EdgeTop", },
		LeftEdge = { atlas = "!UI-Frame-SimpleMetal-EdgeLeft", },
		RightEdge = { atlas = "!UI-Frame-SimpleMetal-EdgeLeft", },
	},

	PortraitFrameTemplate =
	{
		TopLeftCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-PortraitMetal-CornerTopLeft", x = -13, y = 16, },
		TopRightCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerTopRight", x = 4, y = 16, },
		BottomLeftCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerBottomLeft", x = -13, y = -3, },
		BottomRightCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerBottomRight", x = 4, y = -3, },
		TopEdge = { layer="OVERLAY", atlas = "_UI-Frame-Metal-EdgeTop", x = 0, y = 0, x1 = 0, y1 = 0, },
		BottomEdge = { layer = "OVERLAY", atlas = "_UI-Frame-Metal-EdgeBottom", x = 0, y = 0, x1 = 0, y1 = 0, },
		LeftEdge = { layer = "OVERLAY", atlas = "!UI-Frame-Metal-EdgeLeft", x = 0, y = 0, x1 = 0, y1 = 0 },
		RightEdge = { layer = "OVERLAY", atlas = "!UI-Frame-Metal-EdgeRight", x = 0, y = 0, x1 = 0, y1 = 0, },
	},

	PortraitFrameTemplateMinimizable =
	{
		TopLeftCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-PortraitMetal-CornerTopLeft", x = -13, y = 16, },
		TopRightCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerTopRightDouble", x = 4, y = 16, },
		BottomLeftCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerBottomLeft", x = -13, y = -3, },
		BottomRightCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerBottomRight", x = 4, y = -3, },
		TopEdge = { layer="OVERLAY", atlas = "_UI-Frame-Metal-EdgeTop", x = 0, y = 0, x1 = 0, y1 = 0, },
		BottomEdge = { layer = "OVERLAY", atlas = "_UI-Frame-Metal-EdgeBottom", x = 0, y = 0, x1 = 0, y1 = 0, },
		LeftEdge = { layer = "OVERLAY", atlas = "!UI-Frame-Metal-EdgeLeft", x = 0, y = 0, x1 = 0, y1 = 0 },
		RightEdge = { layer = "OVERLAY", atlas = "!UI-Frame-Metal-EdgeRight", x = 0, y = 0, x1 = 0, y1 = 0, },
	},

	ButtonFrameTemplateNoPortrait =
	{
		TopLeftCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerTopLeft", x = -12, y = 16, },
		TopRightCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerTopRight", x = 4, y = 16, },
		BottomLeftCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerBottomLeft", x = -12, y = -3, },
		BottomRightCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerBottomRight", x = 4, y = -3, },
		TopEdge = { layer = "OVERLAY", atlas = "_UI-Frame-Metal-EdgeTop", },
		BottomEdge = { layer = "OVERLAY", atlas = "_UI-Frame-Metal-EdgeBottom", },
		LeftEdge = { layer = "OVERLAY", atlas = "!UI-Frame-Metal-EdgeLeft", },
		RightEdge = { layer = "OVERLAY", atlas = "!UI-Frame-Metal-EdgeRight", },
	},

	ButtonFrameTemplateNoPortraitMinimizable =
	{
		TopLeftCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerTopLeft", x = -12, y = 16, },
		TopRightCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerTopRightDouble", x = 4, y = 16, },
		BottomLeftCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerBottomLeft", x = -12, y = -3, },
		BottomRightCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerBottomRight", x = 4, y = -3, },
		TopEdge = { layer = "OVERLAY", atlas = "_UI-Frame-Metal-EdgeTop", },
		BottomEdge = { layer = "OVERLAY", atlas = "_UI-Frame-Metal-EdgeBottom", },
		LeftEdge = { layer = "OVERLAY", atlas = "!UI-Frame-Metal-EdgeLeft", },
		RightEdge = { layer = "OVERLAY", atlas = "!UI-Frame-Metal-EdgeRight", },
	},

	InsetFrameTemplate =
	{
		TopLeftCorner = { layer = "BORDER", subLevel = -5, atlas = "UI-Frame-InnerTopLeft", },
		TopRightCorner = { layer = "BORDER", subLevel = -5, atlas = "UI-Frame-InnerTopRight", },
		BottomLeftCorner = { layer = "BORDER", subLevel = -5, atlas = "UI-Frame-InnerBotLeftCorner", x = 0, y = -1, },
		BottomRightCorner = { layer = "BORDER", subLevel = -5, atlas = "UI-Frame-InnerBotRight", x = 0, y = -1, },
		TopEdge = { layer = "BORDER", subLevel = -5, atlas = "_UI-Frame-InnerTopTile", },
		BottomEdge = { layer = "BORDER", subLevel = -5, atlas = "_UI-Frame-InnerBotTile", },
		LeftEdge = { layer = "BORDER", subLevel = -5, atlas = "!UI-Frame-InnerLeftTile", },
		RightEdge = { layer = "BORDER", subLevel = -5, atlas = "!UI-Frame-InnerRightTile", },
	},

	BFAMissionHorde =
	{
		mirrorLayout = true,
		TopLeftCorner =	{ atlas = "HordeFrame-Corner-TopLeft", x = -6, y = 6, },
		TopRightCorner =	{ atlas = "HordeFrame-Corner-TopLeft", x = 6, y = 6, },
		BottomLeftCorner =	{ atlas = "HordeFrame-Corner-TopLeft", x = -6, y = -6, },
		BottomRightCorner =	{ atlas = "HordeFrame-Corner-TopLeft", x = 6, y = -6, },
		TopEdge = { atlas = "_HordeFrameTile-Top", },
		BottomEdge = { atlas = "_HordeFrameTile-Top", },
		LeftEdge = { atlas = "!HordeFrameTile-Left", },
		RightEdge = { atlas = "!HordeFrameTile-Left", },
	},

	BFAMissionAlliance =
	{
		mirrorLayout = true,
		TopLeftCorner =	{ atlas = "AllianceFrameCorner-TopLeft", x = -6, y = 6, },
		TopRightCorner =	{ atlas = "AllianceFrameCorner-TopLeft", x = 6, y = 6, },
		BottomLeftCorner =	{ atlas = "AllianceFrameCorner-TopLeft", x = -6, y = -6, },
		BottomRightCorner =	{ atlas = "AllianceFrameCorner-TopLeft", x = 6, y = -6, },
		TopEdge = { atlas = "_AllianceFrameTile-Top", },
		BottomEdge = { atlas = "_AllianceFrameTile-Top", },
		LeftEdge = { atlas = "!AllianceFrameTile-Left", },
		RightEdge = { atlas = "!AllianceFrameTile-Left", },
	},

	Dialog =
	{
		TopLeftCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerTopLeft", },
		TopRightCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerTopRight", },
		BottomLeftCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerBottomLeft", },
		BottomRightCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerBottomRight", },
		TopEdge = { atlas = "_UI-Frame-DiamondMetal-EdgeTop", },
		BottomEdge = { atlas = "_UI-Frame-DiamondMetal-EdgeBottom", },
		LeftEdge = { atlas = "!UI-Frame-DiamondMetal-EdgeLeft", },
		RightEdge = { atlas = "!UI-Frame-DiamondMetal-EdgeRight", },
	},

	IdenticalCornersLayoutNoCenter =
	{
		["TopRightCorner"] = { atlas = "%s-NineSlice-Corner", mirrorLayout = true, },
		["TopLeftCorner"] = { atlas = "%s-NineSlice-Corner", mirrorLayout = true, },
		["BottomLeftCorner"] = { atlas = "%s-NineSlice-Corner", mirrorLayout = true, },
		["BottomRightCorner"] = { atlas = "%s-NineSlice-Corner",  mirrorLayout = true, },
		["TopEdge"] = { atlas = "_%s-NineSlice-EdgeTop", },
		["BottomEdge"] = { atlas = "_%s-NineSlice-EdgeBottom", },
		["LeftEdge"] = { atlas = "!%s-NineSlice-EdgeLeft", },
		["RightEdge"] = { atlas = "!%s-NineSlice-EdgeRight", },
	};

	-- CUSTOM LAYOUTS
	BFAMissionNeutral =
	{
		TopLeftCorner =	{ atlas = "UI-Frame-GenericMetal-Corner", x = -6, y = 6, mirrorLayout = true, },
		TopRightCorner =	{ atlas = "UI-Frame-GenericMetal-Corner", x = 6, y = 6, mirrorLayout = true, },
		BottomLeftCorner =	{ atlas = "UI-Frame-GenericMetal-Corner", x = -6, y = -6, mirrorLayout = true, },
		BottomRightCorner =	{ atlas = "UI-Frame-GenericMetal-Corner", x = 6, y = -6, mirrorLayout = true, },
		TopEdge = { atlas = "_UI-Frame-GenericMetal-TileTop", },
		BottomEdge = { atlas = "_UI-Frame-GenericMetal-TileBottom", },
		LeftEdge = { atlas = "!UI-Frame-GenericMetal-TileLeft", },
		RightEdge = { atlas = "!UI-Frame-GenericMetal-TileRight", },
	},

	Roulette =
	{
		TopLeftCorner =	    { atlas = "Roulette-left-top-corner", x = -6, y = 6, },
		TopRightCorner =	{ atlas = "Roulette-right-top-corner", x = 6, y = 6, },
		BottomLeftCorner =	{ atlas = "Roulette-left-bottom-corner", x = 3, y = -6, },
		BottomRightCorner =	{ atlas = "Roulette-right-bottom-corner", x = 5.6, y = -5.8, },
	},

	GlueDarkTemplate =
	{
		TopLeftCorner =		{ layer = "OVERLAY", atlas = "GlueDark-border-CornerTopLeft", x = -8, y = 8, },
		TopRightCorner =	{ layer = "OVERLAY", atlas = "GlueDark-border-CornerTopRight", x = 8, y = 8, },
		BottomLeftCorner =	{ layer = "OVERLAY", atlas = "GlueDark-border-CornerBottomLeft", x = -8, y = -8, },
		BottomRightCorner =	{ layer = "OVERLAY", atlas = "GlueDark-border-CornerBottomRight", x = 8, y = -8, },
		TopEdge =			{ layer = "OVERLAY", atlas = "GlueDark-border-Top", },
		BottomEdge =		{ layer = "OVERLAY", atlas = "GlueDark-border-Bottom", },
		LeftEdge =			{ layer = "OVERLAY", atlas = "GlueDark-border-Left", },
		RightEdge =			{ layer = "OVERLAY", atlas = "GlueDark-border-Right", },
	},

	GlueDarkDropDownTemplate =
	{
		TopLeftCorner =		{ layer = "OVERLAY", atlas = "GlueDark-borderDropdown-CornerTopLeft", x = -2, y = 2, },
		TopRightCorner =	{ layer = "OVERLAY", atlas = "GlueDark-borderDropdown-CornerTopRight", x = 2, y = 2, },
		BottomLeftCorner =	{ layer = "OVERLAY", atlas = "GlueDark-borderDropdown-CornerBottomLeft", x = -2, y = -2, },
		BottomRightCorner =	{ layer = "OVERLAY", atlas = "GlueDark-borderDropdown-CornerBottomRight", x = 2, y = -2, },
		TopEdge =			{ layer = "OVERLAY", atlas = "GlueDark-borderDropdown-Top", },
		BottomEdge =		{ layer = "OVERLAY", atlas = "GlueDark-borderDropdown-Bottom", },
		LeftEdge =			{ layer = "OVERLAY", atlas = "GlueDark-borderDropdown-Left", },
		RightEdge =			{ layer = "OVERLAY", atlas = "GlueDark-borderDropdown-Right", },
	},
}