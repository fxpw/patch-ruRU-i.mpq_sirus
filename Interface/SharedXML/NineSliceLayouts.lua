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

	DF_PortraitFrameTemplate =
	{
		TopLeftCorner =	{ layer = "OVERLAY", atlas = "DF-UI-Frame-PortraitMetal-CornerTopLeft", x = -13, y = 16, },
		TopRightCorner =	{ layer = "OVERLAY", atlas = "DF-UI-Frame-Metal-CornerTopRight", x = 4, y = 16, },
		BottomLeftCorner =	{ layer = "OVERLAY", atlas = "DF-UI-Frame-Metal-CornerBottomLeft", x = -13, y = -3, },
		BottomRightCorner =	{ layer = "OVERLAY", atlas = "DF-UI-Frame-Metal-CornerBottomRight", x = 4, y = -3, },
		TopEdge = { layer="OVERLAY", atlas = "DF-_UI-Frame-Metal-EdgeTop", x = 0, y = 0, x1 = 0, y1 = 0, },
		BottomEdge = { layer = "OVERLAY", atlas = "DF-_UI-Frame-Metal-EdgeBottom", x = 0, y = 0, x1 = 0, y1 = 0, },
		LeftEdge = { layer = "OVERLAY", atlas = "DF-!UI-Frame-Metal-EdgeLeft", x = 0, y = 0, x1 = 0, y1 = 0 },
		RightEdge = { layer = "OVERLAY", atlas = "DF-!UI-Frame-Metal-EdgeRight", x = 0, y = 0, x1 = 0, y1 = 0, },
	},

	DF_PortraitFrameTemplateMinimizable =
	{
		TopLeftCorner =	{ layer = "OVERLAY", atlas = "DF-UI-Frame-PortraitMetal-CornerTopLeft", x = -13, y = 16, },
		TopRightCorner =	{ layer = "OVERLAY", atlas = "DF-UI-Frame-Metal-CornerTopRightDouble", x = 4, y = 16, },
		BottomLeftCorner =	{ layer = "OVERLAY", atlas = "DF-UI-Frame-Metal-CornerBottomLeft", x = -13, y = -3, },
		BottomRightCorner =	{ layer = "OVERLAY", atlas = "DF-UI-Frame-Metal-CornerBottomRight", x = 4, y = -3, },
		TopEdge = { layer="OVERLAY", atlas = "DF-_UI-Frame-Metal-EdgeTop", x = 0, y = 0, x1 = 0, y1 = 0, },
		BottomEdge = { layer = "OVERLAY", atlas = "DF-_UI-Frame-Metal-EdgeBottom", x = 0, y = 0, x1 = 0, y1 = 0, },
		LeftEdge = { layer = "OVERLAY", atlas = "DF-!UI-Frame-Metal-EdgeLeft", x = 0, y = 0, x1 = 0, y1 = 0 },
		RightEdge = { layer = "OVERLAY", atlas = "DF-!UI-Frame-Metal-EdgeRight", x = 0, y = 0, x1 = 0, y1 = 0, },
	},

	DF_ButtonFrameTemplateNoPortrait =
	{
		TopLeftCorner =	{ layer = "OVERLAY", atlas = "DF-UI-Frame-Metal-CornerTopLeft", x = -8, y = 16, },
		TopRightCorner =	{ layer = "OVERLAY", atlas = "DF-UI-Frame-Metal-CornerTopRight", x = 4, y = 16, },
		BottomLeftCorner =	{ layer = "OVERLAY", atlas = "DF-UI-Frame-Metal-CornerBottomLeft", x = -8, y = -3, },
		BottomRightCorner =	{ layer = "OVERLAY", atlas = "DF-UI-Frame-Metal-CornerBottomRight", x = 4, y = -3, },
		TopEdge = { layer = "OVERLAY", atlas = "DF-_UI-Frame-Metal-EdgeTop", },
		BottomEdge = { layer = "OVERLAY", atlas = "DF-_UI-Frame-Metal-EdgeBottom", },
		LeftEdge = { layer = "OVERLAY", atlas = "DF-!UI-Frame-Metal-EdgeLeft", },
		RightEdge = { layer = "OVERLAY", atlas = "DF-!UI-Frame-Metal-EdgeRight", },
	},

	DF_ButtonFrameTemplateNoPortraitMinimizable =
	{
		TopLeftCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerTopLeft", x = -12, y = 16, },
		TopRightCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerTopRightDouble", x = 4, y = 16, },
		BottomLeftCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerBottomLeft", x = -12, y = -3, },
		BottomRightCorner =	{ layer = "OVERLAY", atlas = "UI-Frame-Metal-CornerBottomRight", x = 4, y = -3, },
		TopEdge = { layer = "OVERLAY", atlas = "DF-_UI-Frame-Metal-EdgeTop", },
		BottomEdge = { layer = "OVERLAY", atlas = "DF-_UI-Frame-Metal-EdgeBottom", },
		LeftEdge = { layer = "OVERLAY", atlas = "DF-!UI-Frame-Metal-EdgeLeft", },
		RightEdge = { layer = "OVERLAY", atlas = "DF-!UI-Frame-Metal-EdgeRight", },
	},

	DialogDF =
	{
		TopLeftCorner		= { atlas = "DF-UI-Frame-DiamondMetal-CornerTopLeft", },
		TopRightCorner		= { atlas = "DF-UI-Frame-DiamondMetal-CornerTopRight", },
		BottomLeftCorner	= { atlas = "DF-UI-Frame-DiamondMetal-CornerBottomLeft", },
		BottomRightCorner	= { atlas = "DF-UI-Frame-DiamondMetal-CornerBottomRight", },
		TopEdge				= { atlas = "DF-_UI-Frame-DiamondMetal-EdgeTop", },
		BottomEdge			= { atlas = "DF-_UI-Frame-DiamondMetal-EdgeBottom", },
		LeftEdge			= { atlas = "DF-!UI-Frame-DiamondMetal-EdgeLeft", },
		RightEdge			= { atlas = "DF-!UI-Frame-DiamondMetal-EdgeRight", },
	},

	PKBT_PanelNoPortrait =
	{
		TopLeftCorner		= { layer = "ARTWORK", atlas = "PKBT-UI-Frame-Metal-CornerTopLeft", x = -2, y = 0, },
		TopRightCorner		= { layer = "ARTWORK", atlas = "PKBT-UI-Frame-Metal-CornerTopRight", x = 9, y = 0, },
		BottomLeftCorner	= { layer = "ARTWORK", atlas = "PKBT-UI-Frame-Metal-CornerBottomLeft", x = -2, y = -9, },
		BottomRightCorner	= { layer = "ARTWORK", atlas = "PKBT-UI-Frame-Metal-CornerBottomRight", x = 9, y = -9, },
		TopEdge				= { layer = "ARTWORK", atlas = "PKBT-UI-Frame-Metal-EdgeTop", },
		BottomEdge			= { layer = "ARTWORK", atlas = "PKBT-UI-Frame-Metal-EdgeBottom", },
		LeftEdge			= { layer = "ARTWORK", atlas = "PKBT-UI-Frame-Metal-EdgeLeft", },
		RightEdge			= { layer = "ARTWORK", atlas = "PKBT-UI-Frame-Metal-EdgeRight", },
	},

	PKBT_PanelNoPortraitSlim =
	{
		TopLeftCorner		= { layer = "ARTWORK", atlas = "PKBT-UI-Frame-Metal-CornerTopLeft-Alt", x = -4, y = 11, },
		TopRightCorner		= { layer = "ARTWORK", atlas = "PKBT-UI-Frame-Metal-CornerTopRight-Alt", x = 11, y = 11, },
		BottomLeftCorner	= { layer = "ARTWORK", atlas = "PKBT-UI-Frame-Metal-CornerBottomLeft", x = -4, y = -11, },
		BottomRightCorner	= { layer = "ARTWORK", atlas = "PKBT-UI-Frame-Metal-CornerBottomRight", x = 11, y = -11, },
		TopEdge				= { layer = "ARTWORK", atlas = "PKBT-UI-Frame-Metal-EdgeTop-Alt", },
		BottomEdge			= { layer = "ARTWORK", atlas = "PKBT-UI-Frame-Metal-EdgeBottom", },
		LeftEdge			= { layer = "ARTWORK", atlas = "PKBT-UI-Frame-Metal-EdgeLeft", },
		RightEdge			= { layer = "ARTWORK", atlas = "PKBT-UI-Frame-Metal-EdgeRight", },
	},

	PKBT_InsetFrameTemplate =
	{
		TopLeftCorner		= { layer = "BORDER", atlas = "PKBT-Inset-CornerTopLeft", },
		TopRightCorner		= { layer = "BORDER", atlas = "PKBT-Inset-CornerTopRight", },
		BottomLeftCorner	= { layer = "BORDER", atlas = "PKBT-Inset-CornerBottomLeft", x = 0, y = -1, },
		BottomRightCorner	= { layer = "BORDER", atlas = "PKBT-Inset-CornerBottomRight", x = 0, y = -1, },
		TopEdge				= { layer = "BORDER", atlas = "PKBT-Inset-EdgeTop", },
		BottomEdge			= { layer = "BORDER", atlas = "PKBT-Inset-EdgeBottom", },
		LeftEdge			= { layer = "BORDER", atlas = "PKBT-Inset-EdgeLeft", },
		RightEdge			= { layer = "BORDER", atlas = "PKBT-Inset-EdgeRight", },
	},

	PKBT_DialogBorder =
	{
		TopLeftCorner		= { atlas = "PKBT-UI-Frame-DiamondMetal-CornerTopLeft", x = -15, y = 14, },
		TopRightCorner		= { atlas = "PKBT-UI-Frame-DiamondMetal-CornerTopRight", x = 15, y = 14, },
		BottomLeftCorner	= { atlas = "PKBT-UI-Frame-DiamondMetal-CornerBottomLeft", x = -15, y = -14, },
		BottomRightCorner	= { atlas = "PKBT-UI-Frame-DiamondMetal-CornerBottomRight", x = 15, y = -14, },
		TopEdge				= { atlas = "PKBT-UI-Frame-DiamondMetal-EdgeTop", },
		BottomEdge			= { atlas = "PKBT-UI-Frame-DiamondMetal-EdgeBottom", },
		LeftEdge			= { atlas = "PKBT-UI-Frame-DiamondMetal-EdgeLeft", },
		RightEdge			= { atlas = "PKBT-UI-Frame-DiamondMetal-EdgeRight", },
	},

	PKBT_Shadow =
	{
		TopLeftCorner		= { layer = "BACKGROUND", atlas = "PKBT-Popup-Background-Shadow-CornerTopLeft", x = -40, y = 43, },
		TopRightCorner		= { layer = "BACKGROUND", atlas = "PKBT-Popup-Background-Shadow-CornerTopRight", x = 41, y = 43, },
		BottomLeftCorner	= { layer = "BACKGROUND", atlas = "PKBT-Popup-Background-Shadow-CornerBottomLeft", x = -40, y = -46, },
		BottomRightCorner	= { layer = "BACKGROUND", atlas = "PKBT-Popup-Background-Shadow-CornerBottomRight", x = 41, y = -46, },
		TopEdge				= { layer = "BACKGROUND", atlas = "PKBT-Popup-Background-Shadow-EdgeTop", },
		BottomEdge			= { layer = "BACKGROUND", atlas = "PKBT-Popup-Background-Shadow-EdgeBottom", },
		LeftEdge			= { layer = "BACKGROUND", atlas = "PKBT-Popup-Background-Shadow-EdgeLeft", },
		RightEdge			= { layer = "BACKGROUND", atlas = "PKBT-Popup-Background-Shadow-EdgeRight", },
	},

	PKBT_ItemPlate = {
		TopLeftCorner		= { layer = "BORDER", atlas = "PKBT-ItemPlate-Border-CornerTopLeft", x = -8, y = 8, },
		TopRightCorner		= { layer = "BORDER", atlas = "PKBT-ItemPlate-Border-CornerTopRight", x = 8, y = 8, },
		BottomLeftCorner	= { layer = "BORDER", atlas = "PKBT-ItemPlate-Border-CornerBottomLeft", x = -8, y = -8, },
		BottomRightCorner	= { layer = "BORDER", atlas = "PKBT-ItemPlate-Border-CornerBottomRight", x = 8, y = -8, },
		TopEdge				= { layer = "BORDER", atlas = "PKBT-ItemPlate-Border-EdgeTop", },
		BottomEdge			= { layer = "BORDER", atlas = "PKBT-ItemPlate-Border-EdgeBottom", },
		LeftEdge			= { layer = "BORDER", atlas = "PKBT-ItemPlate-Border-EdgeLeft", },
		RightEdge			= { layer = "BORDER", atlas = "PKBT-ItemPlate-Border-EdgeRight", },
	},

	PKBT_PanelRhodiumBorder = {
		TopLeftCorner		= { layer = "BORDER", atlas = "PKBT-Panel-Rhodium-Border-CornerTopLeft", x = -1, y = 1, },
		TopRightCorner		= { layer = "BORDER", atlas = "PKBT-Panel-Rhodium-Border-CornerTopRight", x = 1, y = 1, },
		BottomLeftCorner	= { layer = "BORDER", atlas = "PKBT-Panel-Rhodium-Border-CornerBottomLeft", x = -1, y = -2, },
		BottomRightCorner	= { layer = "BORDER", atlas = "PKBT-Panel-Rhodium-Border-CornerBottomRight", x = 1, y = -2, },
		TopEdge				= { layer = "BORDER", atlas = "PKBT-Panel-Rhodium-Border-EdgeTop", },
		BottomEdge			= { layer = "BORDER", atlas = "PKBT-Panel-Rhodium-Border-EdgeBottom", },
		LeftEdge			= { layer = "BORDER", atlas = "PKBT-Panel-Rhodium-Border-EdgeLeft", },
		RightEdge			= { layer = "BORDER", atlas = "PKBT-Panel-Rhodium-Border-EdgeRight", },
	},

	PKBT_PanelRhodiumGlow = {
		TopLeftCorner		= { layer = "BORDER", atlas = "PKBT-Panel-Rhodium-Glow-CornerTopLeft", x = -15, y = 17, },
		TopRightCorner		= { layer = "BORDER", atlas = "PKBT-Panel-Rhodium-Glow-CornerTopRight", x = 15, y = 17, },
		BottomLeftCorner	= { layer = "BORDER", atlas = "PKBT-Panel-Rhodium-Glow-CornerBottomLeft", x = -15, y = -17, },
		BottomRightCorner	= { layer = "BORDER", atlas = "PKBT-Panel-Rhodium-Glow-CornerBottomRight", x = 15, y = -17, },
		TopEdge				= { layer = "BORDER", atlas = "PKBT-Panel-Rhodium-Glow-EdgeTop", },
		BottomEdge			= { layer = "BORDER", atlas = "PKBT-Panel-Rhodium-Glow-EdgeBottom", },
		LeftEdge			= { layer = "BORDER", atlas = "PKBT-Panel-Rhodium-Glow-EdgeLeft", },
		RightEdge			= { layer = "BORDER", atlas = "PKBT-Panel-Rhodium-Glow-EdgeRight", },
	},

	PKBT_PanelBronzeBorder = {
		TopLeftCorner		= { layer = "BORDER", atlas = "PKBT-Panel-Bronze-Border-CornerTopLeft", x = -1, y = 1, },
		TopRightCorner		= { layer = "BORDER", atlas = "PKBT-Panel-Bronze-Border-CornerTopRight", x = 1, y = 1, },
		BottomLeftCorner	= { layer = "BORDER", atlas = "PKBT-Panel-Bronze-Border-CornerBottomLeft", x = -1, y = -2, },
		BottomRightCorner	= { layer = "BORDER", atlas = "PKBT-Panel-Bronze-Border-CornerBottomRight", x = 1, y = -2, },
		TopEdge				= { layer = "BORDER", atlas = "PKBT-Panel-Bronze-Border-EdgeTop", },
		BottomEdge			= { layer = "BORDER", atlas = "PKBT-Panel-Bronze-Border-EdgeBottom", },
		LeftEdge			= { layer = "BORDER", atlas = "PKBT-Panel-Bronze-Border-EdgeLeft", },
		RightEdge			= { layer = "BORDER", atlas = "PKBT-Panel-Bronze-Border-EdgeRight", },
	},

	PKBT_PanelBronzeGlow = {
		TopLeftCorner		= { layer = "BORDER", atlas = "PKBT-Panel-Bronze-Glow-CornerTopLeft", x = -15, y = 17 },
		TopRightCorner		= { layer = "BORDER", atlas = "PKBT-Panel-Bronze-Glow-CornerTopRight", x = 15, y = 17, },
		BottomLeftCorner	= { layer = "BORDER", atlas = "PKBT-Panel-Bronze-Glow-CornerBottomLeft", x = -15, y = -17, },
		BottomRightCorner	= { layer = "BORDER", atlas = "PKBT-Panel-Bronze-Glow-CornerBottomRight", x = 15, y = -17, },
		TopEdge				= { layer = "BORDER", atlas = "PKBT-Panel-Bronze-Glow-EdgeTop", },
		BottomEdge			= { layer = "BORDER", atlas = "PKBT-Panel-Bronze-Glow-EdgeBottom", },
		LeftEdge			= { layer = "BORDER", atlas = "PKBT-Panel-Bronze-Glow-EdgeLeft", },
		RightEdge			= { layer = "BORDER", atlas = "PKBT-Panel-Bronze-Glow-EdgeRight", },
	},

	Roulette =
	{
		TopLeftCorner =		{ atlas = "Roulette-left-top-corner", x = -6, y = 6, },
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