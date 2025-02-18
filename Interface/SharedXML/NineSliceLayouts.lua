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

	PKBT_ItemPlateHighlight = {
		TopLeftCorner		= { layer = "BORDER", atlas = "PKBT-ItemPlate-Border-Highlight-CornerTopLeft", x = -8, y = 8, },
		TopRightCorner		= { layer = "BORDER", atlas = "PKBT-ItemPlate-Border-Highlight-CornerTopRight", x = 8, y = 8, },
		BottomLeftCorner	= { layer = "BORDER", atlas = "PKBT-ItemPlate-Border-Highlight-CornerBottomLeft", x = -8, y = -8, },
		BottomRightCorner	= { layer = "BORDER", atlas = "PKBT-ItemPlate-Border-Highlight-CornerBottomRight", x = 8, y = -8, },
		TopEdge				= { layer = "BORDER", atlas = "PKBT-ItemPlate-Border-Highlight-EdgeTop", },
		BottomEdge			= { layer = "BORDER", atlas = "PKBT-ItemPlate-Border-Highlight-EdgeBottom", },
		LeftEdge			= { layer = "BORDER", atlas = "PKBT-ItemPlate-Border-Highlight-EdgeLeft", },
		RightEdge			= { layer = "BORDER", atlas = "PKBT-ItemPlate-Border-Highlight-EdgeRight", },
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
		TopLeftCorner		= { layer = "BORDER", atlas = "PKBT-Panel-Bronze-Glow-CornerTopLeft", x = -17, y = 15 },
		TopRightCorner		= { layer = "BORDER", atlas = "PKBT-Panel-Bronze-Glow-CornerTopRight", x = 16, y = 15, },
		BottomLeftCorner	= { layer = "BORDER", atlas = "PKBT-Panel-Bronze-Glow-CornerBottomLeft", x = -17, y = -15, },
		BottomRightCorner	= { layer = "BORDER", atlas = "PKBT-Panel-Bronze-Glow-CornerBottomRight", x = 16, y = -15, },
		TopEdge				= { layer = "BORDER", atlas = "PKBT-Panel-Bronze-Glow-EdgeTop", },
		BottomEdge			= { layer = "BORDER", atlas = "PKBT-Panel-Bronze-Glow-EdgeBottom", },
		LeftEdge			= { layer = "BORDER", atlas = "PKBT-Panel-Bronze-Glow-EdgeLeft", },
		RightEdge			= { layer = "BORDER", atlas = "PKBT-Panel-Bronze-Glow-EdgeRight", },
	},

	PKBT_PanelMetalBlackBorder = {
		TopLeftCorner		= { layer = "BORDER", atlas = "PKBT-Panel-MetalBlack-Border-CornerTopLeft", x = -7, y = 9, },
		TopRightCorner		= { layer = "BORDER", atlas = "PKBT-Panel-MetalBlack-Border-CornerTopRight", x = 7, y = 9, },
		BottomLeftCorner	= { layer = "BORDER", atlas = "PKBT-Panel-MetalBlack-Border-CornerBottomLeft", x = -7, y = -9, },
		BottomRightCorner	= { layer = "BORDER", atlas = "PKBT-Panel-MetalBlack-Border-CornerBottomRight", x = 7, y = -9, },
		TopEdge				= { layer = "BORDER", atlas = "PKBT-Panel-MetalBlack-Border-EdgeTop", },
		BottomEdge			= { layer = "BORDER", atlas = "PKBT-Panel-MetalBlack-Border-EdgeBottom", },
		LeftEdge			= { layer = "BORDER", atlas = "PKBT-Panel-MetalBlack-Border-EdgeLeft", },
		RightEdge			= { layer = "BORDER", atlas = "PKBT-Panel-MetalBlack-Border-EdgeRight", },
	},

	PKBT_PanelMetalBlackGlow = {
		TopLeftCorner		= { layer = "BORDER", atlas = "PKBT-Panel-MetalBlack-Glow-CornerTopLeft", x = -18, y = 20 },
		TopRightCorner		= { layer = "BORDER", atlas = "PKBT-Panel-MetalBlack-Glow-CornerTopRight", x = 18, y = 20, },
		BottomLeftCorner	= { layer = "BORDER", atlas = "PKBT-Panel-MetalBlack-Glow-CornerBottomLeft", x = -18, y = -20, },
		BottomRightCorner	= { layer = "BORDER", atlas = "PKBT-Panel-MetalBlack-Glow-CornerBottomRight", x = 18, y = -20, },
		TopEdge				= { layer = "BORDER", atlas = "PKBT-Panel-MetalBlack-Glow-EdgeTop", },
		BottomEdge			= { layer = "BORDER", atlas = "PKBT-Panel-MetalBlack-Glow-EdgeBottom", },
		LeftEdge			= { layer = "BORDER", atlas = "PKBT-Panel-MetalBlack-Glow-EdgeLeft", },
		RightEdge			= { layer = "BORDER", atlas = "PKBT-Panel-MetalBlack-Glow-EdgeRight", },
	},

	PKBT_PanelMetalBorder = {
		TopLeftCorner		= { layer = "BORDER", atlas = "PKBT-Panel-Metal-Border-CornerTopLeft", x = -10, y = 10, },
		TopRightCorner		= { layer = "BORDER", atlas = "PKBT-Panel-Metal-Border-CornerTopRight", x = 10, y = 10, },
		BottomLeftCorner	= { layer = "BORDER", atlas = "PKBT-Panel-Metal-Border-CornerBottomLeft", x = -10, y = -10, },
		BottomRightCorner	= { layer = "BORDER", atlas = "PKBT-Panel-Metal-Border-CornerBottomRight", x = 10, y = -10, },
		TopEdge				= { layer = "BORDER", atlas = "PKBT-Panel-Metal-Border-EdgeTop", },
		BottomEdge			= { layer = "BORDER", atlas = "PKBT-Panel-Metal-Border-EdgeBottom", },
		LeftEdge			= { layer = "BORDER", atlas = "PKBT-Panel-Metal-Border-EdgeLeft", },
		RightEdge			= { layer = "BORDER", atlas = "PKBT-Panel-Metal-Border-EdgeRight", },
	},

	PKBT_InputMultilineOpaque = {
		TopLeftCorner		= { layer = "BORDER", atlas = "PKBT-InputMultiline-Opaque-Backdrop-CornerTopLeft", x = -14, y = 14, },
		TopRightCorner		= { layer = "BORDER", atlas = "PKBT-InputMultiline-Opaque-Backdrop-CornerTopRight", x = 14, y = 14, },
		BottomLeftCorner	= { layer = "BORDER", atlas = "PKBT-InputMultiline-Opaque-Backdrop-CornerBottomLeft", x = -14, y = -15, },
		BottomRightCorner	= { layer = "BORDER", atlas = "PKBT-InputMultiline-Opaque-Backdrop-CornerBottomRight", x = 14, y = -15, },
		TopEdge				= { layer = "BORDER", atlas = "PKBT-InputMultiline-Opaque-Backdrop-EdgeTop", },
		BottomEdge			= { layer = "BORDER", atlas = "PKBT-InputMultiline-Opaque-Backdrop-EdgeBottom", },
		LeftEdge			= { layer = "BORDER", atlas = "PKBT-InputMultiline-Opaque-Backdrop-EdgeLeft", },
		RightEdge			= { layer = "BORDER", atlas = "PKBT-InputMultiline-Opaque-Backdrop-EdgeRight", },
		Center				= { layer = "BORDER", atlas = "PKBT-InputMultiline-Opaque-Backdrop-Center", },
	},

	PKBT_InputMultilineTransparent = {
		TopLeftCorner		= { layer = "BORDER", atlas = "PKBT-InputMultiline-Transparent-Backdrop-CornerTopLeft", x = -4, y = 3, },
		TopRightCorner		= { layer = "BORDER", atlas = "PKBT-InputMultiline-Transparent-Backdrop-CornerTopRight", x = 4, y = 3, },
		BottomLeftCorner	= { layer = "BORDER", atlas = "PKBT-InputMultiline-Transparent-Backdrop-CornerBottomLeft", x = -4, y = -4, },
		BottomRightCorner	= { layer = "BORDER", atlas = "PKBT-InputMultiline-Transparent-Backdrop-CornerBottomRight", x = 4, y = -4, },
		TopEdge				= { layer = "BORDER", atlas = "PKBT-InputMultiline-Transparent-Backdrop-EdgeTop", },
		BottomEdge			= { layer = "BORDER", atlas = "PKBT-InputMultiline-Transparent-Backdrop-EdgeBottom", },
		LeftEdge			= { layer = "BORDER", atlas = "PKBT-InputMultiline-Transparent-Backdrop-EdgeLeft", },
		RightEdge			= { layer = "BORDER", atlas = "PKBT-InputMultiline-Transparent-Backdrop-EdgeRight", },
		Center				= { layer = "BORDER", atlas = "PKBT-InputMultiline-Transparent-Backdrop-Center", },
	},

	PKBT_PanelSilverBorder = {
		TopLeftCorner		= { layer = "BORDER", atlas = "PKBT-Panel-Silver-Border-CornerTopLeft", x = -1, y = 1, },
		TopRightCorner		= { layer = "BORDER", atlas = "PKBT-Panel-Silver-Border-CornerTopRight", x = 1, y = 1, },
		BottomLeftCorner	= { layer = "BORDER", atlas = "PKBT-Panel-Silver-Border-CornerBottomLeft", x = -1, y = -2, },
		BottomRightCorner	= { layer = "BORDER", atlas = "PKBT-Panel-Silver-Border-CornerBottomRight", x = 1, y = -2, },
		TopEdge				= { layer = "BORDER", atlas = "PKBT-Panel-Silver-Border-EdgeTop", },
		BottomEdge			= { layer = "BORDER", atlas = "PKBT-Panel-Silver-Border-EdgeBottom", },
		LeftEdge			= { layer = "BORDER", atlas = "PKBT-Panel-Silver-Border-EdgeLeft", },
		RightEdge			= { layer = "BORDER", atlas = "PKBT-Panel-Silver-Border-EdgeRight", },
	},

	PKBT_SubMenu = {
		TopLeftCorner		= { layer = "BORDER", atlas = "PKBT-Store-SubMenu-Background-EdgeLeft", },
		TopRightCorner		= { layer = "BORDER", atlas = "PKBT-Store-SubMenu-Background-EdgeRight", },
		BottomLeftCorner	= { layer = "BORDER", atlas = "PKBT-Store-SubMenu-Background-CornerBottomLeft", },
		BottomRightCorner	= { layer = "BORDER", atlas = "PKBT-Store-SubMenu-Background-CornerBottomRight", },
		TopEdge				= { layer = "BORDER", atlas = "PKBT-Store-SubMenu-Background", },
		BottomEdge			= { layer = "BORDER", atlas = "PKBT-Store-SubMenu-Background-EdgeBottom", },
		LeftEdge			= { layer = "BORDER", atlas = "PKBT-Store-SubMenu-Background-EdgeLeft", },
		RightEdge			= { layer = "BORDER", atlas = "PKBT-Store-SubMenu-Background-EdgeRight", },
		Center				= { layer = "BORDER", atlas = "PKBT-Store-SubMenu-Background", },
	},

	PKBT_StoreItemPlateHighlight = {
		TopLeftCorner		= { layer = "ARTWORK", atlas = "PKBT-Store-ItemPlate-Highlight-CornerTopLeft", x = 6, y = -6 },
		TopRightCorner		= { layer = "ARTWORK", atlas = "PKBT-Store-ItemPlate-Highlight-CornerTopRight", x = -5, y = -6 },
		BottomLeftCorner	= { layer = "ARTWORK", atlas = "PKBT-Store-ItemPlate-Highlight-CornerBottomLeft", x = 6, y = 7 },
		BottomRightCorner	= { layer = "ARTWORK", atlas = "PKBT-Store-ItemPlate-Highlight-CornerBottomRight", x = -5, y = 7 },
		TopEdge				= { layer = "ARTWORK", atlas = "PKBT-Store-ItemPlate-Highlight-EdgeTop", },
		BottomEdge			= { layer = "ARTWORK", atlas = "PKBT-Store-ItemPlate-Highlight-EdgeBottom", },
		LeftEdge			= { layer = "ARTWORK", atlas = "PKBT-Store-ItemPlate-Highlight-EdgeLeft", },
		RightEdge			= { layer = "ARTWORK", atlas = "PKBT-Store-ItemPlate-Highlight-EdgeRight", },
		Center				= { layer = "ARTWORK", atlas = "PKBT-Store-ItemPlate-Highlight-Center", },
	},

	PKBT_StoreCardPlate = {
		TopLeftCorner		= { layer = "BORDER", atlas = "PKBT-Store-Cards-NineSlice-Border-CornerTopLeft", x = -12, y = 12 },
		TopRightCorner		= { layer = "BORDER", atlas = "PKBT-Store-Cards-NineSlice-Border-CornerTopRight", x = 12, y = 12 },
		BottomLeftCorner	= { layer = "BORDER", atlas = "PKBT-Store-Cards-NineSlice-Border-CornerBottomLeft", x = -12, y = -12 },
		BottomRightCorner	= { layer = "BORDER", atlas = "PKBT-Store-Cards-NineSlice-Border-CornerBottomRight", x = 12, y = -12 },
		TopEdge				= { layer = "BORDER", atlas = "PKBT-Store-Cards-NineSlice-Border-EdgeTop", },
		BottomEdge			= { layer = "BORDER", atlas = "PKBT-Store-Cards-NineSlice-Border-EdgeBottom", },
		LeftEdge			= { layer = "BORDER", atlas = "PKBT-Store-Cards-NineSlice-Border-EdgeLeft", },
		RightEdge			= { layer = "BORDER", atlas = "PKBT-Store-Cards-NineSlice-Border-EdgeRight", },
	},

	PKBT_StoreCardPlateShadow = {
		TopLeftCorner		= { layer = "BORDER", atlas = "PKBT-Store-Cards-NineSlice-Shadow-CornerTopLeft", x = -12, y = 12 },
		TopRightCorner		= { layer = "BORDER", atlas = "PKBT-Store-Cards-NineSlice-Shadow-CornerTopRight", x = 12, y = 12 },
		BottomLeftCorner	= { layer = "BORDER", atlas = "PKBT-Store-Cards-NineSlice-Shadow-CornerBottomLeft", x = -12, y = -12 },
		BottomRightCorner	= { layer = "BORDER", atlas = "PKBT-Store-Cards-NineSlice-Shadow-CornerBottomRight", x = 12, y = -12 },
		TopEdge				= { layer = "BORDER", atlas = "PKBT-Store-Cards-NineSlice-Shadow-EdgeTop", },
		BottomEdge			= { layer = "BORDER", atlas = "PKBT-Store-Cards-NineSlice-Shadow-EdgeBottom", },
		LeftEdge			= { layer = "BORDER", atlas = "PKBT-Store-Cards-NineSlice-Shadow-EdgeLeft", },
		RightEdge			= { layer = "BORDER", atlas = "PKBT-Store-Cards-NineSlice-Shadow-EdgeRight", },
	},

	Roulette =
	{
		TopLeftCorner =		{ atlas = "Roulette-left-top-corner", x = -6, y = 6, },
		TopRightCorner =	{ atlas = "Roulette-right-top-corner", x = 6, y = 6, },
		BottomLeftCorner =	{ atlas = "Roulette-left-bottom-corner", x = 3, y = -6, },
		BottomRightCorner =	{ atlas = "Roulette-right-bottom-corner", x = 5.6, y = -5.8, },
	},

	SplashBattlePass_2024_2 = {
		TopLeftCorner		= { layer = "BORDER", atlas = "Custom-Splash-BattlePass-2024-2-Assets-Card-Border-CornerTopLeft", x = -15, y = 17 },
		TopRightCorner		= { layer = "BORDER", atlas = "Custom-Splash-BattlePass-2024-2-Assets-Card-Border-CornerTopRight", x = 15, y = 17, },
		BottomLeftCorner	= { layer = "BORDER", atlas = "Custom-Splash-BattlePass-2024-2-Assets-Card-Border-CornerBottomLeft", x = -15, y = -17, },
		BottomRightCorner	= { layer = "BORDER", atlas = "Custom-Splash-BattlePass-2024-2-Assets-Card-Border-CornerBottomRight", x = 15, y = -17, },
		TopEdge				= { layer = "BORDER", atlas = "Custom-Splash-BattlePass-2024-2-Assets-Card-Border-EdgeTop", },
		BottomEdge			= { layer = "BORDER", atlas = "Custom-Splash-BattlePass-2024-2-Assets-Card-Border-EdgeBottom", },
		LeftEdge			= { layer = "BORDER", atlas = "Custom-Splash-BattlePass-2024-2-Assets-Card-Border-EdgeLeft", },
		RightEdge			= { layer = "BORDER", atlas = "Custom-Splash-BattlePass-2024-2-Assets-Card-Border-EdgeRight", },
	},

	GlueDarkTemplate =
	{
		TopLeftCorner =		{ layer = "ARTWORK", atlas = "GlueDark-Border-Panel-CornerTopLeft", x = -8, y = 8, },
		TopRightCorner =	{ layer = "ARTWORK", atlas = "GlueDark-Border-Panel-CornerTopRight", x = 8, y = 8, },
		BottomLeftCorner =	{ layer = "ARTWORK", atlas = "GlueDark-Border-Panel-CornerBottomLeft", x = -8, y = -8, },
		BottomRightCorner =	{ layer = "ARTWORK", atlas = "GlueDark-Border-Panel-CornerBottomRight", x = 8, y = -8, },
		TopEdge =			{ layer = "ARTWORK", atlas = "GlueDark-Border-Panel-EdgeTop", },
		BottomEdge =		{ layer = "ARTWORK", atlas = "GlueDark-Border-Panel-EdgeBottom", },
		LeftEdge =			{ layer = "ARTWORK", atlas = "GlueDark-Border-Panel-EdgeLeft", },
		RightEdge =			{ layer = "ARTWORK", atlas = "GlueDark-Border-Panel-EdgeRight", },
	},

	GlueDarkDropDownBorder =
	{
		TopLeftCorner =		{ layer = "OVERLAY", atlas = "GlueDark-Border-Dropdown-CornerTopLeft", x = -1, y = 1, },
		TopRightCorner =	{ layer = "OVERLAY", atlas = "GlueDark-Border-Dropdown-CornerTopRight", x = 1, y = 1, },
		BottomLeftCorner =	{ layer = "OVERLAY", atlas = "GlueDark-Border-Dropdown-CornerBottomLeft", x = -1, y = -1, },
		BottomRightCorner =	{ layer = "OVERLAY", atlas = "GlueDark-Border-Dropdown-CornerBottomRight", x = 1, y = -1, },
		TopEdge =			{ layer = "OVERLAY", atlas = "GlueDark-Border-Dropdown-EdgeTop", },
		BottomEdge =		{ layer = "OVERLAY", atlas = "GlueDark-Border-Dropdown-EdgeBottom", },
		LeftEdge =			{ layer = "OVERLAY", atlas = "GlueDark-Border-Dropdown-EdgeLeft", },
		RightEdge =			{ layer = "OVERLAY", atlas = "GlueDark-Border-Dropdown-EdgeRight", },
	},

	GlueDarkMetalTripleBorder =
	{
		TopLeftCorner =		{ layer = "OVERLAY", atlas = "GlueDark-Metal-Triple-Border-CornerTopLeft", x = -11, y = 7, },
		TopRightCorner =	{ layer = "OVERLAY", atlas = "GlueDark-Metal-Triple-Border-CornerTopRight", x = 11, y = 7, },
		BottomLeftCorner =	{ layer = "OVERLAY", atlas = "GlueDark-Metal-Triple-Border-CornerBottomLeft", x = -11, y = -8, },
		BottomRightCorner =	{ layer = "OVERLAY", atlas = "GlueDark-Metal-Triple-Border-CornerBottomRight", x = 11, y = -8, },
		TopEdge =			{ layer = "OVERLAY", atlas = "GlueDark-Metal-Triple-Border-EdgeTop", },
		BottomEdge =		{ layer = "OVERLAY", atlas = "GlueDark-Metal-Triple-Border-EdgeBottom", },
		LeftEdge =			{ layer = "OVERLAY", atlas = "GlueDark-Metal-Triple-Border-EdgeLeft", },
		RightEdge =			{ layer = "OVERLAY", atlas = "GlueDark-Metal-Triple-Border-EdgeRight", },
	}
}