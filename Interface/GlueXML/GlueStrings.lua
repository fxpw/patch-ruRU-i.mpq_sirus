local GLUE_STRINGS = {
	["SCANDLL_MESSAGE_HACK"] = {
		ruRU = "<html><body><p>В вашей системе обнаружена программа \"%1$s\". Ее запуск может привести к к нежелательным последствиям – вплоть до невозможности игры в World of Warcraft. Крайне рекомендуется устранить эту проблему до начала игры.</p><p>Подробнее см. <a href='%2$s'>здесь</a></p></body></html>",
		enGB = "<html><body><p>\"%1$s\" has been detected on your computer. Running this program may compromise the security of your computer and jeopardize your ability to play World of Warcraft. It is highly advised that you correct this problem before playing the game.</p><p>For more information: <a href='%2$s'>Click Here</a></p></body></html>"
	},
	["AUTH_PARENTAL_CONTROL"] = {
		ruRU = "Доступ к данной учетной записи ограничен на правах родительского контроля. Изменить параметры доступа можно посредством меню управления учетными записями.",
		enGB = "Access to this account is currently restricted by parental controls. You can change your control settings from your online account management."
	},
	["UNKNOWN_ZONE"] = {
		ruRU = "Неизвестная зона",
		enGB = "Unknown Zone"
	},
	["LAUNCH_FAILED"] = {
		ruRU = "Ошибка запуска игры.",
		enGB = "Could not launch World of Warcraft."
	},
	["ABILITY_INFO_TAUREN3"] = {
		ruRU = "- Имеет способности к травничеству.",
		enGB = "- Herbalism skill increased."
	},
	["ABILITY_INFO_TROLL5"] = {
		ruRU = "- Уменьшенная продолжительность действия замедляющих эффектов.",
		enGB = "- Reduced duration of movement reducing effects."
	},
	["CLEAR"] = {
		ruRU = "Очистить",
		enGB = "Clear"
	},
	["DELETE_CHARACTER"] = {
		ruRU = "Удаление персонажа",
		enGB = "Delete Character"
	},
	["LOGINBUTTON_ACCOUNTMANAGER"] = {
		ruRU = "Личный кабинет",
		enGB = "My Account"
	},
	["SAVE_ACCOUNT_NAME"] = {
		ruRU = "Запомнить учетную запись",
		enGB = "Remember Account Name"
	},
	["LOGINBUTTON_OPTIONS"] = {
		ruRU = "Опции",
		enGB = "Options"
	},
	["AUTH_NO_TIME_URL"] = {
		ruRU = "https://www.wow-europe.com/account/",
		enGB = "http://www.worldofwarcraft.com/account"
	},
	["AUTH_SERVER_SHUTTING_DOWN"] = {
		ruRU = "Идет отключение сервера...",
		enGB = "Server Shutting Down"
	},
	["CONFIRM_TEMP"] = {
		ruRU = "Вы уверены, что закончили?",
		enGB = "Are you sure you are done?"
	},
	["SERVER_SPLIT_CURRENT_CHOICE"] = {
		ruRU = "Ваш выбор:\n%s",
		enGB = "Current Choice:\n%s"
	},
	["SCANDLL_MESSAGE_HACKFOUND_CONFIRM"] = {
		ruRU = "<html><body><p>Как уже сообщалось ранее, в вашей системе обнаружена программа \"%1$s\". Ее запуск может привести к к нежелательным последствиям – вплоть до невозможности игры в World of Warcraft. Крайне рекомендуется устранить эту проблему до начала игры.</p><p>Подробнее см. <a href='%2$s'>здесь</a></p></body></html>",
		enGB = "<html><body><p>As stated, \"%1$s\" has been detected on your computer. Running this program may compromise the security of your computer and jeopardize your ability to play World of Warcraft. It is highly advised that you correct this problem before playing the game.</p><p>For more information: <a href='%2$s'>Click Here</a></p></body></html>"
	},
	["CHANGED_OPTIONS_WARNING_TITLE"] = {
		ruRU = "ПРИМЕЧАНИЕ:",
		enGB = "NOTE:"
	},
	["MENU_EDIT_SELECT_ALL"] = {
		ruRU = "Выбрать все",
		enGB = "Select All"
	},
	["RESPONSE_DISCONNECTED"] = {
		ruRU = "Соединение с сервером разорвано",
		enGB = "Disconnected from server"
	},
	["BILLING_FIXED_LASTDAY"] = {
		ruRU = "До истечения срока действия вашего фиксированного тарифного плана осталось менее одного дня. Пожалуйста, зайдите в раздел оплаты, чтобы оплатить новый период.",
		enGB = "Your fixed plan account will expire in less than a day. Please go to the billing pages and purchase another plan."
	},
	["LOGIN_NOTIME"] = {
		ruRU = "<html><body><p align=\"CENTER\">Оплаченное игровое время для этой учетной записи подошло к концу. Вы можете оплатить дополнительное время на странице <a href=\"https://www.wow-europe.com/account\">https://www.wow-europe.com/account</a>.</p></body></html>",
		enGB = "<html><body><p align=\"CENTER\">You have used up your prepaid time for this account. Please visit <a href=\"http://www.worldofwarcraft.com/account\">www.worldofwarcraft.com/account</a> to purchase more to continue playing.</p></body></html>"
	},
	["REALM_LIST_INVALID"] = {
		ruRU = "Неверный список миров",
		enGB = "Invalid realm list"
	},
	["CHARACTER_SELECT_FIX_CHARACTER_LABEL"] = {
		ruRU = "Исправить",
		enGB = "Fix"
	},
	["SCANDLL_URL_TROJAN"] = {
		ruRU = "http://eu.blizzard.com/support/article.xml?articleId=28365",
		enGB = "http://us.blizzard.com/support/article.xml?articleId=21370"
	},
	["LOGIN_STATE_DOWNLOADFILE"] = {
		ruRU = "Загрузка",
		enGB = "Downloading"
	},
	["REALM_TYPE_LOCALE_WARNING"] = {
		ruRU = "Вы пытаетесь выбрать игровой мир с неподходящим языком.",
		enGB = "You are trying to play on a realm with a different language."
	},
	["DISCONNECTED"] = {
		ruRU = "Соединение с сервером разорвано.",
		enGB = "You have been disconnected from the server."
	},
	["CONFIRM_CHAR_DELETE"] = {
		ruRU = "Удаление персонажа",
		enGB = "Deleting a character"
	},
	["CONFIRM_CHAR_DELETE2"] = {
		ruRU = "|cffffffff%1$s, %3$s %2$d-го уровня|r",
		enGB = "|cffffffff%s   Level %d   %s|r"
	},
	["BILLING_HAS_FALLBACK_PAYMENT"] = {
		ruRU = "Для вашей учетной записи может быть доступно дополнительное время за счет других тарифных планов.",
		enGB = "There may be additional time on your account from other payment plans."
	},
	["FORCE_CHANGE_FACTION_EVENT_COMMON"] = {
		ruRU = "Изменяем конфигурацию Азерота",
		enGB = ""
	},
	["CHAR_NAME_FAILURE"] = {
		ruRU = "Недопустимое имя персонажа",
		enGB = "Invalid character name"
	},
	["SPD"] = {
		ruRU = "СКР %d",
		enGB = "SPD %d"
	},
	["SERVER_ALERT_URL"] = {
		ruRU = "http://80.211.250.155/",
		enGB = "http://80.211.250.155/"
	},
	["CHARACTER_SERVICES_COST"] = {
		ruRU = "%d |4бонус:бонуса:бонусов;",
		enGB = "%d |4bonus:bonuses;"
	},
	["CHARACTER_UNDELETE_ALERT_2"] = {
		ruRU = "Персонаж успешно восстановлен.",
		enGB = "The character has been successfully restored."
	},
	["LOGINBOX_REMEMBEME"] = {
		ruRU = "Запомнить данные",
		enGB = "Remember data"
	},
	["LOGIN_ACCOUNT_CONVERTED"] = {
		ruRU = "Данная учетная запись теперь закреплена за учетной записью Battle.net. Пожалуйста, войдите с помощью адреса электронной почты и пароля, используемых для учетной записи Battle.net (например john.doe@blizzard.com).",
		enGB = "This account is now attached to a Battle.net account. Please log in with your Battle.net account email address (example: john.doe@blizzard.com) and password."
	},
	["MELEE_CRIT"] = {
		ruRU = "КРИТ %.2f",
		enGB = "CRIT %.2f"
	},
	["BONUS_DAMAGE"] = {
		ruRU = "Д.УРН %d",
		enGB = "B.DMG %d"
	},
	["LOAD_FULL"] = {
		ruRU = "Нет мест",
		enGB = "Full"
	},
	["AUTH_WAIT_QUEUE"] = {
		ruRU = "Место в очереди: %d",
		enGB = "Position in Queue: %d"
	},
	["CLIENT_ACCOUNT_MISMATCH_BC"] = {
		ruRU = "<html><body><p>Тип вашей учетной записи позволяет вам играть в Burning Crusade, однако на вашем компьютере не установлен соответствующий программный пакет. Загрузить его можно здесь: <a href='http://eu.blizzard.com/support/article/burningcrusade-download'>http://eu.blizzard.com/support/article/burningcrusade-download</a></p></body></html>",
		enGB = "<html><body><p>Your account is authorized for the Burning Crusade expansion, but the computer you are playing on does not contain Burning Crusade data. To play on this machine with this account, you must install the Burning Crusade. Additional data is available at:<a href='http://www.worldofwarcraft.com/burningcrusade/download/'>www.worldofwarcraft.com/burningcrusade/download/</a></p></body></html>"
	},
	["SERVER_SPLIT_CHOOSE_BY"] = {
		ruRU = "Выбрать:",
		enGB = "Choose by:"
	},
	["GAMETYPE_RP"] = {
		ruRU = "Ролевая игра |cff00ff00(RP)|r",
		enGB = "Roleplaying |cff00ff00(RP)|r"
	},
	["GAMETYPE_RP_TEXT"] = {
		ruRU = "В мирах данного типа действует жесткий свод правил, призванный обеспечить игрокам возможность отыграть выбранную роль.",
		enGB = "These realms have strict naming conventions and behavior rules for players interested in immersing themselves as a character in a fantasy-based world."
	},
	["CONTEST_NOTICE"] = {
		ruRU = "Некоторые пункты Правил были изменены. Просмотрите весь текст Соглашения прежде, чем принимать его условия.",
		enGB = "The contest rules have changed. Please scroll down and review the changes before accepting the agreement."
	},
	["VIRTUAL_KEYPAD_OKAY"] = {
		ruRU = "OK",
		enGB = "Okay"
	},
	["FORUM"] = {
		ruRU = "Форум",
		enGB = "Forum"
	},
	["RESPONSE_FAILURE"] = {
		ruRU = "Ошибка",
		enGB = "Failure"
	},
	["QUEUE_NAME_TIME_LEFT_UNKNOWN"] = {
		ruRU = "Свободных мест нет: %s\nМесто в очереди: %d\nВремя ожидания: идет расчет...",
		enGB = "%s is Full\nPosition in queue: %d\nEstimated time: Calculating..."
	},
	["CHAR_NAME_RUSSIAN_SILENT_CHARACTER_AT_BEGINNING_OR_END"] = {
		ruRU = "Имя не должно начинаться с непроизносимого знака или заканчиваться им.",
		enGB = "Silent characters are now allowed at the beginning or end of a name."
	},
	["ABILITY_INFO_DWARF5"] = {
		ruRU = "- Мастерски владеет ударным оружием.",
		enGB = "- Increased expertise with Maces."
	},
	["ABILITY_INFO_GNOME2"] = {
		ruRU = "- Повышенная характеристика «интеллект».",
		enGB = "- Increased Intelligence."
	},
	["SERVER_SPLIT_SERVER_ONE"] = {
		ruRU = "Мир 1",
		enGB = "Realm 1"
	},
	["CHARACTER_SERVICES_BOOST_FREE"] = {
		ruRU = "Доступен БЕСПЛАТНО",
		enGB = "Available FOR FREE"
	},
	["ABILITY_INFO_BLOODELF3"] = {
		ruRU = "- Умеет лишать противников дара речи.",
		enGB = "- May silence nearby opponents."
	},
	["AUTH_DB_BUSY"] = {
		ruRU = "Сеанс завершен. Повторите попытку позднее или проверьте статус игровых серверов на странице www.wow-europe.com/ru/serverstatus.",
		enGB = "This session has timed out. Please try again at a later time or check the status of our WoW servers at www.worldofwarcraft.com/serverstatus"
	},
	["LOGIN_PARENTALCONTROL"] = {
		ruRU = "Доступ к данной учетной записи ограничен на правах родительского контроля. Изменить параметры доступа можно посредством меню управления учетными записями.",
		enGB = "Access to this account is currently restricted by parental controls. You can change your control settings from your online account management."
	},
	["ENTER_EMAIL"] = {
		ruRU = "Адрес электронной почты",
		enGB = "Enter your email address"
	},
	["CHAR_CUSTOMIZE_FAILED"] = {
		ruRU = "Невозможно изменить персонажа.",
		enGB = "Could not customize character."
	},
	["CHAR_LIST_RETRIEVED"] = {
		ruRU = "Список персонажей получен",
		enGB = "Character list retrieved"
	},
	["CONFIRM_LOAD_ADDONS"] = {
		ruRU = "Для корректной работы игры необходимо обновить все модификации. Вы действительно хотите загрузить их без обновления?\n\n|cffffffffПодключение можно осуществить, нажав кнопку «Модификации» в левой нижней части экрана.|r",
		enGB = "The game may not work correctly unless you have updated all your modifications.  Are you sure you want to try to load them?\n\n|cffffffffChanges can be made by using the \"Addons\" button in the lower left.|r"
	},
	["LATEST_TERMINATION_WITHOUT_NOTICE_URL"] = {
		ruRU = "http://launcher.wow-europe.com/ru/legal/termination.htm",
		enGB = "http://launcher.worldofwarcraft.com/legal/notice.htm"
	},
	["RELEASE_BUILD"] = {
		ruRU = "Релиз",
		enGB = "Release"
	},
	["ENABLED_FOR_SOME"] = {
		ruRU = "Данная модификация включена только для некоторых персонажей.",
		enGB = "This addon is only enabled for some characters."
	},
	["CHAR_LIST_FAILED"] = {
		ruRU = "Ошибка загрузки списка персонажей",
		enGB = "Error retrieving character list"
	},
	["AMMO"] = {
		ruRU = "ЗРД %d",
		enGB = "AMMO %d"
	},
	["CHAR_NAME_NO_NAME"] = {
		ruRU = "Введите имя персонажа",
		enGB = "Enter a name for your character"
	},
	["LAUNCH_QUICKTIME_REQUIRED"] = {
		ruRU = "Для запуска игры требуется наличие программы QuickTime версии %s.",
		enGB = "World of Warcraft requires QuickTime version %s."
	},
	["BILLING_TIME_LEFT_DAYS"] = {
		ruRU = "Осталось оплаченных дней: %d",
		enGB = "You have %d days of play time remaining."
	},
	["CANCEL_RESET_SETTINGS"] = {
		ruRU = "Вы уверены, что хотите отменить переход к пользовательским настройкам по умолчанию при следующем входе в игру?",
		enGB = "Are you sure you want to cancel resetting user options the next time you login?"
	},
	["CHARACTER_BOOST_CHARACTER_LABEL"] = {
		ruRU = "Персонаж:",
		enGB = "Character:"
	},
	["WEAPONS"] = {
		ruRU = "Оружие",
		enGB = "Weapons"
	},
	["DELETE_CONFIRM_STRING"] = {
		ruRU = "УДАЛИТЬ",
		enGB = "DELETE"
	},
	["CLEARMATRIX"] = {
		ruRU = "Очистить",
		enGB = "Clear"
	},
	["CHAR_CREATE_FAILED"] = {
		ruRU = "Не удалось создать персонажа",
		enGB = "Character creation failed"
	},
	["ABILITY_INFO_HUMAN1"] = {
		ruRU = "- Способен быстрее замечать спрятавшихся противников.",
		enGB = "- Stealth detection increased."
	},
	["COMMUNITY_SITE"] = {
		ruRU = "Официальный сайт",
		enGB = "Community Site"
	},
	["CHAR_NAME_RUSSIAN_CONSECUTIVE_SILENT_CHARACTERS"] = {
		ruRU = "Использование двух непроизносимых букв подряд не допускается.",
		enGB = "Can not have two silent symbols in a row."
	},
	["CHAR_NAME_TOO_SHORT"] = {
		ruRU = "Имя должно содержать не менее 2 символов",
		enGB = "Names must be at least 2 characters"
	},
	["CHAR_RENAME_IN_PROGRESS"] = {
		ruRU = "Переименование персонажа...",
		enGB = "Renaming Character..."
	},
	["RACE_INFO_TROLL"] = {
		ruRU = "Тролли Черного Копья некогда считали своим домом Тернистую долину, но были вытеснены оттуда враждующими племенами. Это окончательно сплотило между собой орочью Орду и троллей. Тралл, молодой вождь орков, убедил троллей примкнуть к его походу на Калимдор. Хотя тролли и не смогли окончательно отказаться от своего мрачного наследия, в Орде их уважают и почитают.",
		enGB = "Once at home in the jungles of Stranglethorn Vale, the fierce trolls of the Darkspear tribe were pushed out by warring factions. Eventually the trolls befriended the orcish Horde, and Thrall, the orcs' young warchief, convinced the trolls to travel with him to Kalimdor. Though they cling to their shadowy heritage, the Darkspear trolls hold a place of honor in the Horde."
	},
	["LOGIN_NO_BATTLENET_APPLICATION"] = {
		ruRU = "<html><body><p align=\"CENTER\">Произошла ошибка входа в систему. Пожалуйста, повторите попытку позже. Если проблема остается, свяжитесь с технической поддержкой.</p></body></html>",
		enGB = "<html><body><p align=\"CENTER\">There was an error logging in. Please try again later. If the problem persists, please contact Technical Support at: <a href=\"http://us.blizzard.com/support/article.xml?locale=en_US&amp;articleId=21014\">http://us.blizzard.com/support/article.xml?locale=en_US&amp;articleId=21014</a></p></body></html>"
	},
	["FACTION_INFO_HORDE"] = {
		ruRU = "		   В состав Орды входят пять рас: воинственные орки, мрачная нежить, одухотворенные таурены, хитроумные тролли и целеустремленные эльфы крови. Эти изгнанники, против которых ополчился весь мир, решили объединить усилия, чтобы выжить – просто выжить.",
		enGB = "		Five races comprise the Horde: the brutal orcs, the shadowy undead, the spiritual tauren, the quick-witted trolls, and the driven blood elves. Beset by enemies on all sides, these outcasts have forged a union they hope will ensure their mutual survival."
	},
	["ENVIRONMENT_LABEL"] = {
		ruRU = "Окружающая среда",
		enGB = "Environment"
	},
	["ABILITY_INFO_ORC4"] = {
		ruRU = "- Мастерски владеет топорами и кистевым оружием.",
		enGB = "- Increased expertise with Axes and Fist weapons."
	},
	["LOGIN_UNKNOWN_ACCOUNT_PIN"] = {
		ruRU = "<html><body><p align=\"CENTER\">Вы ввели неверную информацию. Пожалуйста, проверьте правильность написания имени учетной записи, пароля и пин-кода. Для восстановления забытых или украденных пароля, учетной записи или пин-кода посетите страницу <a href=\"https://www.wow-europe.com/login-support/?locale=ru_RU\">https://www.wow-europe.com/login-support/?locale=ru_RU</a>.</p></body></html>",
		enGB = "<html><body><p align=\"CENTER\">The information you have entered is not valid.  Please check the spelling of the account name, password, and PIN.  If you need help in retrieving a lost or stolen password, account, or PIN see <a href=\"http://www.worldofwarcraft.com/loginsupport\">www.worldofwarcraft.com/loginsupport</a> for more information.</p></body></html>"
	},
	["LOGIN_AUTH_OUTAGE"] = {
		ruRU = "<html><body><p align=\"CENTER\">Сервер авторизации в настоящее время занят. Пожалуйста, попробуйте подключиться позднее. Если вы постоянно получаете это сообщение, то свяжитесь со службой технической поддержки.</p></body></html>",
		enGB = "<html><body><p align=\"CENTER\">The login server is currently busy. Please try again later. If the problem persists, please contact Technical Support at.</p></body></html>"
	},
	["SERVER_SPLIT_PENDING"] = {
		ruRU = "Идет разделение миров...",
		enGB = "Realm Split Pending..."
	},
	["CHAR_DELETE_SUCCESS"] = {
		ruRU = "Персонаж удален",
		enGB = "Character deleted"
	},
	["ENTER_PIN_NUMBER"] = {
		ruRU = "Введите пин-код",
		enGB = "Enter Your PIN"
	},
	["PROMOTION"] = {
		ruRU = "Акция",
		enGB = "Special offer"
	},
	["ACCOUNT_CREATE_IN_PROGRESS"] = {
		ruRU = "Создание учетной записи",
		enGB = "Creating account"
	},
	["CHAR_LOGIN_FAILED"] = {
		ruRU = "Ошибка входа",
		enGB = "Login failed"
	},
	["LOGIN_ENTER_NAME"] = {
		ruRU = "Введите логин.",
		enGB = "Please enter your account name."
	},
	["CHAR_CREATE_NAME_IN_USE"] = {
		ruRU = "Имя недоступно",
		enGB = "That name is unavailable"
	},
	["SCANDLL_MESSAGE_TROJAN"] = {
		ruRU = "<html><body><p>В вашей системе обнаружена программа \"%1$s\". Ее запуск может привести к к нежелательным последствиям – вплоть до невозможности игры в World of Warcraft. Крайне рекомендуется устранить эту проблему до начала игры.</p><p>Подробнее см. <a href='%2$s'>здесь</a></p></body></html>",
		enGB = "<html><body><p>\"%1$s\" has been detected on your computer. Running this program may compromise the security of your computer and jeopardize your ability to play World of Warcraft. It is highly advised that you correct this problem before playing the game.</p><p>For more information: <a href='%2$s'>Click Here</a></p></body></html>"
	},
	["BILLING_TEXT1"] = {
		ruRU = "Вы используете подписку для оплаты игрового времени. Когда оно сократится до одного дня, вам будет отправлено уведомление.",
		enGB = "You are using a subscription to play this account.  You will be notified when you have one day or less on your account."
	},
	["REALM_HELP_FRAME_TEXT"] = {
		ruRU = "Ваша учетная запись пока не может участвовать в игре в турнирных мирах. За дополнительной информацией о Турнире арены World of Warcraft обращайтесь по адресу: %s.",
		enGB = "This account is currently not flagged to participate in the tournament realms. For more information regarding the World of Warcraft Arena Tournament, please visit: %s."
	},
	["SERVER_ALERT_BETA_URL"] = {
		ruRU = "http://beta.wow-europe.com/ru/alert",
		enGB = "http://beta.worldofwarcraft.com/alert"
	},
	["SELECT_CHARACTER"] = {
		ruRU = "Выбор персонажа",
		enGB = "Select A Character"
	},
	["CHAR_DELETE_FAILED_GUILD_LEADER"] = {
		ruRU = "Этот персонаж является главой гильдии. Прежде чем удалять его, необходимо передать звание главы другому персонажу.",
		enGB = "This character is a Guild Master and cannot be deleted until the rank is transfered to another character."
	},
	["ROLE_DAMAGER"] = {
		ruRU = "Боец",
		enGB = "Damager"
	},
	["CHOOSE_SPECIALIZATION_TYPE"] = {
		ruRU = "Выберите тип специализации",
		enGB = "Choose Your PVE Specialization"
	},
	["CHOOSE_SPECIALIZATION"] = {
		ruRU = "Выберите PVE специализацию",
		enGB = "Choose Your PVE Specialization"
	},
	["CHOOSE_PVP_SPECIALIZATION"] = {
		ruRU = "Выберите PVP специализацию",
		enGB = "Choose Your PVP Specialization"
	},
	["BOOST_SPEC_ITEMS_PVE"] = {
		ruRU = "PVE специализация",
		enGB = "PVE Specialization"
	},
	["BOOST_SPEC_ITEMS_PVP"] = {
		ruRU = "PVP специализация",
		enGB = "PVP Specialization"
	},
	["BOOST_SPEC_ITEMS_LOADING"] = {
		ruRU = "Загрузка предметов",
		enGB = "Loading items..."
	},
	["BOOST_SPEC_ITEMS_CLICK_TIP"] = {
		ruRU = "Кликните чтобы посмотреть подробное описание предмета в нашей базе знаний",
	},
	["SCANDLL_URL_LAUNCHER_TXT"] = {
		ruRU = "",
		enGB = ""
	},
	["LOGIN_MALFORMED_ACCOUNT_NAME"] = {
		ruRU = "<html><body><p align=\"CENTER\">Вы ввели неверную информацию. Пожалуйста, проверьте правильность написания имени учетной записи и пароля к ней. Если вам нужна помощь по восстановлению забытого или украденного пароля или учетной записи, посетите страницу <a href=\"https://www.wow-europe.com/login-support/?locale=ru_RU\">https://www.wow-europe.com/login-support/?locale=ru_RU</a>.</p></body></html>",
		enGB = "<html><body><p align=\"CENTER\">The information you have entered is not valid.  Please check the spelling of the account name and password.  If you need help in retrieving a lost or stolen password and account, see <a href=\"http://www.worldofwarcraft.com/loginsupport\">www.worldofwarcraft.com/loginsupport</a> for more information.</p></body></html>"
	},
	["CHARACTER_SERVICES_BOOST_COST_FREE"] = {
		ruRU = "Бесплатно",
		enGB = "Free"
	},
	["DELETED_CHARACTERS"] = {
		ruRU = "Удаленные персонажи",
		enGB = "Deleted Characters"
	},
	["SERVER_SPLIT"] = {
		ruRU = "Данный игровой мир полностью загружен – он будет разделен на два разных игровых мира. Вы можете выбрать, в каком из миров продолжите играть – сделать это необходимо до |cffffffff%s|r. В противном случае вашего персонажа переместят в автоматическом порядке. Подробнее см.: www.wow-europe.com.\n\nУкажите предпочитаемый вами игровой мир. Вы можете изменить решение до времени разделения.",
		enGB = "This realm has exceeded maximum capacity, and will be undergoing a realm split with players divided between two new realms. You will be able to select which of the two new realms you prefer up until |cffffffff%s|r when the split lockout occurs. If you do not make a selection, you will be assigned to one of the new realms. For more information, visit www.worldofwarcraft.com.\n\nPlease select your new realm preference below. You may change your selection at any time until the lockout date."
	},
	["BF_RANK"] = {
		ruRU = "Звание",
		enGB = "Rank"
	},
	["SCANDLL_BUTTON_CONTINUEANYWAY"] = {
		ruRU = "Продолжить",
		enGB = "Continue Anyway"
	},
	["TEMP_SKILLS"] = {
		ruRU = "- Боевой клич\n- Первая помощь\n- Командный голос",
		enGB = "- Battle Cries\n- First Aid\n- War Shouts"
	},
	["CHOOSE_LOCATION_DESCRIPTION"] = {
		ruRU = "(рекомендуется выбрать ближайший к вам регион)",
		enGB = "(for best results choose the region closest to you)"
	},
	["CHARACTER_SERVICES_BOOST"] = {
		ruRU = "Быстрый старт",
		enGB = "Character Boost"
	},
	["REALM_INFO_TEMPLATE"] = {
		ruRU = "%-32.32s %4d",
		enGB = "%-32.32s %4d"
	},
	["CHAR_FACTION_CHANGE_STILL_IN_GUILD"] = {
		ruRU = "Нельзя сменить расу или фракцию, пока вы состоите в гильдии.",
		enGB = "You may not change race or faction while still a member of a guild."
	},
	["CALCULATING"] = {
		ruRU = "Расчет...",
		enGB = "Calculating..."
	},
	["LOGINBUTTON_QUITGAME"] = {
		ruRU = "Выход из игры",
		enGB = "Exit Game"
	},
	["LOAD_HIGH"] = {
		ruRU = "Высокая",
		enGB = "High"
	},
	["DPS"] = {
		ruRU = "У/С",
		enGB = "DPS"
	},
	["AUTHENTICATOR"] = {
		ruRU = "Код брелка",
		enGB = "Authenticator"
	},
	["ACCOUNT_CREATE_FAILED"] = {
		ruRU = "Ошибка создания учетной записи",
		enGB = "Account creation failed"
	},
	["RACE_INFO_TAUREN"] = {
		ruRU = "Таурены всегда стремились сохранять равновесие природы, следуя завету своей богини, Матери-Земли. Не так давно они подверглись набегу злобных кентавров, и если бы не счастливый случай – встреча с орками, которые помогли отразить нападение, – могли бы и вовсе погибнуть. Чтобы вернуть долг крови, таурены присоединились к Орде вслед за своими соратниками.",
		enGB = "Always the tauren strive to preserve the balance of nature and heed the will of their goddess, the Earth Mother. Recently attacked by murderous centaur, the tauren would have been wiped out, save for a chance encounter with the orcs, who helped defeat the interlopers. To honor this blood-debt, the tauren joined the Horde, solidifying the two races' friendship."
	},
	["RESET_SETTINGS"] = {
		ruRU = "Сброс настроек",
		enGB = "Reset User Options"
	},
	["ACCOUNT_CREATE_SUCCESS"] = {
		ruRU = "Учетная запись создана",
		enGB = "Account created"
	},
	["LOGIN_CONVERSION_REQUIRED"] = {
		ruRU = "<html><body><p align=\"CENTER\">Введите имя и пароль учетной записи Battle.net. Для создания учетной записи <a href=\"https://eu.battle.net/account/creation/landing.xml\">щелкните здесь</a> или перейдите на страницу|n<a href=\"https://eu.battle.net/account/creation/landing.xml\">https://eu.battle.net/account/creation/landing.xml</a>,|n чтобы начать конвертацию.</p></body></html>",
		enGB = "<html><body><p align=\"CENTER\">You must log in with a Battle.net account username and password. To create an account please <a href=\"https://us.battle.net/account/creation/landing.xml\">Click Here</a>or go to:|n<a href=\"https://us.battle.net/account/creation/landing.xml\">https://us.battle.net/account/creation/landing.xml</a>|nto begin the conversion.</p></body></html>"
	},
	["SKILLLINES"] = {
		ruRU = "Навыки",
		enGB = "Skill Lines"
	},
	["CREATE_NEW_CHARACTER"] = {
		ruRU = "Новый персонаж",
		enGB = "Create New Character"
	},
	["STR"] = {
		ruRU = "СИЛ",
		enGB = "STR"
	},
	["SCANDLL_MESSAGE_TROJANFOUND_CONFIRM"] = {
		ruRU = "<html><body><p>Как уже сообщалось ранее, в вашей системе обнаружена программа \"%1$s\". Ее запуск может привести к к нежелательным последствиям – вплоть до невозможности игры в World of Warcraft. Крайне рекомендуется устранить эту проблему до начала игры.</p><p>Подробнее см. <a href='%2$s'>здесь</a></p></body></html>",
		enGB = "<html><body><p>As stated, \"%1$s\" has been detected on your computer. Running this program may compromise the security of your computer and jeopardize your ability to play World of Warcraft. It is highly advised that you correct this problem before playing the game.</p><p>For more information: <a href='%2$s'>Click Here</a></p></body></html>"
	},
	["CHAR_NAME_INVALID_SPACE"] = {
		ruRU = "Нельзя ставить пробел в качестве первого или последнего символа в имени персонажа.",
		enGB = "You cannot use a space as the first or last character of your name"
	},
	["CHAR_CREATE_SERVER_QUEUE"] = {
		ruRU = "Указанный вами сервер переполнен, функция создания персонажей временно отключена. Повторите попытку позднее.",
		enGB = "This server is currently queued and new character creation is temporarily disabled. Please try again during off peak hours."
	},
	["CLIENT_ACCOUNT_MISMATCH_LK"] = {
		ruRU = "<html><body><p>Тип вашей учетной записи позволяет вам играть в Wrath of the Lich King, однако на вашем компьютере не установлен соответствующий программный пакет. Загрузить его можно здесь: <a href=\"http://eu.blizzard.com/support/article/lichking-download\">http://eu.blizzard.com/support/article/lichking-download</a></p></body></html>",
		enGB = "<html><body><p>Your account is authorized for the Wrath of the Lich King expansion, but the computer you are playing on does not contain Wrath of the Lich King data. To play on this machine with this account, you must install the Wrath of the Lich King. Additional data is available at:<a href=\"http://www.worldofwarcraft.com/lichking/download/\">www.worldofwarcraft.com/lichking/download/</a></p></body></html>"
	},
	["BATTLEFIELD_ALERT"] = {
		ruRU = "%s: доступ открыт. Вас исключат из очереди в мир %s",
		enGB = "You are eligible to enter %s You will be removed from the queue in %s"
	},
	["WAIT_SERVER_RESPONCE"] = {
		ruRU = "Ожидание ответа от сервера...",
		enGB = "Waiting for a response from the server..."
	},
	["PENETRATION"] = {
		ruRU = "ПРОНИК %d",
		enGB = "PENET %d"
	},
	["UPGRADE_ACCOUNT"] = {
		ruRU = "Обновить до полной версии",
		enGB = "Upgrade to Full Version"
	},
	["CHOOSE_LOCATION"] = {
		ruRU = "Выберите местонахождение:",
		enGB = "Choose your preferred location:"
	},
	["MENU_EDIT_PASTE"] = {
		ruRU = "Вставить",
		enGB = "Paste"
	},
	["PVP_PARENTHESES"] = {
		ruRU = "(PvP)",
		enGB = "(PVP)"
	},
	["TIME_REMANING"] = {
		ruRU = "Осталось: %s",
		enGB = "%s left"
	},
	["GAMETYPE_NORMAL"] = {
		ruRU = "PvE",
		enGB = "Normal"
	},
	["AUTH_BAD_SERVER_PROOF"] = {
		ruRU = "Недопустимый сервер",
		enGB = "Server is not valid"
	},
	["RESTART"] = {
		ruRU = "Перезапуск",
		enGB = "Restart"
	},
	["WRATH_OF_THE_LICH_KING"] = {
		ruRU = "Wrath of the Lich King",
		enGB = "Wrath of the Lich King"
	},
	["ABILITY_INFO_HUMAN3"] = {
		ruRU = "- Ускоренное получение репутации.",
		enGB = "- Bonus to reputation gains."
	},
	["DRAENEI_DISABLED"] = {
		ruRU = "Дреней\nТребуется дополнение The Burning Crusade",
		enGB = "Draenei\nRequires The Burning Crusade"
	},
	["CHAR_FACTION_CHANGE_ARENA_LEADER"] = {
		ruRU = "Вы не можете сменить расу или фракцию, оставаясь капитаном команды арены.",
		enGB = "You may not change race or faction while still the captain of an arena team."
	},
	["CHAR_CREATE_EXPANSION"] = {
		ruRU = "Создание персонажа этой расы требует наличия соответствующего дополнения к игре.",
		enGB = "Creation of that race requires an account that has been upgraded to the appropriate expansion."
	},
	["LOGIN_INVALID_PROOF_MESSAGE"] = {
		ruRU = "Неверное подтверждающее сообщение",
		enGB = "Invalid Proof Message"
	},
	["CREDITS_WOW_CLASSIC"] = {
		ruRU = "Создатели World of Warcraft",
		enGB = "World of Warcraft Credits"
	},
	["CHARACTER_DELETE_RESTORE_ERROR_1"] = {
		ruRU = "Неверные параметры.",
		enGB = "Incorrect parameters."
	},
	["AUTH_BILLING_ERROR"] = {
		ruRU = "Ошибка платежной системы",
		enGB = "Billing system error"
	},
	["ADDON_INVALID_VERSION_LABEL"] = {
		ruRU = "Модификация устарела.",
		enGB = "This addon is out of date."
	},
	["SECURITYMATRIX_DIRECTIONS"] = {
		ruRU = "Для продолжения входа введите данные своей карты Matrix Card.",
		enGB = "In order to complete logging into World of Warcraft you must enter values from your matrix card."
	},
	["SELECT_RACE"] = {
		ruRU = "Выберите расу",
		enGB = "Select your race"
	},
	["BILLING_FREE_TIME_EXPIRE"] = {
		ruRU = "Срок действия бесплатной учетной записи подходит к концу. По его завершению вы будете отключены от игры.\nОставшееся время: %s.",
		enGB = "Free account is about to expire. Once expired, you will be disconnected.\nThe remaining time is %s."
	},
	["GM_BUILD"] = {
		ruRU = "Гейм-мастер",
		enGB = "GM"
	},
	["LOGIN_BAD_SERVER_RECODE_PROOF"] = {
		ruRU = "Ошибка подтверждения перекодировки",
		enGB = "Recode Proof Bad"
	},
	["PRIEST_DISABLED"] = {
		ruRU = "Жрец\nЭтот класс доступен другим расам.",
		enGB = "Priest\nYou must choose a different race to be this class."
	},
	["ALPHA_BUILD"] = {
		ruRU = "Альфа-версия",
		enGB = "Alpha version"
	},
	["ENVIRONMENT_SUBTEXT"] = {
		ruRU = "С помощью этих настроек вы можете изменить детализацию и расстояние видимости объектов и эффектов окружающей среды.",
		enGB = "These options control the ranges and levels of detail used to draw effects and objects in the game environment."
	},
	["CONFIRM_RESTORE"] = {
		ruRU = "Подтверждение восстановления",
		enGB = "Confirm restoration"
	},
	["GAMETYPE_RPPVP_TEXT"] = {
		ruRU = "В игровых мирах данного типа действует жесткий свод правил, призванный обеспечить игрокам возможность отыграть выбранную роль. Однако, в отличие от обычных ролевых миров, акцент здесь смещен на бои между игроками. Помните: покинув исходную позицию или город, вы всегда рискуете подвергнуться нападению со стороны другого игрока.",
		enGB = "These realms have strict naming conventions and behavior rules for players interested in immersing themselves as a character in a fantasy-based world.  They also focus on player combat; you are always at risk of being attacked by opposing players except in starting areas and cities."
	},
	["SERVER_SPLIT_BUTTON"] = {
		ruRU = "Разделение",
		enGB = "Realm Split"
	},
	["CHAR_CREATE_PVP_TEAMS_VIOLATION"] = {
		ruRU = "Вы не можете создать персонажей Орды и Альянса на одном и том же PvP-сервере.",
		enGB = "You cannot have both a Horde and an Alliance character on the same PvP server"
	},
	["CSTATUS_NEGOTIATION_FAILED"] = {
		ruRU = "Ошибка проверки безопасности",
		enGB = "Security negotiation failed"
	},
	["ROLE_TANK"] = {
		ruRU = "Танк",
		enGB = "Tank"
	},
	["WHISPER_FROM"] = {
		ruRU = "%s шепчет",
		enGB = "Whisper from %s"
	},
	["POWER"] = {
		ruRU = "СА",
		enGB = "PWR"
	},
	["CONFIRM_PFC"] = {
		ruRU = "Вы уверены, что закончили процесс смены фракции?",
		enGB = "Are you sure you are done changing your character?"
	},
	["SPI"] = {
		ruRU = "ДУХ",
		enGB = "SPI"
	},
	["ABILITY_INFO_DRAENEI4"] = {
		ruRU = "- Повышенное сопротивление темной магии.",
		enGB = "- Resistant to Shadow damage."
	},
	["ABILITY_INFO_ORC3"] = {
		ruRU = "- Питомцы/прислужники наносят повышенный урон.",
		enGB = "- Damage done by pets increased."
	},
	["CHAR_CREATE_ONLY_EXISTING"] = {
		ruRU = "Создавать новых персонажей могут только те игроки, у которых уже имеются персонажи в данном мире.",
		enGB = "Only players who already have characters on this realm are currently allowed to create characters."
	},
	["WEB_SITE"] = {
		ruRU = "Официальный сайт",
		enGB = "WoW Website"
	},
	["REALM_TYPE"] = {
		ruRU = "Тип",
		enGB = "Type"
	},
	["ABILITY_INFO_GNOME3"] = {
		ruRU = "- Повышенное сопротивление тайной магии.",
		enGB = "- Resistant to Arcane damage."
	},
	["CREDITS_WOW_BC"] = {
		ruRU = "Создатели Burning Crusade",
		enGB = "Burning Crusade Credits"
	},
	["AUTH_SYSTEM_ERROR"] = {
		ruRU = "Системная ошибка",
		enGB = "System Error"
	},
	["WORLD_OF_WARCRAFT"] = {
		ruRU = "World of Warcraft",
		enGB = "World of Warcraft"
	},
	["CHARACTER_SERVICES_YOU_HAVE_BONUS"] = {
		ruRU = "У вас %d",
		enGB = "You have %d"
	},
	["CHARACTER_DELETE_RESTORE_ERROR_2"] = {
		ruRU = "Выполняется другая операция.",
		enGB = "Another operation is in progress."
	},
	["REALM_DESCRIPTION_TEXT"] = {
		ruRU = "Игровой мир представляет собой отдельную игровую область, существующую только для тех, кто находится в его пределах. Вы не можете общаться с игроками, находящимися в других мирах. Вы не можете перемещать персонажа между мирами. Игровые миры различаются как по географии, так и по правилам поведения.",
		enGB = "A realm is a discrete game world that exists only for the players within it. You can interact with all the players in your realm, but not with players in other realms. You cannot move your characters between realms. Realms are differentiated by location and play style."
	},
	["REALMLIST_TYPE_TOOLTIP"] = {
		ruRU = "PvE – обычный игровой мир.\nPvP – мир, в котором по умолчанию разрешены бои между игроками.\nRP – ролевой игровой мир.\nRPPvP – ролевой игровой мир, в котором по умолчанию разрешены бои между игроками.",
		enGB = "Normal = No special rules on this realm.\nPvP = Player versus Player.\nRP = Roleplaying realm.\nRPPvP = Roleplaying, Player versus Player realm."
	},
	["CHARACTER_SERVICES_BOOST_PURCHASE_LABEL"] = {
		ruRU = "Быстрый старт",
		enGB = "Character Boost"
	},
	["CHARACTER_SERVICES_BOOST_PURCHASE_DESCRIPTION"] = {
		ruRU = "Отличные новости! Наши гномские инженеры смогли изобрести машину времени и достать вас из будущего! Более того, мы можем это будущее отредактировать и научить вас всему чему вы хотите, прямо как в гоблиноматрице!\n\nВаш герой получит прекрасную экипировку, обучится паре профессий и мигом достигнет 80-го уровня!",
		enGB = "Great news! Our Gnomish engineers were able to invent a time machine and bring your future self back in time! We can now even edit this future and teach you anything you want, just like in the Goblin Matrix!\n\nYour hero will receive excellent equipment, learn a couple of professions, and instantly reach level 80!"
	},
	["CHARACTER_SERVICES_BOOST_PURCHASE_WARNING"] = {
		ruRU = "<html><body><p align=\"CENTER\">|cffd53838«Внимание! Есть ограничения!»|r</p><p align=\"CENTER\">|cffd53838Только для низкоуровневых персонажей.|r</p><p align=\"CENTER\"><a href=\"https://forum.sirus.su/threads/60986/\">Подробности</a></p></body></html>",
	},
	["CHARACTER_SERVICES_BOOST_REFUND_ACTION"] = {
		ruRU = "Вернуть",
	},
	["CHARACTER_SERVICES_BOOST_REFUND_AMOUNT"] = {
		ruRU = "Вы получите %d",
	},
	["CHARACTER_SERVICES_BOOST_REFUND_LABEL"] = {
		ruRU = "Возврат Быстрого Старта",
	},
	["CHARACTER_SERVICES_BOOST_REFUND_DESCRIPTION"] = {
		ruRU = "Неиспользованный Быстрый Старт можно вернуть, получив возмещение бонусов.\n\nПравила возврата:\n|TInterface/Scenarios/ScenarioIcon-Combat:16:16:0:-6:16:16:0:16:0:16|tЕсли Быстрый Старт был приобретен менее 1 часа назад, то размер выплаты составит 100%% от цены покупки в бонусах.\n|TInterface/Scenarios/ScenarioIcon-Combat:16:16:0:-6:16:16:0:16:0:16|tЕсли Быстрый Старт был приобретен более 1 часа и менее 14 дней назад, размер выплаты составит %d%% от цены покупки в бонусах.",
	},
	["CHARACTER_SERVICES_BOOST_REFUND_TIMELEFT_FULL"] = {
		ruRU = "Время для возврата |cff1aff1a100%|r стоимости:",
	},
	["CHARACTER_SERVICES_BOOST_REFUND_TIMELEFT_PENALTY"] = {
		ruRU = "Время для возврата |cffff1a1a%d%%|r стоимости:",
	},
	["CHARACTER_SERVICES_BOOST_REFUND_WARNING"] = {
		ruRU = "<html><body><p align=\"CENTER\">|cffd53838Возврат доступен в течение 14 дней с момента покупки.|r</p></body></html>",
	},
	["CHARACTER_SERVICES_LISTPAGE_TITLE"] = {
		ruRU = "Еще больше персонажей",
	},
	["CHARACTER_SERVICES_LISTPAGE_DESCRIPTION"] = {
		ruRU = "Внимание! Чтобы бесплатно разблокировать 2-ю страницу персонажей для создания новых героев вне лимита - необходимо иметь не менее 7 персонажей 80-го уровня.\n\nНо благодаря гномскому проворству и технологиям озаренных можно расширить не только пространство, время и сумки, но и место на вашем аккаунте, раз и навсегда. Вам станет доступно создание еще 10 новых персонажей, что позволит собрать свой небольшой отряд бойцов!",
	},
	["CHARACTER_SERVICES_LISTPAGE_DESCRIPTION_ALT"] = {
		ruRU = "Уже поговаривают, что вы собираете свою небольшую армию...\nА у нас хорошие новости! Умельцы Кезана неплохо потрудились, и у вас теперь есть возможность воспользоваться технологиями гоблинов для расширения места на своем аккаунте, чтобы создать еще больше персонажей!",
	},
	["CHARACTER_SERVICES_LISTPAGE_WARNING"] = {
		ruRU = "<html><body><p align=\"CENTER\">|cffd53838ВНИМАНИЕ! Обмену и возврату данная услуга не подлежит|r</p></body></html>",
	},
	["CHARACTER_SERVICES_RESTORE_CHARACTER_TITLE"] = {
		ruRU = "Восстановление персонажа",
		enGB = "Restore character"
	},
	["CHARACTER_SERVICES_RESTORE_CHARACTER_DESCRIPTION"] = {
		ruRU = "Все предметы и улучшения вашего персонажа сохранятся в том виде, в котором они были до удаления.\n\nПредметы, удаленные до удаления персонажа, не будут восстановлены с помощью данной опции.",
		enGB = "All of your character's items and enhancements be restored as they were before the deletion.\n\nItems deleted before the character was deleted will not be restored using this option."
	},
	["CHARACTER_SERVICES_CHARACTER_RESTORE_FREE"] = {
		ruRU = "<html><body><p align=\"CENTER\">|cffb9ff8bДоступно бесплатное восстановление!|r</p></body></html>",
		enGB = "<html><body><p align=\"CENTER\">|cffb9ff8bFree restoration available!|r</p></body></html>"
	},
	["CHARACTER_SERVICES_FREE_USE"] = {
		ruRU = "Получить",
		enGB = ""
	},
	["EMAIL_ADDRESS"] = {
		ruRU = "E-mail",
		enGB = "E-Mail Address"
	},
	["ABILITY_INFO_DWARF3"] = {
		ruRU = "- Повышенное сопротивление магии льда.",
		enGB = "- Resistant to Frost."
	},
	["OR"] = {
		ruRU = "или",
		enGB = "or"
	},
	["LOGIN_DBBUSY"] = {
		ruRU = "Ошибка входа в игру. Повторите попытку позже.",
		enGB = "Could not log in to World of Warcraft at this time.  Please try again later."
	},
	["CHAR_NAME_TOO_LONG"] = {
		ruRU = "Имя не может содержать больше 12 букв",
		enGB = "Names must be no more than 12 characters"
	},
	["BETA_BUILD"] = {
		ruRU = "Бета",
		enGB = "Beta"
	},
	["DEBUG_BUILD"] = {
		ruRU = "Отладка",
		enGB = "Debug"
	},
	["CHAR_CREATE_DISABLED"] = {
		ruRU = "В данный момент вы не можете создать здесь персонажа. Повторите попытку позднее или создайте персонажа в другом игровом мире.",
		enGB = "Character creation on this realm is currently disabled. Please try again at a later date or create a character on a different realm."
	},
	["CHARACTER_SERVICES_SPECIAL_OFFER"] = {
		ruRU = "Спец. Предложение",
		enGB = "Special offer"
	},
	["FORCE_CHANGE_FACTION_EVENT_VULPERA"] = {
		ruRU = "Смена фракции.. У вас мягкие лапки.",
		enGB = ""
	},
	["RP_PARENTHESES"] = {
		ruRU = "(RP)",
		enGB = "(RP)"
	},
	["TEMP_ARMOR"] = {
		ruRU = "- Тканевые доспехи\n- Кожаные доспехи\n- Кольчуга",
		enGB = "- Cloth\n- Leather\n- Mail"
	},
	["ABILITY_INFO_SCOURGE1"] = {
		ruRU = "- Умеет снимать эффекты страха, сна и подчинения.",
		enGB = "- Can remove fear, sleep, and charm."
	},
	["LOAD_RECOMMENDED"] = {
		ruRU = "Новые игроки",
		enGB = "New Players"
	},
	["CHAR_CREATE_LEVEL_REQUIREMENT"] = {
		ruRU = "Необходимо иметь персонажа как минимум 55-го уровня в этом игровом мире, чтобы создать рыцаря смерти.",
		enGB = "You must have an existing character of at least level 55 on this realm to create a Death Knight."
	},
	["SCAN_FRAME_TITLE"] = {
		ruRU = "Соглашение о сканировании",
		enGB = "Scanning Agreement"
	},
	["CHARACTER_NOT_FOUND"] = {
		ruRU = "Персонаж не выбран",
		enGB = "No character selected"
	},
	["CHARACTER_DELETE_RESTORE_ERROR_4"] = {
		ruRU = "Персонаж не найден.",
		enGB = "Character not found."
	},
	["SELECT_ACCOUNT"] = {
		ruRU = "Выберите учетную запись",
		enGB = "Select an account"
	},
	["REALM_TYPE_TOURNAMENT_WARNING"] = {
		ruRU = "Ваша учетная запись пока не может участвовать в игре в турнирных мирах.\n\nЗа дополнительной информацией о Турнире арены World of Warcraft обращайтесь по адресу: www.wow-europe.com.",
		enGB = "This account is currently not flagged to participate in the tournament realms.\n\nFor more information regarding the World of Warcraft Arena Tournament, please visit: www.worldofwarcraft.com."
	},
	["TEMP_WEAPON"] = {
		ruRU = "- Метательное оружие\n- Топоры\n- Двуручные топоры\n- Мечи\n- Двуручные мечи\n- Дробящее\n- Двуручное дробящее\n- Древковое\n- Луки",
		enGB = "- Throwing\n- Axes\n- 2 - Hand Axes\n- Swords\n- 2 - Hand Swords\n- Maces\n- 2 - Hand Maces\n- Polearms\n- Bows"
	},
	["SCANDLL_MESSAGE_DOWNLOADING"] = {
		ruRU = "Загрузка программы Blizzard Scan",
		enGB = "[TEMPORARY] Downloading Blizzard Scan"
	},
	["DEFENSE"] = {
		ruRU = "ЗАЩ %d",
		enGB = "DEF %d"
	},
	["ABILITY_INFO_NIGHTELF4"] = {
		ruRU = "- Повышенное сопротивление природной магии.",
		enGB = "- Resistant to Nature damage."
	},
	["LOGIN_ACCOUNT_LOCKED"] = {
		ruRU = "<html><body><p align=\"CENTER\">Учетная запись была заблокирована в связи с подозрительными действиями.|nНа адрес электронной почты, указанный при регистрации учетной записи, отправлено сообщение о том, как решить эту проблему.|nДополнительную информацию вы можете получить на странице <a href=\"http://eu.battle.net/wow/account-locked/ru-ru\">http://eu.battle.net/wow/account-locked/ru-ru.</a></p></body></html>",
		enGB = "<html><body><p align=\"CENTER\">Due to suspicious activity, this account is locked.|nA message has been sent to this account's email address containing details on how to resolve this issue.|nVisit <a href=\"http://us.battle.net/wow/account-locked/en-us\">us.battle.net/wow/account-locked/en-us</a> for more information.</p></body></html>"
	},
	["AUTH_BANNED_URL"] = {
		ruRU = "http://www.wow-europe.com/ru/legal/termsofuse.html",
		enGB = "http://www.worldofwarcraft.com/termsofuse.shtml"
	},
	["CATEGORY_DESCRIPTION"] = {
		ruRU = "Тип мира",
		enGB = "Realm Category"
	},
	["REALM_HELP_FRAME_TITLE"] = {
		ruRU = "Миры недоступны",
		enGB = "Realms Unavailable"
	},
	["SUGGESTED_REALM_TEXT"] = {
		ruRU = "|cffffffffВыбранный мир:|r %s.",
		enGB = "|cffffffffYou have been assigned to the|r %s |cffffffffRealm.|r"
	},
	["AUTH_UNAVAILABLE"] = {
		ruRU = "Сервер недоступен. Повторите попытку позже.",
		enGB = "System unavailable - Please try again later"
	},
	["RESPONSE_VERSION_MISMATCH"] = {
		ruRU = "Неверная версия клиента",
		enGB = "Wrong client version"
	},
	["CHARACTER_UNDELETE_NOT_CHARACTER"] = {
		ruRU = "Нет доступных для восстановления персонажей",
		enGB = "No characters available for restoration"
	},
	["LAUNCH_MAC_SYSTEM_REQUIRED"] = {
		ruRU = "Для запуска игры требуется операционная система Mac OS X версии %s.",
		enGB = "World of Warcraft requires Mac OS X version %s."
	},
	["ABILITY_INFO_BLOODELF4"] = {
		ruRU = "- Повышенное сопротивление магии.",
		enGB = "- Resistant to magical damage."
	},
	["SYSTEM_INCOMPATIBLE_SSE"] = {
		ruRU = "<html><body><p align=\"CENTER\">Эта система не будет поддерживаться в следующих версиях World of Warcraft. Более подробную информацию вы найдете здесь: <a href=\"http://www.blizzard.com/support/article/SSE\">http://www.blizzard.com/support/article/SSE</a>.</p></body></html>",
		enGB = "<html><body><p align=\"CENTER\">This system will not be supported in future versions of World of Warcraft. Please see <a href=\"http://www.blizzard.com/support/article/SSE\">http://www.blizzard.com/support/article/SSE</a> for more information.</p></body></html>"
	},
	["CHARACTER_BOOST_DISABLE_REALM"] = {
		ruRU = "Быстрый старт временно недоступен для этого игрового мира.",
		enGB = "This service is temporarily unavailable on this realm"
	},
	["CHARACTER_RESTORE"] = {
		ruRU = "Восстановить",
		enGB = "Restore"
	},
	["ABILITY_INFO_ORC2"] = {
		ruRU = "- Повышенная невосприимчивость к оглушающим эффектам.",
		enGB = "- Resistant to stun effects."
	},
	["TERMINATION_WITHOUT_NOTICE_NOTICE"] = {
		ruRU = "Некоторые пункты Соглашения об условиях пользования были изменены. Просмотрите весь текст Соглашения прежде, чем принимать его условия.",
		enGB = "The Terms of Use have changed. Please scroll down and review the changes before accepting the agreement."
	},
	["LOAD_NEW"] = {
		ruRU = "Новый",
		enGB = "New"
	},
	["REALM_NAME"] = {
		ruRU = "Название",
		enGB = "Realm Name"
	},
	["SCANDLL_MESSAGE_HACKNOCONTINUE"] = {
		ruRU = "<html><body><p>В вашей системе обнаружена программа \"%1$s\". Ее запуск может привести к к нежелательным последствиям – вплоть до невозможности игры в World of Warcraft. Перед началом игры крайне рекомендуется перезагрузить компьютер.</p><p>Подробнее см. <a href='%2$s'>здесь</a></p></body></html>",
		enGB = "<html><body><p>\"%1$s\" has been detected. This program may be a security risk and/or violate the Terms of Use for World of Warcraft. You must restart your computer and ensure that this program is not active in order to continue.</p><p>For more information: <a href='%2$s'>Click Here</a></p></body></html>"
	},
	["CHANGE_REALM"] = {
		ruRU = "Выбор мира",
		enGB = "Change Realm"
	},
	["CHARACTER_SERVICES_199_BONUS"] = {
		ruRU = "199 бонусов",
		enGB = "199 bonuses"
	},
	["ACCOUNT_MESSAGE_READ_URL"] = {
		ruRU = "http://www.wow-europe.com/ru/support/",
		enGB = "http://support.worldofwarcraft.com/accountmessaging/markMessageAsRead.xml"
	},
	["BF_HONOR_KILLS"] = {
		ruRU = "Почетные победы",
		enGB = "Honorable Kills"
	},
	["AUTH_BANNED"] = {
		ruRU = "<html><body><p align=\"CENTER\">Учетная запись заблокирована.</p><p align=\"CENTER\">Более подробную информацию вы найдете в Личном кабинете на сайте:</p><p align=\"CENTER\"><a href=\"http://sirus.su/user\">http://sirus.su/user</a></p><p align=\"CENTER\">По вопросам блокировки обратитесь на</p><p align=\"CENTER\"><a href=\"mailto:info@sirus.su\">info@sirus.su</a></p></body></html>",
		enGB = ""
	},
	["CONFIRM_COMPLETE_EXPENSIVE_QUEST"] = {
		ruRU = "На выполнение этого задания вам придется потратить сумму, указанную ниже. Продолжить выполнение задания?",
		enGB = "Completing this quest requires spending the following amount of money. Do you still want to complete the quest?"
	},
	["BLOCK"] = {
		ruRU = "БЛОК %.2f",
		enGB = "BLOCK %.2f"
	},
	["DEMON_HUNTER"] = {
		ruRU = "Охотник на демонов",
		enGB = "Demon Hunter"
	},
	["CHAR_LOGIN_LOCKED_BY_MOBILE_AH"] = {
		ruRU = "Вы не можете войти в игру, пока пользуетесь мобильным аукционом или веб-аукционом.",
		enGB = "You cannot log in while using World of Warcraft Remote."
	},
	["RACE_CHANGE_IN_PROGRESS"] = {
		ruRU = "Обновление расы…",
		enGB = "Updating Race..."
	},
	["ABILITY_INFO_GNOME4"] = {
		ruRU = "- Имеет способности к инженерному делу.",
		enGB = "- Engineering skill increased."
	},
	["ACCOUNT_CREATE_URL"] = {
		ruRU = "http://signup.wow-europe.com/",
		enGB = "http://signup.worldofwarcraft.com"
	},
	["ABILITY_INFO_DRAENEI1"] = {
		ruRU = "- Имеет способности к ювелирному делу.",
		enGB = "- Jewelcrafting skill increased."
	},
	["RACE_INFO_TAUREN_FEMALE"] = {
		ruRU = "Таурены всегда стремились сохранять равновесие природы, следуя завету своей богини, Матери-Земли. Не так давно они подверглись набегу злобных кентавров, и если бы не счастливый случай – встреча с орками, которые помогли отразить нападение, – могли бы и вовсе погибнуть. Чтобы вернуть долг крови, таурены присоединились к Орде вслед за своими соратниками.",
		enGB = "Always the tauren strive to preserve the balance of nature and heed the will of their goddess, the Earth Mother. Recently attacked by murderous centaur, the tauren would have been wiped out, save for a chance encounter with the orcs, who helped defeat the interlopers. To honor this blood-debt, the tauren joined the Horde, solidifying the two races' friendship."
	},
	["BAG_SLOTS"] = {
		ruRU = "ЯЧК %d",
		enGB = "SLOTS %d"
	},
	["CREDITS"] = {
		ruRU = "Создатели",
		enGB = "Credits"
	},
	["HORDE"] = {
		ruRU = "Орда",
		enGB = "Horde"
	},
	["SECURITY_CODE"] = {
		ruRU = "2FA - код безопасности",
		enGB = "2FA - Security code"
	},
	["LOAD_ADDONS"] = {
		ruRU = "Загрузить",
		enGB = "Load Anyway"
	},
	["SERVER_WEB_SITE"] = {
		ruRU = "Сайт сервера",
		enGB = "Server website"
	},
	["CHAR_LOGIN_IN_PROGRESS"] = {
		ruRU = "Вход в игру",
		enGB = "Entering the World of Warcraft"
	},
	["REALM_DESCRIPTION"] = {
		ruRU = "Выбор мира",
		enGB = "Choosing a Realm"
	},
	["CHARACTER_BOOST_CHOOSE_CHARACTER_FACTION"] = {
		ruRU = "Выберите фракцию",
		enGB = "Choose a faction"
	},
	["LOGIN_EXPIRED"] = {
		ruRU = "<html><body><p align=\"CENTER\">Оплаченное игровое время для вашей учетной записи закончилось. Для продолжения игры необходимо оплатить дополнительное время. Вы можете сделать это по адресу <a href=\"https://www.wow-europe.com/login/login?service=https%3A%2F%2Fwww.wow-europe.com%2Faccount%2F&amp;locale=ru_RU\">https://www.wow-europe.com/account/</a>.</p></body></html>",
		enGB = "<html><body><p align=\"CENTER\">Your game account subscription has expired. Please visit <a href=\"http://www.worldofwarcraft.com/account\">www.worldofwarcraft.com/account</a> to purchase. more time.</p></body></html>"
	},
	["LATEST_AGREEMENTS_URL"] = {
		ruRU = "http://launcher.wow-europe.com/ru/legal/agreements.mpq",
		enGB = "http://launcher.worldofwarcraft.com/legal/agreements.mpq"
	},
	["CHARACTER_SERVICES_BOOST_ERROR"] = {
		ruRU = "Произошла непредвиденная ошибка, обратитесь на форум! Код ошибки: ",
		enGB = "An unexpected error occurred, please leave a message on the forum! Error code:"
	},
	["CHARACTER_SERVICES_BOOST_ERROR_2"] = {
		ruRU = "Персонаж уже максимального уровня",
	},
	["CHARACTER_SERVICES_BOOST_ERROR_3"] = {
		ruRU = "Указана недопустимая профессия",
	},
	["CHARACTER_SERVICES_BOOST_ERROR_4"] = {
		ruRU = "Указана недопустимая специализация",
	},
	["CHARACTER_SERVICES_BOOST_ERROR_5"] = {
		ruRU = "Указана неверная фракция",
	},
	["CHARACTER_SERVICES_BOOST_ERROR_6"] = {
		ruRU = "Быстрый старт временно недоступен",
	},
	["CHARACTER_SERVICES_BOOST_ERROR_7"] = {
		ruRU = "Услуга быстрого старта уже приобретена",
	},
	["CHARACTER_SERVICES_BOOST_ERROR_8"] = {
		ruRU = "Указанный персонаж не найден",
	},
	["CHARACTER_SERVICES_BOOST_ERROR_9"] = {
		ruRU = "Услуга быстрого старта уже применена к этому персонажу, вам необходимо зайти им в игру",
	},
	["CHARACTER_SERVICES_BOOST_ERROR_10"] = {
		ruRU = "Внутренняя ошибка",
	},
	["CHARACTER_SERVICES_BOOST_ERROR_13"] = {
		ruRU = "Внутренняя ошибка",
	},
	["CHARACTER_SERVICES_BOOST_ERROR_14"] = {
		ruRU = "Отмена Быстрого старта временно недоступена",
	},
	["CHARACTER_SERVICES_BOOST_ERROR_16"] = {
		ruRU = "Персонаж является главой гильдии. Для отмены Быстрого Старта необходимо передать звание главы другому персонажу",
	},
	["CHARACTER_SERVICES_BOOST_ERROR_17"] = {
		ruRU = "Персонаж является капитаном команды арены. Для отмены Быстрого Старта необходимо передать звание капитана другому персонажу",
	},
	["CHARACTER_SERVICES_BOOST_ERROR_18"] = {
		ruRU = "Вы не можете отменить Быстрый Старт, пока есть другой неиспользованный Быстрый Старт",
	},
	["CHARACTER_SERVICES_BOOST_ERROR_19"] = {
		ruRU = "Указанный персонаж не найден",
	},
	["CONFIRM_DISABLE_ADDONS"] = {
		ruRU = "После установки обновленных версий модификаций вам нужно подключить их еще раз. Вы действительно хотите отключить их?\n\n|cffffffffПодключение можно осуществить, нажав кнопку «Модификации» в левой нижней части экрана.|r",
		enGB = "You will need to re-enable your modifications once you install updated versions.  Are you sure you want to disable them?\n\n|cffffffffYou can re-enable them by using the \"Addons\" button in the lower left.|r"
	},
	["BILLING_IGR_USAGE_TIME_LEFT_30_MINS"] = {
		ruRU = "Для этого тарифного плана IGR осталось не более 30 минут игрового времени.",
		enGB = "This IGR usage plan has 30 minutes or less of play time left on it."
	},
	["CHARACTER_SERVICES_DISABLE_SUSPECT_ACCOUNT"] = {
		ruRU = "<html><body><p align=\"CENTER\">Услуга недоступна для неподтвержденных учетных записей. Более подробно тут <a href=\"https://sirus.su/unconfirmed\">https://sirus.su/unconfirmed</a></p></body></html>",
		enGB = "<html><body><p align=\"CENTER\">The service is not available for suspicious accounts. Please see <a href=\"https://sirus.su/unconfirmed\">https://sirus.su/unconfirmed</a> for more information.</p></body></html>"
	},
	["CHARACTER_SERVICES_DISABLED"] = {
		ruRU = "Услуга временно недоступна в этом мире",
		enGB = "Service is temporarily unavailable on this realm"
	},
	["CHARACTER_SERVICES_NOT_ENOUGH_MONEY"] = {
		ruRU = "У вас недостаточно бонусов для приобретения услуги.",
		enGB = "You don't have enough bonuses to purchase the service."
	},
	["CHAR_CUSTOMIZE_IN_PROGRESS"] = {
		ruRU = "Изменение внешности персонажа…",
		enGB = "Customizing Character..."
	},
	["SHAMAN_DISABLED"] = {
		ruRU = "Шаман\nЭтот класс доступен другим расам.",
		enGB = "Shaman\nYou must choose a different race to be this class."
	},
	["CHOOSE_GENDER"] = {
		ruRU = "Выберите пол:",
		enGB = "Choose your gender:"
	},
	["CHAR_FACTION_CHANGE_SWAP_FACTION"] = {
		ruRU = "Вы должны выбрать одну из рас противоположной стороны (Альянса или Орды).",
		enGB = "You must choose a race from the opposing faction."
	},
	["RACIAL_ABILITIES"] = {
		ruRU = "Расовые способности",
		enGB = "Racial Abilities"
	},
	["REALM_HELP_FRAME_URL"] = {
		ruRU = "<a href=\"http://www.wow-europe.com/ru\">www.wow-europe.com</a>",
		enGB = "<a href=\"http://www.worldofwarcraft.com/\">www.worldofwarcraft.com</a>"
	},
	["CHAR_FACTION_CHANGE_FORCE_LOGIN"] = {
		ruRU = "Перед тем как провести новую смену расы или фракции, вам нужно войти в игру, чтобы завершить предыдущий процесс смены расы или фракции.",
		enGB = "You must login to complete your previous race or faction change before doing another race or faction change."
	},
	["RESET_SERVER_SETTINGS"] = {
		ruRU = "Вы уверены, что хотите вернуться к пользовательским настройкам по умолчанию при следующем входе в игру?",
		enGB = "Are you sure you want to reset all user options to their defaults the next time you login?"
	},
	["SERVER_SELECTION"] = {
		ruRU = "Выбор мира",
		enGB = "Realm Selection"
	},
	["CHAR_FACTION_CHANGE_CHOOSE_RACE"] = {
		ruRU = "Вы должны сменить расу.",
		enGB = "You must change your race."
	},
	["LOGIN_ENTER_PASSWORD"] = {
		ruRU = "Введите пароль.",
		enGB = "Please enter your password."
	},
	["CHOOSE"] = {
		ruRU = "Выбрать",
		enGB = "Select"
	},
	["INT"] = {
		ruRU = "ИНТ",
		enGB = "INT"
	},
	["DONATE"] = {
		ruRU = "Пожертвование",
		enGB = "Donate"
	},
	["AUTH_FAILED"] = {
		ruRU = "Ошибка авторизации",
		enGB = "Authentication failed"
	},
	["FORCE_CHANGE_FACTION_EVENT_PANDA"] = {
		ruRU = "Смена фракции.. О! Вы - панда!",
		enGB = ""
	},
	["ACCOUNT_MESSAGE_HEADERS_URL"] = {
		ruRU = "http://www.wow-europe.com/ru/support/",
		enGB = "http://support.worldofwarcraft.com/accountmessaging/getMessageHeaders.xml"
	},
	["CHARACTER_SERVICES_PERSONAL_OFFER"] = {
		ruRU = "Перс. Предложение",
		enGB = "Personal offer"
	},
	["AUTH_OK"] = {
		ruRU = "Авторизация выполнена",
		enGB = "Authentication Successful"
	},
	["CHAR_LOGIN_LOCKED_FOR_TRANSFER"] = {
		ruRU = "Вы не можете войти в игру, пока процесс обновления персонажа не будет завершен.",
		enGB = "You cannot log in until the character update process you recently initiated is complete. "
	},
	["CHARACTER_UNDELETE_ALERT_1"] = {
		ruRU = "Персонаж успешно восстановлен.\nЕго старое имя было занято, так что при входе в\nигру вам надо будет выбрать новое",
		enGB = "The character has been successfully restored.\nYour old name was taken, and you will need to pick a\nnew one when you log in."
	},
	["CHAR_LIST_RETRIEVING"] = {
		ruRU = "Загрузка списка персонажей",
		enGB = "Retrieving character list"
	},
	["CHAR_CREATE_UNIQUE_CLASS_LIMIT"] = {
		ruRU = "<html><body><p align=\"CENTER\">В этом игровом мире вы достигли максимального количества персонажей героического класса рыцарь смерти для вашей учетной записи.</p><p></p><p></p><p></p><p align=\"CENTER\">Вы можете создать рыцаря смерти вне лимита с помощью услуги \"Быстрый старт\" или открыв новую страницу персонажей.</p><p align=\"CENTER\"><a href=\"https://forum.sirus.su/threads/289482/\">Подробности</a></p></body></html>",
		enGB = "<html><body><p align=\"CENTER\">You may only have one Death Knight Hero Class character on this realm.</p></body></html>"
	},
	["CHAR_DECLINE_IN_PROGRESS"] = {
		ruRU = "Обновление персонажа...",
		enGB = "Updating Character..."
	},
	["LOGIN_ERROR"] = {
		ruRU = "Ошибка",
		enGB = "Error"
	},
	["LOGIN_BADVERSION"] = {
		ruRU = "<html><body><p align=\"CENTER\">Некорректная версия игры. Возможно, поврежден один из файлов или имеет место вмешательство посторонней программы. Подробнее о проблеме и о ее решении можно прочитать здесь: <a href=\"http://eu.blizzard.com/support/article.xml?articleId=28274\">http://eu.blizzard.com/support/article.xml?articleId=28274</a>.</p></body></html>",
		enGB = "<html><body><p align=\"CENTER\">Unable to validate game version.  This may be caused by file corruption or the interference of another program.  Please visit <a href=\"http://us.blizzard.com/support/article.xml?articleId=21031\">http://us.blizzard.com/support/article.xml?articleId=21031</a> for more information and possible solutions to this issue.</p></body></html>"
	},
	["AUTH_LOCKED_ENFORCED"] = {
		ruRU = "Вы подали заявку на блокировку своей учетной записи. Для изменения статуса блокировки позвоните по соответствующему телефонному номеру.",
		enGB = "You have applied a lock to your account. You can change your locked status by calling your account lock phone number."
	},
	["ENTER_AUTHCODE_TITLE"] = {
		ruRU = "Код брелка безопасности",
		enGB = "Authenticator Code"
	},
	["LOGINBOX_AUTOLOGIN"] = {
		ruRU = "Автоматический вход",
		enGB = "Automatic Login"
	},
	["TRIAL_LOADING_MESSAGE"] = {
		ruRU = "|cffffd100Внимание:|r поскольку вы впервые играете за представителя этой расы, будет выполнена загрузка стартовых данных. Это может занять несколько минут. Пожалуйста, подождите.",
		enGB = "|cffffd100Note:|r Since this is your first time playing this race, please wait while starting data is downloaded to your system. This may take a few minutes."
	},
	["ASSERTIONS_ENABLED_BUILD"] = {
		ruRU = "Режим проверки готовности к выпуску",
		enGB = "Release Assertions Enabled"
	},
	["VIDEO_OPTIONS_RESET"] = {
		ruRU = "Параметры изображения были изменены.",
		enGB = "Your video settings have changed."
	},
	["DOWNLOADING_UPDATE"] = {
		ruRU = "Загрузка обновления",
		enGB = "Downloading Update"
	},
	["ABILITY_INFO_NIGHTELF3"] = {
		ruRU = "- После смерти принимает облик огонька и передвигается быстрее.",
		enGB = "- Wisp form while dead for faster movement."
	},
	["SPECIALIZATION_LABEL"] = {
		ruRU = "Специализация:",
		enGB = "Specialization:"
	},
	["PVP_SPECIALIZATION_LABEL"] = {
		ruRU = "PVP Специализация:",
		enGB = "PVP Specialization:"
	},
	["SPECIALIZATIONS_PVE_LABEL"] = {
		ruRU = "PVE Специализации",
		enGB = "PVE Specializations"
	},
	["SPECIALIZATIONS_PVP_LABEL"] = {
		ruRU = "PVP Специализации",
		enGB = "PVP Specializations"
	},
	["CHAR_FACTION_CHANGE_GOLD_LIMIT"] = {
		ruRU = "Вы превысили лимит на количество золота, предусмотренный для смены фракции.",
		enGB = "You have exceeded the gold limit for faction transfer."
	},
	["DRUID_DISABLED"] = {
		ruRU = "Друид\nЭтот класс доступен другим расам.",
		enGB = "Druid\nYou must choose a different race to be this class."
	},
	["CHARACTER_NAME"] = {
		ruRU = "Имя персонажа",
		enGB = "Character Name"
	},
	["RACE_INFO_DWARF_FEMALE"] = {
		ruRU = "В древние времена дворфов интересовали лишь богатства, которые они добывали из недр земли. Однажды во время раскопок они обнаружили следы древней расы богоподобных существ, которая создала дворфов и наделила их некими могущественными правами. Дворфы возжелали узнать больше и посвятили себя поиску древних сокровищ и знаний. Сегодня дворфов-археологов можно встретить в любом уголке Азерота.",
		enGB = "In ages past, the dwarves cared only for riches taken from the earth's depths. Then records surfaced of a god-like race said to have given the dwarves life... and an enchanted birthright. Driven to learn more, the dwarves devoted themselves to the pursuit of lost artifacts and ancient knowledge. Today dwarven archaeologists are scattered throughout the globe."
	},
	["CHARACTER_SELECT_INFO_GHOST"] = {
		ruRU = "%s (призрак)",
		enGB = "%s (Ghost)"
	},
	["SPELL_EXAMPLE"] = {
		ruRU = "Примеры заклинаний",
		enGB = "Example Spells"
	},
	["CONFIRM_CHAR_DELETE_INSTRUCTIONS"] = {
		ruRU = "Для подтверждения введите слово «УДАЛИТЬ».",
		enGB = "Type \"DELETE\" into the field to confirm."
	},
	["DEATHKNIGHT_DISABLED"] = {
		ruRU = "Рыцарь смерти\nТребуется дополнение Wrath of the Lich King\nи наличие персонажа 55-го уровня",
		enGB = "Death Knight\nRequires Wrath of the Lich King\nand a level 55 character"
	},
	["WOW_ACCOUNTS"] = {
		ruRU = "Учетные записи World of Warcraft",
		enGB = "World of Warcraft Accounts"
	},
	["HARDWARE_SURVEY_DISAGREE"] = {
		ruRU = "Не разрешаю",
		enGB = "I don't consent"
	},
	["EULA_NOTICE"] = {
		ruRU = "Некоторые пункты Лицензионного соглашения с конечным пользователем были изменены. Просмотрите весь текст Соглашения прежде, чем принимать его условия.",
		enGB = "The End User License Agreement has changed. Please scroll down and review the changes before accepting the agreement."
	},
	["RACE_INFO_BLOODELF_FEMALE"] = {
		ruRU = "Много лет назад высшие эльфы-изгнанники основали поселение Кель'Талас, в котором создали магический источник, названный Солнечным Колодцем. Чем больше сил черпали из него эльфы, тем сильнее начинали от него зависеть.|n|nСпустя века Армия Плети разрушила Солнечный Колодец и убила большинство эльфов. Изгнанники назвали себя эльфами крови и стремятся восстановить Кель'Талас, а также найти новый источник волшебной силы, чтобы удовлетворить свое пагубное пристрастие.",
		enGB = "Long ago the exiled high elves founded Quel'Thalas, where they created a magical fount called the Sunwell. Though they were strengthened by its powers, they also grew increasingly dependent on them.|n|nAges later the undead Scourge destroyed the Sunwell and most of the high elf population. Now called blood elves, these scattered refugees are rebuilding Quel'Thalas as they search for a new magic source to satisfy their painful addiction."
	},
	["MENU_EDIT_COPY"] = {
		ruRU = "Копировать",
		enGB = "Copy"
	},
	["LOGIN_SUSPENDED"] = {
		ruRU = "<html><body><p align=\"CENTER\">Учетная запись временно заблокирована.</p><p>Причина блокировки указана в Личном кабинете</p><p align=\"CENTER\"><a href=\"https://sirus.su/user/\">https://sirus.su/user/</a></p><p align=\"CENTER\">Узнать подробности вы можете в теме</p><p align=\"CENTER\"><a href=\"https://forum.sirus.su/threads/17670/\">https://forum.sirus.su/threads/17670/</a></p></body></html>",
	},
	["LOADING_REALM_LIST"] = {
		ruRU = "Загрузка списка игровых миров...",
		enGB = "Loading realm list..."
	},
	["ABILITY_INFO_TROLL2"] = {
		ruRU = "- Быстрее восполняет здоровье.",
		enGB = "- Regeneration increased."
	},
	["QUEUE_TIME_LEFT"] = {
		ruRU = "Свободных мест нет\nМесто в очереди: %d\nВремя ожидания: %d мин.",
		enGB = "Realm is Full\nPosition in queue: %d\nEstimated time: %d min"
	},
	["LOGIN_TRIAL_EXPIRED"] = {
		ruRU = "<html><body><p align=\"CENTER\">Время действия вашей пробной учетной записи закончилось. Пожалуйста, посетите страницу <a href=\"https://www.wow-europe.com/account/\">https://www.wow-europe.com/account/</a>, чтобы изменить статус вашей учетной записи.</p></body></html>",
		enGB = "<html><body><p align=\"CENTER\">Your trial subscription has expired. Please visit <a href=\"http://www.worldofwarcraft.com/account\">www.worldofwarcraft.com/account</a> to upgrade your account.</p></body></html>"
	},
	["ABILITY_INFO_SCOURGE3"] = {
		ruRU = "- Умеет надолго задерживать дыхание под водой.",
		enGB = "- Underwater breathing increased."
	},
	["CHARACTER_SERVICES_DIALOG_BOOST_ENTER_WORLD"] = {
		ruRU = "В момент конфигурации персонажа с помощью функции \"Быстрый старт\", вход в игровой мир недоступен.\nПрервать конфигурацию?",
		enGB = "You cannot log in while the Character Boost function is configuring your character.\nDo you want to suspend the configuration?"
	},
	["CHARACTER_SERVICES_DIALOG_BOOST_ENTER_WORLD_DEATH_KNIGHT"] = {
		ruRU = "Во время создания персонажа с помощью функции \"Быстрый старт\" вход в игровой мир недоступен.\nПрерывание настройки Быстрого старта не позволит вам создать еще одного персонажа с помощью данной услуги или войти в игровой мир, пока вы не удалите созданного Рыцаря смерти или не закончите его настройку.\nПрервать конфигурацию?",
		enGB = ""
	},
	["CHARACTER_SERVICES_DIALOG_BOOST_CANCEL_DEATH_KNIGHT"] = {
		ruRU = "Прерывание настройки Быстрого старта не позволит вам создать еще одного персонажа с помощью данной услуги или войти в игровой мир, пока вы не удалите созданного Рыцаря смерти или не закончите его настройку.\nПрервать конфигурацию?",
		enGB = ""
	},
	["CHARACTER_SERVICES_DIALOG_BOOST_NO_CHARACTERS_AVAILABLE_DEATH_KNIGHT"] = {
		ruRU = "Пожалуйста, завершите начатую настройку \"Быстрого старта\" для Рыцаря смерти или удалите этого персонажа.",
		enGB = ""
	},
	["CHARACTER_DELETE_BLOCKED_BOOST_DEATH_KNIGHT"] = {
		ruRU = "Перед удалением текущего персонажа необходимо завершить применение \"Быстрого старта\" для Рыцаря смерти либо удалить его.",
		enGB = "",
	},
	["CHARACTER_GEAR_BOOST_CONFIRM_TEXT"] = {
		ruRU = "Вы уверены, что хотите использовать услугу \"Апгрейд!\" на персонажа |c%s%s|r?\n\n|cffFFD200ВНИМАНИЕ! Услуга \"Апгрейд!\" не подлежит обмену или возврату.|r",
	},
	["CHARACTER_SERVICES_DIALOG_GEAR_BOOST_ENTER_WORLD"] = {
		ruRU = "В момент конфигурации персонажа с помощью функции \"Апгрейд!\", вход в игровой мир недоступен.\nПрервать конфигурацию?",
	},
	["MENU_EDIT_UNDO"] = {
		ruRU = "Отменить",
		enGB = "Undo"
	},
	["AUTH_LOGIN_SERVER_NOT_FOUND"] = {
		ruRU = "Неверный сервер входа",
		enGB = "Invalid Login Server"
	},
	["DODGE"] = {
		ruRU = "УКЛОН %.2f",
		enGB = "DODGE %.2f"
	},
	["ABILITY_INFO_BLOODELF2"] = {
		ruRU = "- Умеет восполнять ману, энергию или силу рун.",
		enGB = "- May restore mana, energy, or runic power."
	},
	["RESILIENCE"] = {
		ruRU = "УСТЧ %d",
		enGB = "RESIL %d"
	},
	["ABILITY_INFO_DWARF2"] = {
		ruRU = "- С повышенной вероятностью наносит критический удар огнестрельным оружием.",
		enGB = "- Increased critical chance with Guns."
	},
	["BILLING_GAMEROOM_EXPIRE"] = {
		ruRU = "Срок действия вашей учетной записи с фиксированным тарифным планом скоро истечет. После этого соединение будет разорвано.\nОбратитесь к дежурному менеджеру вашей IGR.",
		enGB = "IGR account in use is about to expire. Once expired, you may get disconnected.\nPlease contact the manager on duty in your IGR."
	},
	["QUEUE_FCM"] = {
		ruRU = "В этом игровом мире открыт бесплатный перенос персонажей. Щелкните по кнопке, расположенной ниже, чтобы узнать подробности.",
		enGB = "Free character migration is available for this realm. Click the button below for more information."
	},
	["NEW_REALM"] = {
		ruRU = "Новый",
		enGB = "New"
	},
	["TOS_FRAME_TITLE"] = {
		ruRU = "Соглашения",
		enGB = "Terms of Use"
	},
	["CHARACTER_CREATE_ACCEPT"] = {
		ruRU = "Принять",
		enGB = "Accept"
	},
	["STA"] = {
		ruRU = "ВНС",
		enGB = "STA"
	},
	["DELETED"] = {
		ruRU = " (удален)",
		enGB = "(deleted)"
	},
	["AUTH_ALREADY_ONLINE"] = {
		ruRU = "Персонаж все еще в игре. Если это не так, и вы продолжаете испытывать данную проблему более 15 минут, свяжитесь со службой поддержки по адресу WoWtechEU@blizzard.com.",
		enGB = "This character is still logged on. If this character is not logged in and you continue to experience this issue for more than 15 minutes, please contact our Technical Support Department at wowtech@blizzard.com"
	},
	["BURNING_CRUSADE"] = {
		ruRU = "The Burning Crusade",
		enGB = "The Burning Crusade"
	},
	["CHAR_CREATE_UNKNOWN"] = {
		ruRU = "Неизвестная ошибка",
		enGB = "Unknown error"
	},
	["CONNECTION_HELP_FRAME_TITLE"] = {
		ruRU = "Справка",
		enGB = "Connection Help"
	},
	["NORMAL_BUILD"] = {
		ruRU = "Версия",
		enGB = "Version"
	},
	["CREATE_ACCOUNT"] = {
		ruRU = "Новая запись",
		enGB = "Create Account"
	},
	["SHOW_LAUNCHER"] = {
		ruRU = "Меню запуска",
		enGB = "Show Launcher"
	},
	["ACCOUNT_MESSAGE_BUTTON_READ"] = {
		ruRU = "Отметить как прочтенные",
		enGB = "Mark as read"
	},
	["AUTH_SUSPENDED_URL"] = {
		ruRU = "http://www.wow-europe.com/ru/legal/termsofuse.html",
		enGB = "http://www.worldofwarcraft.com/termsofuse.shtml"
	},
	["ADDONS_OUT_OF_DATE"] = {
		ruRU = "Используемые вами модификации устарели. Для корректной работы новой версии игры рекомендуется отключить их.",
		enGB = "You are running a new version of the game and have interface modifications which are out of date.  Disabling them is recommended."
	},
	["CANCEL_RESET"] = {
		ruRU = "Отменить сброс",
		enGB = "Cancel Reset"
	},
	["CHARACTER_SERVICES_YOU_DONT_HAVE_BONUS"] = {
		ruRU = "У вас нет бонусов",
		enGB = "You do not have any bonuses"
	},
	["LOGIN_INVALID_RECODE_MESSAGE"] = {
		ruRU = "Ошибка сообщение о перекодировке.",
		enGB = "Invalid Recode Message"
	},
	["ACCOUNT_NAME"] = {
		ruRU = "Учетная запись Battle.net",
		enGB = "Battle.net Account Name"
	},
	["ACCOUNT_TWO_FACTOR_AUTHENTICATION"] = {
		ruRU = "Для этого аккаунта включена двухфакторная авторизация.\nВведите код, отображаемый в вашем приложении для генерации кодов.",
		enGB = "Two-factor authentication is enabled for this account.\nEnter the code displayed in your code generation app."
	},
	["RACE_INFO_GNOME"] = {
		ruRU = "Гномы Каз Модана не могут похвастаться статью, зато их интеллект позволил занять им достойное место в истории. Гномреган, подземное королевство, в свое время был чудом паровых технологий. Увы, вторжение троггов привело к разрушению города. Теперь славные строители Гномрегана скитаются по землям дворфов, по мере сил помогая своим союзникам.",
		enGB = "Though small in stature, the gnomes of Khaz Modan have used their great intellect to secure a place in history. Indeed, their subterranean kingdom, Gnomeregan, was once a marvel of steam-driven technology. Even so, due to a massive trogg invasion, the city was lost. Now its builders are vagabonds in the dwarven lands, aiding their allies as best they can."
	},
	["ACCOUNT_MESSAGE_BODY_URL"] = {
		ruRU = "http://www.wow-europe.com/ru/support/",
		enGB = "http://support.worldofwarcraft.com/accountmessaging/getMessageBody.xml"
	},
	["CHAR_LOGIN_NO_INSTANCES"] = {
		ruRU = "Серверы подземелий недоступны",
		enGB = "No instance servers are available"
	},
	["RACE_INFO_NIGHTELF"] = {
		ruRU = "Десять тысяч лет назад ночные эльфы основали огромную империю, но неразумное использование первородной магии привело ее к падению. Полные скорби, они удалились в леса и пребывали в изоляции вплоть до возвращения их вековечного врага, Пылающего Легиона. Тогда ночным эльфам пришлось пожертвовать своим уединенным образом жизни и сплотиться, чтобы отвоевывать свое место в новом мире.",
		enGB = "Ten thousand years ago, the night elves founded a vast empire, but their reckless use of primal magic brought them to ruin. In grief, they withdrew to the forests and remained isolated there until the return of their ancient enemy, the Burning Legion. With no other choice, the night elves emerged at last from their seclusion to fight for their place in the new world."
	},
	["CHAR_CREATE_SERVER_LIMIT"] = {
		ruRU = "Вы достигли максимального числа персонажей для данного игрового мира.",
		enGB = "You already have the maximum number of characters allowed on this realm."
	},
	["VERSION"] = {
		ruRU = "Версия",
		enGB = "Version"
	},
	["USE_ENGLISH_SPEECH_PACK"] = {
		ruRU = "Английский набор звуков",
		enGB = "Use English Speech Pack"
	},
	["CHAR_RENAME_INSTRUCTIONS"] = {
		ruRU = "Введите новое имя",
		enGB = "Please enter a new name"
	},
	["CHARACTER_BOOST_HELP_CHOOSE_SPEC_DESC"] = {
		ruRU = "Выберите для какой специализации вы хотели бы получить экипировку. Иконки меча, щита, и крестика отображают соответствующие роли - нанесение урона, защита союзников, или их исцеление.\n\nОчки талантов вам необходимо распределить самостоятельно.",
		enGB = ""
	},
	["CHARACTER_BOOST_HELP_CHOOSE_SPEC"] = {
		ruRU = "Выбор специализации",
		enGB = ""
	},
	["NAME_AND_REST_STATE"] = {
		ruRU = "%s - %s",
		enGB = "%s - %s"
	},
	["REALM_LIST_IN_PROGRESS"] = {
		ruRU = "Запрос списка миров...",
		enGB = "Retrieving realm list"
	},
	["RACE_INFO_ORC_FEMALE"] = {
		ruRU = "Орки происходят с планеты Дренор. Пока Пылающий Легион не подчинил этот народ своей власти, орки посвящали себя исключительно мирным занятиям и шаманизму. Но однажды демоны поработили орков и погнали на войну с людьми Азерота. Много лет потребовалось, чтобы избавиться от гнета Легиона и обрести долгожданную свободу. Теперь орки вынуждены сражаться за место в чужом для них мире.",
		enGB = "The orc race originated on the planet Draenor. A peaceful people with shamanic beliefs, they were enslaved by the Burning Legion and forced into war with the humans of Azeroth. Although it took many years, the orcs finally escaped the demons' corruption and won their freedom. To this day they fight for honor in an alien world that hates and reviles them."
	},
	["QUEUE_FCM_URL"] = {
		ruRU = "https://www.wow-europe.com/account/",
		enGB = "http://www.worldofwarcraft.com/account"
	},
	["CUSTOMIZE_CHARACTER"] = {
		ruRU = "Параметры персонажа:",
		enGB = "Customize character:"
	},
	["CHAR_DELETE_FAILED"] = {
		ruRU = "Ошибка удаления персонажа",
		enGB = "Character deletion failed"
	},
	["AUTH_SUSPENDED"] = {
		ruRU = "Действие данной учетной записи временно приостановлено в связи с нарушением условий Соглашения об условиях пользования – www.wow-europe.com/ru/legal/termsofuse.html. Для получения подробной информации обращайтесь по адресу электронной почты WoWaccountreviewEU@blizzard.com.",
		enGB = "This account has been temporarily suspended for violating the Terms of Use Agreement - www.worldofwarcraft.com/termsofuse.shtml. Please contact our GM department via Email at wowaccountadmin@blizzard.com for more information."
	},
	["ADDON_SECURE"] = {
		ruRU = "Безопасен",
		enGB = "Secure"
	},
	["BLIZZ_DISCLAIMER"] = {
		ruRU = "© Blizzard Entertainment, 2005-2010 гг. Все права защищены.",
		enGB = "Copyright 2004-2010  Blizzard Entertainment. All Rights Reserved."
	},
	["CATEGORY_DESCRIPTION_TEXT"] = {
		ruRU = "Миры разделены на группы по географическому расположению. Чем ближе выбранный мир, тем меньше будут задержки и выше быстродействие.",
		enGB = "A realm category refers to its geographical location. Players should generally choose the realm that is closest to them. This ensures the lowest amount of latency and provides the best possible game experience."
	},
	["QUIT"] = {
		ruRU = "Выход",
		enGB = "Quit"
	},
	["LOGIN_INVALID_CHALLENGE_MESSAGE"] = {
		ruRU = "Ошибка.",
		enGB = "Invalid Challenge"
	},
	["CHAR_FACTION_CHANGE_DELETE_MAIL"] = {
		ruRU = "Перед сменой расы или фракции, пожалуйста, очистите почтовый ящик персонажа.",
		enGB = "Please remove all mail before changing race or faction."
	},
	["NAME"] = {
		ruRU = "Имя",
		enGB = "Name"
	},
	["SECURITYMATRIX_ENTER_CELL"] = {
		ruRU = "Введите значение ячейки (|cFF00FF00%s%s|r) и нажмите «ОК». Чтобы исправить допущенную ошибку, нажмите кнопку «Очистить».",
		enGB = "Enter the cell value |cFF00FF00%s%s|r then select OK. If you make a mistake, select Clear."
	},
	["BF_HONOR_POINTS"] = {
		ruRU = "чст",
		enGB = "hnr"
	},
	["CREATE_CHARACTER"] = {
		ruRU = "Создание персонажа",
		enGB = "Create Character"
	},
	["LOGIN_INCORRECT_PASSWORD"] = {
		ruRU = "Неверный пароль",
		enGB = "Incorrect Password"
	},
	["CHAR_FACTION_CHANGE_FAILED"] = {
		ruRU = "Не удалось сменить расу этого персонажа.",
		enGB = "Could not change race for character."
	},
	["AUTH_SESSION_EXPIRED"] = {
		ruRU = "Сеанс завершен",
		enGB = "Session Expired"
	},
	["EULA_FRAME_TITLE"] = {
		ruRU = "Лицензионное соглашение с конечным пользователем",
		enGB = "End User License Agreement"
	},
	["BILLING_IGR_USAGE"] = {
		ruRU = "Вы используете тарифный план IGR. Ваше личное время не уменьшается.",
		enGB = "You are currently using an IGR usage plan. Your personal time will not be deducted."
	},
	["CHAR_NAME_MIXED_LANGUAGES"] = {
		ruRU = "Имя должно состоять из букв одного языка",
		enGB = "Names must contain only one language"
	},
	["TECH_SUPPORT_URL"] = {
		ruRU = "http://www.wow-europe.com/ru/support/",
		enGB = "http://www.blizzard.com/support/wow/"
	},
	["BF_KILLBLOWS"] = {
		ruRU = "Смертельные удары",
		enGB = "Killing Blows"
	},
	["ADDON_UPDATE_AVAILABLE"] = {
		ruRU = "Доступна новая версия",
		enGB = "New version is available\n"
	},
	["CRIT"] = {
		ruRU = "КРИТ",
		enGB = "CRIT"
	},
	["BILLING_FIXED_IGR"] = {
		ruRU = "Вы используете фиксированный тарифный план IGR. Ваше личное время не учитывается. Срок действия плана истечет через %s.",
		enGB = "You are currently using a fixed IGR plan. Your personal time will not be deducted. The IGR plan will expire in %s."
	},
	["QUEUE_NAME_TIME_LEFT_SECONDS"] = {
		ruRU = "Свободных мест нет: %s\nМесто в очереди: %d\nВремя ожидания – менее минуты.",
		enGB = "%s is Full\nPosition in queue: %d\nEstimated time: < 1 minute"
	},
	["LOGIN_USE_GRUNT"] = {
		ruRU = "Пожалуйста, вводите имя и пароль вашей учетной записи World of Warcraft, а не Battle.net.",
		enGB = "Please use your World of Warcraft account name and password instead of your Battle.net account."
	},
	["TECH_SUPPORT"] = {
		ruRU = "Техническая поддержка",
		enGB = "Tech Support"
	},
	["LOGIN_STATE_AUTHENTICATED"] = {
		ruRU = "Готово!",
		enGB = "Success!"
	},
	["AUTH_UNKNOWN_ACCOUNT"] = {
		ruRU = "Неизвестная учетная запись",
		enGB = "Unknown account"
	},
	["DOWNLOAD_SUCCESSFUL"] = {
		ruRU = "Требуется обновление",
		enGB = "Patch Required"
	},
	["RESPONSE_FAILED_TO_CONNECT"] = {
		ruRU = "Ошибка соединения. Убедитесь, что ваша система подключена к Интернету, а также проверьте параметры настройки безопасности. Подробнее см. на сайте www.wow-europe.com/ru/support/.",
		enGB = "Failed to connect.  Please be sure that your computer is currently connected to the internet, and that no security features on your system might be blocking traffic.  See www.blizzard.com/support/wow/ for more information."
	},
	["RACE_INFO_DRAENEI"] = {
		ruRU = "После бегства с родной планеты, Аргуса, дренеи тысячелетиями скитались по вселенной, спасаясь от Пылающего Легиона, пока, наконец, не нашли пристанище. Свою новую планету они разделили с орками-шаманами и назвали Дренором. Спустя некоторое время Легион поработил души орков и заставил их развязать войну на планете, уничтожив на ней почти всех миролюбивых дренеев. Немногие счастливчики спаслись бегством на Азерот и ищут теперь союзников для борьбы с Пылающим Легионом.",
		enGB = "Driven from their home world of Argus, the honorable draenei fled the Burning Legion for eons before finding a remote planet to settle on. They shared this world with the shamanistic orcs and named it Draenor. In time the Legion corrupted the orcs, who waged war and nearly exterminated the peaceful draenei. A lucky few fled to Azeroth, where they now seek allies in their battle against the Burning Legion."
	},
	["CINEMATICS"] = {
		ruRU = "Видеоролики",
		enGB = "Cinematics"
	},
	["HARDWARE_SURVEY_TITLE"] = {
		ruRU = "Уведомление о сборе данных",
		enGB = "Hardware Survey Notification"
	},
	["AGI"] = {
		ruRU = "ЛВК",
		enGB = "AGI"
	},
	["CHAR_NAME_RESERVED"] = {
		ruRU = "Имя недоступно",
		enGB = "That name is unavailable"
	},
	["SCANDLL_URL_WIN32_SCAN_DLL"] = {
		ruRU = "",
		enGB = ""
	},
	["LOGINBUTTON_COMMUNITY"] = {
		ruRU = "Сайт сервера",
		enGB = "Server website"
	},
	["NEWS"] = {
		ruRU = "Новости",
		enGB = "News"
	},
	["REALM_LOCKED"] = {
		ruRU = "Доступ ограничен",
		enGB = "Locked"
	},
	["TERMINATION_WITHOUT_NOTICE_FRAME_TITLE"] = {
		ruRU = "Прекращение услуги без уведомления",
		enGB = "Termination of Service without Prior Notice"
	},
	["RACE_INFO_DRAENEI_FEMALE"] = {
		ruRU = "После бегства с родной планеты, Аргуса, дренеи тысячелетиями скитались по вселенной, спасаясь от Пылающего Легиона, пока, наконец, не нашли пристанище. Свою новую планету они разделили с орками-шаманами и назвали Дренором. Спустя некоторое время Легион поработил души орков и заставил их развязать войну на планете, уничтожив на ней почти всех миролюбивых дренеев. Немногие счастливчики спаслись бегством на Азерот и ищут теперь союзников для борьбы с Пылающим Легионом.",
		enGB = "Driven from their home world of Argus, the honorable draenei fled the Burning Legion for eons before finding a remote planet to settle on. They shared this world with the shamanistic orcs and named it Draenor. In time the Legion corrupted the orcs, who waged war and nearly exterminated the peaceful draenei. A lucky few fled to Azeroth, where they now seek allies in their battle against the Burning Legion."
	},
	["ABILITY_INFO_TROLL4"] = {
		ruRU = "- С повышенной вероятностью наносит критический удар метательным оружием и луками.",
		enGB = "- Increased critical chance with Throwing Weapons and Bows."
	},
	["CHAR_RENAME_FAILED"] = {
		ruRU = "Ошибка переименования",
		enGB = "Character rename failed"
	},
	["FACTION_INFO_ALLIANCE"] = {
		ruRU = "		   В состав Альянса входят пять рас: благородные люди, неустрашимые дворфы, таинственные ночные эльфы, изобретательные гномы и доблестные дренеи. Всех их объединяет одна цель: изгнание демонов и восстановление справедливости в истерзанном войной мире.",
		enGB = "		The Alliance consists of five races: the noble humans, the adventurous dwarves, the enigmatic night elves, the ingenious gnomes, and the honorable draenei. Bound by a loathing for all things demonic, they fight to restore order in this war-torn world."
	},
	["ROLE_HEALER"] = {
		ruRU = "Целитель",
		enGB = "Healer"
	},
	["SPEED"] = {
		ruRU = "СКР",
		enGB = "SPD"
	},
	["ABILITY_INFO_NIGHTELF1"] = {
		ruRU = "- Умеет прятаться в тенях.",
		enGB = "- May fade into the shadows."
	},
	["WEAPON_SKILL"] = {
		ruRU = "Ор. навык: %d",
		enGB = "W.Skill %d"
	},
	["LOGIN_STATE_CHECKINGVERSIONS"] = {
		ruRU = "Проверка версии",
		enGB = "Validating Version"
	},
	["ACCOUNT_OPTIONS"] = {
		ruRU = "Настройка учетной записи",
		enGB = "Account Options"
	},
	["CHOOSE_REALM_STYLE"] = {
		ruRU = "Выберите тип мира:",
		enGB = "Choose your realm style:"
	},
	["CHAR_DELETE_FAILED_LOCKED_FOR_TRANSFER"] = {
		ruRU = "Вы не можете войти в игру, пока процесс обновления персонажа не будет завершен.",
		enGB = "You cannot log in until the character update process you recently initiated is complete.  "
	},
	["CHOOSE_CLASS"] = {
		ruRU = "Выберите класс:",
		enGB = "Choose your class:"
	},
	["USEFUL_INFORMATION"] = {
		ruRU = "Полезная информация",
		enGB = "Useful information"
	},
	["BILLING_TEXT3"] = {
		ruRU = "Вы используете личный фиксированный тарифный план. Срок действия: %s.",
		enGB = "You are using a personal fixed plan.  Your plan will expire in %s."
	},
	["CHAR_NAME_THREE_CONSECUTIVE"] = {
		ruRU = "Вы не можете использовать один и тот же символ три раза подряд",
		enGB = "You cannot use the same letter three times consecutively"
	},
	["QUEUE_FCM_BUTTON"] = {
		ruRU = "Перенос персонажей",
		enGB = "Character Migration"
	},
	["LATEST_TOS_URL"] = {
		ruRU = "http://launcher.wow-europe.com/ru/tos.htm",
		enGB = "http://launcher.worldofwarcraft.com/legal/tos.htm"
	},
	["CHAR_LOGIN_NO_CHARACTER"] = {
		ruRU = "Персонаж не найден",
		enGB = "Character not found"
	},
	["ABILITY_INFO_BLOODELF1"] = {
		ruRU = "- Имеет способности к наложению чар.",
		enGB = "- Enchanting skill increased."
	},
	["CONTEST_FRAME_TITLE"] = {
		ruRU = "Правила состязания",
		enGB = "Contest Rules"
	},
	["CHARACTER_SELECT_FIX_CHARACTER_BUTTON"] = {
		ruRU = "Исправление персонажа",
		enGB = "Fix Character"
	},
	["CHARACTER_SELECT_FIX_CHARACTER_TITLE"] = {
		ruRU = "Исправление",
		enGB = "Fix Character"
	},
	["ABILITY_INFO_TROLL1"] = {
		ruRU = "- Может впадать в состояние берсерка, в котором скорость боя и произнесения заклинаний повышается.",
		enGB = "- Berserk, increasing attack and casting speed."
	},
	["RACE_INFO_TROLL_FEMALE"] = {
		ruRU = "Тролли Черного Копья некогда считали своим домом Тернистую долину, но были вытеснены оттуда враждующими племенами. Это окончательно сплотило между собой орочью Орду и троллей. Тралл, молодой вождь орков, убедил троллей примкнуть к его походу на Калимдор. Хотя тролли и не смогли окончательно отказаться от своего мрачного наследия, в Орде их уважают и почитают.",
		enGB = "Once at home in the jungles of Stranglethorn Vale, the fierce trolls of the Darkspear tribe were pushed out by warring factions. Eventually the trolls befriended the orcish Horde, and Thrall, the orcs' young warchief, convinced the trolls to travel with him to Kalimdor. Though they cling to their shadowy heritage, the Darkspear trolls hold a place of honor in the Horde."
	},
	["ABILITY_INFO_DRAENEI3"] = {
		ruRU = "- Особая аура дренея повышает меткость оружия и заклинаний участников группы.",
		enGB = "- Party members' chance to hit with melee and spells increased."
	},
	["STREAMING_BUILD"] = {
		ruRU = "Потоковый",
		enGB = "Streaming"
	},
	["ABILITY_INFO_SCOURGE4"] = {
		ruRU = "- Повышенное сопротивление темной магии.",
		enGB = "- Resistant to Shadow damage."
	},
	["RETURN_TO_LOGIN"] = {
		ruRU = "На экран входа",
		enGB = "Return to Login"
	},
	["CHAR_FACTION_CHANGE_RACE_ONLY"] = {
		ruRU = "Вы должны выбрать одну из рас вашей стороны (Альянса или Орды).",
		enGB = "You must choose a new race from your current faction."
	},
	["LOGIN_NO_GAME_ACCOUNT"] = {
		ruRU = "Не удалось войти в игру с данной учетной записью.|nВозможно, к вашей учетной записи Battle.net не прикреплена ни одна учетная запись World of Warcraft или же вы пытаетесь авторизоваться в регионе, в котором у вас нет прикрепленных учетных записей. Если проблема не исчезнет, обратитесь, пожалуйста, в службу поддержки пользователей.",
		enGB = "There was a problem logging in with this account.|nYou may not have a World of Warcraft game attached to your account, or you may be logging into a region different from the one you created the account in. If you continue having trouble, please contact Customer Support."
	},
	["TOTAL"] = {
		ruRU = "Всего",
		enGB = "Total"
	},
	["CHAR_LOGIN_SUCCESS"] = {
		ruRU = "Вход выполнен",
		enGB = "Login successful"
	},
	["AVAILABLE"] = {
		ruRU = "Доступен",
		enGB = "Available"
	},
	["AUTH_REJECT"] = {
		ruRU = "Ошибка входа в игру. Обратитесь в службу технической поддержки по адресу WoWtechEU@blizzard.com.",
		enGB = "Login unavailable - Please contact Technical Support at WoWTech@Blizzard.com"
	},
	["CHARACTER_BOOST_NEXT"] = {
		ruRU = "Далее",
		enGB = "Next"
	},
	["REALM_LIST_FAILED"] = {
		ruRU = "Невозможно подключиться к серверу",
		enGB = "Unable to connect to realm list server"
	},
	["CHARACTER_SELECT_INFO"] = {
		ruRU = "%s",
		enGB = "%s"
	},
	["CHAR_LOGIN_DISABLED"] = {
		ruRU = "Доступ для данной расы, класса или персонажа в данный момент запрещен.",
		enGB = "Login for that race, class, or character is currently disabled."
	},
	["HARDWARE_SURVEY_AGREE"] = {
		ruRU = "Разрешаю",
		enGB = "I consent"
	},
	["CHARACTER_FIX_STATUS_1"] = {
		ruRU = "Персонаж будет автоматически исправлен при следующем входе в игру.",
		enGB = "The character will be fixed automatically upon the next log on."
	},
	["LOGIN_EMAIL_ERROR"] = {
		ruRU = "Нужно вводить логин, а не E-mail!",
		enGB = "Enter your login, not your e-mail!"
	},
	["CHAR_NAME_PROFANE"] = {
		ruRU = "Имя содержит ненормативную лексику",
		enGB = "That name contains mature language"
	},
	["CHAR_NAME_DECLENSION_DOESNT_MATCH_BASE_NAME"] = {
		ruRU = "В падежах может меняться только окончание слова. Пожалуйста, исправьте падежи.",
		enGB = "Your declensions must match your original name."
	},
	["CHOOSE_VOTE_TOP"] = {
		ruRU = "Выберите топ",
		enGB = "Vote for the top player"
	},
	["CHARACTER_FIX_HELP_HEAD"] = {
		ruRU = "При использовании этой функции",
		enGB = "When this function is used"
	},
	["FACTION_LABEL"] = {
		ruRU = "Фракция:",
		enGB = "Faction:"
	},
	["LOGIN_NO_GAME_ACCOUNTS_IN_REGION_NONE"] = {
		ruRU = "<html><body><p align=\"CENTER\">У вас нет игровых учетных записей в этом регионе.</p></body></html>",
		enGB = "<html><body><p align=\"CENTER\">You have no game accounts in this region.</p></body></html>"
	},
	["LOGIN_UNKNOWN_ACCOUNT"] = {
		ruRU = "<html><body><p align=\"CENTER\">Вы указали неверные сведения. Для восстановления забытого пароля посетите страницу <a href=\"https://sirus.su/user/password/reset\">https://sirus.su/user/password/reset</a>.</p></body></html>",
		enGB = "<html><body><p align=\"CENTER\">The information you have entered is not valid.  Please check the spelling of the account name and password.  If you need help in retrieving a lost or stolen password and account, see <a href=\"http://www.worldofwarcraft.com/loginsupport\">www.worldofwarcraft.com/loginsupport</a> for more information.</p></body></html>"
	},
	["PROFESSION_LABEL"] = {
		ruRU = "Профессии:",
		enGB = "Professions:"
	},
	["ABILITY_INFO_ORC1"] = {
		ruRU = "- Может впадать в ярость, чтобы наносить повышенный урон.",
		enGB = "- May enrage to increase damage."
	},
	["CHARACTER_CREATE"] = {
		ruRU = "Создать",
		enGB = "Create"
	},
	["RACE_INFO_BLOODELF"] = {
		ruRU = "Много лет назад высшие эльфы-изгнанники основали поселение Кель'Талас, в котором создали магический источник, названный Солнечным Колодцем. Чем больше сил черпали из него эльфы, тем сильнее начинали от него зависеть.|n|nСпустя века Армия Плети разрушила Солнечный Колодец и убила большинство эльфов. Изгнанники назвали себя эльфами крови и стремятся восстановить Кель'Талас, а также найти новый источник волшебной силы, чтобы удовлетворить свое пагубное пристрастие.",
		enGB = "Long ago the exiled high elves founded Quel'Thalas, where they created a magical fount called the Sunwell. Though they were strengthened by its powers, they also grew increasingly dependent on them.|n|nAges later the undead Scourge destroyed the Sunwell and most of the high elf population. Now called blood elves, these scattered refugees are rebuilding Quel'Thalas as they search for a new magic source to satisfy their painful addiction."
	},
	["RESPONSE_SUCCESS"] = {
		ruRU = "Готово",
		enGB = "Success"
	},
	["ADDON_INVALID_VERSION_DIALOG"] = {
		ruRU = "|cffFF0000Мы обнаружили одну или несколько модификаций, несовместимых с нашей версией игры, и отключили их.|r\n\n|cffFFFFFFОткройте окно \"Модификаций\" чтобы просмотреть информацию об обновлении.|r",
		enGB = "|cffFF0000We have found one or several addons incompatible with our game version and have disabled them.|r\n\n|cffFFFFFFOpen the AddOns window to view information on available updates.|r"
	},
	["CHOOSE_ALL_PROFESSION"] = {
		ruRU = "Выберите обе профессии",
		enGB = "Select both professions"
	},
	["CHARACTER_BOOST_CHARACTER_NAME"] = {
		ruRU = "|c%s%s|r",
		enGB = "|c%s%s|r"
	},
	["CHARACTER_BOOST_CHARACTER_INFO"] = {
		ruRU = "Уровень %i |c%s%s|r",
		enGB = "Level %i |c%s%s|r"
	},
	["FACTION_CHANGE_IN_PROGRESS"] = {
		ruRU = "Обновление фракции…",
		enGB = "Updating Faction..."
	},
	["LOGIN_LOCKED_ENFORCED"] = {
		ruRU = "Вы подали заявку на блокировку своей учетной записи. Для изменения статуса блокировки позвоните по соответствующему телефонному номеру.",
		enGB = "You have applied a lock to your account. You can change your locked status by calling your account lock phone number."
	},
	["REALMLIST_NUMCHARACTERS_TOOLTIP"] = {
		ruRU = "Количество персонажей,\nсозданных в этом мире.",
		enGB = "The number of characters\nyou have created on this realm."
	},
	["VERSION_TEMPLATE"] = {
		ruRU = "%s %s (%s) (%s)\n%s",
		enGB = "%s %s (%s) (%s)\n%s"
	},
	["LOGIN_STATE_INITIALIZED"] = {
		ruRU = "Инициализация",
		enGB = "Initialized"
	},
	["NOT_ENOUGH_BONUSES_TO_BUY_A_CHARACTER_BOOST"] = {
		ruRU = "Недостаточно бонусов для покупки быстрого старта.",
		enGB = "Insufficient bonuses to purchase Character Boost."
	},
	["CHARACTER_FIX_STATUS_3"] = {
		ruRU = "Неверные параметры.",
		enGB = "Invalid parameters."
	},
	["TOS_NOTICE"] = {
		ruRU = "Некоторые пункты Соглашения об условиях пользования были изменены. Просмотрите весь текст Соглашения прежде, чем принимать его условия.",
		enGB = "The Terms of Use have changed. Please scroll down and review the changes before accepting the agreement."
	},
	["CHARACTER_UNDELETE"] = {
		ruRU = "Восстановить удаленного персонажа",
		enGB = "Restore deleted character"
	},
	["CHARACTER_FIX_STATUS_2"] = {
		ruRU = "Персонаж не найден.",
		enGB = "Character not found."
	},
	["GAMETYPE_PVE"] = {
		ruRU = "Обычный",
		enGB = "Normal"
	},
	["WARRIOR_DISABLED"] = {
		ruRU = "Воин\nЭтот класс доступен другим расам.",
		enGB = "Warrior\nYou must choose a different race to be this class."
	},
	["RANDOM"] = {
		ruRU = "Случайно",
		enGB = "Random"
	},
	["ENTER_CHARACTER_NAME"] = {
		ruRU = "Введите имя персонажа:",
		enGB = "Enter a name for your character:"
	},
	["ARM"] = {
		ruRU = "БРН",
		enGB = "ARM"
	},
	["ABILITY_INFO_NIGHTELF2"] = {
		ruRU = "- Лучше других уклоняется от вражеских ударов.",
		enGB = "- More difficult to hit."
	},
	["AUTH_ALREADY_LOGGING_IN"] = {
		ruRU = "Вход в систему...",
		enGB = "Already Logging In"
	},
	["PATCH_FAILED_DISK_FULL"] = {
		ruRU = "Невозможно загрузить обновление – недостаточно свободного пространства на диске. Освободите как минимум %d Мб и повторите попытку. Внимание: для запуска обновления понадобится дополнительное свободное пространство.",
		enGB = "There is not enough disk space available to download the patch.  Please make %d megabytes available and then try again.  Please note that additional space will be required to apply the patch."
	},
	["DECLENSION_NAME_RESERVED"] = {
		ruRU = "Имя недоступно\n(возможно в результате склонения имени получилось запрещенное слово, попробуйте разные варианты)",
		enGB = "That name is unavailable\n(you may have entered a forbidden word, please try a different name)"
	},
	["CHOOSE_FACTION"] = {
		ruRU = "Выберите фракцию",
		enGB = "Choose your faction"
	},
	["PANDAREN"] = {
		ruRU = "Пандарен",
		enGB = "Pandaren"
	},
	["VULPERA"] = {
		ruRU = "Вульпера",
		enGB = "Vulpera"
	},
	["SERVER_VOTE"] = {
		ruRU = "Проголосовать",
		enGB = "Vote"
	},
	["CHARACTER_SELECT_FIX_CHARACTER_DESC"] = {
		ruRU = "Если у Вас возникли проблемы с этим персонажем, Вы можете воспользоваться автоматическим исправлением. Персонаж будет воскрешен и перемещён в домашнюю локацию.",
		enGB = "If you encounter any problems with this character, you can use the automatic fix option. The character will be resurrected and teleported to the home location."
	},
	["CHARACTER_SELECT_FIX_CHARACTER_NOTE"] = {
		ruRU = "Внимание! Эффект \"Слабость после воскрешения\" будет получен в любом случае.",
		enGB = "Please note that Resurrection Sickness will be applied in any case."
	},
	["STEP"] = {
		ruRU = "Этап",
		enGB = "Stage"
	},
	["ADDON_INVALID_VERSION_OKAY_HIDE"] = {
		ruRU = "Скрыть",
		enGB = "Hide"
	},
	["CONFIRM_LAUNCH_UPLOAD_ADDON_URL"] = {
		ruRU = "<html><body><p align=\"CENTER\">Нажмите на ссылку или кнопку \"ОК\", чтобы перейти на страницу загрузки обновленной версии.</p><p align=\"CENTER\"><a href=\"%s\">%s</a></p></body></html>",
		enGB = "<html><body><p align=\"\"CENTER\"\">Follow the link or click OK to go to the download page of the updated version.</p><p align=\"\"CENTER\"\"><a href=\"\"%s\"\">%s</a></p></body></html>"
	},
	["ADDON_CLICK_TO_OPEN_UPDATE_PAGE"] = {
		ruRU = "Нажмите для загрузки актуальной версии данной модификации.",
		enGB = "Click to download an updated version of this addon."
	},
	["ADDON_INVALID_VERSION"] = {
		ruRU = "Некоторые ваши модификации имеют несовместимую с нашим клиентом версию.\nНажмите на кнопку \"Модификации\", чтобы просмотреть полный список и обновить их.",
		enGB = "Some of your addons are incompatible with our client.\nTo view a full list of your addons and update them, click AddOns."
	},
	["ADDON_INVALID_VERSION_TITLE"] = {
		ruRU = "Ваши модификации устарели.",
		enGB = "Your addons are outdated."
	},
	["CHARACTER_DELETE_RESTORE_ERROR_6"] = {
		ruRU = "Данная операция не доступна для вашего аккаунта.",
		enGB = "This operation is not available on your account."
	},
	["DURABILITY"] = {
		ruRU = "ПРОЧ %d",
		enGB = "DURA %d"
	},
	["WARLOCK_DISABLED"] = {
		ruRU = "Чернокнижник\nЭтот класс доступен другим расам.",
		enGB = "Warlock\nYou must choose a different race to be this class."
	},
	["CHARACTER_SERVICES_BUY_BOOST_RESULT"] = {
		ruRU = "Функция быстрого старта успешно куплена. С вашего аккаунта были списаны бонусы.",
		enGB = "The Character Boost function has been successfully purchased. Bonuses were written off from your account."
	},
	["REGEN"] = {
		ruRU = "ВОССТ %.0f",
		enGB = "REGEN %.0f"
	},
	["CHARACTER_SERVICES_VIP_GIFT"] = {
		ruRU = "VIP подарок",
		enGB = "VIP gift"
	},
	["CHARACTER_SERVICES_DISCOUNT"] = {
		ruRU = "Скидка %d%%",
		enGB = "Discount %d%%"
	},
	["PTR_AE_BUILD"] = {
		ruRU = "Тестовый игровой мир - режим проверки готовности",
		enGB = "PTR - Assertions Enabled"
	},
	["REPLENISH"] = {
		ruRU = "Пополнить",
		enGB = "Replenish"
	},
	["CSTATUS_AUTHENTICATING"] = {
		ruRU = "Авторизация",
		enGB = "Authenticating"
	},
	["AUTH_INCORRECT_PASSWORD"] = {
		ruRU = "Неверный пароль",
		enGB = "Incorrect Password"
	},
	["LOGIN_BANNED"] = {
		ruRU = "<html><body><p align=\"CENTER\">Данный аккаунт заблокирован. Более подробную информацию вы найдете в Личном Кабинете на сайте: <a href=\"http://sirus.su\">http://sirus.su</a>.</p></body></html>",
		enGB = ""
	},
	["TOS_ACCEPT"] = {
		ruRU = "Принять",
		enGB = "Accept"
	},
	["RACE_INFO_SCOURGE_FEMALE"] = {
		ruRU = "Отрекшиеся, не попавшие под власть Короля-лича, ищут способ положить конец его правлению. Под предводительством банши Сильваны они сражаются против Армии Плети. Их врагами стали и люди, неустанно стремящиеся стереть с лица земли любую нежить. Отверженные не хранят верность союзам и даже Орду считают всего лишь инструментом воплощения своих темных замыслов.",
		enGB = "Free of the Lich King's grasp, the Forsaken seek to overthrow his rule. Led by the banshee Sylvanas, they hunger for vengeance against the Scourge. Humans, too, have become the enemy, relentless in their drive to purge all undead from the land. The Forsaken care little even for their allies; to them the Horde is merely a tool that may further their dark schemes."
	},
	["REALM_IS_FULL_WARNING"] = {
		ruRU = "Вы выбрали сервер, на котором не осталось свободных мест. Это может привести к задержке в подключении. Крайне рекомендуется указать менее заселенный сервер.\n\nВы действительно хотите выбрать данный сервер?",
		enGB = "You have selected a full server which can result in a wait to play. You should consider selecting a server with a low population.\n\nDo you really want to select this server?"
	},
	["ABILITY_INFO_SCOURGE2"] = {
		ruRU = "- Может поедать трупы для восполнения здоровья.",
		enGB = "- May consume corpses to regain health."
	},
	["CHAR_RENAME_DESCRIPTION"] = {
		ruRU = "Вам нужно сменить имя",
		enGB = "Your name has been flagged for rename"
	},
	["CHAR_LOGIN_DUPLICATE_CHARACTER"] = {
		ruRU = "Персонаж с таким именем уже существует",
		enGB = "A character with that name already exists"
	},
	["SERVER_SPLIT_NOT_NOW"] = {
		ruRU = "Решить позже",
		enGB = "Decide Later"
	},
	["ROGUE_DISABLED"] = {
		ruRU = "Разбойник\nЭтот класс доступен другим расам.",
		enGB = "Rogue\nYou must choose a different race to be this class."
	},
	["CREDITS_WOW_LK"] = {
		ruRU = "Создатели Wrath of the Lich King",
		enGB = "Wrath of the Lich King Credits"
	},
	["RPPVP_PARENTHESES"] = {
		ruRU = "(RPPvP)",
		enGB = "(RPPVP)"
	},
	["CSTATUS_NEGOTIATING_SECURITY"] = {
		ruRU = "Проверка безопасности",
		enGB = "Negotiating security"
	},
	["CSTATUS_CONNECTING"] = {
		ruRU = "Соединение...",
		enGB = "Connecting to server..."
	},
	["SERVER_ALERT_BUTTON_TEXT"] = {
		ruRU = "Подробнее",
		enGB = "More Info"
	},
	["LOGIN_UNLOCKABLE_LOCK"] = {
		ruRU = "Данная учетная запись была заблокирована, но может быть разблокирована.",
		enGB = "This account has been locked but can be unlocked."
	},
	["LOGIN_ALREADYONLINE"] = {
		ruRU = "Указанная учетная запись уже в игре. Проверьте правильность написания и повторите попытку.",
		enGB = "This account is already logged into World of Warcraft.  Please check the spelling and try again."
	},
	["ALLIANCE"] = {
		ruRU = "Альянс",
		enGB = "Alliance"
	},
	["SCANDLL_MESSAGE_SCANNING"] = {
		ruRU = "Поиск вирусов",
		enGB = "[TEMPORARY] Scanning for Trojans"
	},
	["SCANDLL_BUTTON_MOREINFO"] = {
		ruRU = "Подробнее",
		enGB = "More Info"
	},
	["BILLING_TEXT4"] = {
		ruRU = "Вы начали использовать личное игровое время. На данный момент его запас составляет %d мин. За 30 минут до окончания личного времени на экране отобразится соответствующее предупреждение.",
		enGB = "You are now using your personal time to play this account.  You currently have %d minutes left on the current subscription.  You will be notified 30 minutes before you will run out of time."
	},
	["LOGIN_SERVER_DOWN"] = {
		ruRU = "Сервер входа недоступен",
		enGB = "Login Server Down"
	},
	["CHAR_CREATE_CHARACTER_IN_GUILD"] = {
		ruRU = "Не удалось сменить франкцию: персонаж является членом гильдии.",
		enGB = "Faction change failed, character in guild."
	},
	["REALM_LOAD"] = {
		ruRU = "Заселенность",
		enGB = "Population"
	},
	["DOWNLOAD_SUCCESSFUL_TEXT"] = {
		ruRU = "Нажмите «Перезапуск», чтобы выйти\nиз игры и загрузить обновление.",
		enGB = "Press the restart button below to exit World of\nWarcraft and download the patch."
	},
	["LOGINBOX_LOGIN"] = {
		ruRU = "Логин",
		enGB = "Login"
	},
	["LOGINBOX_PASSWORD"] = {
		ruRU = "Пароль",
		enGB = "Password"
	},
	["CHAR_CREATE_INVALID_NAME"] = {
		ruRU = "Недопустимое имя персонажа",
		enGB = "Invalid character name"
	},
	["RANDOMIZE"] = {
		ruRU = "Случайный выбор",
		enGB = "Randomize"
	},
	["ABILITY_INFO_DRAENEI2"] = {
		ruRU = "- Может накладывать заклинание постепенного лечения на себя или других персонажей.",
		enGB = "- May heal self or others over time."
	},
	["ABILITY_INFO_TAUREN1"] = {
		ruRU = "- Может оглушать противников, находящихся поблизости.",
		enGB = "- May stomp, stunning nearby opponents."
	},
	["DMG"] = {
		ruRU = "УРН",
		enGB = "DMG"
	},
	["ABILITY_INFO_GNOME1"] = {
		ruRU = "- Умеет избегать снижающие скорость эффекты.",
		enGB = "- May escape from speed altering effects."
	},
	["QUEUE_TIME_LEFT_SECONDS"] = {
		ruRU = "Свободных мест нет\nМесто в очереди: %d\nВремя ожидания – менее 1 мин.",
		enGB = "Realm is Full\nPosition in queue: %d\nEstimated time: < 1 minute"
	},
	["ABILITY_INFO_TAUREN2"] = {
		ruRU = "- Увеличенный запас здоровья.",
		enGB = "- Maximum health increased."
	},
	["ABILITY_INFO_DWARF4"] = {
		ruRU = "- Умеет обнаруживать сокровища.",
		enGB = "- Treasure finding."
	},
	["ABILITY_INFO_HUMAN5"] = {
		ruRU = "- Может избавляться от ловушек и изменяющих скорость передвижения эффектов.",
		enGB = "- Can break out of speed altering and trapping effects."
	},
	["LOGIN_SRP_ERROR"] = {
		ruRU = "Ошибка авторизации",
		enGB = "Authentication Error"
	},
	["ABILITY_INFO_HUMAN2"] = {
		ruRU = "- Повышенная характеристика «дух».",
		enGB = "- Increased Spirit."
	},
	["ENTER_AUTHCODE_INFO"] = {
		ruRU = "Введите код брелка безопасности",
		enGB = "Enter the generated digital code."
	},
	["SOUL_SHARD"] = {
		ruRU = "ОСКОЛ %d",
		enGB = "SHRDS %d"
	},
	["CLIENT_CONVERTED_TEXT"] = {
		ruRU = "Спасибо за покупку World of Warcraft. Пожалуйста, нажмите на кнопку перезапуска, чтобы начать загрузку полной версии World of Warcraft.",
		enGB = "Thank you for buying World of Warcraft.  Please click the restart button to begin downloading the full version of World of Warcraft."
	},
	["LOGIN_FAILED"] = {
		ruRU = "<html><body><p align=\"CENTER\">Ошибка подключения. Пожалуйста, попробуйте подключиться позднее. Если вы постоянно получаете это сообщение, то свяжитесь со службой технической поддержки. Более подробно в <a href=\"https://forum.sirus.su/threads/2347/\">теме</a>.</p></body></html>",
		enGB = ""
	},
	["GAME_SERVER_LOGIN"] = {
		ruRU = "Вход на игровой сервер",
		enGB = "Logging in to game server"
	},
	["AUTH_DB_BUSY_URL"] = {
		ruRU = "http://www.wow-europe.com/ru/serverstatus",
		enGB = "http://www.worldofwarcraft.com/serverstatus"
	},
	["VIEW_ALL_REALMS"] = {
		ruRU = "Список миров",
		enGB = "View Realm List"
	},
	["CHAR_NAME_INVALID_CHARACTER"] = {
		ruRU = "Имя может содержать буквы только одного алфавита: русского или английского",
		enGB = "Names can only contain letters"
	},
	["LOGIN_ANTI_INDULGENCE"] = {
		ruRU = "Ваша учетная запись заблокирована с помощью средств ограничения доступа.",
		enGB = "Your game account is locked by anti-indulgence controls."
	},
	["ABILITY_INFO_TAUREN4"] = {
		ruRU = "- Повышенное сопротивление природной магии.",
		enGB = "- Resistant to Nature damage."
	},
	["CONFIRM_LAUNCH_ADDON_URL"] = {
		ruRU = "Если вы нажмете «ОК», вы выйдете из игры и в окне браузера откроется сайт:\n|cffFFFFFF[%s]|r",
		enGB = "Clicking \"Okay\" will take you out of the game and open the following link in a web browser:\n|cffFFFFFF[%s]|r"
	},
	["SECONDARY_PROFESSION"] = {
		ruRU = "Вспомогательная",
		enGB = "Secondary"
	},
	["RACE_CLASS_ERROR"] = {
		ruRU = "Недопустимое сочетание расы и класса. Пожалуйста, выберите подходящую расу для данного класса.",
		enGB = "Unacceptable race and class combination. Please select a suitable race for this class."
	},
	["LOGIN_STATE_HANDSHAKING"] = {
		ruRU = "Подтверждение связи",
		enGB = "Handshaking"
	},
	["MENU_SWITCH_TO_FULLSCREEN"] = {
		ruRU = "Полноэкранный режим",
		enGB = "Switch to Full Screen Mode"
	},
	["CHAR_CREATE_ACCOUNT_LIMIT"] = {
		ruRU = "Вы достигли максимального числа персонажей для данной учетной записи.",
		enGB = "You already have the maximum number of characters allowed on this account."
	},
	["CHAR_FACTION_CHANGE_STILL_IN_ARENA"] = {
		ruRU = "Нельзя сменить расу или фракцию, пока вы состоите в команде арены.",
		enGB = "You may not change race or faction while still a member of an arena team."
	},
	["RACE_INFO_DWARF"] = {
		ruRU = "В древние времена дворфов интересовали лишь богатства, которые они добывали из недр земли. Однажды во время раскопок они обнаружили следы древней расы богоподобных существ, которая создала дворфов и наделила их некими могущественными правами. Дворфы возжелали узнать больше и посвятили себя поиску древних сокровищ и знаний. Сегодня дворфов-археологов можно встретить в любом уголке Азерота.",
		enGB = "In ages past, the dwarves cared only for riches taken from the earth's depths. Then records surfaced of a god-like race said to have given the dwarves life... and an enchanted birthright. Driven to learn more, the dwarves devoted themselves to the pursuit of lost artifacts and ancient knowledge. Today dwarven archaeologists are scattered throughout the globe."
	},
	["LOGIN_CHARGEBACK"] = {
		ruRU = "<html><body><p align=\"CENTER\">Эта учетная запись World of Warcraft была временно приостановлена из-за возврата оплаты подписки. Более подробная информация находится по адресу<a href=\"http://eu.blizzard.com/support/article.xml?articleId=37442\">http://eu.blizzard.com/support/article.xml?articleId=37442</a>.</p></body></html>",
		enGB = "<html><body><p align=\"CENTER\">This World of Warcraft account has been temporary closed due to a chargeback on its subscription.  Please refer to this <a href=\"http://us.blizzard.com/support/article/chargeback\">http://us.blizzard.com/support/article/chargeback</a> for further information.</p></body></html>"
	},
	["LOGIN_TOO_FAST"] = {
		ruRU = "Слишком много попыток подключиться к серверу. Попробуйте еще раз через несколько минут.",
		enGB = "You have too many login attempts. Please try again in a few minutes."
	},
	["CHOOSE_RACE"] = {
		ruRU = "Выберите расу:",
		enGB = "Choose your race:"
	},
	["GAMETYPE_RPPVP"] = {
		ruRU = "Ролевая игра, PvP |cffff0000(RPPvP)|r",
		enGB = "Roleplaying PVP |cffff0000(RPPVP)|r"
	},
	["CHAR_DELETE_IN_PROGRESS"] = {
		ruRU = "Удаление персонажа",
		enGB = "Deleting character"
	},
	["LOGINBOX_ENTER"] = {
		ruRU = "Войти",
		enGB = "Sign In"
	},
	["BF_DEATHS"] = {
		ruRU = "Смерти",
		enGB = "Deaths"
	},
	["LOGIN"] = {
		ruRU = "Вход",
		enGB = "Login"
	},
	["CHAR_NAME_INVALID_APOSTROPHE"] = {
		ruRU = "Имя не должно начинаться с апострофа или заканчиваться им",
		enGB = "You cannot use an apostrophe as the first or last character of your name"
	},
	["LOGIN_GAME_ACCOUNT_LOCKED"] = {
		ruRU = "<html><body><p align=\"CENTER\">Доступ к вашей учетной записи временно заблокирован. Пожалуйста, свяжитесь со службой поддержки по адресу: <a href=\"https://www.wow-europe.com/account/account-error.html\">https://www.wow-europe.com/account/account-error.html</a></p></body></html>",
		enGB = "<html><body><p align=\"CENTER\">Access to your account has been temporarily disabled. Please contact support for more information at: <a href=\"https://www.worldofwarcraft.com/account/account-error.html\">https://www.worldofwarcraft.com/account/account-error.html</a></p></body></html>"
	},
	["BILLING_TEXT2"] = {
		ruRU = "Вы пользуетесь пробной учетной записью. В этом случае плата за игру не взимается.",
		enGB = "You are currently in your free trial period and will not be charged."
	},
	["CHARACTER_SERVICES_BALANCE_LABEL"] = {
		ruRU = "У вас",
	},
	["CHARACTER_SERVICES_PRICE_LABEL"] = {
		ruRU = "Цена",
		enGB = "Price"
	},
	["CHARACTER_SERVICES_BUYCOST"] = {
		ruRU = "Цена: %s",
		enGB = "Price: %s"
	},
	["SERVER_ALERT_PTR_URL"] = {
		ruRU = "",
		enGB = ""
	},
	["LAUNCH_VIDEO_CARD_UNSUPPORTED"] = {
		ruRU = "Игра несовместима с вашей видеокартой.",
		enGB = "World of Warcraft cannot run on your video card."
	},
	["BONUS_HEALING"] = {
		ruRU = "Д.ЛЕЧ %d",
		enGB = "B.HEAL %d"
	},
	["BILLING_TIME_LEFT_LAST_DAY"] = {
		ruRU = "У вас осталось менее 1 дня оплаченного игрового времени.",
		enGB = "Your play time will expire in less than 1 day."
	},
	["AUTH_BILLING_EXPIRED"] = {
		ruRU = "Срок оплаты истек",
		enGB = "Account billing has expired"
	},
	["AUTH_LOCALE_MISMATCH"] = {
		ruRU = "Неверный язык клиента",
		enGB = "Wrong client language"
	},
	["LAUNCH_USE_SOFTWARE_UPDATE"] = {
		ruRU = "Обновите операционную систему с помощью средств обновления, доступных в меню настройки системы.",
		enGB = "Please use Software Update in System Preferences to upgrade your system software."
	},
	["BILLING_TIME_LEFT_30_MINS"] = {
		ruRU = "У вас осталось менее 30 минут оплаченного игрового времени. Рекомендуется перейти в соответствующий раздел и оплатить дополнительное время.",
		enGB = "You currently have 30 minutes or less left on your account.  If you have not already done so, please go to the billing pages and purchase more time."
	},
	["CHARACTER_SERVICES_BUY"] = {
		ruRU = "Купить",
		enGB = "Buy"
	},
	["CHARACTER_SERVICES_USE"] = {
		ruRU = "Использовать",
		enGB = ""
	},
	["LOGINBUTTON_ACCOUNTCREATE"] = {
		ruRU = "Создать аккаунт",
		enGB = "Create Account"
	},
	["RACE_INFO_HUMAN"] = {
		ruRU = "Люди – молодая раса, а потому их способности разносторонни. Искусство боя, ремесло и магия доступны им в равной степени. Жизнелюбие и уверенность в своих силах позволили людям создать могучие королевства. В эпоху, когда войны длятся веками, люди стремятся возродить былую славу и заложить основу для будущих блистательных побед.",
		enGB = "Humans are a young race, and thus highly versatile, mastering the arts of combat, craftsmanship, and magic with stunning efficiency. The humans’ valor and optimism have led them to build some of the world’s greatest kingdoms. In this troubled era, after generations of conflict, humanity seeks to rekindle its former glory and forge a shining new future."
	},
	["ABILITY_INFO_DWARF1"] = {
		ruRU = "- Умеет превращаться в камень.",
		enGB = "- May take on a stone form."
	},
	["CHAR_NAME_MULTIPLE_APOSTROPHES"] = {
		ruRU = "Вы можете использовать только один апостроф",
		enGB = "You can only have one apostrophe"
	},
	["FEMALE"] = {
		ruRU = "Женщина",
		enGB = "Female"
	},
	["HIT"] = {
		ruRU = "МЕТ",
		enGB = "HIT"
	},
	["CLICK_TO_LAUNCH_ADDON_URL"] = {
		ruRU = "Перейти на сайт модификаций\n",
		enGB = "Click to launch addon website\n"
	},
	["HUNTER_DISABLED"] = {
		ruRU = "Охотник\nЭтот класс доступен другим расам.",
		enGB = "Hunter\nYou must choose a different race to be this class."
	},
	["AUTH_VERSION_MISMATCH"] = {
		ruRU = "Неверная версия клиента",
		enGB = "Wrong client version"
	},
	["IDLE_LOGOUT_WARNING"] = {
		ruRU = "Сеанс игры скоро завершится.",
		enGB = "You will be logged out soon"
	},
	["LATEST_EULA_URL"] = {
		ruRU = "http://launcher.wow-europe.com/ru/eula.htm",
		enGB = "http://launcher.worldofwarcraft.com/legal/eula.htm"
	},
	["CHAR_LOGIN_LOCKED_BY_BILLING"] = {
		ruRU = "Персонаж заблокирован. Обратитесь в службу поддержки.",
		enGB = "Character locked. Contact Technical Support for more information."
	},
	["GAMETYPE_PVP_TEXT"] = {
		ruRU = "В мирах данного типа акцент смещен на бои между игроками. Помните: покинув исходную позицию или город, вы всегда рискуете подвергнуться нападению со стороны другого игрока.",
		enGB = "These realms allow you to focus on player combat; you are always at risk of being attacked by opposing players except in starting areas and cities."
	},
	["PATCH_FAILED_MESSAGE"] = {
		ruRU = "Ошибка инициализации обновления. Повторите попытку позднее. Если проблема не разрешится, попробуйте переустановить его или обратиться в службу технической поддержки.",
		enGB = "Failed to apply patch. Please try again later.  If this problem persists you may need to reinstall or contact technical support."
	},
	["ENTER_WORLD"] = {
		ruRU = "Вход в игровой мир",
		enGB = "Enter World"
	},
	["PTR_RELEASE_BUILD"] = {
		ruRU = "Тестовый игровой мир - релиз",
		enGB = "PTR - Release"
	},
	["SCANDLL_MESSAGE_ERROR"] = {
		ruRU = "[TEMPORARY] |cFFFF0000Ошибка программыBlizzard Scan|r\n\nNEED WORDING",
		enGB = "[TEMPORARY] |cFFFF0000Blizzard Scan failed to complete|r\n\nNEED WORDING"
	},
	["AVAILABLE_CLASSES"] = {
		ruRU = "Доступные классы",
		enGB = "Available Classes"
	},
	["CHAR_FACTION_CHANGE_RACECLASS_RESTRICTED"] = {
		ruRU = "Такое сочетание расы и класса невозможно.",
		enGB = "This race and class combination is restricted from the race change service."
	},
	["LOGIN_BAD_SERVER_PROOF"] = {
		ruRU = "<html><body><p align=\"CENTER\">Вы пытаетесь подключиться к некорректному серверу. Если вам потребуется помощь, пожалуйста, свяжитесь со службой технической поддержки.</p></body></html>",
		enGB = "<html><body><p align=\"CENTER\">You are connecting to an invalid game server. Please contact Technical Support for assistance.</p></body></html>"
	},
	["LOGIN_STATE_SURVEY"] = {
		ruRU = "Загрузка сведений о системе",
		enGB = "Submitting non-personal system specification"
	},
	["LOGIN_IGR_WITHOUT_BNET"] = {
		ruRU = "<html><body><p align=\"CENTER\">Для того чтобы играть в World of Warcraft, используя время Internet Game Room, эту учетную запись нужно сначала объединить с учетной записью Battle.net. Пройдите на страницу <a href=\"http://eu.battle.net/\">http://eu.battle.net/</a> , чтобы объединить учетную запись.</p></body></html>",
		enGB = "<html><body><p align=\"CENTER\">In order to log in to World of Warcraft using IGR time, this World of Warcraft account must first be merged with a Battle.net account. Please visit <a href=\"http://us.battle.net/\">http://us.battle.net/</a> to merge this account.</p></body></html>"
	},
	["CHAR_DECLINE_FAILED"] = {
		ruRU = "Ошибка склонения имени персонажа",
		enGB = "Character name declension failed"
	},
	["CLIENT_TRIAL"] = {
		ruRU = "<html><body><p>Ваша учетная запись является полноценной платной учетной записью World of Warcraft и не подходит для использования пробной версии игры. Установите полную версию с DVD или CD либо загрузите ее отсюда: <a href='https://www.worldofwarcraft.com/account/download_wow.html'>https://www.worldofwarcraft.com/account/download_wow.html</a></p></body></html>",
		enGB = "<html><body><p>Your account is a full retail account, and is not compatible with the World of Warcraft Trial version. Please install the retail version of World of Warcraft. If you need more help, see <a href='https://www.worldofwarcraft.com/account/download_wow.html'>https://www.worldofwarcraft.com/account/download_wow.html</a></p></body></html>"
	},
	["CHAR_CREATE_ERROR"] = {
		ruRU = "Ошибка создания персонажа",
		enGB = "Error creating character"
	},
	["LOGIN_STATE_CONNECTING"] = {
		ruRU = "Установка связи",
		enGB = "Connecting"
	},
	["GAME_UPDATES"] = {
		ruRU = "Обновление игры",
		enGB = "Game Updates"
	},
	["RACE_INFO_ORC"] = {
		ruRU = "Орки происходят с планеты Дренор. Пока Пылающий Легион не подчинил этот народ своей власти, орки посвящали себя исключительно мирным занятиям и шаманизму. Но однажды демоны поработили орков и погнали на войну с людьми Азерота. Много лет потребовалось, чтобы избавиться от гнета Легиона и обрести долгожданную свободу. Теперь орки вынуждены сражаться за место в чужом для них мире.",
		enGB = "The orc race originated on the planet Draenor. A peaceful people with shamanic beliefs, they were enslaved by the Burning Legion and forced into war with the humans of Azeroth. Although it took many years, the orcs finally escaped the demons' corruption and won their freedom. To this day they fight for honor in an alien world that hates and reviles them."
	},
	["MAGE_DISABLED"] = {
		ruRU = "Маг\nЭтот класс доступен другим расам.",
		enGB = "Mage\nYou must choose a different race to be this class."
	},
	["SERVER_SPLIT_SERVER_TWO"] = {
		ruRU = "Мир 2",
		enGB = "Realm 2"
	},
	["MENU_ABOUT"] = {
		ruRU = "Об игре...",
		enGB = "About World of Warcraft..."
	},
	["CLIENT_CONVERTED_TITLE"] = {
		ruRU = "Добро пожаловать в World of Warcraft.",
		enGB = "Welcome to the World of Warcraft."
	},
	["MENU_EDIT_CUT"] = {
		ruRU = "Вырезать",
		enGB = "Cut"
	},
	["LOGIN_LOCALE_MISMATCH"] = {
		ruRU = "Неверный язык клиента",
		enGB = "Wrong client language"
	},
	["CHAR_LOGIN_NO_WORLD"] = {
		ruRU = "Сервер недоступен",
		enGB = "World server is down"
	},
	["CHARACTER_FIX_HELP_TEXT"] = {
		ruRU = "- Будут сброшены все ауры.\n- Вы будете перемещены в локацию \"камня возвращения\".\n- При нахождении на поле боя, вы получите дезертира.\n- Ваш персонаж будет воскрешен, если это необходимо.\n- Вы получите дебаф \"Слабость после воскрешения\".",
		enGB = "- All your auras will be reset.\n- You will be teleported to your Hearthstone location.\n- If you are in a battleground, you will receive the Deserter debuff.\n- Your character will be resurrected if necessary.\n- You will afflicted with the Resurrection Sickness debuff."
	},
	["CHAR_CREATE_IN_PROGRESS"] = {
		ruRU = "Создание персонажа",
		enGB = "Creating character"
	},
	["COMMUNITY_URL"] = {
		ruRU = "http://www.wow-europe.com/ru",
		enGB = "http://www.worldofwarcraft.com"
	},
	["LOGIN_STATE_AUTHENTICATING"] = {
		ruRU = "Авторизация",
		enGB = "Authenticating"
	},
	["SCANDLL_URL_HACK"] = {
		ruRU = "http://eu.blizzard.com/support/article.xml?articleId=28360",
		enGB = "http://us.blizzard.com/support/article.xml?articleId=21583"
	},
	["ACCOUNT_MESSAGE_BODY_NO_READ_URL"] = {
		ruRU = "http://www.wow-europe.com/ru/support/",
		enGB = "http://support.worldofwarcraft.com/accountmessaging/getMessageBodyUnread.xml"
	},
	["SPELLS_HELP_1"] = {
		ruRU = "Уникальные способности, которые относятся как к ведению боя, так и другим аспектам игры. Заклинания могут быть как Активные, так и Пассивные.",
		enGB = "Unique abilities that relate to both combat and other aspects of the game. There are Active and Passive spells."
	},
	["AUTH_NO_TIME"] = {
		ruRU = "Срок действия вашей подписки истек. Необходима повторная активация учетной записи. Подробнее см. www.wow-europe.com/account/.",
		enGB = "Your World of Warcraft subscription has expired. You will need to reactivate your account. To do so, please visit www.worldofwarcraft.com/account for more information."
	},
	["QUEUE_NAME_TIME_LEFT"] = {
		ruRU = "Свободных мест нет: %s\nМесто в очереди: %d\nВремя ожидания: %d мин.",
		enGB = "%s is Full\nPosition in queue: %d\nEstimated time: %d min"
	},
	["CHOOSE_CHARACTER_RIGHT"] = {
		ruRU = "Выберите персонажа справа",
		enGB = "Select a character on the right"
	},
	["REALMLIST_REALMNAME_TOOLTIP"] = {
		ruRU = "Не забудьте узнать, в каком из миров играют ваши друзья!",
		enGB = "Make sure you check which realm your friends are playing on!"
	},
	["RACE_INFO_NIGHTELF_FEMALE"] = {
		ruRU = "Десять тысяч лет назад ночные эльфы основали огромную империю, но неразумное использование первородной магии привело ее к падению. Полные скорби, они удалились в леса и пребывали в изоляции вплоть до возвращения их вековечного врага, Пылающего Легиона. Тогда ночным эльфам пришлось пожертвовать своим уединенным образом жизни и сплотиться, чтобы отвоевывать свое место в новом мире.",
		enGB = "Ten thousand years ago, the night elves founded a vast empire, but their reckless use of primal magic brought them to ruin. In grief, they withdrew to the forests and remained isolated there until the return of their ancient enemy, the Burning Legion. With no other choice, the night elves emerged at last from their seclusion to fight for their place in the new world."
	},
	["CHAR_CREATE_EXPANSION_CLASS"] = {
		ruRU = "Создание персонажа этого класса требует наличия соответствующего дополнения к игре.",
		enGB = "Creation of that class requires an account that has been upgraded to the appropriate expansion."
	},
	["OUTBID_ON_SHORT"] = {
		ruRU = "У вас перекупили %s",
		enGB = "Outbid on %s"
	},
	["ABILITY_INFO_HUMAN4"] = {
		ruRU = "- Мастерски владеет ударным оружием и мечами.",
		enGB = "- Increased expertise with Swords and Maces."
	},
	["RACE_INFO_HUMAN_FEMALE"] = {
		ruRU = "Люди – молодая раса, а потому их способности разносторонни. Искусство боя, ремесло и магия доступны им в равной степени. Жизнелюбие и уверенность в своих силах позволили людям создать могучие королевства. В эпоху, когда войны длятся веками, люди стремятся возродить былую славу и заложить основу для будущих блистательных побед.",
		enGB = "Humans are a young race, and thus highly versatile, mastering the arts of combat, craftsmanship, and magic with stunning efficiency. The humans’ valor and optimism have led them to build some of the world’s greatest kingdoms. In this troubled era, after generations of conflict, humanity seeks to rekindle its former glory and forge a shining new future."
	},
	["PALADIN_DISABLED"] = {
		ruRU = "Паладин\nЭтот класс доступен другим расам.",
		enGB = "Paladin\nYou must choose a different race to be this class."
	},
	["PARRY"] = {
		ruRU = "ПАРИР %.2f",
		enGB = "PARRY %.2f"
	},
	["AUTH_PARENTAL_CONTROL_URL"] = {
		ruRU = "https://www.wow-europe.com/account/",
		enGB = "http://www.worldofwarcraft.com/account"
	},
	["CHAR_DELETE_FAILED_ARENA_CAPTAIN"] = {
		ruRU = "Этот персонаж является капитаном команды арены. Прежде чем его удалить, передайте управление другому персонажу.",
		enGB = "This character is an Arena Captain and cannot be deleted until the rank is transfered to another character."
	},
	["REALMLIST_POPULATION_TOOLTIP"] = {
		ruRU = "Наиболее подходящие для комфортной игры миры\nимеют отметку «Новые игроки». Выбрав мир, помеченный как «Нет мест»,\nвы рискуете прождать некоторое время,\nпрежде чем сможете присоединиться к игре.",
		enGB = "New Players\" realms will give you the best play experience.\n\"Full\" realms are the most crowded, and you will often\nexperience a wait time to play."
	},
	["SUGGEST_REALM"] = {
		ruRU = "Автовыбор",
		enGB = "Suggest Realm"
	},
	["QUEUE_TIME_LEFT_UNKNOWN"] = {
		ruRU = "Свободных мест нет\nМесто в очереди: %d\nВремя ожидания: идет расчет...",
		enGB = "Realm is Full\nPosition in queue: %d\nEstimated time: Calculating..."
	},
	["LOAD_MEDIUM"] = {
		ruRU = "Средняя",
		enGB = "Medium"
	},
	["RACE_INFO_GNOME_FEMALE"] = {
		ruRU = "Гномы Каз Модана не могут похвастаться статью, зато их интеллект позволил занять им достойное место в истории. Гномреган, подземное королевство, в свое время был чудом паровых технологий. Увы, вторжение троггов привело к разрушению города. Теперь славные строители Гномрегана скитаются по землям дворфов, по мере сил помогая своим союзникам.",
		enGB = "Though small in stature, the gnomes of Khaz Modan have used their great intellect to secure a place in history. Indeed, their subterranean kingdom, Gnomeregan, was once a marvel of steam-driven technology. Even so, due to a massive trogg invasion, the city was lost. Now its builders are vagabonds in the dwarven lands, aiding their allies as best they can."
	},
	["HELP"] = {
		ruRU = "Справка",
		enGB = "Help"
	},
	["CHARACTER_BOOST_CHOOSE_CHARACTER_PROFESSION"] = {
		ruRU = "Выберите профессию",
		enGB = "Choose a profession"
	},
	["CHARACTER_BOOST_PROFESSION_WARNING"] = {
		ruRU = "Внимание!\nВсе имеющиеся у персонажа профессии будут удалены и заменены на выбранные вами профессии максимального уровня навыка, но без рецептов.",
	},
	["RACE_INFO_SCOURGE"] = {
		ruRU = "Отрекшиеся, не попавшие под власть Короля-лича, ищут способ положить конец его правлению. Под предводительством банши Сильваны они сражаются против Армии Плети. Их врагами стали и люди, неустанно стремящиеся стереть с лица земли любую нежить. Отверженные не хранят верность союзам и даже Орду считают всего лишь инструментом воплощения своих темных замыслов.",
		enGB = "Free of the Lich King's grasp, the Forsaken seek to overthrow his rule. Led by the banshee Sylvanas, they hunger for vengeance against the Scourge. Humans, too, have become the enemy, relentless in their drive to purge all undead from the land. The Forsaken care little even for their allies; to them the Horde is merely a tool that may further their dark schemes."
	},
	["LOGIN_NO_BATTLENET_MANAGER"] = {
		ruRU = "<html><body><p align=\"CENTER\">Произошла ошибка входа в систему. Пожалуйста, повторите попытку позже. Если проблема остается, свяжитесь с технической поддержкой.</p></body></html>",
		enGB = "<html><body><p align=\"CENTER\">There was an error logging in. Please try again later. If the problem persists, please contact Technical Support at: <a href=\"http://us.blizzard.com/support/article.xml?locale=en_US&amp;articleId=21014\">http://us.blizzard.com/support/article.xml?locale=en_US&amp;articleId=21014</a></p></body></html>"
	},
	["REALM_DOWN"] = {
		ruRU = "Нет доступа",
		enGB = "Offline"
	},
	["BLOODELF_DISABLED"] = {
		ruRU = "Эльф крови\nТребуется дополнение The Burning Crusade",
		enGB = "Blood Elf\nRequires The Burning Crusade"
	},
	["REALM_LIST_REALM_NOT_FOUND"] = {
		ruRU = "Данный сервер в настоящий момент недоступен. Воспользуйтесь кнопкой «Выбор мира» для указания другого сервера. Для проверки статуса сервера перейдите на сайт www.sirus.su",
		enGB = "The game server you have chosen is currently down.  Use the Change Realm button to choose another Realm.  Check www.worldofwarcraft.com/serverstatus for current server status."
	},
	["REALM_LIST_SUCCESS"] = {
		ruRU = "Список миров получен",
		enGB = "Realm list retrieved"
	},
	["RESPONSE_CONNECTED"] = {
		ruRU = "Соединение установлено",
		enGB = "Connected"
	},
	["RESET_WARNING"] = {
		ruRU = "Настройки пользователя будут сброшены при следующем входе в игру!",
		enGB = "All user options will be reset the next time you log in!"
	},
	["REALM_CHARACTERS"] = {
		ruRU = "Персонажи",
		enGB = "Characters"
	},
	["MENU_EDIT"] = {
		ruRU = "Правка",
		enGB = "Edit"
	},
	["CHANGE"] = {
		ruRU = "Изменить",
		enGB = "Change"
	},
	["ABILITY_INFO_TROLL3"] = {
		ruRU = "- Наносит увеличенный урон животным.",
		enGB = "- Damage increased versus beasts."
	},
	["CHARACTER_DELETE_RESTORE_ERROR_5"] = {
		ruRU = "<html><body><p align=\"CENTER\">Недостаточно бонусов!</p><p align=\"CENTER\">Внести добровольное пожертвование в <a href=\"https://sirus.su/pay\">личном кабинете</a></p></body></html>",
		enGB = "<html><body><p align=\"\"CENTER\"\">Not enough bonuses!</p><p align=\"\"CENTER\"\">Make a donation in <a href=\"\"https://sirus.su/pay\"\">your account</a></p></body></html>"
	},
	["SERVER_ALERT_TITLE"] = {
		ruRU = "Последние новости",
		enGB = "Breaking News"
	},
	["LOGIN_UNKNOWN_ACCOUNT_CALL"] = {
		ruRU = "Позвоните в службу поддержки",
		enGB = "Call customer service"
	},
	["GAMETYPE_PVP"] = {
		ruRU = "Игроки пр. игроков |cffff0000(PvP)|r",
		enGB = "Player Versus Player  |cffff0000(PVP)|r"
	},
	["SERVER_SPLIT_REALM_CHOICE"] = {
		ruRU = "Ваш выбор – '|cffffffff%s|r'",
		enGB = "Your current choice is '|cffffffff%s|r'"
	},
	["MALE"] = {
		ruRU = "Мужчина",
		enGB = "Male"
	},
	["GAMETYPE_PVE_TEXT"] = {
		ruRU = "Миры данного типа подходят для игроков, предпочитающих странствия и охоту на монстров, нежели бои с другими игроками. Впрочем, устраивать сражения здесь можно – но только с согласия других игроков.",
		enGB = "These realms allow you to focus on adventuring and fighting monsters while allowing you to fight other players at your own discretion."
	},
	["PANDAREN_ALLIANCE"] = {
		ruRU = "Пандарен (Альянс)",
		enGB = "Pandaren (Alliance)"
	},
	["RESPONSE_CANCELLED"] = {
		ruRU = "Отменено",
		enGB = "Cancelled"
	},
	["SERVER_SPLIT_DONT_CHANGE"] = {
		ruRU = "Отменить выбор",
		enGB = "Clear Choice"
	},
	["SCANNING_NOTICE"] = {
		ruRU = "Некоторые пункты Соглашения о сканировании были изменены. Просмотрите весь текст Соглашения прежде, чем принимать его условия.",
		enGB = "The scanning aggreement has changed. Please scroll down and review the changes before accepting the agreement."
	},
	["CSTATUS_NEGOTIATION_COMPLETE"] = {
		ruRU = "Проверка безопасности завершена",
		enGB = "Security negotiation complete"
	},
	["CHARACTER_DELETE_RESTORE_ERROR_3"] = {
		ruRU = "Достингуто максимальное количество персонажей.",
		enGB = "The maximum number of characters has been reached."
	},
	["CHAR_CREATE_SUCCESS"] = {
		ruRU = "Персонаж создан",
		enGB = "Character created"
	},
	["LOAD_LOW"] = {
		ruRU = "Низкая",
		enGB = "Low"
	},
	["SERVER_DOWN"] = {
		ruRU = "Сервер недоступен",
		enGB = "Server down"
	},
	["CONFIRM_PAID_FACTION_CHANGE"] = {
		ruRU = "Смена фракции приведет к сбросу всех принятых вами заданий, при этом их прогресс будет полностью утерян.\nВы уверены, что хотите сменить фракцию прямо сейчас?",
		enGB = ""
	},
	["ALLIED_RACE_UNLOCKED"] = {
		ruRU = "|cff00ff00Вы получили поддержку %s и имеете доступ к этой расе.|r",
		enGB = "",
	},
	["ALLIED_RACE_UNLOCKED_NIGHTBORNE"] = {
		ruRU = "|cff00ff00Вы получили поддержку Ночнорожденных и имеете доступ к этой расе.|r",
		enGB = ""
	},
	["ALLIED_RACE_UNLOCKED_EREDAR"] = {
		ruRU = "|cff00ff00Вы получили поддержку Эредаров и имеете доступ к этой расе.|r",
		enGB = ""
	},
	["ALLIED_RACE_UNLOCKED_ZANDALARITROLL"] = {
		ruRU = "|cff00ff00Вы получили поддержку Зандалар и имеете доступ к этой расе.|r",
		enGB = ""
	},
	["ALLIED_RACE_UNLOCKED_VOIDELF"] = {
		ruRU = "|cff00ff00Вы получили поддержку Эльфов Бездны и имеете доступ к этой расе.|r",
		enGB = ""
	},
	["ALLIED_RACE_UNLOCKED_DARKIRONDWARF"] = {
		ruRU = "|cff00ff00Вы получили поддержку Дворфов Черного Железа и имеете доступ к этой расе.|r",
		enGB = ""
	},
	["ALLIED_RACE_UNLOCKED_LIGHTFORGED"] = {
		ruRU = "|cff00ff00Вы получили поддержку Озаренных дренеев и имеете доступ к этой расе.|r",
		enGB = ""
	},
	["ALLIED_RACE_DISABLE"] = {
		ruRU = "Чтобы получить возможность создания персонажа данной расы",
		enGB = ""
	},
	["ALLIED_RACE_SIGN_DISABLE"] = {
		ruRU = "Чтобы получить возможность создания персонажа со знаком зодиака %s",
		enGB = ""
	},
	["ALLIED_RACE_DISABLE_REASON_NIGHTBORNE"] = {
		ruRU = "добейтесь превознесения Дома Селентрис и выполните задание \"Цвет Ночи\".",
		enGB = ""
	},
	["ALLIED_RACE_DISABLE_REASON_EREDAR"] = {
		ruRU = "добейтесь превознесения Саргерайских раскольников и выполните задание \"Пылающая месть\".",
		enGB = ""
	},
	["ALLIED_RACE_DISABLE_REASON_ZANDALARITROLL"] = {
		ruRU = "добейтесь превознесения Атал\'зула и выполните задание \"Герой Атал\'зул\".",
		enGB = ""
	},
	["ALLIED_RACE_DISABLE_REASON_VOIDELF"] = {
		ruRU = "добейтесь превознесения Скитальцев Тенебры и выполните задание \"Высшая награда\".",
		enGB = ""
	},
	["ALLIED_RACE_DISABLE_REASON_DARKIRONDWARF"] = {
		ruRU = "добейтесь превознесения Стражей Кузни и выполните задание \"Пламя перерождения\".",
		enGB = ""
	},
	["ALLIED_RACE_DISABLE_REASON_LIGHTFORGED"] = {
		ruRU = "добейтесь превознесения Связанных Светом и выполните задание \"Свет Тёмной Звезды\".",
		enGB = ""
	},
	["CHOOSE_SPECIALIZATION_WARNING_TEXT_DEATHKNIGHT"] = {
		ruRU = "|cffFF0000Внимание! Быстрый старт для Рыцаря Смерти предоставляет исключительно экипировку для роли \"Нанесение урона\".|r",
		enGB = ""
	},
	["REALM_LIST_XP_TOOLTIP"] = {
		ruRU = "Множитель получаемого опыта за выполнение заданий и убийство монстров",
		enGB = ""
	},
	["ERROR_CONNECTION_HTML"] = {
		ruRU = "<html><body><p align=\"CENTER\">Невозможно подключиться</p><br /><p>Попробуйте перезапустить клиент, если это не поможет - ознакомьтесь с актуальной информацией на <a href='https://forum.sirus.su/'>форуме</a> или в нашем <a href='https://discord.gg/sirus'>дискорде</a>.</p></body></html>",
		enGB = ""
	},
	["PROXY"] = {
		ruRU = "Прокси",
		enGB = "Proxy"
	},
	["PROXY_DESCRIPTION"] = {
		ruRU = "Используйте эти игровые миры чтобы подсоединиться через проксирующий сервер. Обратите внимание, что это может увеличить пинг.",
		enGB = ""
	},
	["REALM_NELTHARION_DESCRIPTION"] = {
		ruRU = "Самый «горячий» из наших миров, заточенный под WPVP сражения. Включает в себя как постепенную прогрессию PVE-контента, так и нонстоп PVP активности по всему миру. Если в свободное от походов в рейды время Вас привлекает охота за головами, противостояние фракций, нападение на столицы и города противника, то Neltharion однозначно Ваш выбор, времяпрепровождение на котором подарит Вам море адреналина.",
	},
	["REALM_FROSTMOURNE_DESCRIPTION"] = {
		ruRU = "Новый мир, ожидающий своих героев, полный достижений и открытий, еще никем не виданных.\n\nСтаньте первым, кто завоюет себе звание настоящего героя и получит предметы невиданной ценности из рейдовых подземелий!",
	},
	["REALM_LEGACY_X10_DESCRIPTION"] = {
		ruRU = "Мир тех, кто уже достиг настоящих высот, тех, кто стал покорителями Нордскола и Запределья.\n\nЕсли Вы хотите настоящего соревнования, хотите встать на одну вершину с легендами - Вам сюда!",
	},
	["REALM_SCOURGE_DESCRIPTION"] = {
		ruRU = "Прогрессивный игровой мир с преуспевающим освоением как PvP, так и PvE-аспектов. Сочетает в себе множество внутриигровых изменений и лучших кастомных внедрений в стандартный клиент. Scourge готов подарить вам максимум приятных впечатлений от игры. Однако, если вы хотите стать легендой, то придётся приложить немало усилий. Что бы вы ни любили: рейды, подземелья, поля боя или арены - этому миру будет что вам предложить.",
		enGB = ""
	},
	["REALM_SIRUS_DESCRIPTION"] = {
		ruRU = "Одноименный игровой мир, включающий в себя все наши лучшие идеи и новшества, собранные воедино. Наш многолетний опыт позволил превратить эту игру в нечто особенное, в мир, где каждый найдёт себе место. Поэтапное развитие PvE-прогресса, где вы сможете побороться за первые на сервере достижения, и полный набор PvP-активностей с регулярными сезонными обновлениями. Всё это точно не даст вам заскучать и позволит погрузиться с головой в мир Warcraft'а.",
		enGB = ""
	},
	["REALM_ALGALON_DESCRIPTION"] = {
		ruRU = "Активно развивающийся игровой мир без системы Категорий, но со всеми новшествами нашего проекта, на котором будет интересно как новичкам, так и опытным игрокам, желающим достигнуть небывалых высот. Перед нами стояла задача сохранить для вас баланс и при этом погрузить в захватывающий мир, полный наших лучших нововведений: поэтапное освоение PvE, полный набор PvP-атрибутов и многое другое, что позволит вам получить незабываемые впечатления об игре.",
		enGB = ""
	},
	["REALM_SOULSEEKER_DESCRIPTION"] = {
		ruRU = "Новый игровой мир для самых стойких и выносливых героев. Мир включает в себя все особенности нашего проекта, а также уникальную систему испытаний для тех, кто готов проверить себя и свои силы на прочность. Усиленный игровой мир, поэтапное развитие PvE-прогресса и большой выбор PVP активностей позволит вам прочувствовать всю атмосферу вселенной Warcraft'а и настоящего приключения!",
		enGB = ""
	},
	["CONFIRM_PAID_SERVICE"] = {
		ruRU = "Вы уверены, что завершили изменение персонажа |c%s%s|r?",
		enGB = "Are you sure you are done changing your character |c%s%s|r?"
	},
	["CONFIRM_CHARACTER_CREATE"] = {
		ruRU = "Вы уверены, что хотите завершить создание персонажа |c%s%s|r?",
		enGB = ""
	},
	["CONFIRM_CHARACTER_CREATE_CUSTOMIZATION"] = {
		ruRU = "\nНе забудьте выбрать внешность!",
		enGB = ""
	},
	["RENEGADE"] = {
		ruRU = "Ренегат",
		enGB = "Renegade",
	},
	["NEUTRAL"] = {
		ruRU = "Нейтрал",
		enGB = "Neutral",
	},
	["NEUTRALS"] = {
		ruRU = "Нейтральные",
		enGB = "Neutrals",
	},
	["CHARACTER_SELECT_UNDELETED_CHARACTER"] = {
		ruRU = "Удаленные персонажи",
		enGB = ""
	},
	["CHARACTER_CREATE_CUSTOMIZATION_LABEL"] = {
		ruRU = "Выбор внешности",
		enGB = "Customization"
	},
	["CHARACTER_CREATE_RACE_LABEL"] = {
		ruRU = "Выбор расы",
		enGB = "Customization"
	},
	["CHARACTER_CREATE_ZODIAC_SIGN_LABEL"] = {
		ruRU = "Знак зодиака",
		enGB = "Zodiac sign"
	},
	["CHARACTER_SERVICES_FIX_CHARACTER"] = {
		ruRU = "Исправить персонажа",
	},
	["CHARACTER_SERVICES_DELETE"] = {
		ruRU = "Удалить",
	},
	["CHARACTER_SERVICES_BOOST_LABEL"] = {
		ruRU = "Быстрый Старт",
	},
	["CHARACTER_SERVICES_BOOST_CONFIRMATION_DESCRIPTION"] = {
		ruRU = "Вы уверены, что хотите использовать Быстрый Cтарт?",
	},
	["CHARACTER_SERVICES_BOOST_CONFIRMATION_WARNING"] = {
		ruRU = "После подтверждения у вас будет возможность один раз изменить выбор персонажа в течение 2 дней с момента активации Быстрого Старта, если персонаж проведёт в игре менее 6 часов.\nПри этом текущий персонаж будет удален без возможности восстановления.",
	},
	["PAID_CHARACTER_CUSTOMIZE_TOOLTIP"] = {
		ruRU = "Нажмите здесь, чтобы изменить персонажа",
		enGB = "Click to customize your character"
	},
	["PAID_FACTION_CHANGE_TOOLTIP"] = {
		ruRU = "Нажмите здесь, чтобы сменить фракцию персонажа",
		enGB = "Click to change your character's faction"
	},
	["PAID_RACE_CHANGE_TOOLTIP"] = {
		ruRU = "Нажмите здесь, чтобы сменить расу персонажа",
		enGB = "Click to change your character's race"
	},
	["PAID_CHARACTER_RESTORE_TOOLTIP"] = {
		ruRU = "Нажмите здесь, чтобы восстановить персонажа",
		enGB = "Click to change your character's faction"
	},
	["PAID_ZODIAC_CHANGE_TOOLTIP"] = {
		ruRU = "Нажмите здесь, чтобы сменить знак зодиака персонажа",
		enGB = "Click to change your character's zodiac sign"
	},
	["PAID_BOOST_CANCEL_TOOLTIP"] = {
		ruRU = "Нажмите здесь, чтобы отменить Быстрый Старт.",
	},
	["PAID_BOOST_CANCEL_REMAINING_TIME"] = {
		ruRU = "Отмена услуги \"Быстрый старт\" доступна в течение 2-х дней с момента ее активации и если персонаж провел в игре менее 6 часов.\nОсталось |cff00FF00%s|r\nПроведено в игре |cff00FF00%s|r",
	},
	["PAID_BOOST_CANCEL_TOOLTIP_DESCRIPTION"] = {
		ruRU = "Это можно сделать до истечения срока возможного возврата.",
	},
	["RIGHT_CLICK_FOR_LESS"] = {
		ruRU = "ПКМ: убрать подсказку",
		enGB = "Right click for less",
	},
	["RIGHT_CLICK_FOR_MORE"] = {
		ruRU = "ПКМ: подробное описание",
		enGB = "Right click for more",
	},
	["RACIAL_TRAITS_ACTIVE_TOOLTIP"] = {
		ruRU = "Активные способности",
		enGB = "Racial Traits",
	},
	["RACIAL_TRAITS_PASSIVE_TOOLTIP"] = {
		ruRU = "Пассивные способности",
		enGB = "Passive"
	},
	["DECLENSION_EXAMPLE_PRE"] = {
		ruRU = "прим. %s",
		enGB = "",
	},
	["UNREAD_MAILS"] = {
		ruRU = "Непрочитанных писем: %i",
		enGB = "",
	},
	["CHARACTER_ITEM_LEVEL"] = {
		ruRU = "Ур. предметов",
		enGB = "",
	},
	["NEVER_SHOW_AGAIN"] = {
		ruRU = "Больше не показывать",
		enGB = "",
	},
	["WORLD_PROXY_LOCATION_HEADER"] = {
		ruRU = "Выберите свою локацию",
		enGB = "",
	},
	["WORLD_PROXY_LOCATION"] = {
		ruRU = "Выберите ваш регион",
		enGB = "",
	},
	["WORLD_PROXY_LOCATION_TEXT"] = {
		ruRU = "Вы выбрали |cffffd200%s|r и будете играть через специально настроенное соединение.\nВ случае если сервера будут недоступны, у вас увеличится количество разрывов соединений или будет слишком высокая задержка, то вы можете изменить локацию.",
		enGB = "",
	},
	["WORLD_PROXY_LOCATION_HELP"] = {
		ruRU = "Нажмите на одну из этих кнопок чтобы выбрать другое соединение",
		enGB = "",
	},
	["CHARACTER_SELECT_CHARACTER_LIST"] = {
		ruRU = "Список персонажей",
		enGB = "Character list"
	},
	["CHAR_CUSTOMIZATION0_DESC"] = {
		ruRU = "Пол",
		enGB = "Gender"
	},
	["CHAR_CUSTOMIZATION1_DESC"] = {
		ruRU = "Цвет кожи",
		enGB = "Skin Color"
	},
	["CHAR_CUSTOMIZATION2_DESC"] = {
		ruRU = "Лицо",
		enGB = "Face"
	},
	["CHAR_CUSTOMIZATION3_DESC"] = {
		ruRU = "Прическа",
		enGB = "Hair Style"
	},
	["CHAR_CUSTOMIZATION4_DESC"] = {
		ruRU = "Цвет волос",
		enGB = "Hair Color"
	},
	["CHAR_CUSTOMIZATION5_DESC"] = {
		ruRU = "Борода и усы",
		enGB = "Facial Hair"
	},
	["CHAR_CUSTOMIZATION6_DESC"] = {
		ruRU = "Снаряжение",
		enGB = "Outfit"
	},
	["CLASS_DISABLE_REASON_DEATH_KNIGHT"] = {
		ruRU = "Вы достигли максимального количества персонажей героического класса рыцарь смерти в этом игровом мире, и создание новых недоступно.",
		enGB = ""
	},
	["CLASS_DISABLE_REASON_DEMON_HUNTER"] = {
		ruRU = "Новый класс \"Охотник на демонов\", в данный момент недоступен! Следите за новостями сервера, чтобы первым узнать когда \"Охотник на демонов\", станет доступным.",
		enGB = "The new Demon Hunter class is not available yet! Follow the server’s news to be the first to know when the Demon Hunter class becomes available."
	},
	["CLASS_TRAITS_TOOLTIP"] = {
		ruRU = "Классовые способности",
		enGB = "Class Traits",
	},

	["CLASS_WARRIOR"] = {
		ruRU = "Воины – бойцы в латных доспехах, стремящиеся достичь совершенства во владении оружием. Когда воин наносит урон или получает удар, он накапливает ярость, которую затем расходует на применение способностей.|n|nПерсонаж может посвятить себя освоению двуручного оружия, на бой с оружием в каждой руке или на классическое сочетание меча и щита. Воин также наделен способностями, которые позволяют ему быстро перемещаться по полю боя. Главная характеристика класса – сила, хотя воины, принимающие на себя урон, должны думать и о выносливости.",
		enGB = "Warriors are plate-wearing fighters who strive for perfection in armed combat. As warriors deal or take damage, they generate rage, which is used to power their special attacks.|n|nWarriors can choose to focus on a two-handed weapon, dual-wielding or using a sword and shield. Warriors have several abilities that let them move quickly around the battlefield. Their primary stat is Strength, though tanking warriors desire Stamina as well."
	},
	["CLASS_WARRIOR_FEMALE"] = {
		ruRU = "Воины – бойцы в латных доспехах, стремящиеся достичь совершенства во владении оружием. Когда воин наносит урон или получает удар, он накапливает ярость, которую затем расходует на применение способностей.|n|nПерсонаж может посвятить себя освоению двуручного оружия, на бой с оружием в каждой руке или на классическое сочетание меча и щита. Воин также наделен способностями, которые позволяют ему быстро перемещаться по полю боя. Главная характеристика класса – сила, хотя воины, принимающие на себя урон, должны думать и о выносливости.",
		enGB = "Warriors are plate-wearing fighters who strive for perfection in armed combat. As warriors deal or take damage, they generate rage, which is used to power their special attacks.|n|nWarriors can choose to focus on a two-handed weapon, dual-wielding or using a sword and shield. Warriors have several abilities that let them move quickly around the battlefield. Their primary stat is Strength, though tanking warriors desire Stamina as well."
	},
	["CLASS_INFO_WARRIOR0"] = {
		ruRU = "- Роль: танкование, нанесение урона",
		enGB = "- Role: Tank, Damage"
	},
	["CLASS_INFO_WARRIOR1"] = {
		ruRU = "- Тяжелая броня (кольчуга/латы и щит)",
		enGB = "- Heavy Armor (Mail / Plate and Shield)"
	},
	["CLASS_INFO_WARRIOR2"] = {
		ruRU = "- Ведет сражение в ближнем бою.",
		enGB = "- Deals damage with melee weapons."
	},
	["CLASS_INFO_WARRIOR3"] = {
		ruRU = "- Может принимать одну из трех боевых стоек, у каждой из которых есть свои преимущества.",
		enGB = "- Has 3 fighting stances with different benefits."
	},
	["CLASS_INFO_WARRIOR4"] = {
		ruRU = "- Пользуется яростью как ресурсом.",
		enGB = "- Uses rage as a resource."
	},
	["CLASS_PALADIN"] = {
		ruRU = "Паладин – облаченный в тяжелую броню боец, призывающий силу Света для лечения раненых и борьбы со злом. Паладин – самодостаточный персонаж, наделенный всеми необходимыми способностями для спасения союзника от гибели. Он может сосредоточиться на мастерстве владения двуручным оружием, щитом или на лечении. Основные характеристики зависят от игровой роли персонажа.",
		enGB = "Paladins are heavily-armored fighters and defenders who use Holy magic to heal wounds and combat evil. Paladins are relatively self-sufficient and have many abilities targeted at death prevention. They can focus on two-handed weapons, shields or healing. Their primary stats depend on their role."
	},
	["CLASS_PALADIN_FEMALE"] = {
		ruRU = "Паладин – облаченный в тяжелую броню боец, призывающий силу Света для лечения раненых и борьбы со злом. Паладин – самодостаточный персонаж, наделенный всеми необходимыми способностями для спасения союзника от гибели. Он может сосредоточиться на мастерстве владения двуручным оружием, щитом или на лечении. Основные характеристики зависят от игровой роли персонажа.",
		enGB = "Paladins are heavily-armored fighters and defenders who use Holy magic to heal wounds and combat evil. Paladins are relatively self-sufficient and have many abilities targeted at death prevention. They can focus on two-handed weapons, shields or healing. Their primary stats depend on their role."
	},
	["CLASS_INFO_PALADIN0"] = {
		ruRU = "- Роль: танкование, лечение, нанесение урона",
		enGB = "- Role: Tank, Healer, Damage"
	},
	["CLASS_INFO_PALADIN1"] = {
		ruRU = "- Тяжелая броня (кольчуга/латы и щит)",
		enGB = "- Heavy Armor (Mail / Plate and Shield)"
	},
	["CLASS_INFO_PALADIN2"] = {
		ruRU = "- Неутомимый борец со злом.",
		enGB = "- Righteous vanquishers of evil."
	},
	["CLASS_INFO_PALADIN3"] = {
		ruRU = "- Сражается в ближнем бою и пользуется магией Света.",
		enGB = "- Deals Holy and melee damage."
	},
	["CLASS_INFO_PALADIN4"] = {
		ruRU = "- Владеет рядом защитных заклинаний.",
		enGB = "- Has a variety of defensive spells."
	},
	["CLASS_INFO_PALADIN5"] = {
		ruRU = "- Пользуется маной как ресурсом.",
		enGB = "- Uses mana as a resource."
	},
	["CLASS_HUNTER"] = {
		ruRU = "Дикая природа – родная стихия охотника, а животные для него – почти как братья. Охотник умеет стрелять из ружей, арбалетов и луков. В бою ему помогают и прирученные звери. Ловушки могут наносить противнику повреждения или удерживать его на расстоянии. Основные характеристики этого класса – сила атаки и ловкость.",
		enGB = "Hunters are at home in the wilderness and have a special affinity for beasts. They use ranged weapons, such as bows or guns, and their pet to deal damage. They can use traps to cause damage or keep an enemy at bay. The hunter's primary stats are Attack Power and Agility."
	},
	["CLASS_HUNTER_FEMALE"] = {
		ruRU = "Дикая природа – родная стихия охотника, а животные для него – почти как братья. Охотник умеет стрелять из ружей, арбалетов и луков. В бою ему помогают и прирученные звери. Ловушки могут наносить противнику повреждения или удерживать его на расстоянии. Основные характеристики этого класса – сила атаки и ловкость.",
		enGB = "Hunters are at home in the wilderness and have a special affinity for beasts. They use ranged weapons, such as bows or guns, and their pet to deal damage. They can use traps to cause damage or keep an enemy at bay. The hunter's primary stats are Attack Power and Agility."
	},
	["CLASS_INFO_HUNTER0"] = {
		ruRU = "- Роль: нанесение урона",
		enGB = "- Role: Damage"
	},
	["CLASS_INFO_HUNTER1"] = {
		ruRU = "- Средняя броня (кожа/кольчуга)",
		enGB = "- Medium Armor (Leather / Mail)"
	},
	["CLASS_INFO_HUNTER2"] = {
		ruRU = "- Акцент на дальнем бое и ловушках.",
		enGB = "- Emphasis on ranged damage and traps."
	},
	["CLASS_INFO_HUNTER3"] = {
		ruRU = "- Приручает животных и делает их своими помощниками.",
		enGB = "- Gains a beast of your choice as a lifelong companion."
	},
	["CLASS_INFO_HUNTER4"] = {
		ruRU = "- Приятный процесс развития, интересная одиночная игра.",
		enGB = "- Good at leveling and soloing."
	},
	["CLASS_ROGUE"] = {
		ruRU = "Разбойники часто служат наемными убийцами и лазутчиками, хотя есть среди них и убежденные одиночки. Отличительная черта класса – мастерское владение самыми разными видами оружия, хотя классическим разбойничьим оружием остается кинжал.|n|nРазбойник не гнушается подкрасться к жертве сзади, чтобы прикончить ее наверняка, а иногда пробирается незамеченным среди врагов. Основные характеристики класса – сила атаки и ловкость.",
		enGB = "Rogues often serve as assassins or scouts, though many are lone wolves as well. Rogues specialize in dual-wielding a variety of weapons, though the iconic rogue weapon is the dagger.|n|nRogues can often sneak around enemies or attack an opponent from behind to try and finish them off quickly. Their primary stats are Attack Power and Agility."
	},
	["CLASS_ROGUE_FEMALE"] = {
		ruRU = "Разбойники часто служат наемными убийцами и лазутчиками, хотя есть среди них и убежденные одиночки. Отличительная черта класса – мастерское владение самыми разными видами оружия, хотя классическим разбойничьим оружием остается кинжал.|n|nРазбойник не гнушается подкрасться к жертве сзади, чтобы прикончить ее наверняка, а иногда пробирается незамеченным среди врагов. Основные характеристики класса – сила атаки и ловкость.",
		enGB = "Rogues often serve as assassins or scouts, though many are lone wolves as well. Rogues specialize in dual-wielding a variety of weapons, though the iconic rogue weapon is the dagger.|n|nRogues can often sneak around enemies or attack an opponent from behind to try and finish them off quickly. Their primary stats are Attack Power and Agility."
	},
	["CLASS_INFO_ROGUE0"] = {
		ruRU = "- Роль: нанесение урона",
		enGB = "- Role: Damage"
	},
	["CLASS_INFO_ROGUE1"] = {
		ruRU = "- Средняя броня (кожа)",
		enGB = "- Medium Armor (Leather)"
	},
	["CLASS_INFO_ROGUE2"] = {
		ruRU = "- Держит в каждой руке по оружию.",
		enGB = "- Wields a weapon in each hand."
	},
	["CLASS_INFO_ROGUE3"] = {
		ruRU = "- Полагается на незаметность, отравленное оружие и удержание противника под контролем.",
		enGB = "- Emphasizes stealth, poisons and control."
	},
	["CLASS_INFO_ROGUE4"] = {
		ruRU = "- После использования 5 приемов серии разбойник может нанести особенно сильный завершающий удар.",
		enGB = "- Build up 5 combo points to unleash finishing moves."
	},
	["CLASS_INFO_ROGUE5"] = {
		ruRU = "- Пользуется энергией как ресурсом.",
		enGB = "- Uses energy as a resource."
	},
	["CLASS_PRIEST"] = {
		ruRU = "Жрецы – прекрасные лекари с полным набором целительных заклинаний. В то же время жрец может пожертвовать своей ролью целителя и посвятить себя изучению темной магии. Жрецы – духовные лидеры своих народов. Для всех персонажей этого класса важен показатель силы заклинаний и интеллекта, а для лекарей – и духа.",
		enGB = "Priests are well-rounded healers with a variety of tools. However, they can also sacrifice their healing to deal damage with Shadow magic. Within society, priests act as the spiritual leaders of their respective races. The priest's primary stats are Spell Power, Intellect, and Spirit if healing."
	},
	["CLASS_PRIEST_FEMALE"] = {
		ruRU = "Жрецы – прекрасные лекари с полным набором целительных заклинаний. В то же время жрец может пожертвовать своей ролью целителя и посвятить себя изучению темной магии. Жрецы – духовные лидеры своих народов. Для всех персонажей этого класса важен показатель силы заклинаний и интеллекта, а для лекарей – и духа.",
		enGB = "Priests are well-rounded healers with a variety of tools. However, they can also sacrifice their healing to deal damage with Shadow magic. Within society, priests act as the spiritual leaders of their respective races. The priest's primary stats are Spell Power, Intellect, and Spirit if healing."
	},
	["CLASS_INFO_PRIEST0"] = {
		ruRU = "- Роль: лечение, нанесение урона",
		enGB = "- Role: Healer, Damage"
	},
	["CLASS_INFO_PRIEST1"] = {
		ruRU = "- Легкая броня (ткань)",
		enGB = "- Light Armor (Cloth)"
	},
	["CLASS_INFO_PRIEST2"] = {
		ruRU = "- Исцеляет при помощи магии Света",
		enGB = "- Heal damage with Holy magic."
	},
	["CLASS_INFO_PRIEST3"] = {
		ruRU = "- Использует темную магию для нанесения урона.",
		enGB = "- Cause damage with Shadow magic."
	},
	["CLASS_INFO_PRIEST4"] = {
		ruRU = "- Пользуется маной как ресурсом.",
		enGB = "- Uses mana as a resource."
	},
	["CLASS_DEATHKNIGHT"] = {
		ruRU = "Рыцари смерти, бывшие некогда частью Плети, перешли теперь на сторону Орды или Альянса. Эти персонажи принадлежат к героическому классу, и игру они начинают на высоком уровне. Основной ресурс рыцарей смерти – руны трех видов, применяемые для различных способностей.|n|nУ рыцарей смерти, по сравнению с другими классами ближнего боя, больше способностей для воздействия на расстоянии: они могут насылать болезни и призывать прислужника-вурдалака. Сила является их основной характеристикой, а для рыцарей смерти, выступающих в роли танка, также важна выносливость.",
		enGB = "These former agents of the Scourge have now allied themselves with the Alliance or Horde. Death knights are a hero class, which means they start at high level. Death knights use runes as their primary resource. Each of the three types of rune is used for different abilities.|n|nDeath knights have more ranged capabilities than most melee classes with an emphasis on causing diseases and doing damage with their undead pets. Their primary stat is Strength and also Stamina if tanking."
	},
	["CLASS_DEATHKNIGHT_FEMALE"] = {
		ruRU = "Рыцари смерти, бывшие некогда частью Плети, перешли теперь на сторону Орды или Альянса. Эти персонажи принадлежат к героическому классу, и игру они начинают на высоком уровне. Основной ресурс рыцарей смерти – руны трех видов, применяемые для различных способностей.|n|nУ рыцарей смерти, по сравнению с другими классами ближнего боя, больше способностей для воздействия на расстоянии: они могут насылать болезни и призывать прислужника-вурдалака. Сила является их основной характеристикой, а для рыцарей смерти, выступающих в роли танка, также важна выносливость.",
		enGB = "These former agents of the Scourge have now allied themselves with the Alliance or Horde. Death knights are a hero class, which means they start at high level. Death knights use runes as their primary resource. Each of the three types of rune is used for different abilities.|n|nDeath knights have more ranged capabilities than most melee classes with an emphasis on causing diseases and doing damage with their undead pets. Their primary stat is Strength and also Stamina if tanking."
	},
	["CLASS_INFO_DEATHKNIGHT0"] = {
		ruRU = "- Роль: танкование, нанесение урона",
		enGB = "- Role: Tank, Damage"
	},
	["CLASS_INFO_DEATHKNIGHT1"] = {
		ruRU = "- Тяжелая броня (латы)",
		enGB = "- Heavy Armor (Plate)"
	},
	["CLASS_INFO_DEATHKNIGHT2"] = {
		ruRU = "- Рыцари смерти – это бывшие слуги Короля-лича.",
		enGB = "- Former servants of the Lich King."
	},
	["CLASS_INFO_DEATHKNIGHT3"] = {
		ruRU = "- Начальный уровень - 55.",
		enGB = "- Start at level 55."
	},
	["CLASS_INFO_DEATHKNIGHT4"] = {
		ruRU = "- Дополняет ведение ближнего боя призывом питомца, применением заклинаний и насыланием болезней.",
		enGB = "- Combine melee combat with spells, diseases and undead minions."
	},
	["CLASS_INFO_DEATHKNIGHT5"] = {
		ruRU = "- Пользуется рунами как ресурсом.",
		enGB = "- Uses runes as a resource."
	},
	["CLASS_SHAMAN"] = {
		ruRU = "Шаманы обращаются к духам стихий, чтобы усиливать свое оружие и заклинания. В бою для усиления и лечения союзников или нанесения урона врагам шаман использует тотемы. Шаман нередко становится духовным лидером своего племени. Основные характеристики зависят от игровой роли персонажа.",
		enGB = "Shaman use the power of the elements to enhance their weapon damage or spells. Shaman summon totems in combat, small objects that buff, heal or cause damage to enemies. Shaman often act as spiritual leaders in tribal communities. Their primary stats depend on their role."
	},
	["CLASS_SHAMAN_FEMALE"] = {
		ruRU = "Шаманы обращаются к духам стихий, чтобы усиливать свое оружие и заклинания. В бою для усиления и лечения союзников или нанесения урона врагам шаман использует тотемы. Шаман нередко становится духовным лидером своего племени. Основные характеристики зависят от игровой роли персонажа.",
		enGB = "Shaman use the power of the elements to enhance their weapon damage or spells. Shaman summon totems in combat, small objects that buff, heal or cause damage to enemies. Shaman often act as spiritual leaders in tribal communities. Their primary stats depend on their role."
	},
	["CLASS_INFO_SHAMAN0"] = {
		ruRU = "- Роль: лечение, нанесение урона",
		enGB = "- Role: Healer, Damage"
	},
	["CLASS_INFO_SHAMAN1"] = {
		ruRU = "- Средняя броня (кожа/кольчуга и щит)",
		enGB = "- Medium Armor (Leather / Mail and Shield)"
	},
	["CLASS_INFO_SHAMAN2"] = {
		ruRU = "- Взывает к силам четырех стихий",
		enGB = "- Invokes the power of the four elements."
	},
	["CLASS_INFO_SHAMAN3"] = {
		ruRU = "- Использует тотемы для усилений, лечения и нанесения урона.",
		enGB = "- Uses totems to buff, heal or deal damage."
	},
	["CLASS_INFO_SHAMAN4"] = {
		ruRU = "- На время зачаровывает оружие своими заклинаниями.",
		enGB = "- Temporarily enchants weapons with spells."
	},
	["CLASS_INFO_SHAMAN5"] = {
		ruRU = "- Пользуется маной как ресурсом.",
		enGB = "- Uses mana as a resource."
	},
	["CLASS_MAGE"] = {
		ruRU = "Маги – канонические волшебники Азерота. Долгими годами прилежной учебы они приобретают свои знания. Класс носит легкую броню, компенсируя свою уязвимость целым арсеналом атакующих и защитных заклинаний. Основные характеристики мага – сила заклинаний и интеллект.",
		enGB = "Mages are the iconic magic-users of Azeroth and learn their craft through intense research and study. They make up for their light armor with a potent array of offensive and defensive spells. Their primary stats are Spell Power and Intellect."
	},
	["CLASS_MAGE_FEMALE"] = {
		ruRU = "Маги – канонические волшебники Азерота. Долгими годами прилежной учебы они приобретают свои знания. Класс носит легкую броню, компенсируя свою уязвимость целым арсеналом атакующих и защитных заклинаний. Основные характеристики мага – сила заклинаний и интеллект.",
		enGB = "Mages are the iconic magic-users of Azeroth and learn their craft through intense research and study. They make up for their light armor with a potent array of offensive and defensive spells. Their primary stats are Spell Power and Intellect."
	},
	["CLASS_INFO_MAGE0"] = {
		ruRU = "- Роль: нанесение урона",
		enGB = "- Role: Damage"
	},
	["CLASS_INFO_MAGE1"] = {
		ruRU = "- Легкая броня (ткань)",
		enGB = "- Light Armor (Cloth)"
	},
	["CLASS_INFO_MAGE2"] = {
		ruRU = "- Взывает к силам огня, льда и тайной магии.",
		enGB = "- Deals Frost, Fire or Arcane magic damage."
	},
	["CLASS_INFO_MAGE3"] = {
		ruRU = "- Может превращать противников в безобидных животных или примораживать их к земле.",
		enGB = "- Can polymorph enemies or freeze them to the ground."
	},
	["CLASS_INFO_MAGE4"] = {
		ruRU = "- Умеет телепортироваться в города и создавать еду и воду.",
		enGB = "- Can teleport to cities and conjure food and water."
	},
	["CLASS_INFO_MAGE5"] = {
		ruRU = "- Пользуется маной как ресурсом.",
		enGB = "- Uses mana as a resource."
	},
	["CLASS_WARLOCK"] = {
		ruRU = "Чернокнижники пользуются проклятиями и заклинаниями стихии огня и Тьмы и вытягивают из противника жизненные силы. Души, вытянутые из врагов, служат усилению магии чернокнижников. Чернокнижники могут обращать свое здоровье в ману и телепортировать к себе участников группы.|n|nНекоторые сообщества Альянса трепещут перед чернокнижниками, в то время как некоторые кланы Орды видят в них превосходных лидеров. Как любой заклинатель, чернокнижник превыше всего ценит силу заклинаний и интеллект.",
		enGB = "Warlocks deal Fire or Shadow magic to damage, drain or curse their enemy. They can drain souls to power their spells. Warlocks can convert their health into mana or summon group members to their locations.|n|nWarlocks are feared in some Alliance societies while considered great leaders in some Horde societies. As casters, the warlock's primary stats are Spell Power and Intellect."
	},
	["CLASS_WARLOCK_FEMALE"] = {
		ruRU = "Чернокнижники пользуются проклятиями и заклинаниями стихии огня и Тьмы и вытягивают из противника жизненные силы. Души, вытянутые из врагов, служат усилению магии чернокнижников. Чернокнижники могут обращать свое здоровье в ману и телепортировать к себе участников группы.|n|nНекоторые сообщества Альянса трепещут перед чернокнижниками, в то время как некоторые кланы Орды видят в них превосходных лидеров. Как любой заклинатель, чернокнижник превыше всего ценит силу заклинаний и интеллект.",
		enGB = "Warlocks deal Fire or Shadow magic to damage, drain or curse their enemy. They can drain souls to power their spells. Warlocks can convert their health into mana or summon group members to their locations.|n|nWarlocks are feared in some Alliance societies while considered great leaders in some Horde societies. As casters, the warlock's primary stats are Spell Power and Intellect."
	},
	["CLASS_INFO_WARLOCK0"] = {
		ruRU = "- Роль: нанесение урона",
		enGB = "- Role: Damage"
	},
	["CLASS_INFO_WARLOCK1"] = {
		ruRU = "- Легкая броня (ткань)",
		enGB = "- Light Armor (Cloth)"
	},
	["CLASS_INFO_WARLOCK2"] = {
		ruRU = "- Призывает прислужников-демонов.",
		enGB = "- Summons demons as servants."
	},
	["CLASS_INFO_WARLOCK3"] = {
		ruRU = "- Акцент на проклятиях, вытягивании сил и эффектах, наносящих периодический урон.",
		enGB = "- Emphasis on curses, drains and damage-over-time spells."
	},
	["CLASS_INFO_WARLOCK4"] = {
		ruRU = "- Для некоторых способностей использует осколки души.",
		enGB = "- Can consume a Soul Shard for special abilities."
	},
	["CLASS_INFO_WARLOCK5"] = {
		ruRU = "- Пользуется маной как ресурсом.",
		enGB = "- Uses mana as a resource."
	},
	["CLASS_DRUID"] = {
		ruRU = "Друиды искусно меняют свой облик, принимая вид животных и растений. Есть три школы друидов. Друиды, пошедшие по пути равновесия, предпочитают дальний бой и атакуют противника заклинаниями сил природы и тайной магии, друиды-оборотни ведут сражение в ближнем бою в облике кошки и медведя, а друиды-целители восстанавливают здоровье себе и союзникам с помощью заклинаний постепенного исцеления. Основные характеристики друида определяются его игровой ролью.",
		enGB = "Druids are shape-shifters with an affinity for the plant and animal kingdoms. There are three types of druids: Balance druids who cast Nature or Arcane spells at range, Feral druids who can take on the form of a cat or bear to fight in melee, or Restoration druids who can heal their allies with an emphasis on heal-over-time spells. Druid primary stats depend on their role."
	},
	["CLASS_DRUID_FEMALE"] = {
		ruRU = "Друиды искусно меняют свой облик, принимая вид животных и растений. Есть три школы друидов. Друиды, пошедшие по пути равновесия, предпочитают дальний бой и атакуют противника заклинаниями сил природы и тайной магии, друиды-оборотни ведут сражение в ближнем бою в облике кошки и медведя, а друиды-целители восстанавливают здоровье себе и союзникам с помощью заклинаний постепенного исцеления. Основные характеристики друида определяются его игровой ролью.",
		enGB = "Druids are shape-shifters with an affinity for the plant and animal kingdoms. There are three types of druids: Balance druids who cast Nature or Arcane spells at range, Feral druids who can take on the form of a cat or bear to fight in melee, or Restoration druids who can heal their allies with an emphasis on heal-over-time spells. Druid primary stats depend on their role."
	},
	["CLASS_INFO_DRUID0"] = {
		ruRU = "- Роль: танкование, лечение, нанесение урона",
		enGB = "- Role: Tank, Healer, Damage"
	},
	["CLASS_INFO_DRUID1"] = {
		ruRU = "- Средняя броня (кожа)",
		enGB = "- Medium Armor (Leather)"
	},
	["CLASS_INFO_DRUID2"] = {
		ruRU = "- Превращается в животных.",
		enGB = "- Shape-shifts into animal forms."
	},
	["CLASS_INFO_DRUID3"] = {
		ruRU = "- Универсальность: доступны роли лекаря, \"танка\", заклинателя и бойца ближнего боя.",
		enGB = "- Versatile: can fill a healing, tanking, melee or caster role."
	},
	["CLASS_INFO_DRUID4"] = {
		ruRU = "- В разных обликах пользуется маной, яростью или энергией как ресурсом.",
		enGB = "- Uses mana, rage or energy as a resource depending on form."
	},

	["CHAR_INFO_CLASS_WARRIOR_DESC"] = {
		ruRU = "Воины тщательно готовятся к бою, а с противником сражаются лицом к лицу, принимая все удары на свои доспехи. Они пользуются различными боевыми тактиками и применяют разнообразное оружие, чтобы защитить своих более хрупких союзников. Для максимальной эффективности воины должны контролировать свою ярость — ту силу, что питает их наиболее опасные атаки.",
		enGB = "Warriors equip themselves carefully for combat and engage their enemies head-on, letting attacks glance off their heavy armor. They use diverse combat tactics and a wide variety of weapon types to protect their more vulnerable allies. Warriors must carefully master their rage – the power behind their strongest attacks – in order to maximize their effectiveness in combat.",
	},
	["CHAR_INFO_CLASS_WARRIOR_ROLE"] = {
		ruRU = "Роли: |cffffffffтанк или боец ближнего боя|r",
		enGB = "Roles: |cffffffffTank or Melee Damage|r",
	},
	["CHAR_INFO_CLASS_WARRIOR_SPELL1"] = {
		ruRU = "Ability_Racial_BloodRage|Когда воин получает урон, гнев его растет, позволяя в разгар битвы наносить поистине сокрушительные удары.",
		enGB = "Ability_Racial_BloodRage|As warriors deal or take damage, their rage grows, allowing them to deliver truly crushing attacks in the heat of battle.",
	},
	["CHAR_INFO_CLASS_WARRIOR_SPELL2"] = {
		ruRU = "spell_shadow_unholyfrenzy|После получения урона в бою наносимый воином урон с вероятностью 30% увеличится на 10% на 12 сек.",
		enGB = "spell_shadow_unholyfrenzy|Gives you a 30% chance to receive a 10% damage bonus for 12 sec after being the victim of a damaging attack.",
	},
	["CHAR_INFO_CLASS_WARRIOR_SPELL3"] = {
		ruRU = "Ability_Defend|При успешном блокировании атаки воин с вероятностью 60% заблокирует в два раза больше урона. Вероятность нанести критический удар при применении способности Мощный удар щитом повышается на 15%.",
		enGB = "Ability_Defend|Your successful blocks have a 60% chance to block double the normal amount and increases your chance to critically hit with your Shield Slam ability by an additional 15%.",
	},
	["CHAR_INFO_CLASS_WARRIOR_SPELL4"] = {
		ruRU = "Spell_Shadow_DeathPact|Вводит воина в состояние ярости, в котором наносимый физический урон увеличивается на 20%, а весь получаемый урон – на 5%.",
		enGB = "Spell_Shadow_DeathPact|When activated you become enraged, increasing your physical damage by 20% but increasing all damage taken by 5%.",
	},
	["CHAR_INFO_CLASS_WARRIOR_SPELL5"] = {
		ruRU = "Ability_Warrior_Shockwave|Посылает перед воином силовую волну, наносящую урона (величина зависит от силы атаки) и оглушающую всех противников на расстоянии 10 м. перед ним на 4 сек.",
		enGB = "Ability_Warrior_Shockwave|Sends a wave of force in front of the warrior, causing a certain amount of damage (based on attack power) and stunning all enemy targets within 10 yards in a frontal cone for 4 sec.",
	},
	["CHAR_INFO_CLASS_PALADIN_DESC"] = {
		ruRU = "Паладины бьются с врагом лицом к лицу, полагаясь на тяжелые доспехи и навыки целительства. Прочный щит или двуручное оружие — не столь важно, чем владеет паладин. Он сумеет не только защитить соратников от вражеских когтей и клинков, но и удержит группу на ногах при помощи исцеляющих заклинаний.",
		enGB = "Paladins stand directly in front of their enemies, relying on heavy armor and healing in order to survive incoming attacks. Whether with massive shields or crushing two-handed weapons, Paladins are able to keep claws and swords from their weaker fellows – or they use healing magic to ensure that they remain on their feet.",
	},
	["CHAR_INFO_CLASS_PALADIN_ROLE"] = {
		ruRU = "Роли: |cffffffffтанк, лекарь или боец ближнего боя|r",
		enGB = "Roles: |cffffffffTank, Healer, or Melee Damage|r",
	},
	["CHAR_INFO_CLASS_PALADIN_SPELL1"] = {
		ruRU = "Spell_Holy_DevotionAura|Паладины, защитники порядка, очень эффективны в группе: их благословения и ауры могут повысить наносимый урон и повысить выживаемость и для них самих, и для их союзников.",
		enGB = "Spell_Holy_DevotionAura|As champions of order, paladins are extremely potent in a group – their blessings and auras can improve damage and survivability for both themselves and their party.",
	},
	["CHAR_INFO_CLASS_PALADIN_SPELL2"] = {
		ruRU = "Ability_Paladin_SanctifiedWrath|Увеличивает вероятность критического удара заклинания Молот гнева на 50%, сокращает время восстановления заклинания Гнев карателя на 60 сек. Когда паладин находится под действием заклинания Гнев карателя, 50% наносимого паладином урона игнорируют все снижающие урон эффекты.",
		enGB = "Ability_Paladin_SanctifiedWrath|Increases the critical strike chance of Hammer of Wrath by 50%, reduces the cooldown of Avenging Wrath by 60 secs and while affected by Avenging Wrath 50% of all damage caused bypasses damage reduction effects.",
	},
	["CHAR_INFO_CLASS_PALADIN_SPELL3"] = {
		ruRU = "Spell_Holy_ArdentDefender|Если при получении удара уровень здоровья паладина падает ниже 35%, весь получаемый вами урон снижается на 20%. Удары, которые могли бы оказаться смертельными, вместо этого восстанавливают паладину до 30% от максимального запаса здоровья (количество восполненного здоровья зависит от защиты).",
		enGB = "Spell_Holy_ArdentDefender|Damage that takes you below 35% health is reduced by 20%. In addition, attacks which would otherwise kill you cause you to be healed by up to 30% of your maximum health (amount healed based on defense).",
	},
	["CHAR_INFO_CLASS_PALADIN_SPELL4"] = {
		ruRU = "Spell_Holy_BlessingOfProtection|Повышает вероятность блокировать удар на 30% на 10 сек. Если атака блокирована, атакующему наносится урон от светлой магии. При каждом блоке расходуется 1 заряд. 8 зарядов.",
		enGB = "Spell_Holy_BlessingOfProtection|Increases chance to block by 30% for 10 sec and deals Holy damage for each attack blocked while active. Each block expends a charge. 8 charges.",
	},
	["CHAR_INFO_CLASS_PALADIN_SPELL5"] = {
		ruRU = "Ability_Paladin_BeaconofLight|Наделяет выбранного участника группы или рейда частицей Света. Любое исцеляющее заклинание, которое вы накладываете на союзников в радиусе 60 метров от цели, также восстанавливает наделенному Светом персонажу 100% от объема восстановленного с помощью этого заклинания здоровья. Частицей Света можно наделить только одного персонажа.",
		enGB = "Ability_Paladin_BeaconofLight|The target becomes a Beacon of Light to all members of your party or raid within a 60 yard radius. Any heals you cast on party or raid members will also heal the Beacon for 100% of the amount healed. Only one target can be the Beacon of Light at a time.",
	},
	["CHAR_INFO_CLASS_HUNTER_DESC"] = {
		ruRU = "Охотники бьют врага на расстоянии, приказывая питомцам атаковать, пока сами натягивают тетиву или заряжают ружье. Ружья и луки очень действенны и вблизи, и издалека. Кроме того, охотники очень подвижны. Они могут уклониться от атаки или задержать противника, чтобы выиграть время.",
		enGB = "Hunters battle their foes at a distance, commanding their pets to attack while they nock their arrows and fire their guns. Though their missile weapons are effective at short and long ranges, hunters are also highly mobile. They can evade or restrain their foes to control the arena of battle.",
	},
	["CHAR_INFO_CLASS_HUNTER_ROLE"] = {
		ruRU = "Роль: |cffffffffбоец дальнего боя|r",
		enGB = "Role: |cffffffffRanged Damage|r",
	},
	["CHAR_INFO_CLASS_HUNTER_SPELL1"] = {
		ruRU = "Ability_Hunter_BeastTaming|Охотники приручают диких зверей, которые служат им, нападая на врагов и прикрывая хозяина.",
		enGB = "Ability_Hunter_BeastTaming|Hunters tame the beasts of the wild, and those beasts serve in return by assaulting their enemies and shielding them from harm.",
	},
	["CHAR_INFO_CLASS_HUNTER_SPELL2"] = {
		ruRU = "Ability_Hunter_LongShots|Повышает вероятность критического удара способности Убийственный выстрел на 15%. Если охотник не двигается в течение 6 сек., на него накладывается эффект Навыки снайпера, увеличивающий урон от способностей Верный выстрел, Прицельный выстрел, Черная стрела и Разрывной выстрел на 6%.",
		enGB = "Ability_Hunter_LongShots|Increases the critical strike chance of your Kill Shot ability by 15%, and while standing still for 6 sec, you gain Sniper Training increasing the damage done by your Steady Shot, Aimed Shot, Black Arrow and Explosive Shot by 6%.",
	},
	["CHAR_INFO_CLASS_HUNTER_SPELL3"] = {
		ruRU = "Ability_Hunter_WildQuiver|Если при автоматической стрельбе выстрел охотника наносит урон, он с вероятностью 12% делает дополнительный выстрел, наносящий 80% урона от оружия. Этот урон считается уроном от сил природы. Боеприпасы при этом не расходуются.",
		enGB = "Ability_Hunter_WildQuiver|You have a 12% chance to shoot an additional shot when doing damage with your auto shot, dealing 80% weapon nature damage. Wild Quiver consumes no ammo.",
	},
	["CHAR_INFO_CLASS_HUNTER_SPELL4"] = {
		ruRU = "Spell_Shadow_PainSpike|Поражает цель, повышая весь наносимый охотником урон по цели на 6% и нанося урон от темной магии.",
		enGB = "Spell_Shadow_PainSpike|Fires a Black Arrow at the target, increasing all damage done by you to the target by 6% and dealing Shadow damage.",
	},
	["CHAR_INFO_CLASS_HUNTER_SPELL5"] = {
		ruRU = "Ability_Druid_FerociousBite|Питомца обуревает ярость, увеличивающая наносимый им урон на 50% на 10 сек. В ярости питомец не знает ни страха, ни жалости, и его может остановить только смерть.",
		enGB = "Ability_Druid_FerociousBite|Send your pet into a rage causing 50% additional damage for 10 sec. While enraged, the beast does not feel pity or remorse or fear and it cannot be stopped unless killed.",
	},
	["CHAR_INFO_CLASS_ROGUE_DESC"] = {
		ruRU = "Разбойники часто нападают из теней, начиная бой комбинацией свирепых ударов. В затяжном бою они изматывают врага тщательно продуманной серией атак, прежде чем нанести решающий удар. Разбойнику следует внимательно отнестись к выбору противника, чтобы оптимально использовать тактику, и не упустить момент, когда надо спрятаться или бежать, если ситуация складывается не в их пользу.",
		enGB = "Rogues often initiate combat with a surprise attack from the shadows, leading with vicious melee strikes. When in protracted battles, they utilize a successive combination of carefully chosen attacks to soften the enemy up for a killing blow. Rogues must take special care when selecting targets so that their combo attacks are not wasted, and they must be conscious of when to hide or flee if a battle turns against them.",
	},
	["CHAR_INFO_CLASS_ROGUE_ROLE"] = {
		ruRU = "Роль: |cffffffffбоец ближнего боя|r",
		enGB = "Role: |cffffffffMelee Damage|r",
	},
	["CHAR_INFO_CLASS_ROGUE_SPELL1"] = {
		ruRU = "Ability_Rogue_CombatExpertise|Разбойники могут наносить приемы сериями, что позволяет сделать завершающий удар поистине сокрушительным.",
		enGB = "Ability_Rogue_CombatExpertise|By planning and combining successive melee attacks, rogues can build up combo points that allow them to deliver devastating finishing blows in combat.",
	},
	["CHAR_INFO_CLASS_ROGUE_SPELL2"] = {
		ruRU = "INV_Sword_27|С вероятностью 5% позволяет атаковать противника повторно после того, как разбойник ударит его мечом или топором.",
		enGB = "INV_Sword_27|Gives you a 5% chance to get an extra attack on the same target after hitting your target with your Sword or Axe.",
	},
	["CHAR_INFO_CLASS_ROGUE_SPELL3"] = {
		ruRU = "Ability_Rogue_CutToTheChase|С вероятностью 100% применение способностей Потрошение и Отравление возобновит продолжительность действия вашей способности Мясорубка до максимально возможного времени.",
		enGB = "Ability_Rogue_CutToTheChase|Your Eviscerate and Envenom abilities have a 100% chance to refresh your Slice and Dice duration.",
	},
	["CHAR_INFO_CLASS_ROGUE_SPELL4"] = {
		ruRU = "Ability_Rogue_ShadowDance|Начав танец теней, разбойник может использовать способности, которые обычно требуют состояния незаметности.",
		enGB = "Ability_Rogue_ShadowDance|Enter the Shadow Dance, allowing the use of abilities regardless of being stealthed.",
	},
	["CHAR_INFO_CLASS_ROGUE_SPELL5"] = {
		ruRU = "Ability_Rogue_MurderSpree|Разбойник проходит сквозь тень, от противника к противнику, в радиусе 10 м, атакуя каждые 0,5 секунды обоими оружиями, пока не будет совершено 5 атак. Во время действия эффекта наносимый урон возрастает на 20%. Разбойник может атаковать одну цель несколько раз. Не затрагивает невидимые или незаметные цели.",
		enGB = "Ability_Rogue_MurderSpree|Step through the shadows from enemy to enemy within 10 yards, attacking an enemy every .5 secs with both weapons until 5 assaults are made, and increasing all damage done by 20% for the duration. Can hit the same target multiple times. Cannot hit invisible or stealthed targets.",
	},
	["CHAR_INFO_CLASS_PRIEST_DESC"] = {
		ruRU = "Жрецы могут задействовать мощную целительную магию, чтобы спасти себя и своих спутников. Им подвластны и сильные атакующие заклинания, но физическая слабость и отсутствие прочных доспехов заставляют жрецов бояться сближения с противником. Опытные жрецы используют боевые и контролирующие способности, не допуская гибели членов отряда.",
		enGB = "Priests use powerful healing magic to fortify themselves and their allies. They also wield powerful offensive spells from a distance, but can be overwhelmed by enemies due to their physical frailty and minimal armor. Experienced priests carefully balance the use of their offensive powers when tasked with keeping their party alive.",
	},
	["CHAR_INFO_CLASS_PRIEST_ROLE"] = {
		ruRU = "Роли: |cffffffffлекарь или боец дальнего боя|r",
		enGB = "Roles: |cffffffffHealer or Ranged Damage|r",
	},
	["CHAR_INFO_CLASS_PRIEST_SPELL1"] = {
		ruRU = "Spell_Holy_HolyProtection|Повышает вероятность критического целебного эффекта заклинаний Быстрое исцеление, Великое исцеление и Исповедь на целях, находящихся под воздействием эффекта Ослабленная душа, на 4%. С вероятностью 100% после применения заклинания Слово силы: Щит урон, получаемый всеми участниками группы или рейда, на 60 сек. уменьшится на 3%.",
		enGB = "Spell_Holy_HolyProtection|Increases the critical effect chance of your Flash Heal, Greater Heal and Penance (Heal) spells by 4% on targets afflicted by the Weakened Soul effect, and you have a 100% chance to reduce all damage taken by 3% for 1 min to all friendly party and raid targets when you cast Power Word: Shield.",
	},
	["CHAR_INFO_CLASS_PRIEST_SPELL2"] = {
		ruRU = "Spell_Holy_SpiritualGuidence|Увеличивает силу заклинаний на 25% от вашего показателя духа.",
		enGB = "Spell_Holy_SpiritualGuidence|Increases spell power by 25% of your total Spirit.",
	},
	["CHAR_INFO_CLASS_PRIEST_SPELL3"] = {
		ruRU = "Spell_Shadow_Metamorphosis|Увеличивает дополнительный урон от критических эффектов заклинаний Взрыв разума, Пытка разума и Слово Тьмы: Смерть на 100%.",
		enGB = "Spell_Shadow_Metamorphosis|Increases the critical strike damage bonus of your Mind Blast, Mind Flay, and Shadow Word: Death spells by 100%.",
	},
	["CHAR_INFO_CLASS_PRIEST_SPELL4"] = {
		ruRU = "Spell_Shadow_SummonVoidWalker|Жрец принимает облик Тьмы, в котором наносимый им урон от темной магии увеличивается на 15%, получаемый урон уменьшается на 15%, а уровень создаваемой угрозы понижается на 30%. В этом облике нельзя использовать светлую магию, за исключением некоторых заклинаний. Заклинания магии тьмы усиливаются.",
		enGB = "Spell_Shadow_SummonVoidWalker|Assume a Shadowform, increasing your Shadow damage by 15%, reducing all damage done to you by 15% and threat generated by 30%. However, you may not cast Holy spells while in this form, with a few exceptions. Increases Shadow damage.",
	},
	["CHAR_INFO_CLASS_PRIEST_SPELL5"] = {
		ruRU = "Spell_Holy_GuardianSpirit|Призывает оберегающего духа для охраны дружественной цели. Дух улучшает действие всех эффектов исцеления на выбранного союзника на 40% и спасает его от смерти, жертвуя собой. Смерть духа прекращает действие эффекта улучшенного исцеления, но восстанавливает цели 50% ее максимального запаса здоровья.",
		enGB = "Spell_Holy_GuardianSpirit|Calls upon a guardian spirit to watch over the friendly target. The spirit increases the healing received by the target by 40%, and also prevents the target from dying by sacrificing itself. This sacrifice terminates the effect but heals the target of 50% of their maximum health.",
	},
	["CHAR_INFO_CLASS_DEATHKNIGHT_DESC"] = {
		ruRU = "Рыцари смерти сходятся с противником в ближнем бою, дополняя удары клинка темной магией, которая делает врага уязвимым или ранит его нечестивой энергией. Они провоцируют противников, вынуждая их сражаться один на один и не подпуская их к более слабым союзникам. Чтобы не дать противнику ускользнуть, рыцари смерти должны постоянно помнить о силе, извлекаемой из рун, и соответствующим образом направлять свои атаки.",
		enGB = "Death Knights engage their foes up-close, supplementing swings of their weapons with dark magic that renders enemies vulnerable or damages them with unholy power. They drag foes into one-on-one conflicts, compelling them to focus their attacks away from weaker companions. To prevent their enemies from fleeing their grasp, death knights must remain mindful of the power they call forth from runes, and pace their attacks appropriately.",
	},
	["CHAR_INFO_CLASS_DEATHKNIGHT_ROLE"] = {
		ruRU = "Роли: |cffffffffтанк или боец ближнего боя|r",
		enGB = "Roles: |cffffffffTank or Melee Damage|r",
	},
	["CHAR_INFO_CLASS_DEATHKNIGHT_SPELL1"] = {
		ruRU = "Spell_DeathKnight_FrozenRuneWeapon|Рыцари смерти связаны со своими клинками и могут высекать на них руны, увеличивая силу оружия.",
		enGB = "Spell_DeathKnight_FrozenRuneWeapon|Death knights have a personal connection with their blades, and can forge runes into them in order to increase their power.",
	},
	["CHAR_INFO_CLASS_DEATHKNIGHT_SPELL2"] = {
		ruRU = "Spell_Shadow_CallofBone|Когда болезнь, которой рыцарь смерти заразил противника, причиняет ему урон, то с вероятностью, равной вероятности нанесения критического удара в ближнем бою, она нанесет еще 100% урона цели и всем врагам в радиусе 8 м. Заклинание игнорирует цели, находящиеся под воздействием эффектов, которые прерываются при получении урона.",
		enGB = "Spell_Shadow_CallofBone|When your diseases damage an enemy, there is a chance equal to your melee critical strike chance that they will cause 100% additional damage to the target and all enemies within 8 yards. Ignores any target under the effect of a spell that is cancelled by taking damage.",
	},
	["CHAR_INFO_CLASS_DEATHKNIGHT_SPELL3"] = {
		ruRU = "Spell_Misc_WarsongFocus|Повышает силу рыцаря смерти на 6%, выносливость на 3%, а мастерство – на 6.",
		enGB = "Spell_Misc_WarsongFocus|Increases your total Strength by 6%, your Stamina by 3%, and your expertise by 6.",
	},
	["CHAR_INFO_CLASS_DEATHKNIGHT_SPELL4"] = {
		ruRU = "Ability_DeathKnight_BoneShield|Вокруг рыцаря смерти начинают вращаться 3 кости. Каждая атака, нанесшая урон рыцарю смерти, уничтожает 1 кость. До тех пор, пока остается хотя бы одна кость, рыцарь смерти получает на 20% меньше урона и наносит на 2% больше урона всеми атаками, заклинаниями и способностями.",
		enGB = "Ability_DeathKnight_BoneShield|The Death Knight is surrounded by 3 whirling bones. Each damaging attack that lands consumes 1 bone. While at least 1 bone remains, the Death Knight takes 20% less damage from all sources and deals 2% more damage with all attacks, spells and abilities.",
	},
	["CHAR_INFO_CLASS_DEATHKNIGHT_SPELL5"] = {
		ruRU = "Spell_DeathKnight_BladedArmor|Погружает дружественную цель в кровожадное безумие на 30 сек. Цель впадает в исступление: наносимый ею физический урон увеличивается на 20%, но каждую секунду она теряет 1% от максимального запаса здоровья.",
		enGB = "Spell_DeathKnight_BladedArmor|Induces a friendly unit into a killing frenzy for 30 sec. The target is Enraged, which increases their physical damage by 20%, but causes them to lose health equal to 1% of their maximum health every second.",
	},
	["CHAR_INFO_CLASS_SHAMAN_DESC"] = {
		ruRU = "В бою шаман ставит на землю контролирующие и наносящие урон тотемы, чтобы помочь союзникам и ослабить противника. Шаманы могут как вступать в ближний бой, так и атаковать с расстояния. Мудрый шаман всегда старается учитывать сильные и слабые стороны врага.",
		enGB = "During combat, shaman place damaging and controlling totems on the ground to maximize their effectiveness while hindering their enemies. Shaman are versatile enough to battle foes up close or at range, but wise shaman choose their avenue of attack based on their enemies’ strengths and weaknesses.",
	},
	["CHAR_INFO_CLASS_SHAMAN_ROLE"] = {
		ruRU = "Роли: |cffffffffлекарь, боец дальнего или ближнего боя|r",
		enGB = "Roles: |cffffffffHealer, Ranged Damage, or Melee Damage|r",
	},
	["CHAR_INFO_CLASS_SHAMAN_SPELL1"] = {
		ruRU = "Ability_Shaman_TranquilMindTotem|Тотемы шамана обладают массой положительных свойств: они увеличивают скорость атаки, эффективность восстановления и наносимый противнику урон.",
		enGB = "Ability_Shaman_TranquilMindTotem|Shaman totems have many positive effects: they can increase attack speed, healing efficiency, or damage done.",
	},
	["CHAR_INFO_CLASS_SHAMAN_SPELL2"] = {
		ruRU = "Spell_Nature_BloodLust|Увеличивает силу атаки на 100% от величины интеллекта шамана.",
		enGB = "Spell_Nature_BloodLust|Increases your Attack Power by 100% of your Intellect.",
	},
	["CHAR_INFO_CLASS_SHAMAN_SPELL3"] = {
		ruRU = "Spell_Nature_LightningOverload|При произнесении заклинаний Молния и Цепная молния шаман с вероятностью 33% может поразить противника еще одним таким же заклинанием. Второе заклинание не требует затрат маны, наносит в два раза меньше урона и не создает угрозы.",
		enGB = "Spell_Nature_LightningOverload|Gives your Lightning Bolt and Chain Lightning spells a 33% chance to cast a second, similar spell on the same target at no additional cost that causes half damage and no threat.",
	},
	["CHAR_INFO_CLASS_SHAMAN_SPELL4"] = {
		ruRU = "Spell_Nature_SkinofEarth|Защищает цель земляным щитом, который уменьшает время, теряемое из-за получения урона при произнесении и поддержании заклинаний, на 30%. Кроме того, атаки восстанавливают защищенной цели здоровье, но этот эффект срабатывает не чаще, чем раз в несколько секунд. 6 зарядов.",
		enGB = "Spell_Nature_SkinofEarth|Protects the target with an earthen shield, reducing casting or channeling time lost when damaged by 30% and causing attacks to heal the shielded target. This effect can only occur once every few seconds. 6 charges.",
	},
	["CHAR_INFO_CLASS_SHAMAN_SPELL5"] = {
		ruRU = "Spell_Nature_WispHeal|Делает следующее заклинание Молния, Цепная молния или Выброс лавы мгновенным. Повышает скорость произнесения заклинаний на 15% на 15 сек. Имеет общее время восстановления с заклинанием Природная стремительность.",
		enGB = "Spell_Nature_WispHeal|When activated, your next Lightning Bolt, Chain Lightning or Lava Burst spell becomes an instant cast spell. In addition, you gain 15% spell haste for 15 sec. Elemental Mastery shares a cooldown with Nature's Swiftness.",
	},
	["CHAR_INFO_CLASS_MAGE_DESC"] = {
		ruRU = "Маги уничтожают врагов тайными заклинаниями. Несмотря на магическую силу, маги хрупки, не носят тяжелых доспехов, поэтому уязвимы в ближнем бою. Умные маги при помощи заклинаний удерживают врага на расстоянии или вовсе обездвиживают его.",
		enGB = "Mages demolish their foes with arcane incantations. Although they wield powerful offensive spells, mages are fragile and lightly armored, making them particularly vulnerable to close-range attacks. Wise mages make careful use of their spells to keep their foes at a distance or hold them in place.",
	},
	["CHAR_INFO_CLASS_MAGE_ROLE"] = {
		ruRU = "Роль: |cffffffffбоец дальнего боя|r",
		enGB = "Role: |cffffffffRanged Damage|r",
	},
	["CHAR_INFO_CLASS_MAGE_SPELL1"] = {
		ruRU = "Spell_Arcane_PortalDalaran|Маги обладают способностью перемещаться между городами и создавать пищу и воду, где бы они ни находились.",
		enGB = "Spell_Arcane_PortalDalaran|Mages possess the ability to transport themselves and their allies between cities and can summon replenishing food and water.",
	},
	["CHAR_INFO_CLASS_MAGE_SPELL2"] = {
		ruRU = "Ability_Mage_WintersGrasp|При наложении эффектов окоченения вы с 15%-й вероятностью можете попасть под действие эффекта Ледяные пальцы. Во время его действия для 2 ваших последующих заклинаний цель считается замороженной.",
		enGB = "Ability_Mage_WintersGrasp|Gives your Chill effects a 15% chance to grant you the Fingers of Frost effect, which treats your next 2 spells cast as if the target were Frozen.",
	},
	["CHAR_INFO_CLASS_MAGE_SPELL3"] = {
		ruRU = "Spell_Arcane_StarFire|Повышает вероятность нанести критический урон заклинанием, накладываемым в состоянии Ясность мысли или Величие разума на 30%.",
		enGB = "Spell_Arcane_StarFire|Increases the critical strike chance of your next damaging spell by 30% after gaining Clearcasting or Presence of Mind.",
	},
	["CHAR_INFO_CLASS_MAGE_SPELL4"] = {
		ruRU = "Spell_Nature_Lightning|При использовании увеличивает урон, наносимый вашими заклинаниями, на 20% и затраты маны на 20%.",
		enGB = "Spell_Nature_Lightning|When activated, your spells deal 20% more damage while costing 20% more mana to cast.",
	},
	["CHAR_INFO_CLASS_MAGE_SPELL5"] = {
		ruRU = "Spell_Fire_SelfDestruct|При использовании повышает критический урон заклинаний магии огня на 50%. Каждое заклинание магии огня, достигшее цели, увеличивает вероятность нанесения критического урона от огня на 10%. Этот эффект длится, пока 3 заклинания огня не нанесут критический урон прямым действием.",
		enGB = "Spell_Fire_SelfDestruct|When activated, this spell increases your critical strike damage bonus with Fire damage spells by 50%, and causes each of your Fire damage spell hits to increase your critical strike chance with Fire damage spells by 10%. This effect lasts until you have caused 3 non-periodic critical strikes with Fire spells.",
	},
	["CHAR_INFO_CLASS_WARLOCK_DESC"] = {
		ruRU = "Чернокнижники уничтожают ослабленного противника, сочетая увечащие проклятия и темную магию. Находясь под защитой своих питомцев, чернокнижники разят врага на расстоянии. Физически слабые колдуны не могут носить тяжелую броню, поэтому подставляют под вражеские удары своих слуг.",
		enGB = "Warlocks burn and destroy weakened foes with a combination of crippling illnesses and dark magic. While their demon pets protect and enhance them, warlocks strike at their enemies from a distance. As physically weak spellcasters bereft of heavy armor, cunning warlocks allow their minions to take the brunt of enemy attacks in order to save their own skin.",
	},
	["CHAR_INFO_CLASS_WARLOCK_ROLE"] = {
		ruRU = "Роль: |cffffffffбоец дальнего боя|r",
		enGB = "Role: |cffffffffRanged Damage|r",
	},
	["CHAR_INFO_CLASS_WARLOCK_SPELL1"] = {
		ruRU = "Spell_Shadow_SummonImp|Чернокнижники подчиняют своей воле демонов: обитатели Круговерти Пустоты защищают своих хозяев и сражаются с их врагами.",
		enGB = "Spell_Shadow_SummonImp|Warlocks bind demons to their will; these infernal denizens defend their masters with their lives or rain death upon their enemies.",
	},
	["CHAR_INFO_CLASS_WARLOCK_SPELL2"] = {
		ruRU = "Ability_Warlock_Backdraft|После произнесения заклинания Поджигание скорость произнесения и общее время восстановления следующих трех заклинаний категории Разрушение уменьшается на 30%.",
		enGB = "Ability_Warlock_Backdraft|When you cast Conflagrate, the cast time and global cooldown of your next three Destruction spells is reduced by 30%.",
	},
	["CHAR_INFO_CLASS_WARLOCK_SPELL3"] = {
		ruRU = "Ability_Warlock_Eradication|При нанесении урона Порчей чернокнижник с 6%-й вероятностью может увеличить скорость применения заклинаний на 20%.",
		enGB = "Ability_Warlock_Eradication|When you deal damage with Corruption, you have 6% chance to increase your spell casting speed by 20%.",
	},
	["CHAR_INFO_CLASS_WARLOCK_SPELL4"] = {
		ruRU = "Spell_Shadow_DemonForm|Чернокнижник превращается в демона на 30 сек. Его броня усиливается на 600%, наносимый урон увеличивается на 20%, вероятность, что атаки ближнего боя нанесут ему критическое повреждение, уменьшается на 6%, а длительность действия эффектов оглушения и сковывания снижается на 50%. Чернокнижник приобретает уникальные демонические способности вдобавок к своим обычным.",
		enGB = "Spell_Shadow_DemonForm|You transform into a Demon for 30 sec. This form increases your armor contribution from items by 600%, damage by 20%, reduces the chance you'll be critically hit by melee attacks by 6% and reduces the duration of stun and snare effects by 50%. You gain some unique demon abilities in addition to your normal abilities.",
	},
	["CHAR_INFO_CLASS_WARLOCK_SPELL5"] = {
		ruRU = "Ability_Warlock_Haunt|В противника вселяется блуждающий дух, который наносит урон от темной магии и увеличивает периодический урон от ваших заклинаний темной магии на 20% на 12 сек. Если заклинание было рассеяно или его действие завершилось, блуждающий дух возвращается к чернокнижнику, исцеляя его на 100% от урона, нанесенного противнику.",
		enGB = "Ability_Warlock_Haunt|You send a ghostly soul into the target, dealing Shadow damage and increasing all damage done by your Shadow damage-over-time effects on the target by 20% for 12 sec. When the Haunt spell ends or is dispelled, the soul returns to you, healing you for 100% of the damage it did to the target.",
	},
	["CHAR_INFO_CLASS_DEMONHUNTER_DESC"] = {
		ruRU = "Охотники на демонов не пользуются тяжелой броней, вместо этого полагаясь на скорость, которая дает им возможность стремительно приближаться к противнику и наносить ему урон одноручным оружием. Однако иллидари не стоит забывать о том, чтобы использовать свою ловкость и в защитных целях, обеспечивая себе благоприятный исход битвы.",
		enGB = "Forgoing heavy armor, Demon Hunters capitalize on speed, closing the distance quickly to strike enemies with one-handed weapons. However, Illidari must also use their agility defensively to ensure that battles end favorably.",
	},
	["CHAR_INFO_CLASS_DEMONHUNTER_ROLE"] = {
		ruRU = "Роли: |cffffffffтанк или боец ближнего боя|r",
		enGB = "Roles: |cffffffffTank or Melee Damage|r",
	},
	["CHAR_INFO_CLASS_DEMONHUNTER_SPELL1"] = {
		ruRU = "|За кажущейся слепотой охотников на демонов скрывается истинная сила их обостренного восприятия. Они способны обнаруживать даже хорошо замаскировавшихся противников.",
		enGB = "|The Demon Hunters’ apparent blindness belies their true powers of perception. They rely on magically augmented sight to detect enemies, even those that hide behind obstacles.",
	},
	["CHAR_INFO_CLASS_DEMONHUNTER_SPELL2"] = {
		ruRU = "|Охотники на демонов могут выполнять двойные прыжки, длинные кувырки и даже распахивать свои гигантские крылья, которые позволяют им планировать в воздухе и внезапно нападать на врагов сверху.",
		enGB = "|Demon Hunters can double jump, vault in and out of combat, and unfold their monstrous wings, surprising enemies from above with devastating attacks.",
	},
	["CHAR_INFO_CLASS_DEMONHUNTER_SPELL3"] = {
		ruRU = "|На месте убитого противника иногда остается фрагмент души. Подойдя к фрагменту души, охотник на демонов поглощает его, восстанавливая 25% от максимального запаса здоровья.",
		enGB = "|Killing an enemy sometimes creates a Soul Fragment that is consumed when you approach it, healing you for 25% of maximum health.",
	},
	["CHAR_INFO_CLASS_DEMONHUNTER_SPELL4"] = {
		ruRU = "|Охотник на демонов освобождает демоническую энергию, обращаясь в демона. В облике демона его способности заменяются на более мощные, и в зависимости от специализации или увеличивая рейтинг скорости, или рейтинг брони.",
		enGB = "|You release demonic energy, turning into a demon. In demon form, your abilities become more powerful and your haste/armor rating increases (depending on the specialization).",
	},
	["CHAR_INFO_CLASS_DEMONHUNTER_SPELL5"] = {
		ruRU = "|Освобождает свою демоническую энергию, материализуя её в виде тени охотника на демонов, которая атакует те же цели, что и сам охотник, при этом усиливая его атаки.",
		enGB = "|Releases demonic energy, manifesting it in the form of your shadow, which will attack your targets and improve your attacks.",
	},
	["CHAR_INFO_CLASS_DRUID_DESC"] = {
		ruRU = "Друиды могут подходить к сражению совершенно по-разному. Они вольны играть почти любую роль в команде: быть целителями, танками или бойцами, но должны помнить об особенностях каждой роли. Друид вынужден внимательно подбирать облик к ситуации, так как каждый из них служит определенной цели.",
		enGB = "Druids are versatile combatants, in that they can fulfill nearly every role – healing, tanking, and damage dealing. It’s critical that druids tailor the form they choose to the situation, as each form bears a specific purpose.",
	},
	["CHAR_INFO_CLASS_DRUID_ROLE"] = {
		ruRU = "Роли: |cffffffffтанк, лекарь, боец дальнего или ближнего боя|r",
		enGB = "Roles: |cffffffffTank, Healer, Ranged Damage, or Melee Damage|r",
	},
	["CHAR_INFO_CLASS_DRUID_SPELL1"] = {
		ruRU = "Ability_Druid_TravelForm|Cпособность друидов менять облик позволяет им играть разные роли в команде: танка, целителя или бойца. Также смена облика дает возможность быстро передвигаться по суше, морю и воздуху.",
		enGB = "Ability_Druid_TravelForm|Druids are versatile combatants, in that they can fulfill nearly every role – healing, tanking, and damage dealing. It’s critical that druids tailor the form they choose to the situation, as each form bears a specific purpose.",
	},
	["CHAR_INFO_CLASS_DRUID_SPELL2"] = {
		ruRU = "Spell_Holy_BlessingOfAgility|Повышает интеллект на 20%. Также повышает выносливость в облике медведя и лютого медведя на 10%, а в облике кошки – силу атаки на 10%.",
		enGB = "Spell_Holy_BlessingOfAgility|Increases your Intellect by 20%. In addition, while in Bear or Dire Bear Form your Stamina is increased by 10% and while in Cat Form your attack power is increased by 10%.",
	},
	["CHAR_INFO_CLASS_DRUID_SPELL3"] = {
		ruRU = "Ability_Druid_Eclipse|После нанесения критического удара заклинанием Звездный огонь с вероятностью 100% урон от заклинания Гнев увеличится на 40%. После нанесения критического удара заклинанием Гнев с вероятностью 60% рейтинг критического удара заклинания Звездный огонь повысится на 40%.",
		enGB = "Ability_Druid_Eclipse|When you critically hit with Starfire, you have a 100% chance of increasing damage done by Wrath by 40%. When you critically hit with Wrath, you have a 60% chance of increasing your critical strike chance with Starfire by 40%.",
	},
	["CHAR_INFO_CLASS_DRUID_SPELL4"] = {
		ruRU = "Ability_Druid_TreeofLife|Принять облик Древа Жизни. В этом облике вы увеличиваете эффективность исцеления всех участников группы или рейда в радиусе 100 м на 6% и можете произносить только заклинания школы Исцеления",
		enGB = "Ability_Druid_TreeofLife|Shapeshift into the Tree of Life. While in this form you increase healing received by 6% for all party and raid members within 100 yards, and you can only cast Restoration spells.",
	},
	["CHAR_INFO_CLASS_DRUID_SPELL5"] = {
		ruRU = "Ability_Druid_ImprovedMoonkinForm|Друид превращается в лунного совуха. Бонус к броне за счет экипировки увеличивается на 370%, урон, получаемый во время оглушения, уменьшается на 15%, а вероятность критического эффекта заклинаний участников группы или рейда в радиусе 100 м повышается на 5%. При критическом ударе заклинанием по одиночной цели друид может мгновенно восстановить 2% от общего запаса маны. В облике лунного совуха нельзя произносить исцеляющие и воскрешающие заклинания.",
		enGB = "Ability_Druid_ImprovedMoonkinForm|Shapeshift into Moonkin Form. While in this form the armor contribution from items is increased by 370%, damage taken while stunned is reduced by 15%, and all party and raid members within 100 yards have their spell critical chance increased by 5%. Single target spell critical strikes in this form have a chance to instantly regenerate 2% of your total mana. The Moonkin can not cast healing or resurrection spells while shapeshifted.",
	},

	["CHAR_INFO_RACE_HUMAN_DESC"] = {
		ruRU = "Люди – молодая раса, а потому их способности разносторонни. Искусство боя, ремесло и магия доступны им в равной степени. Жизнелюбие и уверенность в своих силах позволили людям создать могучие королевства. В эпоху, когда войны длятся веками, люди стремятся возродить былую славу и заложить основу для будущих блистательных побед.",
		enGB = "Humans are a young race, and thus highly versatile, mastering the arts of combat, craftsmanship, and magic with stunning efficiency. The humans’ valor and optimism have led them to build some of the world’s greatest kingdoms. In this troubled era, after generations of conflict, humanity seeks to rekindle its former glory and forge a shining new future.",
	},
	["CHAR_INFO_RACE_DWARF_DESC"] = {
		ruRU = "В древние времена дворфов интересовали лишь богатства, которые они добывали из недр земли. Однажды во время раскопок они обнаружили следы древней расы богоподобных существ, которая создала дворфов и наделила их некими могущественными правами. Дворфы возжелали узнать больше и посвятили себя поиску древних сокровищ и знаний. Сегодня дворфов-археологов можно встретить в любом уголке Азерота.",
		enGB = "In ages past, the dwarves cared only for riches taken from the earth's depths. Then records surfaced of a god-like race said to have given the dwarves life... and an enchanted birthright. Driven to learn more, the dwarves devoted themselves to the pursuit of lost artifacts and ancient knowledge. Today dwarven archaeologists are scattered throughout the globe.",
	},
	["CHAR_INFO_RACE_NIGHTELF_DESC"] = {
		ruRU = "Десять тысяч лет назад ночные эльфы основали огромную империю, но неразумное использование первородной магии привело ее к падению. Полные скорби, они удалились в леса и пребывали в изоляции вплоть до возвращения их вековечного врага, Пылающего Легиона. Тогда ночным эльфам пришлось пожертвовать своим уединенным образом жизни и сплотиться, чтобы отвоевывать свое место в новом мире.",
		enGB = "Ten thousand years ago, the night elves founded a vast empire, but their reckless use of primal magic brought them to ruin. In grief, they withdrew to the forests and remained isolated there until the return of their ancient enemy, the Burning Legion. With no other choice, the night elves emerged at last from their seclusion to fight for their place in the new world.",
	},
	["CHAR_INFO_RACE_GNOME_DESC"] = {
		ruRU = "Гномы Каз Модана не могут похвастаться статью, зато их интеллект позволил занять им достойное место в истории. Гномреган, подземное королевство, в свое время был чудом паровых технологий. Увы, вторжение троггов привело к разрушению города. Теперь славные строители Гномрегана скитаются по землям дворфов, по мере сил помогая своим союзникам.",
		enGB = "Though small in stature, the gnomes of Khaz Modan have used their great intellect to secure a place in history. Indeed, their subterranean kingdom, Gnomeregan, was once a marvel of steam-driven technology. Even so, due to a massive trogg invasion, the city was lost. Now its builders are vagabonds in the dwarven lands, aiding their allies as best they can.",
	},
	["CHAR_INFO_RACE_DRAENEI_DESC"] = {
		ruRU = "После бегства с родной планеты, Аргуса, дренеи тысячелетиями скитались по вселенной, спасаясь от Пылающего Легиона, пока, наконец, не нашли пристанище. Свою новую планету они разделили с орками-шаманами и назвали Дренором. Спустя некоторое время Легион поработил души орков и заставил их развязать войну на планете, уничтожив на ней почти всех миролюбивых дренеев. Немногие счастливчики спаслись бегством на Азерот и ищут теперь союзников для борьбы с Пылающим Легионом.",
		enGB = "Driven from their home world of Argus, the honorable draenei fled the Burning Legion for eons before finding a remote planet to settle on. They shared this world with the shamanistic orcs and named it Draenor. In time the Legion corrupted the orcs, who waged war and nearly exterminated the peaceful draenei. A lucky few fled to Azeroth, where they now seek allies in their battle against the Burning Legion.",
	},
	["CHAR_INFO_RACE_WORGEN_DESC"] = {
		ruRU = "Первые упоминания о воргенах в Восточных королевствах относятся ко временам Третьей войны, куда они попали благодаря стараниям верховного мага Аругала. Сначала зверей использовали как живое оружие против Плети, но вскоре они стали бременем куда более тяжким, чем народ Лордерона мог вынести. Тех, кто сражался бок о бок с воргенами, поразило проклятье, заставлявшее их обращаться в таких же зверей. Занесенная в Гилнеас болезнь мгновенно распространилась, превратив добровольное затворничество граждан в вынужденную изоляцию. Все, кто выжил после страшного проклятья, ищут новый путь, которому последует их народ, и пытаются предугадать судьбу, которая его ожидает.",
	},
	["CHAR_INFO_RACE_QUELDO_DESC"] = {
		ruRU = "Высшие эльфы - гордый народ с многовековой историей, потерявший всё. Преданные братьями, изгнанные со своей родины, терзаемые магическим голодом, они, тем не менее, не потеряли надежды. Многие из них мечтают о возрождении былого величия своего народа. Многие горят желанием отомстить Плети, что разрушила Кель-Талас, лишив эльфов дома, источника их силы - Солнечного Колодца и всего, что было им дорого. А многие хотят просто мирно жить.",
	},
	["CHAR_INFO_RACE_VOIDELF_DESC"] = {
		ruRU = "В результате самонадеянного плана Кель'таса, связанного с манагорнами, и рокового стечения обстоятельств, группа Син'дорай чудом пережила столкновение с чудовищным Повелителем Бездны - там, у Предела Тенебры - но дорогой ценой. Скитальцев Тенебры преобразили силы тени, навсегда изменив их тела и души, но железная воля эльфов оказалась не по зубам даже первозданной тьме. Воодушевленные своим возвращением на Азерот, они ищут способы обуздать новообретенные способности и уберечься от губительного влияния Бездны.",
	},
	["CHAR_INFO_RACE_DARKIRONDWARF_DESC"] = {
		ruRU = "Дворфы Черного Железа известны крутым нравом и неколебимым упорством. Три столетия назад они положили начало Войне Трех Кланов, в результате которой многие дворфы Черного Железа перешли на службу к Повелителю Огня Рагнаросу. Теперь, когда их повелитель был изгнан из Азерота, многие из них поддержали королеву-регента Мойру Тауриссан и надеются вернуть доверие других кланов.",
	},
	["CHAR_INFO_RACE_LIGHTFORGED_DESC"] = {
		ruRU = "На протяжении многих тысячелетий армия Света сражалась с полчищами Пылающего Легиона в Круговерти Пустоты. Самые преданные делу дренеи проходили особый ритуал, чтобы стать одним целым с энергией Света и войти в число озаренных. Некоторые из них были призваны на Азерот и объединились со своими собратьями из Экзодара, чтобы помочь в грядущей войне с демонами и защитить наару от тех, кто смеет посягать на Свет.",
	},
	["CHAR_INFO_RACE_ORC_DESC"] = {
		ruRU = "Орки происходят с планеты Дренор. Пока Пылающий Легион не подчинил этот народ своей власти, орки посвящали себя исключительно мирным занятиям и шаманизму. Но однажды демоны поработили орков и погнали на войну с людьми Азерота. Много лет потребовалось, чтобы избавиться от гнета Легиона и обрести долгожданную свободу. Теперь орки вынуждены сражаться за место в чужом для них мире.",
		enGB = "The orc race originated on the planet Draenor. A peaceful people with shamanic beliefs, they were enslaved by the Burning Legion and forced into war with the humans of Azeroth. Although it took many years, the orcs finally escaped the demons' corruption and won their freedom. To this day they fight for honor in an alien world that hates and reviles them.",
	},
	["CHAR_INFO_RACE_SCOURGE_DESC"] = {
		ruRU = "Отрекшиеся, не попавшие под власть Короля-лича, ищут способ положить конец его правлению. Под предводительством банши Сильваны они сражаются против Армии Плети. Их врагами стали и люди, неустанно стремящиеся стереть с лица земли любую нежить. Отверженные не хранят верность союзам и даже Орду считают всего лишь инструментом воплощения своих темных замыслов.",
		enGB = "The Forsaken, who have managed to break free from the will of the Lich King, are seeking to put an end to his rule. Led by the banshee Sylvanas, they are fighting against both the Scourge and the humans, who tirelessly seek to wipe out any undead from the face of the earth. The Forsaken do not hold loyalty to any alliances and consider even the Horde to be just a tool for furthering their sinister designs.",
	},
	["CHAR_INFO_RACE_TAUREN_DESC"] = {
		ruRU = "Таурены всегда стремились сохранять равновесие природы, следуя завету своей богини, Матери-Земли. Не так давно они подверглись набегу злобных кентавров, и если бы не счастливый случай – встреча с орками, которые помогли отразить нападение, – могли бы и вовсе погибнуть. Чтобы вернуть долг крови, таурены присоединились к Орде вслед за своими соратниками.",
		enGB = "Always the tauren strive to preserve the balance of nature and heed the will of their goddess, the Earth Mother. Not so long ago, they were attacked by the marauding centaur, and had it not been for good fortune – their meeting with orcs who helped them to repel the attack – their whole race may have been wiped out. To repay the blood debt, the tauren joined the Horde along with their other comrades-in-arms.",
	},
	["CHAR_INFO_RACE_TROLL_DESC"] = {
		ruRU = "Тролли Черного Копья некогда считали своим домом Тернистую долину, но были вытеснены оттуда враждующими племенами. Тралл, молодой вождь орков, убедил троллей примкнуть к его походу на Калимдор. Это окончательно сплотило между собой орочью Орду и троллей. Хотя тролли и не смогли окончательно отказаться от своего мрачного наследия, в Орде их уважают и почитают.",
		enGB = "Once at home in the jungles of Stranglethorn Vale, the trolls of the Darkspear tribe were besieged on all sides by warring factions. This finally brought the Orcish Horde and the trolls together. Thrall, the young Orcish Warchief, managed to convince the trolls to join the Horde in its journey to Kalimdor. Though they cling to their shadowy heritage, they are respected and honored in the Horde.",
	},
	["CHAR_INFO_RACE_GOBLIN_DESC"] = {
		ruRU = "Гоблины, начавшие свой исторический путь в кандалах рабов на острове Кезан, вынуждены были добывать для троллей каджа'митовую руду в Подкопье, глубоко под вулканом Каджаро. Никто не знал, что эта руда обладает магическими свойствами, но именно эти свойства позволили гоблинам быстро развить ум и смекалку. Втайне от угнетателей гоблины изобретали приборы и создавали алхимические препараты, которые в конце концов помогли им освободиться от троллей и захватить власть над островом. С тех пор они стали звать Кезан своим домом, возведя на нем настоящий технологический рай, откуда многочисленные конгломераты гоблинов контролировали все коммерческие процессы, протекающие в Азероте. Но недавнее извержение Каджаро уничтожило остров, вынудив гоблинов спасаться бегством и заключить союз с Ордой.",
	},
	["CHAR_INFO_RACE_NAGA_DESC"] = {
		ruRU = "Воинственные наги Мерцающих Глубин некогда считали своим домом Вайш'ир, однако недавнее нападение слуг Нептулона, Владыки Морей, вынудило их покинуть родные воды и примкнуть к Орде. И, хотя они не расстались с мрачным наследием своего народа, а новые союзники не всегда верят в благие намерения обитателей глубин, наги позволяют другим пользоваться своей грубой силой и могущественной стихийной магией, рассматривая союз с Ордой как необходимое средство выживания в чужом для них наземном мире.",
	},
	["CHAR_INFO_RACE_BLOODELF_DESC"] = {
		ruRU = "Много лет назад высшие эльфы-изгнанники основали поселение Кель'Талас, в котором создали магический источник, названный Солнечным Колодцем. Чем больше сил черпали из него эльфы, тем сильнее начинали от него зависеть.|n|nСпустя века Армия Плети разрушила Солнечный Колодец и убила большинство эльфов. Изгнанники назвали себя эльфами крови и стремятся восстановить Кель'Талас, а также найти новый источник волшебной силы, чтобы удовлетворить свое пагубное пристрастие.",
		enGB = "Many years ago, the exiled high elves founded the settlement of Quel’Thalas, where they created a source of magic called the Sunwell. The more power the elves drew from it, the more dependent on it they became.|n|nCenturies later, the Scourge destroyed the Sunwell and killed most of the elves. The exiles dubbed themselves Blood Elves and now seek to restore Quel’Thalas and to find a new source of magical power to satisfy their addiction.",
	},
	["CHAR_INFO_RACE_NIGHTBORNE_DESC"] = {
		ruRU = "Выжившие в чудовищной Войне Древних и пережившие катаклизм, последовавший после уничтожения Колодца Вечности, Ночнорожденные скрывались в Сурамаре за магическим куполом от любых угроз внешнего мира. Магия служила им инструментом, защитой, и пищей - и стала их сутью. Дом Селентрис - изгнанники-ночнорожденные, которые стремятся обрести новый дом в мире за пределами Сурамара, а также справиться с жаждой магии прежде, чем она их погубит.",
	},
	["CHAR_INFO_RACE_EREDAR_DESC"] = {
		ruRU = "Тысячи лет назад родину эредаров, Аргус, посетил темный титан Саргерас. Увидев потенциал в народе волшебников и мыслителей, он предложил им силу и знания в обмен на служение. Эта сделка навсегда изменила облик эредаров и поставила их выдающиеся таланты на службу Пылающему Легиону.\nОднако не все из искаженных Скверной ман'ари хранят верность Саргерасу. Секта новообращенных демонов из числа бывших дренеев, разочаровавшись в идеях Пылающего Легиона, открыто бросила вызов своим бывшим властителям. Теперь они ищут союза со смертными народами Азерота, чтобы вместе противостоять грозному врагу.",
	},
	["CHAR_INFO_RACE_ZANDALARITROLL_DESC"] = {
		ruRU = "Зандалары — гордый народ, история которого началась на заре Азерота. Их свирепые воины сражаются верхом на динозаврах и пользуются покровительством могучих божеств, именуемых лоа. Сейчас, когда в Азероте зреют угрозы, ставящие на кон существование не только зандаларов, но и всего мира, эти тролли вынуждены покинуть свои священные земли в поисках достойных союзников.",
	},
	["CHAR_INFO_RACE_PANDAREN_DESC"] = {
		ruRU = "Таинственные пандарены родом с окутанных туманами земель Пандарии. Тысячи лет назад их народ страдал под безжалостным игом древней империи Могу, но, благодаря исключительной стойкости, мастерству дипломатии и особому боевому искусству пандаренам удалось сплотить вокруг себя народы Пандарии, положить конец тирании Могу и принести мир в свои земли. Немногие пандарены-путешественники отважились покинуть родные края в поисках мудрости или приключений. Они далеки от конфликтов Альянса и Орды, но готовы протянуть руку помощи тем, кто в ней действительно нуждается.",
		enGB = "The mysterious Pandaren hail from the mist-shrouded lands of Pandaria. Thousands of years ago, their people suffered under the ruthless yoke of the ancient Mogu Empire, but, thanks to their exceptional resilience, diplomatic skills and special martial arts, the Pandaren managed to unite the peoples of Pandaria around them, put an end to the tyranny of Mogu, and bring peace to their lands. Few Pandaren travelers dared to leave their homeland in search of wisdom or adventure. While far from the conflicts of the Alliance and the Horde, they are ready to lend a helping hand to those who really need it.",
	},
	["CHAR_INFO_RACE_VULPERA_DESC"] = {
		ruRU = "Обитающие в неприветливых пустынных землях Тель'Абима, вульперы были вынуждены вести кочевой образ жизни, следуя за песками и скрываясь от противников. Они мастерски научились выживать там, где другие встретили бы свой конец, и находить применение тому, что другие посчитали бы барахлом. Теперь же, когда их остров стал желанной добычей для чужестранцев, вульперы ищут союзников, готовых помочь им отстоять свою родину.",
	},
	["CHAR_INFO_RACE_DRACTHYR_DESC"] = {
		ruRU = "Созданные усилиями драконьих стай после освобождения королевы Алекстразы из Грим-Батола, драктиры объединяют в себе лучшие черты как своих прародителей, так и смертных. Теперь этим благородным существам предстоит найти союзников среди младших рас, чтобы вместе противостоять нависшему над Азеротом року, а заодно и тьме, что зреет среди самих драконов.",
	},

	["CHAR_INFO_RACE_HUMAN_SPELL_PASSIVE1_SHORT"] = {
		ruRU = "inv_cape_battlepvps1_d_01_alliance|Сила, ловкость и интеллект повышены на 2%.",
	},
	["CHAR_INFO_RACE_HUMAN_SPELL_PASSIVE2_SHORT"] = {
		ruRU = "inv_sword_05|Меткость повышена на 2%, Мастерство - на 2 ед.",
	},
	["CHAR_INFO_RACE_HUMAN_SPELL_PASSIVE3_SHORT"] = {
		ruRU = "ability_warrior_rallyingcry|Весь получаемый урон снижен на 2%.",
	},
	["CHAR_INFO_RACE_HUMAN_SPELL_ACTIVE1_SHORT"] = {
		ruRU = "Spell_Shadow_Charm|Развеивает эффекты потери контроля над персонажем (кроме Ужаса и Превращения)\nПерезарядка: 120 секунд",
	},
	["CHAR_INFO_RACE_HUMAN_SPELL_ACTIVE2_SHORT"] = {
		ruRU = "ability_rogue_quickrecovery|Повышает наносимый урон и исцеление на 5%, а также снижает получаемый урон на 5% на 10 сек.\nПерезарядка: 30 секунд",
	},
	["CHAR_INFO_RACE_DWARF_SPELL_PASSIVE1_SHORT"] = {
		ruRU = "achievement_dungeon_ulduarraid_irondwarf_01|Повышает скорость атаки и произнесения заклинаний участников группы на 1%.",
	},
	["CHAR_INFO_RACE_DWARF_SPELL_PASSIVE2_SHORT"] = {
		ruRU = "spell_shaman_primalstrike|Модификатор критического урона и исцеления всех атак и заклинаний увеличен на 4%, а шанс крит. эффекта - на 1%.",
	},
	["CHAR_INFO_RACE_DWARF_SPELL_PASSIVE3_SHORT"] = {
		ruRU = "ability_golemthunderclap|Показатель блокирования увеличен на 15%, а вероятность блокирования - на 3%.",
	},
	["CHAR_INFO_RACE_DWARF_SPELL_ACTIVE1_SHORT"] = {
		ruRU = "warrior_talent_icon_avatar|Развеивает эффекты болезней, яда и кровотечения, предоставляет невосприимчивость к ним и оглушению, ошеломлению, параличу сроком на 3 сек.\nПерезарядка: 120 секунд",
	},
	["CHAR_INFO_RACE_DWARF_SPELL_ACTIVE2_SHORT"] = {
		ruRU = "ability_racial_avatar|Повышает наносимый вами урон и творимое исцеление на 10%, а также снижает получаемый физический урон на 20% сроком на 10 сек.\nПерезарядка: 60 секунд",
	},
	["CHAR_INFO_RACE_NIGHTELF_SPELL_PASSIVE1_SHORT"] = {
		ruRU = "ability_hunter_onewithnature|Применение способностей и заклинаний с шансом 25% восполнит 9 ед. вашей ярости, энергии, силы рун или 6% от базовой маны.",
	},
	["CHAR_INFO_RACE_NIGHTELF_SPELL_PASSIVE2_SHORT"] = {
		ruRU = "spell_holy_elunesgrace|Скорость атаки и произнесения заклинаний увеличена на 2%, а вероятность крит. эффекта - на 1%.",
	},
	["CHAR_INFO_RACE_NIGHTELF_SPELL_PASSIVE3_SHORT"] = {
		ruRU = "spell_nature_spiritarmor|Вероятность уклонения увеличена на 3%, получаемый магический урон снижен на 1%.",
	},
	["CHAR_INFO_RACE_NIGHTELF_SPELL_ACTIVE1_SHORT"] = {
		ruRU = "ability_vanish|Наделяет вас невидимостью. Действует до отмены или любого движения. По окончанию действия снижает получаемый вами урон от игроков на 50% на 3 сек.\nПерезарядка: 120 секунд",
	},
	["CHAR_INFO_RACE_NIGHTELF_SPELL_ACTIVE2_SHORT"] = {
		ruRU = "spell_nature_moonglow|Благословляет цель (или вас), повышая наносимый урон и исцеление на 4% и показатель сопротивления на 1.25 за каждый уровень персонажа.\nПерезарядка: 30 секунд",
	},
	["CHAR_INFO_RACE_GNOME_SPELL_PASSIVE1_SHORT"] = {
		ruRU = "inv_engineering_90_scope_blue|Повышает меткость участников группы на 1%.",
	},
	["CHAR_INFO_RACE_GNOME_SPELL_PASSIVE2_SHORT"] = {
		ruRU = "inv_engineering_90_math|Увеличивает максимальный показатель используемого ресурса (мана, энергия, и т. д.)",
	},
	["CHAR_INFO_RACE_GNOME_SPELL_PASSIVE3_SHORT"] = {
		ruRU = "inv_engineering_90_gizmo|Вероятность уклонения увеличена на 3%, а вероятность получения критического удара снижена на 2%.",
	},
	["CHAR_INFO_RACE_GNOME_SPELL_ACTIVE1_SHORT"] = {
		ruRU = "ability_rogue_sprint_blue|Развеивает обездвиживание и замедление, а также наделяет вас невосприимчивостью к ним и активации ловушек.\nПерезарядка: 120 секунд",
	},
	["CHAR_INFO_RACE_GNOME_SPELL_ACTIVE2_SHORT"] = {
		ruRU = "spell_arcane_mindmastery|Повышает урон или исцеление следующего примененного заклинания или способности на 33%.\nВо время действия эффекта, эффекты периодического урона также получают эффект от данной способности, не расходуя её заряд.\nПерезарядка: 30 секунд",
	},
	["CHAR_INFO_RACE_DRAENEI_SPELL_PASSIVE1_SHORT"] = {
		ruRU = "spell_holy_healingfocus|Повышает показатель выносливости участников группы на 2%.",
	},
	["CHAR_INFO_RACE_DRAENEI_SPELL_PASSIVE2_SHORT"] = {
		ruRU = "inv_misc_book_17|Показатель интеллекта увеличен на 4%, а меткость в ближнем и дальнем бою - на 1%.",
	},
	["CHAR_INFO_RACE_DRAENEI_SPELL_PASSIVE3_SHORT"] = {
		ruRU = "spell_holy_divinespirit|Получаемый магический урон снижен на 2%, физический - на 1%, а длительность страха и оглушения сокращена на 10%.",
	},
	["CHAR_INFO_RACE_DRAENEI_SPELL_ACTIVE1_SHORT"] = {
		ruRU = "spell_holy_holyprotection|Восполняет цели 25% от максимального запаса здоровья за 10 сек.\nПерезарядка: 120 секунд",
	},
	["CHAR_INFO_RACE_DRAENEI_SPELL_ACTIVE2_SHORT"] = {
		ruRU = "ability_paladin_savedbythelight|Отмечает цель. При получении урона цель будет испускать волны света, поглощающие получаемый союзниками урон или наносящие урон врагам (в зависимости от того, друг цель или нет).\nПерезарядка: 60 секунд",
	},
	["CHAR_INFO_RACE_WORGEN_SPELL_PASSIVE1_SHORT"] = {
		ruRU = "spell_hunter_lonewolf|Повышает показатель ловкости участников группы на 2%.",
	},
	["CHAR_INFO_RACE_WORGEN_SPELL_PASSIVE2_SHORT"] = {
		ruRU = "ability_druid_rake|Применяя способности, вы повышаете свою скорость атаки и произнесения заклинаний на 1% вплоть до 3% сроком на 10 сек.",
	},
	["CHAR_INFO_RACE_WORGEN_SPELL_PASSIVE3_SHORT"] = {
		ruRU = "ability_hunter_longevity|Вероятность уклонения увеличена на 3%, а показатель брони - на 2%.",
	},
	["CHAR_INFO_RACE_WORGEN_SPELL_ACTIVE1_SHORT"] = {
		ruRU = "ability_racial_darkflight|Ускоряет ваше перемещение на 50% сроком на 10 сек. Скорость перемещения не может быть снижена ниже 100%.\nПерезарядка: 90 секунд",
	},
	["CHAR_INFO_RACE_WORGEN_SPELL_ACTIVE2_SHORT"] = {
		ruRU = "ability_racial_viciousness|Освобождает звериную ярость, повышая наносимый урон и творимое исцеление на 1% (вплоть до 10%) раз в 1 сек. в течение 10 сек.\nПерезарядка: 30 секунд",
	},
	["CHAR_INFO_RACE_QUELDO_SPELL_PASSIVE1_SHORT"] = {
		ruRU = "spell_holy_arcaneintellect|Повышает показатель интеллекта участников группы на 2%.",
	},
	["CHAR_INFO_RACE_QUELDO_SPELL_PASSIVE2_SHORT"] = {
		ruRU = "spell_arcane_arcanepotency|Меткость повышена на 1%, а вероятность критического эффекта - на 2%.",
	},
	["CHAR_INFO_RACE_QUELDO_SPELL_PASSIVE3_SHORT"] = {
		ruRU = "spell_arcane_invocation|Получаемый магический урон снижен на 2%. С вероятностью 2% вы отразите заклинание обратно в противника (если это возможно).",
	},
	["CHAR_INFO_RACE_QUELDO_SPELL_ACTIVE1_SHORT"] = {
		ruRU = "spell_arcane_arcaneresilience|Наделяет вас невосприимчивостью к 1 следующему магическому эффекту потери контроля над персонажем, полученному в течение 2 сек.\nПерезарядка: 90 сек",
	},
	["CHAR_INFO_RACE_QUELDO_SPELL_ACTIVE2_SHORT"] = {
		ruRU = "spell_arcane_blast|Отмечает цель. Отмеченный противник получает на 7% больше урона от вас, а союзник - на 7% больше получаемого от вас исцеления.\nПерезарядка: 30 секунд",
	},
	["CHAR_INFO_RACE_VOIDELF_SPELL_PASSIVE1_SHORT"] = {
		ruRU = "inv_enchant_voidcrystal|Повышает максимальный показатель основного ресурса участников группы.",
	},
	["CHAR_INFO_RACE_VOIDELF_SPELL_PASSIVE2_SHORT"] = {
		ruRU = "spell_priest_voidshift|Восполняет ваш основной ресурс, пока его показатель находится на 50% или ниже.",
	},
	["CHAR_INFO_RACE_VOIDELF_SPELL_PASSIVE3_SHORT"] = {
		ruRU = "spell_shadow_twilight|Применяя способности, вы с некоторой вероятностью повысите свою силу атаки или силу заклинаний.",
	},
	["CHAR_INFO_RACE_VOIDELF_SPELL_PASSIVE4_SHORT"] = {
		ruRU = "spell_shadow_possession|Снижает скорость передвижения противников в радиусе 8 м. на 5%, их вероятность попадания - на 1%, а урон, наносимый их атаками ближнего боя - на 1%.",
	},
	["CHAR_INFO_RACE_VOIDELF_SPELL_ACTIVE1_SHORT"] = {
		ruRU = "ability_priest_voidentropy|Окутывает указанную область зоной Бездны. Любой противник, находящийся в этой зоне, будет замедлен, а союзник - ускорен.\nПерезарядка: 90 секунд",
	},
	["CHAR_INFO_RACE_VOIDELF_SPELL_ACTIVE2_SHORT"] = {
		ruRU = "spell_priest_voidtendrils|Умение, снижающее время восстановления следующей произнесенной способности или заклинания на 7 сек.\nПерезарядка: 35 секунд",
	},
	["CHAR_INFO_RACE_DARKIRONDWARF_SPELL_PASSIVE1_SHORT"] = {
		ruRU = "spell_fire_sealoffire|Повышает множитель критического эффекта участников группы на 2%.",
	},
	["CHAR_INFO_RACE_DARKIRONDWARF_SPELL_PASSIVE2_SHORT"] = {
		ruRU = "spell_fire_rune|Повышает наносимый урон и эффективность исцеления на 2%.",
	},
	["CHAR_INFO_RACE_DARKIRONDWARF_SPELL_PASSIVE3_SHORT"] = {
		ruRU = "inv_shoulder_leather_firelandsdruid_d_01|Множитель критического эффекта увеличен на 4%, а вероятность критического удара - на 1%.",
	},
	["CHAR_INFO_RACE_DARKIRONDWARF_SPELL_PASSIVE4_SHORT"] = {
		ruRU = "ability_racial_fireblood|Показатель брони увеличен на 4%. Получение урона с некоторой вероятностью восстановит вам 2% от максимального запаса здоровья.",
	},
	["CHAR_INFO_RACE_DARKIRONDWARF_SPELL_ACTIVE1_SHORT"] = {
		ruRU = "inv_hammer_unique_sulfuras|Бросок молота, оглушающий указанного противника на 3 сек.\nПерезарядка: 90 секунд",
	},
	["CHAR_INFO_RACE_DARKIRONDWARF_SPELL_ACTIVE2_SHORT"] = {
		ruRU = "ability_rhyolith_lavapool|Покрывает цель (будь то противник или союзник) и область вокруг него шлаком, повышая урон, получаемый от вас противниками и исцеление, получаемое от вас союзниками на 6%.\nПерезарядка: 30 секунд",
	},
	["CHAR_INFO_RACE_LIGHTFORGED_SPELL_PASSIVE1_SHORT"] = {
		ruRU = "racial_highpurpose|Повышает показатель силы атаки и силы заклинаний участников группы на 1%.",
	},
	["CHAR_INFO_RACE_LIGHTFORGED_SPELL_PASSIVE2_SHORT"] = {
		ruRU = "racial_lightforged_giftoflight|Показатель силы атаки увеличен на 2%, а модификатор критического эффекта атакующих и целительных заклинаний - на 4%.",
	},
	["CHAR_INFO_RACE_LIGHTFORGED_SPELL_PASSIVE3_SHORT"] = {
		ruRU = "spell_holy_surgeoflight|Повышает наносимый урон и эффективность исцеления на 2%.",
	},
	["CHAR_INFO_RACE_LIGHTFORGED_SPELL_PASSIVE4_SHORT"] = {
		ruRU = "spell_holy_greaterblessingoflight|Получаемый магический урон снижен на 1%. Падение уровня здоровья вызывает щит, снижающий получаемый урон.",
	},
	["CHAR_INFO_RACE_LIGHTFORGED_SPELL_ACTIVE1_SHORT"] = {
		ruRU = "ability_paladin_blindinglight|Снижает скорость передвижения указанного противника на 95%, после чего тот медленно восстанавливает скорость за 10 сек.\nПерезарядка: 90 секунд",
	},
	["CHAR_INFO_RACE_LIGHTFORGED_SPELL_ACTIVE2_SHORT"] = {
		ruRU = "spell_holy_healingfocus|Увеличивает наносимый вами урон и исходящее исцеление на 20%, а также снижает получаемый магический урон на 40% сроком на 5.5 секунд. Перезарядка 60 секунд.",
	},
	["CHAR_INFO_RACE_ORC_SPELL_PASSIVE1_SHORT"] = {
		ruRU = "ui_horde_honorboundmedal|Повышает показатель силы участников группы на 2%.",
	},
	["CHAR_INFO_RACE_ORC_SPELL_PASSIVE2_SHORT"] = {
		ruRU = "ability_warrior_strengthofarms|Множитель критического эффекта всех атак, способностей и заклинаний увеличен на 4%, а мастерство - на 2 ед.",
	},
	["CHAR_INFO_RACE_ORC_SPELL_PASSIVE3_SHORT"] = {
		ruRU = "warrior_talent_icon_innerrage|Показатель блокирования увеличен на 20%, а вероятность парирования - на 2%.",
	},
	["CHAR_INFO_RACE_ORC_SPELL_ACTIVE1_SHORT"] = {
		ruRU = "ability_warrior_improveddisciplines|Предоставляет вам временную невосприимчивость к замедлению и сковыванию.\nПерезарядка: 90 секунд",
	},
	["CHAR_INFO_RACE_ORC_SPELL_ACTIVE2_SHORT"] = {
		ruRU = "ability_warrior_endlessrage|Временно повышает модификатор критического урона и исцеления на 25%.\nПерезарядка: 60 секунд",
	},
	["CHAR_INFO_RACE_SCOURGE_SPELL_PASSIVE1_SHORT"] = {
		ruRU = "spell_necro_deathall|Применяя способности, вы с некоторой вероятностью увеличите силу атаки или силу заклинаний на 1% вплоть до 3%.",
	},
	["CHAR_INFO_RACE_SCOURGE_SPELL_PASSIVE2_SHORT"] = {
		ruRU = "spell_shadow_skull|Показатель духа увеличен на 4%, а меткость в ближнем и дальнем бою - на 1%.",
	},
	["CHAR_INFO_RACE_SCOURGE_SPELL_PASSIVE3_SHORT"] = {
		ruRU = "inv_gauntlets_09|Пока ваш уровень здоровья находится на отметке 50% или ниже, вы получаете на 4% меньше урона.",
	},
	["CHAR_INFO_RACE_SCOURGE_SPELL_ACTIVE1_SHORT"] = {
		ruRU = "spell_shadow_animatedead|Развеивает любые эффекты контроля над разумом, страха, ужаса, ошеломления и паралича.\nПерезарядка: 120 секунд",
	},
	["CHAR_INFO_RACE_SCOURGE_SPELL_ACTIVE2_SHORT"] = {
		ruRU = "spell_shadow_fingerofdeath|Наносит периодический урон цели, восстанавливая вам здоровье в том же объеме.\nПерезарядка: 60 секунд",
	},
	["CHAR_INFO_RACE_TAUREN_SPELL_PASSIVE1_SHORT"] = {
		ruRU = "ability_druid_giftoftheearthmother|Снижает физический урон, получаемый участниками группы, на 1%.",
	},
	["CHAR_INFO_RACE_TAUREN_SPELL_PASSIVE2_SHORT"] = {
		ruRU = "spell_shaman_unleashweapon_wind|Показатель силы атаки увеличен на 2%, а вероятность критического эффекта только заклинаний - на 2%.",
	},
	["CHAR_INFO_RACE_TAUREN_SPELL_PASSIVE3_SHORT"] = {
		ruRU = "inv_misc_tournaments_symbol_tauren|Показатель выносливости увеличен на 4%.",
	},
	["CHAR_INFO_RACE_TAUREN_SPELL_ACTIVE1_SHORT"] = {
		ruRU = "ability_warstomp|Вы оглушаете всех противников в радиусе 8 м. на 2 сек.\nПерезарядка: 90 секунд",
	},
	["CHAR_INFO_RACE_TAUREN_SPELL_ACTIVE2_SHORT"] = {
		ruRU = "ability_smash|Повышает модификатор критического урона способности или заклинания, примененного в течение 3 сек., на 100%.\nВо время действия эффекта, критический периодический урон также получает эффект от данной способности, не расходуя её.\nПерезарядка: 30 секунд",
	},
	["CHAR_INFO_RACE_TROLL_SPELL_PASSIVE1_SHORT"] = {
		ruRU = "shaman_talent_unleashedfury|Повышает показатель духа участников группы на 2%.",
	},
	["CHAR_INFO_RACE_TROLL_SPELL_PASSIVE2_SHORT"] = {
		ruRU = "spell_nature_bloodlust|Применение способностей с некоторой вероятностью повысит шанс нанести критический удар на 1% вплоть до 3% сроком на 10 сек.",
	},
	["CHAR_INFO_RACE_TROLL_SPELL_PASSIVE3_SHORT"] = {
		ruRU = "spell_nature_regenerate|Повышает эффективность получаемого вами исцеления и периодически восстанавливает ваше здоровье.",
	},
	["CHAR_INFO_RACE_TROLL_SPELL_ACTIVE1_SHORT"] = {
		ruRU = "racial_troll_berserk|Предоставляет невосприимчивость к эффектам ослепления, страха, ужаса и контроля над разумом, а также повышает скорость перемещения на 20%.\nПерезарядка: 90 секунд",
	},
	["CHAR_INFO_RACE_TROLL_SPELL_ACTIVE2_SHORT"] = {
		ruRU = "inv_hand_1h_trollshaman_c_01|Повышает скорость ваших атак и заклинаний на 20% сроком на 10 сек.\nПерезарядка: 60 секунд",
	},
	["CHAR_INFO_RACE_GOBLIN_SPELL_PASSIVE1_SHORT"] = {
		ruRU = "ability_siege_engineer_pattern_recognition|Скорость атаки и произнесения заклинаний, а также вероятность критического удара увеличены на 1%.",
	},
	["CHAR_INFO_RACE_GOBLIN_SPELL_PASSIVE2_SHORT"] = {
		ruRU = "ability_siege_engineer_protective_frenzy|Применение способностей с некоторой вероятностью повышает модификатор критического эффекта на 2% вплоть до 6%.",
	},
	["CHAR_INFO_RACE_GOBLIN_SPELL_PASSIVE3_SHORT"] = {
		ruRU = "achievement_guildperk_ladyluck_rank2|Вероятность уклонения увеличена на 3%, а вероятность попадания по вам снижена на 1%.",
	},
	["CHAR_INFO_RACE_GOBLIN_SPELL_ACTIVE1_SHORT"] = {
		ruRU = "ability_racial_rocketjump|Развеивает эффекты сковывания, замедления и позволяет вам совершить реактивный прыжок вперед. \nИмеет общее время восстановления со способностями \"Рывок\", \"Перехват\", и \"Вмешательство\", равное 15 сек.\nПерезарядка: 120 секунд",
	},
	["CHAR_INFO_RACE_GOBLIN_SPELL_ACTIVE2_SHORT"] = {
		ruRU = "ability_racial_rocketbarrage|Запускает в цель ракету, наносящую урон противнику или исцеляющую союзника.\nПерезарядка: 60 секунд",
	},
	["CHAR_INFO_RACE_NAGA_SPELL_PASSIVE1_SHORT"] = {
		ruRU = "inv_misc_nagamale|Снижает магический урон, получаемый участниками группы, на 1%.",
	},
	["CHAR_INFO_RACE_NAGA_SPELL_PASSIVE2_SHORT"] = {
		ruRU = "spell_frost_summonwaterelemental|Показатель силы атаки или силы заклинаний повышен на 2%.",
	},
	["CHAR_INFO_RACE_NAGA_SPELL_PASSIVE3_SHORT"] = {
		ruRU = "spell_naga_armor_racial|Показатель брони увеличен на 5%, получаемый физический урон снижен на 1%.",
	},
	["CHAR_INFO_RACE_NAGA_SPELL_ACTIVE1_SHORT"] = {
		ruRU = "spell_naga_weapon_racial|Предоставляет невосприимчивость к эффектам немоты, прерывания, а также обезоруживания.\nПерезарядка: 90 секунд",
	},
	["CHAR_INFO_RACE_NAGA_SPELL_ACTIVE2_SHORT"] = {
		ruRU = "inv_elemental_crystal_water|Повышает показатель одной из выбранных характеристик (сила, ловкость, выносливость, интеллект, дух) отмеченной цели на 20% сроком на 10 сек.\nПерезарядка: 30 секунд",
	},
	["CHAR_INFO_RACE_BLOODELF_SPELL_PASSIVE1_SHORT"] = {
		ruRU = "inv_misc_tournaments_banner_bloodelf|Повышает вероятность критического удара участников группы на 1%.",
	},
	["CHAR_INFO_RACE_BLOODELF_SPELL_PASSIVE2_SHORT"] = {
		ruRU = "sha_ability_rogue_bloodyeye_nightmare|Повышает меткость на 1%, а скорость атак и произнесения заклинаний - на 2%.",
	},
	["CHAR_INFO_RACE_BLOODELF_SPELL_PASSIVE3_SHORT"] = {
		ruRU = "spell_shadow_antimagicshell|Получаемый магический урон снижен на 4%.",
	},
	["CHAR_INFO_RACE_BLOODELF_SPELL_ACTIVE1_SHORT"] = {
		ruRU = "spell_shadow_teleport|Вызывает немоту у всех противников в радиусе 8 м. на 3 сек. и восстаналивает 60 ед. ярости, энергии, силы рун или 45% от базовой маны.\nПерезарядка: 90 секунд",
	},
	["CHAR_INFO_RACE_BLOODELF_SPELL_ACTIVE2_SHORT"] = {
		ruRU = "inv_misc_gem_bloodstone_01|Снижает получаемый магический урон на 20%, при этом повышая наносимый урон и исцеление на 10%, сроком на 10 сек.\nПерезарядка: 60 секунд",
	},
	["CHAR_INFO_RACE_NIGHTBORNE_SPELL_PASSIVE1_SHORT"] = {
		ruRU = "sha_spell_warlock_demonsoul_nightborne|Повышает максимальный показатель основного ресурса участников группы.",
	},
	["CHAR_INFO_RACE_NIGHTBORNE_SPELL_PASSIVE2_SHORT"] = {
		ruRU = "sha_ability_rogue_sturdyrecuperate_nightborne|Вступая в бой, вы восстанавливаете 9 ед. энергии, ярости, силы рун или 6% от базовой маны раз в 2 сек. в течение 60 сек.\nСрабатывает не чаще, чем раз в 180 сек.",
	},
	["CHAR_INFO_RACE_NIGHTBORNE_SPELL_PASSIVE3_SHORT"] = {
		ruRU = "spell_mage_supernova_nightborne|С некоторой вероятностью вы можете повысить магический урон, получаемый от вас противником, на 4%, при этом ваши атаки и способности будут игнорировать 4% от его брони.",
	},
	["CHAR_INFO_RACE_NIGHTBORNE_SPELL_PASSIVE4_SHORT"] = {
		ruRU = "spell_arcane_prismaticcloak|Показатель брони увеличен на 5%, а получаемый магический урон снижен на 1%.",
	},
	["CHAR_INFO_RACE_NIGHTBORNE_SPELL_ACTIVE1_SHORT"] = {
		ruRU = "spell_arcane_arcane01_nightborne|Отмечает противника. Метка увеличивает время перезарядки следующей способности, которую применит противником, на 10 сек.\nПерезарядка: 30 секунд",
	},
	["CHAR_INFO_RACE_NIGHTBORNE_SPELL_ACTIVE2_SHORT"] = {
		ruRU = "sha_ability_rogue_bloodyeye_nightborne|Предоставляет невосприимчивость к эффектам прерывания и немоты, а также снижает расход ресурсов на все способности на 50% на 10 сек.\nПерезарядка: 30 секунд",
	},
	["CHAR_INFO_RACE_EREDAR_SPELL_PASSIVE1_SHORT"] = {
		ruRU = "ability_bloodmage_drain|Повышает множитель критического эффекта участников группы на 2%.",
	},
	["CHAR_INFO_RACE_EREDAR_SPELL_PASSIVE2_SHORT"] = {
		ruRU = "passive_eredar_gift|Шанс нанести критический удар способностями ближнего и дальнего боя увеличен на 2%, а скорость произнесения заклинаний - на 2%.",
	},
	["CHAR_INFO_RACE_EREDAR_SPELL_PASSIVE3_SHORT"] = {
		ruRU = "ability_bloodmage_hotstreak_red|Одержание победы над противником предоставляет вам \"Фрагмент души\", повышающий урон и исцеление на 2%.",
	},
	["CHAR_INFO_RACE_EREDAR_SPELL_PASSIVE4_SHORT"] = {
		ruRU = "passive_demonskin_racial|Повышает сопротивление магии. Также увеличивает показатель брони на 2%.",
	},
	["CHAR_INFO_RACE_EREDAR_SPELL_ACTIVE1_SHORT"] = {
		ruRU = "spell_warlock_demonicportal_green|Перемещает вас в указанную точку на расстоянии 20 м.\nИмеет общее время восстановления со способностями \"Рывок\", \"Перехват\", и \"Вмешательство\", равное 15 сек.\nПерезарядка: 60 секунд",
	},
	["CHAR_INFO_RACE_EREDAR_SPELL_ACTIVE2_SHORT"] = {
		ruRU = "spell_bloodmage_soulgem|Расходует \"Фрагмент души\", повышая наносимый урон и исцеление на 4% и понижая получаемый урон на 4% сроком на 20 сек.",
	},
	["CHAR_INFO_RACE_ZANDALARITROLL_SPELL_PASSIVE1_SHORT"] = {
		ruRU = "ability_racial_wardoftheloa|Повышает показатели силы атаки и силы заклинаний участников группы на 1%.",
	},
	["CHAR_INFO_RACE_ZANDALARITROLL_SPELL_PASSIVE2_SHORT"] = {
		ruRU = "ability_racial_embracetheloa|Зандалары верны традициям, и лоа - неотъемлемая часть их жизни. Обращаясь к тому лоа, с которым вы заключили контракт, вы получаете его опеку и поддержку.",
	},
	["CHAR_INFO_RACE_ZANDALARITROLL_SPELL_PASSIVE3_SHORT"] = {
		ruRU = "ability_racial_zandalariempire|Повышает модификатор критического урона и исцеления на 4%.",
	},
	["CHAR_INFO_RACE_ZANDALARITROLL_SPELL_PASSIVE4_SHORT"] = {
		ruRU = "spell_nature_bloodlust|Увеличивает получаемое исцеление на 5%, а вероятность уклонения - на 2%.",
	},
	["CHAR_INFO_RACE_ZANDALARITROLL_SPELL_ACTIVE1_SHORT"] = {
		ruRU = "ability_racial_zandalar_shout|Оглушительный боевой клич Зандаларов, ошеломляющий разум противников в радиусе 10 м., слышащих его, и снижающий их скорость передвижения на 75% в течение 5 сек.\nПерезарядка: 120 секунд",
	},
	["CHAR_INFO_RACE_ZANDALARITROLL_SPELL_ACTIVE2_SHORT"] = {
		ruRU = "Ability_racial_regeneratin|Восполняет 40% запаса здоровья за 10 сек., увеличивает скорость атаки и произнесения заклинаний на 10%, а модификатор критического эффекта - на 12%.\nПерезарядка: 60 секунд",
	},
	["CHAR_INFO_RACE_PANDAREN_SPELL_PASSIVE1_SHORT"] = {
		ruRU = "ability_monk_domeofmist|Скорость атаки и произнесения заклинаний увеличена на 2%, а мастерство - на 2 ед.",
	},
	["CHAR_INFO_RACE_PANDAREN_SPELL_PASSIVE2_SHORT"] = {
		ruRU = "ability_monk_drunkenhaze|Наносимый вами урон и исцеление усиливаются в зависимости от степени вашего опьянения.",
	},
	["CHAR_INFO_RACE_PANDAREN_SPELL_PASSIVE3_SHORT"] = {
		ruRU = "monk_ability_avertharm|Получаемый физический урон снижен на 4%.",
	},
	["CHAR_INFO_RACE_PANDAREN_SPELL_ACTIVE1_SHORT"] = {
		ruRU = "ability_monk_paralysis|Парализует противника на 1 минуту (или на 5 сек., если целью является игрок). Эффект паралича будет развеян, если цель получит урон.\nПерезарядка: 90 секунд",
	},
	["CHAR_INFO_RACE_PANDAREN_SPELL_ACTIVE2_SHORT"] = {
		ruRU = "ability_monk_sparring|Усиливает следующие 5 ваших атак или способностей ближнего/дальнего боя, нанося урон способностью \"Искусный удар\", равный 40% от силы атаки.\nПерезарядка: 60 секунд",
	},
	["CHAR_INFO_RACE_PANDAREN_SPELL_ACTIVE3_SHORT"] = {
		ruRU = "ability_monk_effuse|Запускает заряд Ци в цель, нанося противнику урон, равный 80% от силы заклинаний, или поглощает получаемый союзником урон, равный 80% от силы заклинаний на 10 сек.\nПерезарядка: 12 секунд",
	},
	["CHAR_INFO_RACE_VULPERA_SPELL_PASSIVE1_SHORT"] = {
		ruRU = "inv_inscription_80_contract_vulpera|Модификатор критического исцеления увеличен на 6%, а расходы маны на исцеляющие заклинания - снижены на 2%.",
	},
	["CHAR_INFO_RACE_VULPERA_SPELL_PASSIVE2_SHORT"] = {
		ruRU = "spell_sandelemental|Снижает получаемый вами физический или магический урон, при этом повышая наносимый урон того же типа.",
	},
	["CHAR_INFO_RACE_VULPERA_SPELL_PASSIVE3_SHORT"] = {
		ruRU = "ability_priest_phantasm|Снижает вероятность обнаружения во время незаметности и снижает получаемый периодический урон на 5%.",
	},
	["CHAR_INFO_RACE_VULPERA_SPELL_ACTIVE1_SHORT"] = {
		ruRU = "spell_sandbolt|Опутывает цель на короткое время. Если эффект не будет развеян - то дополнительно оглушает цель.\nПерезарядка: 90 секунд",
	},
	["CHAR_INFO_RACE_VULPERA_SPELL_ACTIVE2_SHORT"] = {
		ruRU = "spell_quicksand|Создает руну в позиции персонажа, повышающую наносимый вами урон и исцеление на 6%, пока вы находитесь на расстоянии не более чем 10 м. от неё.\nПерезарядка: 30 сек",
	},
	["CHAR_INFO_RACE_DRACTHYR_SPELL_PASSIVE1_SHORT"] = {
		ruRU = "classicon_evoker_devastation|Показатель силы заклинаний увеличен на 5% от вашего интеллекта, а сила атаки увеличена на 2%.",
	},
	["CHAR_INFO_RACE_DRACTHYR_SPELL_PASSIVE2_SHORT"] = {
		ruRU = "ability_evoker_fontofmagic_green|Модификатор критического исцеления увеличен на 8%.",
	},
	["CHAR_INFO_RACE_DRACTHYR_SPELL_PASSIVE3_SHORT"] = {
		ruRU = "ability_evoker_quell|В крови представителей юной расы Драктиров хранится наследие каждого драконьего Рода когда-либо существовавшего. Это причудливое наследие позволяет Драктиру адаптироваться к любой ситуации, повышая выбранное сопротивление и сокращая длительность эффектов потери контроля.",
	},
	["CHAR_INFO_RACE_DRACTHYR_SPELL_ACTIVE1_SHORT"] = {
		ruRU = "ability_racial_wingbuffet|Могучий взмах крыльями, который отбрасывает противников на 20 м. и снижает их скорость передвижения на 70% сроком на 4 сек.\nПерезарядка: 120 секунд",
	},
	["CHAR_INFO_RACE_DRACTHYR_SPELL_ACTIVE2_SHORT"] = {
		ruRU = "ability_deathwing_cataclysm|Наносимый вами урон и эффективность исходящего исцеления повышаются и весь получаемый урон уменьшается на 10 сек.\nПерезарядка: 60 сек",
	},

	["COMPLETE_FORCED_CUSTOMIZATION"] = {
		ruRU = "Завершить настройку"
	},
	["COMPLETE_FORCED_RENAME"] = {
		ruRU = "Смена имени и вход в игровой мир"
	},
	["CHARACTER_NO_NAME"] = {
		ruRU = "Без имени",
		enGB = "",
	},
	["CHARACTER_UNDELETE_STATUS_1"] = {
		ruRU = "Выполняется другая операция.",
		enGB = "Another operation is in progress."
	},
	["CHARACTER_UNDELETE_STATUS_2"] = {
		ruRU = "Неверные параметры.",
		enGB = "Invalid parameters."
	},
	["CHARACTER_UNDELETE_STATUS_3"] = {
		ruRU = "Достингуто максимальное количество персонажей.",
		enGB = "The maximum number of characters has been reached."
	},
	["CHARACTER_UNDELETE_STATUS_4"] = {
		ruRU = "Персонаж не найден.",
		enGB = "Character not found."
	},
	["CHARACTER_UNDELETE_STATUS_5"] = {
		ruRU = "<html><body><p align=\"CENTER\">Недостаточно бонусов!</p><p align=\"CENTER\">Внести добровольное пожертвование в <a href=\"https://sirus.su/pay\">личном кабинете</a></p></body></html>",
		enGB = "<html><body><p align=\"\"CENTER\"\">Not enough bonuses!</p><p align=\"\"CENTER\"\">Make a donation in <a href=\"\"https://sirus.su/pay\"\">your account</a></p></body></html>"
	},
	["CHARACTER_UNDELETE_STATUS_6"] = {
		ruRU = "Вы не можете восстановить рыцаря смерти, так как достигли лимита персонажей этого класса.",
		enGB = ""
	},
	["CHARACTER_UNDELETE_STATUS_7"] = {
		ruRU = "Это действие невозможно для неподтвержденных учетных записей",
		enGB = ""
	},
	["CHARACTER_UNDELETE_STATUS_8"] = {
		ruRU = "Неверный индекс персонажа",
		enGB = ""
	},
	["CHARACTER_UNDELETE_STATUS_9"] = {
		ruRU = "Вы не можете восстановить персонажа, так как достигли лимита персонажей.",
		enGB = ""
	},
	["REALM_CARD_RATE"] = {
		ruRU = "РЕЙТ",
		enGB = "",
	},
	["REALM_CARD_PVP_MODE"] = {
		ruRU = "РЕЖИМ PVP",
		enGB = "",
	},
	["REALM_CARD_PLAY"] = {
		ruRU = "Играть",
		enGB = "",
	},
	["SUPPORT"] = {
		ruRU = "Поддержка",
		enGB = "",
	},
	["INSPECT_CHARACTER"] = {
		ruRU = "Осмотреть",
		enGB = "Inspect"
	},
	["RACE_UNAVAILABLE"] = {
		ruRU = "Выбранная раса недоступна",
		enGB = "",
	},
	["CHARACTER_INFO_HARDCORE_LABEL"] = {
		ruRU = "Персонаж участвует в испытании",
		enGB = ""
	},
	["CHARACTER_CREATE_HARDCORE_LABEL"] = {
		ruRU = "Один шанс",
		enGB = ""
	},
	["CHARACTER_CREATE_HARDCORE_TIP"] = {
		ruRU = "Один шанс - это испытание для самых смелых! У вас будет всего одна жизнь и один шанс, чтобы достигнуть 80 уровня, преодолевая опасности, цепляясь за удачу и сражаясь без шанса на ошибку!\nЗа успешное прохождение испытания вы получите уникальные и ценные награды!\n\n|cffFF0000ВНИМАНИЕ!|r Во время прохождения испытания также будет действовать ряд ограничений, включая запрет на использование аукциона, почты, поиска подземелий, взаимодействия с игроками без испытания и т.п.\n\nРежим \"Один Шанс\" недоступен персонажам класса Рыцарь Смерти ввиду ограничений по уровню.",
		enGB = ""
	},
	["CHARACTER_HARDCORE_PROPOSAL"] = {
		ruRU = "При создании этого персонажа вы не смогли выбрать, хотите ли вы участвовать в испытании \"Один шанс\", пожалуйста ознакомьтесь с описанием режима и выберите, хотите ли вы участвовать в испытании.",
	},
	["CHARACTER_HARDCORE_PROPOSAL_WARNING"] = {
		ruRU = "ВНИМАНИЕ! Этот выбор нельзя будет изменить. Только если вы создадите персонажа заново.",
	},
	["CLASS_DISABLE_REASON_DEATH_KNIGHT_HARDCORE"] = {
		ruRU = "Создание Рыцаря смерти при активированном режиме испытаний невозможно",
		enGB = ""
	},
	["RACE_DISABLE_REASON_REALM"] = {
		ruRU = "Создание |3-1(%s) в данный момент недоступно в этом мире",
		enGB = ""
	},
	["RACE_DISABLE_REASON_REALM_DEATH_KNIGHT"] = {
		ruRU = "Создание Рыцаря смерти в данный момент недоступно в этом мире",
		enGB = ""
	},
	["RACE_DISABLE_CLASS_COMBINATION"] = {
		ruRU = "Этот класс доступен другим расам",
		enGB = "You must choose a different race to be this class",
	},
	["CHARACTER_CREATION_INFO_ZODIAC_SIGN_ERROR_1"] = {
		ruRU = "Выбранное созвездие недоступно",
	},
	["CHARACTER_CREATION_INFO_CUSTOM_FLAG_ERROR_1"] = {
		ruRU = "Этот класс не может быть создан с активированным режимом испытаний",
	},
	["CUSTOMIZATION_DISABLED_REASON_FORCED_RENAME"] = {
		ruRU = "Использование сервисов недоступно для этого персонажа до завершения смены имени, которое произойдет при входе в мир."
	},
	["CUSTOMIZATION_DISABLED_REASON_FORCED_CUSTOMIZATION"] = {
		ruRU = "Использование сервисов недоступно для этого персонажа до завершения настройки персонажа."
	},
	["CUSTOMIZATION_DISABLED_REASON_BOOST_SERVICE_MODE"] = {
		ruRU = "Использование сервисов недоступно до завершения настроек Быстрого старта."
	},
	["CUSTOMIZATION_ZODIAC_ALREADY_SELECTED"] = {
		ruRU = "Вы должны выбрать знак зодиака отличный от текущего",
	},
	["CUSTOMIZATION_ZODIAC_NOT_FOUND"] = {
		ruRU = "Информация о выбранном знаке зодиака не найдена",
	},
	["CUSTOMIZATION_ZODIAC_STATUS_1"] = {
		ruRU = "Неверные параметры",
	},
	["CUSTOMIZATION_ZODIAC_STATUS_2"] = {
		ruRU = "Персонаж не найден",
	},
	["CUSTOMIZATION_ZODIAC_STATUS_3"] = {
		ruRU = "Выбранная раса недоступна",
	},
	["CUSTOMIZATION_ZODIAC_STATUS_4"] = {
		ruRU = "Неверный индекс расы",
	},
	["CUSTOMIZATION_ZODIAC_STATUS_5"] = {
		ruRU = "Внутренняя ошибка",
	},
	["CUSTOMIZATION_ZODIAC_STATUS_7"] = {
		ruRU = "Это действие невозможно для неподтвержденных учетных записей",
	},
	["CHAR_ZODIAC_IN_PROGRESS"] = {
		ruRU = "Обновление знака зодика…",
		enGB = "Updating Zodiac sign..."
	},
	["ZODIAC_SIGN_DESCRIPTION_LABEL"] = {
		ruRU = "Описание",
		enGB = "",
	},
	["ZODIAC_SIGN_SPELLS_LABEL"] = {
		ruRU = "Способности",
		enGB = "",
	},
	["ZODIAC_SIGN_DISABLE"] = {
		ruRU = "Выбранное созвездие недоступно",
		enGB = ""
	},
	["REALM_TYPE_0"] = {
		ruRU = "PvE",
	},
	["REALM_TYPE_1"] = {
		ruRU = "Всегда включен",
	},
	["REALM_TYPE_1_DESC"] = {
		ruRU = "Неотключаемый PvP режим",
	},
	["REALM_TYPE_2"] = {
		ruRU = "FFA",
	},
	["REALM_TYPE_2_DESC"] = {
		ruRU = "Каждый сам за себя",
	},
	["REALM_TYPE_3"] = {
		ruRU = "Режим войны",
	},
	["REALM_TYPE_3_DESC"] = {
		ruRU = "Переключаемый в столицах режим пвп",
	},
	["REALM_LABEL_NEW"] = {
		ruRU = "НОВЫЙ ИГРОВОЙ МИР",
	},
	["LOADING_DATA_LABEL"] = {
		ruRU = "Загрузка данных"
	},
	["BOOST_SERVICE_BROWSE_ITEMS"] = {
		ruRU = "Предметы %.0f",
	},
	["PREVIEW"] = {
		ruRU = "Предпросмотр",
	},
	["BOOST_SERVICE_UPDATE_TIP"] = {
		ruRU = "Ознакомьтесь с содержимым быстрого старта!",
	},
	["RPE_UPDATE"] = {
		ruRU = "Обновить",
	},
	["RPE_GEAR_UPDATE"] = {
		ruRU = "Апгрейд!",
	},
	["RPE_GEAR_UPDATE_DESCRIPTION"] = {
		ruRU = "Воспользовавшись этой услугой вы получите один комплект экипировки для выбранной вами специализации.\n\nВещи будут добавлены в ваш инвентарь или экипированы на персонажа, если уровень имеющейся экипировки достаточно низок.\n\n|cffff0000Обратите внимание, что эта услуга не подлежит обмену или возврату.|r",
	},
	["RPE_CHARACTER_INFO"] = {
		ruRU = "%s\n|c%s%s|r",
	},
	["RPE_INFO_TEXT1"] = {
		ruRU = "Для персонажей 80 уровня",
	},
	["RPE_INFO_TEXT2"] = {
		ruRU = "Один комплект экипировки на выбор: PVE или PVP",
	},
	["RPE_INFO_TEXT2_NOPVP"] = {
		ruRU = "Комплект PvE экипировки",
	},
	["RPE_INFO_TEXT3"] = {
		ruRU = "Комплекты экипировки соответствуют наборам Быстрого Старта",
	},
	["RPE_TOOLTIP_LINE1"] = {
		ruRU = "Доступно обновление экипировки!",
	},
	["RPE_TOOLTIP_LINE2"] = {
		ruRU = "Ваш уровень экипировки: |c%s%d|r",
	},
	["RPE_TOOLTIP_LINE3"] = {
		ruRU = "Доступный уровень PVE экипировки: |c%s%d|r",
	},
	["RPE_TOOLTIP_LINE4"] = {
		ruRU = "Доступный уровень PVP экипировки: |c%s%d|r",
	},
	["RPE_NO_SPEC_SELECTED"] = {
		ruRU = "Выберите специализацию",
	},
	["RPE_EQUIP_ITEMS"] = {
		ruRU = "Экипировать на персонажа",
	},
	["RPE_EQUIP_ITEMS_TOOLTIP"] = {
		ruRU = "При выборе \"Экипировать на персонажа\" - все экипированные предметы на вашем персонаже перенесутся в сумку, а новый приобретенный комплект экипировки будет автоматически надет на вашего персонажа.\nВ обратном случае новый комплект экипировки будет ожидать вас в инвентаре.",
	},
	["BOOST_PREVIEW_SELECT_CLASS"] = {
		ruRU = "Выберите класс",
	},
	["BOOST_PREVIEW_SELECT_SPEC"] = {
		ruRU = "Выберите специализацию",
	},
	["BOOST_PREVIEW_PVP_SPEC_NOT_AVAILABLE"] = {
		ruRU = "PVP экипировка отсутствует",
	},
	["CHARACTER_CREATION_STATUS_1"] = {
		ruRU = "Это действие невозможно для неподтвержденных учетных записей",
	},
	["ENABLE_GLUE_MUSIC"] = {
		ruRU = "Музыка главного меню",
	},
	["BOOST_REFUND_DESCRIPTION"] = {
		ruRU = "Вы хотите воспользоваться услугой возврата Быстрого Старта?\nОбратите внимание, сумма выплаты зависит от стоимости, по которой вы приобретали Быстрый Старт, а не от текущей стоимости Быстрого Старта. Отменить услугу возврата после подтверждения будет невозможно, но вы сможете купить Быстрый Старт заново за полную стоимость, актуальную на момент новой покупки.",
	},
	["BOOST_REFUND_CONFIRM"] = {
		ruRU = "СОГЛАСЕН",
	},
	["BOOST_REFUND_CONFIRM_INSTRUCTION"] = {
		ruRU = "Для подтверждения введите слово \"СОГЛАСЕН\"",
	},
	["BOOST_CANCEL_TITLE"] = {
		ruRU = "Отмена Быстрого Старта",
	},
	["BOOST_CANCEL_DESCRIPTION"] = {
		ruRU = "Вы хотите воспользоваться услугой отмены Быстрого Старта. Ее можно применить 1 раз на каждый полученный вами Быстрый старт.",
	},
	["BOOST_CANCEL_WARNING"] = {
		ruRU = "Обратите внимание, что персонаж будет безвозвратно удален, и вернуть его невозможно.",
	},
	["BOOST_CANCEL_CONFIRM"] = {
		ruRU = "УДАЛИТЬ",
	},
	["BOOST_CANCEL_CONFIRM_INSTRUCTION"] = {
		ruRU = "Для подтверждения введите слово \"УДАЛИТЬ\"",
	},
	["CHARACTER_SERVICES_AVAILABLE"] = {
		ruRU = "Персонажу доступны особые услуги"
	},
	["GLUE_STATUS_DIALOG_TEXT_200"] = {
		ruRU = "Вы не можете удалить персонажа с активным периодом отмены Быстрого Старта.",
	},
}

do
	local _G = _G
	local next = next
	local locale = GetLocale()
	for key, data in next, GLUE_STRINGS do
		_G[key] = data[locale] or data.enGB or key
	end
	table.wipe(GLUE_STRINGS)
	GLUE_STRINGS = nil
end