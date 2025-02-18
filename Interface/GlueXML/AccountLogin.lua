local BACKGROUND_MODEL = [[Interface\Glues\Models\UI_MainMenu_SirusDefault\UI_MainMenu_SirusDefault.m2]]
local BACKGROUND_MODEL_NY = [[Interface\Glues\Models\UI_Login_NewYearSirus\UI_Login_NewYearSirus.m2]]

LOGIN_MODEL_STRUCT = {
	ENABLED		= 1,
	WIDTH		= 2,
	HEIGHT		= 3,
	ALPHA		= 4,
	SCALE		= 5,
	FACING		= 6,
	LIGHT_TYPE	= 7,
	SEQUENCE	= 8,
	POSITION	= 9,
	MODEL_PATH	= 10,
}

LOGIN_MODELS = {
	{1, 1, 1, 1, 0.35, 2.456, 2, 0, {-12.7, -1.574, -1.663}, [[interface\glues\models\ui_mainmenu_sirusdefault\humanmalefarmer.m2]]},
	{1, 1, 1, 1, 0.22, 2.456, 2, 0, {-19.4, -1.861, -2.436}, [[world\goober\g_fishingbobber.m2]]},
	{1, 1, 1, 1, 0.37, 2.63, 2, 0, {-14.4, 2.026, -1.997}, [[creature\frogduck\frogduck.m2]]},
	{1, 1, 1, 1, 0.46, 1.059, 2, 0, {-14.4, -5.432, -1.526}, [[creature\frogduck\frogduck.m2]]},
	{1, 1, 1, 1, 0.25, 2.282, 2, 0, {-16.6, -5.736, -2.506}, [[world\kalimdor\azshara\seaplants\starfish01_02\starfish01_02.m2]]},
	{1, 1, 1, 1, 0.01, -1.383, 2, 0, {-12.5, -2.523, 0.882}, [[world\generic\passivedoodads\particleemitters\blacksmith_smoke.m2]]},
	{1, 1, 1, 1, 0.01, -1.383, 2, 0, {-12.5, -2.911, 1.025}, [[world\generic\passivedoodads\particleemitters\blacksmith_smoke.m2]]},
	{1, 1, 1, 1, 0.02, -1.383, 2, 0, {-12.5, -3.327, 1.11}, [[world\generic\passivedoodads\particleemitters\blacksmith_smoke.m2]]},
	{1, 1, 1, 1, 0.01, -1.383, 2, 0, {-12.5, -0.959, 1.528}, [[world\generic\passivedoodads\particleemitters\blacksmith_smoke.m2]]},
	{1, 1, 1, 1, 0.01, -0.859, 2, 0, {-12.5, 0.555, 1.692}, [[world\generic\passivedoodads\particleemitters\blacksmith_smoke.m2]]},
	{1, 1, 1, 1, 0.07, -1.034, 2, 0, {-23.8, -2.613, 1.534}, [[interface\glues\models\ui_mainmenu_sirusdefault\8hu_kultiras_proudmoorekeep_flag02.m2]]},
	{1, 1, 1, 1, 0.08, -1.035, 2, 0, {-22, -2.229, 1.507}, [[interface\glues\models\ui_mainmenu_sirusdefault\8hu_kultiras_proudmoorekeep_flag02.m2]]},
	{1, 1, 1, 1, 0.09, 1.059, 2, 0, {-23.7, -1.999, 1.556}, [[interface\glues\models\ui_mainmenu_sirusdefault\8hu_kultiras_proudmoorekeep_flag02.m2]]},
	{1, 1, 1, 1, 0.1, -1.035, 2, 0, {-22.2, -1.653, 1.539}, [[interface\glues\models\ui_mainmenu_sirusdefault\8hu_kultiras_proudmoorekeep_flag02.m2]]},
	{1, 1, 1, 1, 0.11, -1.035, 2, 0, {-23.8, -1.38, 1.801}, [[interface\glues\models\ui_mainmenu_sirusdefault\8hu_kultiras_proudmoorekeep_flag02.m2]]},
	{1, 1, 1, 1, 0.12, -0.86, 2, 0, {-23.8, -1.016, 1.863}, [[interface\glues\models\ui_mainmenu_sirusdefault\8hu_kultiras_proudmoorekeep_flag02.m2]]},
	{1, 1, 1, 1, 0.13, -1.035, 2, 0, {-24.1, 0.25, 1.956}, [[interface\glues\models\ui_mainmenu_sirusdefault\8hu_kultiras_proudmoorekeep_flag02.m2]]},
	{1, 1, 1, 1, 0.13, -0.86, 2, 0, {-23.8, 0.659, 2.021}, [[interface\glues\models\ui_mainmenu_sirusdefault\8hu_kultiras_proudmoorekeep_flag02.m2]]},
	{1, 1, 1, 1, 0.15, -0.86, 2, 0, {-23.8, 2.063, 2.226}, [[interface\glues\models\ui_mainmenu_sirusdefault\8hu_kultiras_proudmoorekeep_flag02.m2]]},
	{1, 1, 1, 1, 0.15, -0.86, 2, 0, {-23.2, 2.63, 2.255}, [[interface\glues\models\ui_mainmenu_sirusdefault\8hu_kultiras_proudmoorekeep_flag02.m2]]},
	{1, 1, 1, 1, 0.16, -0.86, 2, 0, {-23.8, 3.361, 2.707}, [[interface\glues\models\ui_mainmenu_sirusdefault\8hu_kultiras_proudmoorekeep_flag02.m2]]},
	{1, 1, 1, 1, 0.19, -1.035, 2, 0, {-23.8, 4.109, 2.74}, [[interface\glues\models\ui_mainmenu_sirusdefault\8hu_kultiras_proudmoorekeep_flag02.m2]]},
	{1, 1, 1, 1, 0.25, -1.209, 2, 0, {-23.8, 5.303, 3.382}, [[interface\glues\models\ui_mainmenu_sirusdefault\8hu_kultiras_proudmoorekeep_flag02.m2]]},
	{1, 1, 1, 1, 0.26, -1.035, 2, 0, {-23.8, 6.071, 3.437}, [[interface\glues\models\ui_mainmenu_sirusdefault\8hu_kultiras_proudmoorekeep_flag02.m2]]},
	{1, 1, 1, 1, 0.18, -1.035, 2, 0, {-23.8, 4.375, 4.852}, [[interface\glues\models\ui_mainmenu_sirusdefault\8hu_kultiras_proudmoorekeep_flag02.m2]]},
	{1, 1, 1, 1, 0.24, -1.035, 2, 0, {-23.8, 1.796, 3.794}, [[interface\glues\models\ui_mainmenu_sirusdefault\8hu_kultiras_proudmoorekeep_flag02.m2]]},
	{1, 1, 1, 1, 0.13, -0.86, 2, 0, {-22.8, -0.013, 3.311}, [[interface\glues\models\ui_mainmenu_sirusdefault\8hu_kultiras_proudmoorekeep_flag02.m2]]},
	{1, 1, 1, 1, 0.16, -1.209, 2, 0, {-12.5, 4.703, -0.058}, [[world\expansion09\doodads\volcanic\10can_beachfillerbush_b01.m2]]},
	{1, 1, 1, 1, 0.16, -2.256, 2, 0, {-12.5, 4.545, -0.348}, [[world\expansion09\doodads\volcanic\10can_beachfillerbush_b01.m2]]},
	{1, 1, 1, 1, 0.41, 2.107, 2, 0, {-13, 0.405, -2.397}, [[world\nodxt\detail\itkfish01.m2]]},
	{1, 1, 1, 1, 0.21, -1.034, 2, 0, {-23.5, -8.609, -3.795}, [[world\expansion07\doodads\nazjatar\8nzj_creepystarfish_clump_b01.m2]]},
	{1, 1, 1, 1, 0.42, -0.162, 2, 0, {-13.1, -1.378, -1.831}, [[world\expansion06\doodads\murloc\7mu_murloc_food_fish04.m2]]},
	{1, 1, 1, 1, 0.3, 0.886, 2, 0, {-13, -1.175, -1.726}, [[world\expansion05\doodads\human\doodads\6hu_fishing_bucket02.m2]]},
	{1, 1, 1, 1, 0.33, -2.779, 2, 0, {-12.5, -1.059, -1.364}, [[world\azeroth\bootybay\passivedoodad\fishingpoles\fishingpole02.m2]]},
	{1, 1, 1, 1, 0.3, 2.98, 2, 0, {-12.5, 3.825, 0.137}, [[world\expansion04\doodads\pandaren\birds\pa_butterfly_red_loop.m2]]},
	{1, 1, 1, 1, 0.33, 2.98, 2, 0, {-12.5, 1.242, -1.745}, [[world\expansion04\doodads\pandaren\birds\pa_dragonfly_red_loop.m2]]},
	{1, 1, 1, 1, 0.18, -0.161, 2, 0, {-14, 0.855, 3.636}, [[world\critter\birds\bird01.m2]]},
	{1, 1, 1, 1, 0.07, 0.362, 2, 0, {-14, -0.83, 2.048}, [[world\critter\birds\bird01.m2]]},
	{1, 1, 1, 1, 0.13, 1.235, 2, 0, {-14, 3.243, 2.991}, [[world\critter\birds\bird01.m2]]},
	{1, 1, 1, 1, 0.15, 1.933, 2, 0, {-14, 3.313, 3.044}, [[world\critter\birds\bird01.m2]]},
	{1, 1, 1, 1, 0.06, 2.98, 2, 0, {-17.4, -4.663, 2.185}, [[world\critter\birds\bird02.m2]]},
	{1, 1, 1, 1, 0.06, -1.907, 2, 0, {-17.4, -4.733, 2.044}, [[world\critter\birds\bird02.m2]]},
	{1, 1, 1, 1, 0.08, -2.605, 2, 0, {-17.4, -1.131, 2.603}, [[world\critter\birds\bird02.m2]]},
	{1, 1, 1, 1, 0.1, 2.98, 2, 0, {-16.3, -0.224, 5.393}, [[world\critter\birds\birds_condor_01.m2]]},
	{1, 1, 1, 1, 0.11, 2.98, 2, 0, {-20.5, -6.095, -2.701}, [[world\critter\birds\wasp01.m2]]},
	{1, 1, 1, 1, 0.09, -1.034, 2, 0, {-17.7, 0.062, -2.305}, [[world\critter\birds\wasp02.m2]]},
	{1, 1, 1, 1, 0.35, 2.63, 2, 0, {-14.4, -1.791, -2.355}, [[interface\glues\models\ui_mainmenu_sirusdefault\cat2large.m2]]},
	{1, 1, 1, 1, 0.22, 0.711, 2, 0, {-12.5, -2.154, -1.519}, [[world\expansion09\doodads\explorersleague\10el_explorersleague_waterskin02.m2]]},
	{1, 1, 1, 1, 0.31, 2.456, 2, 0, {-12.4, -1.649, -1.661}, [[world\expansion09\doodads\explorersleague\10el_explorersleague_stool01.m2]]},
	{1, 1, 1, 1, 0.19, -1.035, 2, 0, {-12.5, 5.442, 0.02}, [[world\expansion09\doodads\volcanic\10can_beachfillerbush_b01.m2]]},
	{1, 1, 1, 1, 0.15, -0.162, 2, 0, {-12.5, 5.156, -0.048}, [[world\expansion09\doodads\volcanic\10can_beachfillerbush_b01.m2]]},
	{1, 1, 1, 1, 0.32, 2.282, 2, 0, {-12.5, -6.209, -2.923}, [[world\expansion09\doodads\10xp_plant16.m2]]},
	{1, 1, 1, 1, 0.46, 1.932, 2, 0, {-12.5, 5.365, -0.171}, [[world\expansion09\doodads\10xp_plant13.m2]]},
	{1, 1, 1, 1, 0.19, -1.907, 2, 0, {-12.5, 4.886, -0.398}, [[world\expansion09\doodads\volcanic\10can_beachfillerbush_b01.m2]]},
	{1, 1, 1, 1, 0.14, -0.86, 2, 0, {-12.5, 4.301, -0.144}, [[world\expansion09\doodads\volcanic\10can_beachfillerbush_b01.m2]]},
	{1, 1, 1, 1, 0.26, -1.558, 2, 0, {-12.5, 5.961, 0.044}, [[world\expansion09\doodads\volcanic\10can_beachfillerbush_b01.m2]]},
	{1, 1, 1, 1, 0.26, -0.511, 2, 0, {-15.4, -7.877, -3.489}, [[world\expansion09\doodads\10xp_tree17.m2]]},
	{1, 1, 1, 1, 0.08, 1.758, 2, 0, {-15.4, 5.1, -0.413}, [[world\expansion09\doodads\10xp_tree17.m2]]},
	{1, 1, 1, 1, 0.1, 1.759, 2, 0, {-15.2, 6.804, -0.264}, [[interface\glues\models\ui_mainmenu_sirusdefault\6ng_foresttreeyoung_b01.m2]]},
	{1, 1, 1, 1, 0.3, 2.98, 2, 0, {-12.5, 3.825, 0.137}, [[world\expansion04\doodads\pandaren\birds\pa_butterfly_red_loop.m2]]},
	{1, 1, 1, 1, 0.15, -2.605, 2, 0, {-16.2, 1.863, -2.947}, [[world\expansion09\doodads\10xp_rock_a02.m2]]},
	{1, 1, 1, 1, 0.14, 0.712, 2, 0, {-16.2, 2.388, -3.013}, [[world\expansion09\doodads\10xp_rock_a02.m2]]},
	{1, 1, 1, 1, 0.19, -2.081, 2, 0, {-16.2, -3.851, -3.076}, [[world\expansion09\doodads\10xp_rock_a02.m2]]},
	{1, 1, 1, 1, 0.32, 2.282, 2, 0, {-12.5, -6.209, -2.923}, [[world\expansion09\doodads\10xp_plant16.m2]]},
	{1, 1, 1, 1, 0.6, -2.78, 2, 0, {-12.5, -6.679, -2.929}, [[world\expansion09\doodads\10xp_plant13.m2]]},
	{1, 1, 1, 1, 0.17, -2.256, 2, 0, {-12.5, 4.173, -0.417}, [[world\expansion09\doodads\volcanic\10can_beachfillerbush_b01.m2]]},
	{1, 1, 1, 1, 0.35, -2.431, 2, 134, {-12.5, -0.93, -1.65}, [[interface\glues\models\ui_mainmenu_sirusdefault\humanmalekid.m2]]},
	{1, 1, 1, 1, 0.39, 2.631, 2, 0, {-12.5, 4.023, -2.974}, [[world\expansion09\doodads\volcanic\10can_beachfillerbush_b01.m2]]},
	{1, 1, 1, 1, 0.57, -0.336, 2, 0, {-1, 1.95, -0.298}, [[interface\glues\models\ui_mainmenu_sirusdefault\6ng_aridtree_b03.m2]]},
	{1, 1, 1, 1, 0.56, -0.685, 2, 0, {-12.5, 4.929, -3.157}, [[world\expansion09\doodads\volcanic\10can_beachfillerbush_b01.m2]]},
	{1, 1, 1, 1, 0.84, 2.98, 2, 0, {-10, 5.534, -2.573}, [[world\expansion09\doodads\grasslands\10gsl_foothillsfillerbush_a01.m2]]},
	{1, 1, 1, 1, 0.14, -3.13, 2, 0, {-14.3, -3.718, -2.958}, [[world\expansion06\doodads\hippogryph\7hg_hippogryph_nest02.m2]]},
	{1, 1, 1, 1, 0.21, 0.71, 2, 97, {-14.4, -3.732, -2.837}, [[interface\glues\models\ui_mainmenu_sirusdefault\duckbaby.m2]]},

	{0, 1, 1, 1, 0.21, -3, 0, 0, {-11, -1.193, 1.323}, [[Interface\Glues\Models\UI_Login_NewYearSirus\s_firework_bigsnowflakes.m2]]},
	{0, 1, 1, 1, 0.3, -3, 0, 0, {-13.5, 0.092, 1.267}, [[Interface\Glues\Models\UI_Login_NewYearSirus\s_firework_fir-tree.m2]]},
	{0, 1, 1, 1, 0.32, -3, 0, 0, {-11, -1.171, 0.971}, [[Interface\Glues\Models\UI_Login_NewYearSirus\s_firework_newyear.m2]]},
	{0, 1, 1, 1, 0.28, -3, 0, 0, {-11, 1.642, 1.056}, [[Interface\Glues\Models\UI_Login_NewYearSirus\s_firework_sirus.m2]]},
	{0, 1, 1, 1, 0.61, -3, 0, 0 , {-11, 1.218, 4.004}, [[Interface\Glues\Models\UI_Login_NewYearSirus\s_firework_snowflakestarget1.m2]]},
	{0, 1, 1, 1, 0.69, -3, 0, 0 , {-11, -0.429, 1.955}, [[Interface\Glues\Models\UI_Login_NewYearSirus\s_firework_snowflakestarget2.m2]]},
	{0, 1, 1, 1, 0.69, -3, 0, 0 , {-11, -1.31, 2.63}, [[Interface\Glues\Models\UI_Login_NewYearSirus\s_firework_snowflakestarget3.m2]]},
	{0, 1, 1, 1, 0.7, -3, 0, 0, {-11, 0.947, 2.607}, [[Interface\Glues\Models\UI_Login_NewYearSirus\s_firework_snowflakestarget4.m2]]},
	{0, 1, 1, 1, 0.06, 0, 0, 0, {-13.9, -2.773, 4.83}, [[world\expansion08\doodads\babylonzone\9pln_basecloud01.m2]]},
	{0, 1, 1, 1, 0.5, 0, 0, 0, {-3, -0.243, 0.043}, [[Interface\Glues\Models\UI_Login_NewYearSirus\snowfall.m2]]},
	{0, 1, 1, 1, 0.43, 2.443, 0, 0, {-23.7, 0.07, 0.435}, [[Interface\Glues\Models\UI_Login_NewYearSirus\xmastree_particle.m2]]},
	{0, 1, 1, 1, 0.23, -2.967, 0, 0, {-13.6, 1.043, -0.109}, [[world\expansion07\doodads\human\8hu_humanfemale_crowd01.m2]]},
	{0, 1, 1, 1, 0.19, 2.411, 0, 0, {-11, -0.552, 0.087}, [[world\expansion07\doodads\human\8hu_humanfemale_crowd03.m2]]},
	{0, 1, 1, 1, 0.19, 2.934, 0, 0, {-11, -0.32, 0.05}, [[world\expansion07\doodads\human\8hu_humanmale_crowd02_animated.m2]]},
	{0, 1, 1, 1, 0.2, -2.476, 0, 0, {-11.6, 0.59, 0.036}, [[world\expansion07\doodads\human\8hu_humanmale_crowd01_animated.m2]]},
	{0, 1, 1, 1, 0.23, -3, 0, 0, {-13.4, 0.226, -0.09}, [[world\expansion07\doodads\human\8hu_humanmale_crowd02_animated.m2]]},
	{0, 1, 1, 1, 0.22, -2.825, 0, 0, {-11, 0.382, 0.013}, [[world\expansion07\doodads\human\8hu_humanmale_crowd03_animated.m2]]},
	{0, 1, 1, 1, 0.23, 2.236, 0, 0, {-12.4, -1.194, -0.141}, [[world\expansion07\doodads\human\8hu_humanmale_crowd05_animated.m2]]},
	{0, 1, 1, 1, 0.23, -2.302, 0, 0, {-13.8, 1.363, -0.098}, [[world\expansion07\doodads\human\8hu_humanmale_crowd06_animated.m2]]},
	{0, 1, 1, 1, 0.22, -2.825, 0, 0, {-11.7, 1.107, -0.007}, [[world\expansion07\doodads\human\8hu_humanfemale_crowd01.m2]]},
	{0, 1, 1, 1, 0.23, 2.76, 0, 0, {-12.2, -0.132, -0}, [[world\expansion07\doodads\human\8hu_humanfemale_crowd03.m2]]},
	{0, 1, 1, 1, 0.25, -2.476, 0, 0, {-12.4, 1.419, -0.082}, [[world\expansion07\doodads\human\8hu_humanmale_crowd05_animated.m2]]},
	{0, 1, 1, 1, 0.23, -3, 0, 0, {-11, 0.505, -0.124}, [[world\expansion07\doodads\human\8hu_humanmale_crowd01_animated.m2]]},
	{0, 1, 1, 1, 0.23, 2.585, 0, 0, {-11.9, -0.477, -0.081}, [[world\expansion07\doodads\human\8hu_humanmale_crowd02_animated.m2]]},
	{0, 1, 1, 1, 0.29, -2.476, 0, 0, {-9.1, 1.556, -0.085}, [[world\expansion07\doodads\human\8hu_humanmale_crowd03_animated.m2]]},
	{0, 1, 1, 1, 0.23, 2.934, 0, 0, {-10.4, -0.188, -0.08}, [[world\expansion07\doodads\human\8hu_humanmale_crowd05_animated.m2]]},
	{0, 1, 1, 1, 0.27, -2.825, 0, 0, {-12.4, 0.805, -0.143}, [[world\expansion07\doodads\human\8hu_humanmale_crowd06_animated.m2]]},
	{0, 1, 1, 1, 0.23, 2.585, 0, 0, {-11.3, -0.989, -0.081}, [[world\expansion07\doodads\human\8hu_humanfemale_crowd01.m2]]},
	{0, 1, 1, 1, 0.35, -2.476, 0, 0, {-10.4, 1.832, -0.194}, [[world\expansion07\doodads\human\8hu_humanfemale_crowd03.m2]]},
	{0, 1, 1, 1, 0.25, -3, 0, 0, {-10.7, 0.171, -0.068}, [[world\expansion07\doodads\human\8hu_humanfemale_crowd01.m2]]},
	{0, 1, 1, 1, 0.28, 2.76, 0, 0, {-10.6, -0.487, -0.105}, [[world\expansion07\doodads\human\8hu_humanmale_crowd01_animated.m2]]},
	{0, 1, 1, 1, 0.28, 2.236, 0, 0, {-14.6, -2.181, -0.349}, [[world\expansion07\doodads\human\8hu_humanmale_crowd02_animated.m2]]},
	{0, 1, 1, 1, 0.35, -0.382, 0, 97, {-7.7, -1.38, -1.17}, [[Interface\Glues\Models\UI_Login_NewYearSirus\dogprimal.m2]]},
	{0, 1, 1, 1, 0.58, 2.061, 0, 69, {-8.1, -1.507, -1.352}, [[world\expansion05\doodads\human\doodads\6hu_inn_meathaunch01.m2]]},
	{0, 1, 1, 1, 0.4, -2.476, 0, 0, {-2.9, -0.945, -0.353}, [[world\expansion03\doodads\worgen\items\worgen_bottle_03.m2]]},
	{0, 1, 1, 1, 0.44, 2.759, 0, 69, {-8, -1.899, -1.658}, [[Interface\Glues\Models\UI_Login_NewYearSirus\wolfdraenor.m2]]},
	{0, 1, 1, 1, 0.39, 0.84, 0, 0, {-5.2, -1.824, -0.157}, [[Interface\Glues\Models\UI_Login_NewYearSirus\kultiranfemalekid.m2]]},
	{0, 1, 1, 1, 0.19, 1.014, 0, 0, {-0.9, 0.57, 0.418}, [[Interface\Glues\Models\UI_Login_NewYearSirus\kultiranfemalekid1.m2]]},
	{0, 1, 1, 1, 0.42, 2.41, 0, 123, {-5.8, 1.599, -0.157}, [[Interface\Glues\Models\UI_Login_NewYearSirus\kultiranfemalekid2.m2]]},
	{0, 1, 1, 1, 0.13, 1.188, 0, 0, {-11, 2.967, -0.558}, [[world\goober\g_witchhat_01.m2]]},
	{0, 1, 1, 1, 0.61, -2.127, 0, 0, {-11, -2.862, -0.895}, [[Interface\Glues\Models\UI_Login_NewYearSirus\kultiranmalekid.m2]]},
	{0, 1, 1, 1, 0.53, -2.302, 0, 43, {-8, 2.451, -0.549}, [[Interface\Glues\Models\UI_Login_NewYearSirus\worgenmalekid.m2]]},
	{0, 1, 1, 1, 0.53, 2.411, 0, 0, {-9.3, -2.159, 1.793}, [[Interface\Glues\Models\UI_Login_NewYearSirus\squirrel2.m2]]},
	{0, 1, 1, 1, 0.39, 0.316, 0, 0, {-11, -2.787, -0.72}, [[item\objectcomponents\weapon\offhand_rosebouquet_a_01.m2]]},
}

LOGIN_MODEL_LIGHTS = {
	[0] = {1, 0, 0, -0.707, -0.707, 0.7, 1.0, 1.0, 1.0, 0, 1.0, 1.0, 0.8},
	[1] = {1, 0, 1, -0.707, -0.707, 0.4, 1.0, 1.0, 1.0, 1, 1.0, 0.0, 0.0},
	[2] = {1, 0, 0, -0.707, -0.707, 1, 0.7, 0.7, 0.7, 0, 1.0, 1.0, 1.0},
}

NEW_YEAR = IsNewYearDecorationEnabled()

function AccountLogin_OnLoad(self)
	self.LoginUI.Logo:SetAtlas(C_RealmInfo.GetServerLogo(0))
	self.Models = {}

	if NEW_YEAR then
		if BACKGROUND_MODEL_NY then
			self:SetCamera(0)
			self:SetSequence(0)
			self:SetModel(BACKGROUND_MODEL_NY)
		else
			self.LoginUI.BGTexture:SetTexture([[Interface\Custom\Glue\Kelthuzad-Room]])
			self.LoginUI.BGTexture:Show()
		end

		self.BGModel:Hide()

		for i = 1, 73 do
			LOGIN_MODELS[i][1] = 0
		end

		for i = 74, #LOGIN_MODELS do
			LOGIN_MODELS[i][1] = 1
		end
	else
		self.BGModel:SetModel(BACKGROUND_MODEL)
	end

	AcceptTOS()
	AcceptEULA()

	self:RegisterEvent("SHOW_SERVER_ALERT")
	self:RegisterEvent("LOGIN_FAILED")
	self:RegisterEvent("SCANDLL_ERROR")
	self:RegisterEvent("SCANDLL_FINISHED")
	self:RegisterEvent("PLAYER_ENTER_TOKEN")
	self:RegisterEvent("FRAMES_LOADED")
	self:RegisterCustomEvent("SERVER_ALERT_UPDATE")
	self:RegisterCustomEvent("CONNECTION_LIST_UPDATE")
	self:RegisterCustomEvent("CONNECTION_AUTOLOGIN_READY")
	self:RegisterCustomEvent("CONNECTION_ERROR")
end

function AccountLogin_OnShow(self)
	for _, model in ipairs(self.Models) do
		local data = LOGIN_MODELS[model.id]

		model:SetModel("Character\\Human\\Male\\HumanMale.mdx")
		model:SetCamera(1)

		model:SetModel(data[LOGIN_MODEL_STRUCT.MODEL_PATH])
		model:SetSequence(data[LOGIN_MODEL_STRUCT.SEQUENCE])

		model:SetModelScale(data[LOGIN_MODEL_STRUCT.SCALE])
		model:SetFacing(data[LOGIN_MODEL_STRUCT.FACING])
		model:SetPosition(unpack(data[LOGIN_MODEL_STRUCT.POSITION], 1, 3))

		local lightType = data[LOGIN_MODEL_STRUCT.LIGHT_TYPE]
		model:SetLight(unpack(lightType and LOGIN_MODEL_LIGHTS[lightType] or LOGIN_MODEL_LIGHTS[0]))
	end

	self.LoginUI:Raise()
end

function AccountLogin_OnEvent(self, event, ...)
	if event == "FRAMES_LOADED" then
		self:UnregisterEvent(event)

		local _, _, width, height = self:GetRect()

		for index, data in ipairs(LOGIN_MODELS) do
			if data[1] == 1 then
				local model = CreateFrame("Model", "$parentModel"..index, self)
				model.id = index

				model:SetPoint("CENTER", 0, 0)
				model:SetSize(width * data[LOGIN_MODEL_STRUCT.WIDTH], height * data[LOGIN_MODEL_STRUCT.HEIGHT])
				model:SetAlpha(data[LOGIN_MODEL_STRUCT.ALPHA])

				table.insert(self.Models, model)
			end
		end

		local accountName, oldPassword, oldAutologin = strsplit("|", GetSavedAccountName())
		if accountName then
			if oldPassword then
				SetSavedAccountName(accountName);

				SetCVar("readTerminationWithoutNotice", oldPassword);
				C_GlueCVars.SetCVar("AUTO_LOGIN", oldAutologin == "true" and "1" or "0");
			end

			AccountLoginAccountEdit:SetText(accountName)

			local password = GetCVar("readTerminationWithoutNotice");
			if password and password ~= "" and password ~= "1" and password ~= "0" then
				AccountLoginPasswordEdit:SetText(password)

				if C_GlueCVars.GetCVar("AUTO_LOGIN") == "1" then
					AccountLoginAutoLogin:SetChecked(1)
				end
			end

			AccountLoginSaveAccountName:SetChecked(true)
			AccountLoginAutoLogin.TitleText:SetTextColor(1, 1, 1)
			AccountLoginAutoLogin:Enable()
		else
			AccountLoginSaveAccountName:SetChecked(false)
			AccountLoginAutoLogin.TitleText:SetTextColor(0.5, 0.5, 0.5)
			AccountLoginAutoLogin:Disable()
		end

		AccountLoginDevTools:SetShown(IsDevClient())
	elseif event == "SCANDLL_ERROR" or event == "SCANDLL_FINISHED" then
		ScanDLLContinueAnyway()
	elseif event == "PLAYER_ENTER_TOKEN" then
		TokenEnterDialog:Show()
	elseif event == "SERVER_ALERT_UPDATE" then
		local alertHTML = ...
		AccountLoginUI_UpdateServerAlertText(alertHTML)
	elseif event == "CONNECTION_LIST_UPDATE" then
		AccountLoginChooseRealmDropDown:Update()
	elseif event == "CONNECTION_AUTOLOGIN_READY" then
		local autologinAlert = ...
		if self:IsShown() then
			if autologinAlert then
				GlueDialog:ShowDialog("OKAY_SERVER_ALERT", autologinAlert)
			else
				AccountLogin_AutoLogin()
			end
		end
	elseif event == "CONNECTION_ERROR" then
		AccountLoginConnectionErrorFrame:Show()
	end
end

function AccountLoginUI_UpdateServerAlertText(text)
	ServerAlertText:SetText(text)
	ServerAlertFrame:Show()
end

function TokenEnterDialog_Okay()
	if string.len( TokenEnterEditBox:GetText() ) < 6 then
		return
	end

	TokenEntered(TokenEnterEditBox:GetText())
	TokenEnterDialog:Hide()
end

function TokenEnterDialog_Cancel()
	TokenEnterDialog:Hide()
	CancelLogin()
end

function AccountLogin_Login()
	local login = AccountLoginAccountEdit:GetText()
	local password = AccountLoginPasswordEdit:GetText()

	if string.find(login, "@", 1, true) then
		GlueDialog:ShowDialog("OKAY", LOGIN_EMAIL_ERROR)
		return
	end

	if login and password then
		if AccountLoginSaveAccountName:GetChecked() then
			if login ~= "" or password ~= "" then
				SetSavedAccountName(login)

				SetCVar("readTerminationWithoutNotice", password);
				C_GlueCVars.SetCVar("AUTO_LOGIN", AccountLoginAutoLogin:GetChecked() and "1" or "0");
			end
		else
			SetSavedAccountName("")
		end

		PlaySound(SOUNDKIT.GS_LOGIN)
		DefaultServerLogin(login, password)
	end
end

function AccountLogin_AutoLogin()
	if C_GlueCVars.GetCVar("AUTO_LOGIN") == "1" then
		C_Timer:NewTicker(0.01, function()
			if AccountLogin:IsVisible() then
				DefaultServerLogin(GetSavedAccountName(), GetCVar("readTerminationWithoutNotice"))
			end
		end, 5)
	end
end

function AccountLoginDevTools_OnShow(self)
	if not SIRUS_DEV_ACCOUNT_LOGIN_MANAGER then return end
	self.AccountsDropDown_Button:SetShown(type(SIRUS_DEV_ACCOUNT_LOGIN_MANAGER.accounts) == "table" and next(SIRUS_DEV_ACCOUNT_LOGIN_MANAGER.accounts))
	self.RealmListDropDown:SetShown(type(SIRUS_DEV_ACCOUNT_LOGIN_MANAGER.realmList) == "table" and next(SIRUS_DEV_ACCOUNT_LOGIN_MANAGER.realmList))
end

function DevToolsRealmListDropDown_OnShow(self)
	GlueDark_DropDownMenu_Initialize(self, DevToolsRealmListDropDown_Initialize)
	GlueDark_DropDownMenu_SetSelectedValue(self, GetCVar("realmList"))
	GlueDark_DropDownMenu_SetWidth(self, 185, true)
	GlueDark_DropDownMenu_JustifyText(self, "CENTER")
end

function DevToolsRealmListDropDown_OnClick(self)
	SetCVar("realmList", self.value)
	GlueDark_DropDownMenu_SetSelectedValue(AccountLoginDevTools.RealmListDropDown, self.value)
end

function DevToolsRealmListDropDown_Initialize()
	if SIRUS_DEV_ACCOUNT_LOGIN_MANAGER and SIRUS_DEV_ACCOUNT_LOGIN_MANAGER.realmList then
		local info = GlueDark_DropDownMenu_CreateInfo()
		info.func = DevToolsRealmListDropDown_OnClick

		for _, realmData in ipairs(SIRUS_DEV_ACCOUNT_LOGIN_MANAGER.realmList) do
			info.text = string.format("%s (%s)", realmData[1], realmData[2])
			info.value = realmData[2]
			info.checked = GetCVar("realmList") == info.value

			GlueDark_DropDownMenu_AddButton(info)
		end
	end
end

function DevToolsAccountsDropDown_OnShow(self)
	GlueDark_DropDownMenu_Initialize(self, DevToolsAccountsDropDown_Initialize, "MENU")
end

function DevToolsAccountsDropDown_OnClick(self)
	AccountLoginAccountEdit:SetText(string.sub(self.value[1], 2, -2))
	AccountLoginPasswordEdit:SetText(string.sub(self.value[2], 2, -2))
end

function DevToolsAccountsDropDown_Initialize()
	if SIRUS_DEV_ACCOUNT_LOGIN_MANAGER and SIRUS_DEV_ACCOUNT_LOGIN_MANAGER.accounts then
		local info = GlueDark_DropDownMenu_CreateInfo()
		info.func = DevToolsAccountsDropDown_OnClick

		for i, accountData in ipairs(SIRUS_DEV_ACCOUNT_LOGIN_MANAGER.accounts) do
			info.text = string.format("%i - %s", i, string.sub(accountData[1], 2, -2))
			info.value = {accountData[1], accountData[2]}
			info.checked = nil

			GlueDark_DropDownMenu_AddButton(info)
		end
	end
end

AccountLoginChooseRealmDropDownMixin = {}

local function ChooseRealmDropdown_OnClick(self)
	GlueDark_DropDownMenu_SetSelectedValue(AccountLoginChooseRealmDropDown, self.value)
	SetCVar("realmList", self.value)
	C_GlueCVars.SetCVar("ENTRY_POINT", self.value)
end

local function ChooseRealmDropdownInit()
	local info = GlueDark_DropDownMenu_CreateInfo()

	info.func = ChooseRealmDropdown_OnClick

	for i, entryData in ipairs(AccountLoginChooseRealmDropDown.realmStorage) do
		info.text = entryData.name
		info.value = entryData.ip
		info.checked = nil
		GlueDark_DropDownMenu_AddButton(info)
	end
end

function AccountLoginChooseRealmDropDownMixin:Update()
	self.realmStorage = C_ConnectManager:GetAllRealmList()

	self:SetShown(#self.realmStorage > 0)
	GlueDark_DropDownMenu_Initialize(self, ChooseRealmDropdownInit)

	local currentRealmList = GetCVar("realmList")

	if StringStartsWith(currentRealmList, "192.168.") or StringStartsWith(currentRealmList, "127.0.") then
		return
	end

	local entryPoint = C_GlueCVars.GetCVar("ENTRY_POINT")
	if entryPoint ~= "" then
		for _, entryData in ipairs(self.realmStorage) do
			if entryData.ip == entryPoint then
				currentRealmList = entryPoint
				break
			end
		end
	end

	local selectedValue = self.realmStorage[1] and self.realmStorage[1].ip or nil
	for _, entryData in ipairs(self.realmStorage) do
		if entryData.ip == currentRealmList then
			selectedValue = entryData.ip
			break
		end
	end

	GlueDark_DropDownMenu_SetSelectedValue(self, selectedValue)
	SetCVar("realmList", selectedValue)

	GlueDark_DropDownMenu_SetWidth(self, 185, true)
	GlueDark_DropDownMenu_JustifyText(self, "CENTER")
end