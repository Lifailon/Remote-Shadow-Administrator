# RSA - Remote Shadow Administrator

Первостепенная цель программы, это подключение к текущим RDP-сессия по средствам Shadow-подключения. 100% кода на powershell и Windows Forms (без использования Visual Studio), можно использовать как альтернативное средство удаленного подключения (например, Radmin или VNC, которые требуют установки ПО и имеют некоторые дыры в безопасности).

При выборе сервера и нажатии на кнопку "Проверить" отображается список текущих пользователей в виде таблице, при выборе ID пользователя можно произвести действия: Shadow-подключения с возможностью запроса на подключение и без, отключения пользователя (выход из системы) и отправки набранного сообщения всем пользователям на сервере или выбранному в таблице. Создание таблицы происходит в 3 этапа, вначале проверяется доступность сервера, о чем сообщается в статус-баре и дополнительно проверяется uptime (если не доступен WinRM, программа об этом сообщит), если сервер не доступен, во избежании долгой задержки проверка пользователей не производится. На втором этапе парсится вывод команды query по средствам Regex, на последнем происходит создание Custom Object с выводом в GridView.

Подключение к серверу имеет ключ /admin, что позволяет подключаться к RDSH-серверу минуя Broker, для аутентификации используется cmdkey, распростроняется на все сервера в списке и действует до закрытия программы, что позволяет не хранить пароль администратора в коде а так же хранилище ключей ОС. Список серверов хранится в файле RSA.conf.txt (%USERPROFILE%\Documents\), который можно вызвать из программы нажатием правой кнопки мыши в списке серверов или комбинацией клавиш Ctrl+S.

Программ имеет порядка 20 скриптов по удаленному взаимодействию и администрированию серверов и рабочих станций. Присутствует вывод всех команд в статус-бар.

Типовые: перезагрузка и выключение (shutdown) с задержкий 30 секунд и возможностью отмены. Управление компьютером (Computer Management), gpupdate на удаленной машине, gpresult с выводом в XML-файл и указанием пользователя. Проверка служб с возможностью удобной фильтрации поиска и повторной проверки статуса. Список всех процессов пользователей с возможностью их завершения. Список открытых SMB-сессий с их завершением для освобождения файла. Просмотр всех сетевых ресурсов с возможностью открытия (в т.ч. c$). Просмотр и фильтрация логов (используется 3 журнала и 100 последних сообщений в каждом).

Заимствованные: TCP Viewer (источник: winitpro.ru) - производит resolve FQDN для всех удаленных адресов и через Get-Process по ID определяет path исполняемого процесса. Подключение к Connection Broker (для подключения требуется модуль RemoteDesktop) с возможностью Shadow-подключения. Wake on Lan (источник: coolcode.ru) - формирование Magic Packet c отправкой broadcast (MAC-адрес берется из формы ввода сообщения). Просмотр свободного места на разделах дисков (источник: fixmypc.ru) и по аналогии ОЗУ.

**Собственные идеи:**

1. Поиск MAC-адреса компьютера, которые уже не доступен по средствам просмотра ARP-таблиц на других сервера в кач-ве proxy, или вывод таблицы сервера с ролью DHCP (установка модуля не требуется) для поиска MAC-адреса. Используется с последующей отправкой Magic Packet.

2. Скрипты по синхронизации компьютерных часов - 1). Отображает текущее время на сервере и разницу с сервером источником запроса. 2) Узнать источник времени, а так же частоту и время последней синхронизации (последнее в силу сложности с выводом в зависимости от языкового пакета). 3) Проверка сервера как источника времени. 4) Незамедлительно синхронизировать время на удаленном сервере. 5) Изменить на удаленном сервере источник времени на ближайший DC в подсети.

![Image alt](https://github.com/Lifailon/Remote-Shadow-Administrator/blob/rsa/Time.jpg)

3. WMI: 1). Просмотри списка обновлений с возможностью копирования номер в буфер обмена. В связи с тем, что более не поддерживается удаление обновлений через WUSA в тихом режиме, используется в связке с DISM online (специально оставил отдельной вкладкой, можно автоматизировать сразу процесс удаления и/или отпарсить вывод dism). 2). Удаленная проверка а так же включение/отключение rdp и nla. 3). Список установленных программ, используется два метода: get-packet и gwmi с возможностью удаления. Пример:

![Image alt](https://github.com/Lifailon/Remote-Shadow-Administrator/blob/rsa/Programs.jpg)

4). Инвентаризация оборудования - модель процессора, мат. платы, видеокарты, оперативной памяти, модели дисков, так же присутствует вывод всех сетевых адаптеро, очень часто в сканерах используется для инициализации хоста ВМ (раскомментировать строки 505-506) с ковертацией в HTML-файл:

![Image alt](https://github.com/Lifailon/Remote-Shadow-Administrator/blob/rsa/Report.jpg)

! На текущий момент есть одна нерешенная проблема с установкой программ, функция wmi-installer (452-475 строки). Использовал install-package и 2 метода gwmi (в т.ч. через icm session). В первом случае установка происходит не на всех серверах (не зависимо от использования версии TLS и установленных репозиториев), в случае с wmi установка происходит из unc-пути только на тот же сервер, где лежит msi-пакет (при условии полного доступа к директории и даже с предварительной аудентификацией, файл через icm доступен по пути).

По вопросам и предложениям Telegram: @kup57
