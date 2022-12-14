#region Config
$conf = "$env:USERPROFILE\Documents\RSA.conf.txt"
$gconf = Get-Content $conf
$srv_list = $gconf
$Font = "Arial"
$Size = "10"
Add-Type -assembly System.Drawing # подключить сборку для отображения иконок
$ico_rdp = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command mstsc).Path)
$ico_usr = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command lusrmgr.msc).Path)
$ico_cred = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command netplwiz).Path)
$ico_pad = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command notepad).Path)
#endregion

#region Создание формы
Add-Type -assembly System.Windows.Forms # добавить сборку WinForm

$main_form = New-Object System.Windows.Forms.Form
$main_form.Text = "Remote Shadow Administrator"
$main_form.ShowIcon = $false # убрать иконку в углу названия
$main_form.StartPosition = "CenterScreen" # стартовая позиция расположения формы при открытии
$main_form.Font = "$Font,$Size" # шрифт и размер
$main_form.ForeColor = "Black" # цвет букв
$main_form.Size = New-Object System.Drawing.Size(1010,700) # размер формы
$main_form.AutoSize = $true
#endregion

#region Функции
function Get-Query {
$ping = ping -n 1 -v 4 $srv
# Создать массив
if ($ping -match "ttl") {$ping = @("Сервер: $srv - доступен")} else {$ping = @("Сервер: $srv - не доступен")} # если вывод команды ping возвращает ttl
$outputBox_1.text = $ping | out-string
$usrv = query user /server:$srv # получить список пользователей
# Парсинг вывода
$usrv = $usrv -replace "\s{1,50}"," " # удалить все повторяющиеся пробелы
$usrv = $usrv -replace "USERNAME.+","Пользователи:" # заменить первую строку с описанием
$usrv = $usrv -replace "rdp-tcp#(\d{1,4})\s" # удалить тип подключения
$usrv = $usrv -replace "console "
$usrv = $usrv -replace "Active([\s\d\.]{1,20})","подключен" # заменить слово
$usrv = $usrv -replace "Disc","отключен"
$usrv = $usrv -replace "подключен.+","- Подключен" # удалить все после слова
$usrv = $usrv -replace "отключен.+","- Отключен"
$usrv = $usrv -replace "^\s" # удалить пробел в начале
# Добавить в массив
$ping += " "
$ping += $usrv
$outputBox_1.text = $ping | out-string
}

function up-time {
$boottime = Get-CimInstance -ComputerName $srv Win32_OperatingSystem | select LastBootUpTime
$datetime = (Get-Date) - $boottime.LastBootUpTime | SELECT Days,Hours,Minutes
$string = [convert]::ToString($datetime) # преобразовать в строку
$string = $string -replace "@{"
$string = $string -replace "}"
$string = $string -replace ";"
$string = $string -replace "Days=","Дней: "
$string = $string -replace "Hours=","Часов: "
$string = $string -replace "Minutes=","Минут: "
$global:uptime = $string
}

function net-time {
$net_time = net time \\$srv
$regtime = $net_time -match "$srv"
$regtime = $regtime -replace "$srv"
$regtime = $regtime -replace "Current time at \\\\ is "
$global:nettime = $regtime
}
#endregion

#region Список серверов
$Label_1 = New-Object System.Windows.Forms.Label
$Label_1.Text = "Выберите сервер:"
$Label_1.Location = New-Object System.Drawing.Point(8,30)
$Label_1.AutoSize = $true
$main_form.Controls.Add($Label_1) # Добавить текст 1 на форму

# Меню списка серверов
$ListBox = New-Object System.Windows.Forms.ListBox
$ListBox.Location  = New-Object System.Drawing.Point(10,55)
$ListBox.Size = New-Object System.Drawing.Size(200,440)
$ListBox.Font = "$Font,12"
foreach ($tmp in $srv_list) {$ListBox.Items.Add($tmp)}
$main_form.Controls.add($ListBox)

# Нажатие правой кнопки мыши в списке
$ContextMenu = New-Object System.Windows.Forms.ContextMenu
$ContextMenu.MenuItems.Add("Список серверов",{ii $conf})
$ListBox.ContextMenu = $ContextMenu

$button_1 = New-Object System.Windows.Forms.Button
$button_1.Text = " Проверить"
$button_1.Image = $ico_usr # наложить иконку
$button_1.ImageAlign = "MiddleLeft" # расположение изображения слева
$button_1.Location = New-Object System.Drawing.Point(8,500)
$button_1.Size = New-Object System.Drawing.Size(145,40)
$main_form.Controls.Add($button_1)

$button_1.Add_Click({
$global:srv = $ListBox.selectedItem # присвоить глобальной переменной имени сервера текст выбранного в списке для всех скриптов
Get-Query
up-time
net-time
if ($uptime.Length -gt 1) {$Status.Text = "Выбран сервер: $srv. Время работы: $uptime. Текущее время на сервере: $nettime"}` # добавить в статус
else {$Status.Text = "Выбран сервер: $srv. Текущее время на сервере: $nettime. WinRM недоступен"}
})

$button_mstsc = New-Object System.Windows.Forms.Button
$button_mstsc.Text = "        Подключиться"
$button_mstsc.Image = $ico_rdp
$button_mstsc.ImageAlign = "MiddleLeft"
$button_mstsc.Location = New-Object System.Drawing.Point(8,545)
$button_mstsc.Size = New-Object System.Drawing.Size(145,40)
$main_form.Controls.Add($button_mstsc)

$button_mstsc.Add_Click({
$Status.Text = "Подключение к серверу $srv"
if ($password -ne $Null) { # если предварительная аудентификация использовалась и переменная пароля не пустая
cmdkey /generic:"TERMSRV/$srv" /user:"$username" /pass:"$password" # добавить указанные креды аудентификации на сервер
}
mstsc /admin /v:$srv
Start-Sleep -Seconds 1 # задержка перед удалением
cmdkey /delete:"TERMSRV/$srv" # удалить добавленные креды аудентификации из системы
})
#endregion

#region Список пользователей
$Label_2 = New-Object System.Windows.Forms.Label
$Label_2.Text = "Список пользователей:"
$Label_2.Location = New-Object System.Drawing.Point(228,30)
$Label_2.AutoSize = $true
$main_form.Controls.Add($Label_2)

# Форма вывода текста
$outputBox_1 = New-Object System.Windows.Forms.TextBox
$outputBox_1.Location = New-Object System.Drawing.Point(230,55)
$outputBox_1.Font = "$Font,12"
$outputBox_1.Size = New-Object System.Drawing.Size(350,435)
$outputBox_1.MultiLine = $True
$main_form.Controls.Add($outputBox_1)

# Скролл
$VScrollBar = New-Object System.Windows.Forms.VScrollBar
$outputBox_1.Scrollbars = "Vertical"

$Label_3 = New-Object System.Windows.Forms.Label
$Label_3.Text = "Введите ID пользователя:"
$Label_3.Location = New-Object System.Drawing.Point(280,502)
$Label_3.AutoSize = $true
$main_form.Controls.Add($Label_3)

# Форма ввода текста
$TextBox_1 = New-Object System.Windows.Forms.TextBox
$TextBox_1.Location = New-Object System.Drawing.Point(460,500)
$TextBox_1.Size = New-Object System.Drawing.Size(120)
$main_form.Controls.Add($TextBox_1)

$button_2 = New-Object System.Windows.Forms.Button
$button_2.Text = "Подключиться"
$button_2.Location = New-Object System.Drawing.Point(460,530)
$button_2.Size = New-Object System.Drawing.Size(120,35)
$main_form.Controls.Add($button_2)

$button_2.Add_Click({
$id = $TextBox_1.Text
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("Запрашивать разрешение на подключение?",0,"Выберите действие",3)
if ($output -eq "6") {mstsc /shadow:$id /v:$srv /control} # действие, если ответ да
if ($output -eq "7") {mstsc /shadow:$id /v:$srv /control /noconsentprompt} # действие, если ответ нет
$outputBox_1.text = @("Подключение к пользователю: $id","На сервер: $srv") | out-string # проверка переменных (debug)
})

$button_3 = New-Object System.Windows.Forms.Button
$button_3.Text = "Отключить"
$button_3.Location = New-Object System.Drawing.Point(460,570)
$button_3.Size = New-Object System.Drawing.Size(120,35)
$main_form.Controls.Add($button_3)

$button_3.Add_Click({
$id = $TextBox_1.Text
$wshell = New-Object -ComObject Wscript.Shell
$Output = $wshell.Popup("Отключить пользователя $id ?",0,"Выберите действие",4)
if ($output -eq "6") {logoff $id /server:$srv /v}
Get-Query # выполнить функцию, для повторного отображения списка текущих пользователей на сервере
})
#endregion

#region Сообщение
$outputBox_2 = New-Object System.Windows.Forms.TextBox
$outputBox_2.Text = "Введите сообщение для отправки пользователям"
$outputBox_2.Location = New-Object System.Drawing.Point(600,55)
$outputBox_2.Size = New-Object System.Drawing.Size(250,160)
$outputBox_2.MultiLine = $True
$main_form.Controls.Add($outputBox_2) 

$button_6 = New-Object System.Windows.Forms.Button
$button_6.Text = "Отправить"
$button_6.Location = New-Object System.Drawing.Point(860,155)
$button_6.Size = New-Object System.Drawing.Size(115,60)
$main_form.Controls.Add($button_6)

$button_6.Add_Click({
$id = $TextBox_1.Text
$text = $outputBox_2.Text
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("Отправить всем - да, или пользователю с id: $id - нет на сервер: $srv",0,"Выберите действие",3)
if ($output -eq "6") {msg * /server:$srv $text}
if ($output -eq "7") {msg $id /server:$srv $text}
if ($lastexitcode -eq 0) {$Status.Text = "Сообщение отправлено"} else {$Status.Text = "Сообщение не отправлено"}
})
#endregion

#region Администрирование
$GroupBox_admin = New-Object System.Windows.Forms.GroupBox
$GroupBox_admin.Text = "Администрирование"
$GroupBox_admin.AutoSize = $true
$GroupBox_admin.Location  = New-Object System.Drawing.Point(600,230)
$GroupBox_admin.Size = New-Object System.Drawing.Size(380,255)
$main_form.Controls.Add($GroupBox_admin)

$button_7 = New-Object System.Windows.Forms.Button
$button_7.Text = "Перезагрузить"
$button_7.Location = New-Object System.Drawing.Point(10,25)
$button_7.Size = New-Object System.Drawing.Size(115,35)
$GroupBox_admin.Controls.Add($button_7)

$button_7.Add_Click({
shutdown /r /f /t 60 /m \\$srv /c "Плановая перезагрузка сервера через 30 секунд"
if ($lastexitcode -eq 0) {$Status.Text = "Перезагрузка запланирована"}
if (($lastexitcode -ne 0) -and ($lastexitcode -eq 1190)) {$Status.Text = "Перезагрузка уже запланирована"}
if (($lastexitcode -ne 0) -and ($lastexitcode -ne 1190)) {$Status.Text = "Ошибка перезапуска"}
})

$button_8 = New-Object System.Windows.Forms.Button
$button_8.Text = "Отменить"
$button_8.Location = New-Object System.Drawing.Point(135,25)
$button_8.Size = New-Object System.Drawing.Size(115,35)
$GroupBox_admin.Controls.Add($button_8)

$button_8.Add_Click({
shutdown /a /m \\$srv
if ($lastexitcode -eq 0) {$Status.Text = "Перезагрузка отменена"}
if (($lastexitcode -ne 0) -and ($lastexitcode -eq 1116)) {$Status.Text = "Перезагрузка уже отменена"}
if (($lastexitcode -ne 0) -and ($lastexitcode -ne 1116)) {$Status.Text = "Ошибка отмены перезапуска"}
})

$button_off = New-Object System.Windows.Forms.Button
$button_off.Text = "Выключить"
$button_off.Location = New-Object System.Drawing.Point(260,25)
$button_off.Size = New-Object System.Drawing.Size(115,35)
$GroupBox_admin.Controls.Add($button_off)

$button_off.Add_Click({
shutdown /s /f /t 30 /m \\$srv
if ($lastexitcode -eq 0) {$Status.Text = "Выключение запланировано"} else {$Status.Text = "Ошибка выключения"}
})

# WOL
$button_WOL = New-Object System.Windows.Forms.Button
$button_WOL.Text = "Wake-on-LAN"
$button_WOL.Location = New-Object System.Drawing.Point(10,70)
$button_WOL.Size = New-Object System.Drawing.Size(115,35)
$GroupBox_admin.Controls.Add($button_WOL)

$button_WOL.Add_Click({
$mac = $outputBox_1.text
$BroadcastProxy=[System.Net.IPAddress]::Broadcast # ip адрес который сможет доставить пакет до сетевого интерфейса целевого компьютера
$Ports = 0,7,9

$synchronization = [byte[]](,0xFF * 6) # создать 6 байт забитых «0xFF» — называемые цепочкой синхронизации
$bmac = $Mac -Split '-' | ForEach-Object { [byte]('0x' + $_) } # разбить адрес на массив и преобразовать в тип [byte]
$packet = $synchronization + $bmac * 16 # сложить первые 6 байт и 96 байт (8 байт mac-адреса повторяющиеся 16 раз)

$UdpClient = New-Object System.Net.Sockets.UdpClient # создать сокет upd-клиента
ForEach ($port in $Ports) {$UdpClient.Connect($BroadcastProxy, $port) # установить соединение с сервером и портам из цикла 3 раза
$UdpClient.Send($packet, $packet.Length) | Out-Null} # отправить сформированный пакет
$UdpClient.Close() # закрыть соединения
})

# Get-MAC-Proxy через ARP
$button_MAC_Proxy = New-Object System.Windows.Forms.Button
$button_MAC_Proxy.Text = "Get-MAC-Proxy"
$button_MAC_Proxy.Location = New-Object System.Drawing.Point(135,70)
$button_MAC_Proxy.Size = New-Object System.Drawing.Size(115,35)
$GroupBox_admin.Controls.Add($button_MAC_Proxy)

function resolve {
#$ns = nslookup $srv
#$ns = $ns[-2]
#$global:ns = $ns -replace "Address:\s{1,10}"
$rdns = Resolve-DnsName $srv # получаем ip через dns, если сервер не доступен
$global:ns = $rdns.IPAddress
}

$button_MAC_Proxy.Add_Click({
if ($srv -NotMatch "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}") {resolve} else {$ns = $srv} # если сервер не равен ip, выполнить преобразование имени

$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("Использовать proxy-сервер?",0,"Выберите действие",3)
if ($output -eq "6") {$proxy = Read-Host "Введите адрес прокси сервера:"}
if ($output -eq "7") {$arp = arp -a} # получить локальную ARP-таблицу
if ($proxy -ne $null) {$arp = Invoke-Command -ComputerName $proxy -ScriptBlock {arp -a}} # получить ARP-таблицу с сервера proxy
$arp = $arp -match "\b$ns\b"
$arp = $arp -replace "\s{1,10}"," "
$arp = $arp -replace "\s","+"
$arp = $arp -split "\+"
$mac = $arp -match "\w\w-\w\w-"
$outputBox_1.text = $mac
})

# Get-DHCP
$button_DHCP = New-Object System.Windows.Forms.Button
$button_DHCP.Text = "Get-DHCP"
$button_DHCP.Location = New-Object System.Drawing.Point(260,70)
$button_DHCP.Size = New-Object System.Drawing.Size(115,35)
$GroupBox_admin.Controls.Add($button_DHCP)

$button_DHCP.Add_Click({
$mac = Invoke-Command -ComputerName $srv -ScriptBlock {Get-DhcpServerv4Scope | Get-DhcpServerv4Lease} | out-gridview -Title "HDCP Server: $srv" –PassThru
$mac = $mac.ClientId
$outputBox_1.text = $mac
})

# Computer Managenet
$button_9 = New-Object System.Windows.Forms.Button
$button_9.Text = "Управление"
$button_9.Location = New-Object System.Drawing.Point(10,115)
$button_9.Size = New-Object System.Drawing.Size(115,35)
$GroupBox_admin.Controls.Add($button_9)

$button_9.Add_Click({
compmgmt.msc /computer=\\$srv
})

# Services
$button_10 = New-Object System.Windows.Forms.Button
$button_10.Text = "Службы"
$button_10.Location = New-Object System.Drawing.Point(135,115)
$button_10.Size = New-Object System.Drawing.Size(115,35)
$GroupBox_admin.Controls.Add($button_10)

$button_10.Add_Click({
$Service = Get-Service -computername "$srv" | Out-GridView -Title "Services to Server $srv" –PassThru # выбранную службу добавить в переменную
$Service = $Service.Name # изъять из переменной только имя
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("Остановить или перезапустить службу: $Service",0,"Выберите действие",2)
if ($output -eq "4") {Get-Service -computername $srv | Where {$_.Name -Like $Service} | Restart-Service} # найти службу по имени
if ($output -eq "3") {Get-Service -computername $srv | Where {$_.Name -Like $Service} | Stop-Service}
$status = Get-Service -computername $srv | Where {$_.Name -Like $Service} # повторно проверить службу
$status = $status.Status # забрать статус
$output = $wshell.Popup("Статус: $status",0,"Информация",64) # отобразить статус
})

# Process
$button_11 = New-Object System.Windows.Forms.Button
$button_11.Text = "Процессы"
$button_11.Location = New-Object System.Drawing.Point(260,115)
$button_11.Size = New-Object System.Drawing.Size(115,35)
$GroupBox_admin.Controls.Add($button_11)

$button_11.Add_Click({
Invoke-Command -ComputerName "$srv" -ScriptBlock {Get-Process -IncludeUserName} | sort -Descending CPU | `
select CPU, WS, UserName, ProcessName, Company, ProductVersion, Path | `
Out-GridView -Title "Process to server $srv" –PassThru | `
Invoke-Command -ComputerName $srv -ScriptBlock {Stop-Process -Force}
})

# TCP-Viewer
$button_TCP = New-Object System.Windows.Forms.Button
$button_TCP.Text = "TCP-Viewer"
$button_TCP.Location = New-Object System.Drawing.Point(10,160)
$button_TCP.Size = New-Object System.Drawing.Size(115,35)
$GroupBox_admin.Controls.Add($button_TCP)

$button_TCP.Add_Click({
# Производит Resolve-DnsName для всех удаленных адресов и через Get-Process по ID определяет path исполняемого процесса
Invoke-Command -ComputerName $srv -ScriptBlock {Get-NetTCPConnection -State Established,Listen | Select-Object -Property LocalAddress, LocalPort, `
@{name='RemoteHostName';expression={(Resolve-DnsName $_.RemoteAddress).NameHost}},RemoteAddress, RemotePort, State, `
@{name='ProcessName';expression={(Get-Process -Id $_.OwningProcess). Path}},OffloadState,CreationTime} | Out-Gridview -Title "Network TCP Connection to server $srv"
})

# GPUpdate
$button_gpupdate = New-Object System.Windows.Forms.Button
$button_gpupdate.Text = "GPUpdate"
$button_gpupdate.Location = New-Object System.Drawing.Point(135,160)
$button_gpupdate.Size = New-Object System.Drawing.Size(115,35)
$GroupBox_admin.Controls.Add($button_gpupdate)

$button_gpupdate.Add_Click({
Invoke-Command -ComputerName $srv -ScriptBlock {gpupdate /force}
})

# GPResult
$button_gpresult = New-Object System.Windows.Forms.Button
$button_gpresult.Text = "GPResult"
$button_gpresult.Location = New-Object System.Drawing.Point(260,160)
$button_gpresult.Size = New-Object System.Drawing.Size(115,35)
$GroupBox_admin.Controls.Add($button_gpresult)

$button_gpresult.Add_Click({
$usr = Read-Host "Введите имя пользователя:"
$path = "C:\Users\$env:UserName\desktop\GPResult-$srv-$usr.html"
GPRESULT /S $srv /user $usr /H $path
ii $path
})
#endregion

#region Логи
# Логи удаленных RDP-подключений
$button_Security = New-Object System.Windows.Forms.Button
$button_Security.Text = "Подключения"
$button_Security.Location = New-Object System.Drawing.Point(10,205)
$button_Security.Size = New-Object System.Drawing.Size(115,35)
$GroupBox_admin.Controls.Add($button_Security)

$button_Security.Add_Click({
$RDPAuths = Get-WinEvent -ComputerName $srv -LogName "Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational" `
-FilterXPath '<QueryList><Query Id="0"><Select>*[System[EventID=1149]]</Select></Query></QueryList>' # поиск по ID события 1149
[xml[]]$xml = $RDPAuths | Foreach {$_.ToXml()} # помещаем в xml
$EventData = Foreach ($event in $xml.Event)
{ New-Object PSObject -Property @{
"Время подключения" = (Get-Date ($event.System.TimeCreated.SystemTime) -Format 'yyyy-MM-dd hh:mm K')
"Имя пользователя" = $event.UserData.EventXML.Param1
"Адрес клиента" = $event.UserData.EventXML.Param3
}} $EventData | Out-Gridview -Title "Remote Desktop Connection to server $srv"
})

$button_System = New-Object System.Windows.Forms.Button
$button_System.Text = "Система"
$button_System.Location = New-Object System.Drawing.Point(135,205)
$button_System.Size = New-Object System.Drawing.Size(115,35)
$GroupBox_admin.Controls.Add($button_System)

$button_System.Add_Click({
Get-EventLog -ComputerName $srv -LogName System -Newest 100 -EntryType Error,Warning | `
select TimeWritten, EventID, EntryType, Source, Message | `
Out-Gridview -Title "Log Viewer Filter to server $srv"
})

$button_Application = New-Object System.Windows.Forms.Button
$button_Application.Text = "Приложения"
$button_Application.Location = New-Object System.Drawing.Point(260,205)
$button_Application.Size = New-Object System.Drawing.Size(115,35)
$GroupBox_admin.Controls.Add($button_Application)

$button_Application.Add_Click({
Get-EventLog -ComputerName $srv -LogName Application -Newest 100 -EntryType Error,Warning | `
select TimeWritten, EventID, EntryType, Source, Message | `
Out-Gridview -Title "Log Viewer Filter to server $srv"
})
#endregion

#region WMI
$GroupBox_wmi = New-Object System.Windows.Forms.GroupBox
$GroupBox_wmi.Text = "Windows Management Instrumentation"
$GroupBox_wmi.AutoSize = $true
$GroupBox_wmi.Location  = New-Object System.Drawing.Point(600,500)
$GroupBox_wmi.Size = New-Object System.Drawing.Size(380,120)
$main_form.Controls.Add($GroupBox_wmi)

$button_15 = New-Object System.Windows.Forms.Button
$button_15.Text = "Память"
$button_15.Location = New-Object System.Drawing.Point(10,30)
$button_15.Size = New-Object System.Drawing.Size(115,35)
$GroupBox_wmi.Controls.Add($button_15)

$button_15.Add_Click({
$disk = gwmi Win32_logicalDisk -ComputerName $srv | ft @{Label="Раздел |"; Expression={$_.DeviceID}}, @{Label="Размер |"; Expression={[string]([int]($_.Size/1Gb))+" ГБ"}},`
@{Label="Доступно"; Expression={[string]([int]($_.FreeSpace/1Gb))+" ГБ"}}, @{Label=""; Expression={[string]"("+([int]($_.FreeSpace/$_.Size*100))+" %)"}}
$outputBox_1.text = $disk | out-string
$memory = Invoke-Command -ComputerName $srv -ScriptBlock {Get-ComputerInfo | ft @{Label="Всего |"; `
Expression={[string]($_.CsPhyicallyInstalledMemory/1mb)+" ГБайт"}}, `
@{Label="Доступно"; Expression={[string]([int]($_.OsFreePhysicalMemory/1kb))+" Мбайт"}}}
$outputBox_1.text += $memory | out-string
})

# Windows Updates
$button_13 = New-Object System.Windows.Forms.Button
$button_13.Text = "Обновления"
$button_13.Location = New-Object System.Drawing.Point(135,30)
$button_13.Size = New-Object System.Drawing.Size(115,35)
$GroupBox_wmi.Controls.Add($button_13)

$button_13.Add_Click({
$HotFixID = Get-WmiObject -Class Win32_QuickFixEngineering -ComputerName "$srv" | `
sort -Descending InstalledOn | Out-Gridview -Title "Windows Update to server $srv" –PassThru
$update = $HotFixID.HotFixID
$update = $update -replace "KB","" # удалить из переменной буквы
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("Удалить обновление $update на сервере $srv ?",0,"Выберите действие",4)
if ($output -eq "6") {
Invoke-Command -ComputerName "$srv" -ScriptBlock {Start-Process "wusa.exe" @("/uninstall", "/kb:$update)", "/quiet") -Wait}
}})

# Programs
$button_14 = New-Object System.Windows.Forms.Button
$button_14.Text = "Программы"
$button_14.Location = New-Object System.Drawing.Point(260,30)
$button_14.Size = New-Object System.Drawing.Size(115,35)
$GroupBox_wmi.Controls.Add($button_14)

$button_14.Add_Click({
gwmi Win32_Product -ComputerName $srv | select Name,Version,Vendor,InstallDate,InstallLocation,InstallSource | `
sort -Descending InstallDate | Out-Gridview -Title "Installed Applications to server $srv"
})

# Отчет
$button_16 = New-Object System.Windows.Forms.Button
$button_16.Text = "Report"
$button_16.Location = New-Object System.Drawing.Point(10,70)
$button_16.Size = New-Object System.Drawing.Size(115,35)
$GroupBox_wmi.Controls.Add($button_16)

$button_16.Add_Click({
$path = "C:\Users\$env:UserName\desktop\$srv-Report.html"
$date = Get-Date
$space += "Операционная система:"
$space += gwmi Win32_OperatingSystem -computername $srv | ConvertTo-HTML -As list Caption,Version
$space += "Материнская плата:"
$space += gwmi Win32_BaseBoard -computername $srv | ConvertTo-HTML -As list Manufacturer,Product
$space += "Процессор:"
$space += gwmi Win32_Processor -computername $srv | ConvertTo-HTML -As list Name, @{Label="Ядра"; Expression={$_.NumberOfCores}}, @{Label="Потоки"; Expression={$_.NumberOfLogicalProcessors}}
$space += "Оперативная память:"
$space += gwmi Win32_PhysicalMemory -computername $srv | ConvertTo-HTML -As list DeviceLocator, @{Label="Memory"; Expression={[string]($_.Capacity/1Mb)+" Мбайт"}}
$space += "Модель диска:"
$space += gwmi Win32_DiskDrive -computername $srv | ConvertTo-HTML -As list Model
$space += "Видеокарта:"
$space += gwmi Win32_VideoController -computername $srv | ConvertTo-HTML -As list Name,CurrentHorizontalResolution,CurrentVerticalResolution,DriverVersion,`
@{Label="vRAM"; Expression={[string]($_.AdapterRAM/1Gb)+" Гбайт"}}
#$space += "Сетевой адаптер:"
#$space += gwmi Win32_NetworkAdapter -computername $srv | ConvertTo-HTML -As list Name,Macaddress
$space += @("Дата отчета: $date")
$space | Out-File $path # вывод в файл
Invoke-Item $path
})

# Invoke-Item Share
$button_share = New-Object System.Windows.Forms.Button
$button_share.Text = "Share"
$button_share.Location = New-Object System.Drawing.Point(135,70)
$button_share.Size = New-Object System.Drawing.Size(115,35)
$GroupBox_wmi.Controls.Add($button_share)

$button_share.Add_Click({
$share = Get-WmiObject -ComputerName $srv -Class Win32_Share | Out-Gridview -Title "Share List to server $srv" –PassThru
$name = $share.name
$path = "\\$srv\"+"$name"
ii $path
})

# Удаленное включение RDP
$button_rdp = New-Object System.Windows.Forms.Button
$button_rdp.Text = "RDP"
$button_rdp.Location = New-Object System.Drawing.Point(260,70)
$button_rdp.Size = New-Object System.Drawing.Size(115,35)
$GroupBox_wmi.Controls.Add($button_rdp)

$button_rdp.Add_Click({
$rdp = Get-WmiObject -Class Win32_TerminalServiceSetting -Namespace root\CIMV2\TerminalServices -Computer $srv -Authentication 6
$rdp_status = $rdp.AllowTSConnections
if ($rdp_status -eq 1) {$rdp_var = "включено"} elseif ($rdp_status -eq 0) {$rdp_var = "отключено"}
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("Удаленное подключение - $rdp_var на сервере $srv, нажмите да, что бы включить и нет - отключить",0,"Выберите действие",3)
if ($output -eq "6") {(Get-WmiObject -Class Win32_TerminalServiceSetting -Namespace root\CIMV2\TerminalServices -Computer $srv -Authentication 6).SetAllowTSConnections(1,1)}
if ($output -eq "7") {(Get-WmiObject -Class Win32_TerminalServiceSetting -Namespace root\CIMV2\TerminalServices -Computer $srv -Authentication 6).SetAllowTSConnections(0,0)}
})
#endregion

#region Mеню
$Menu = New-Object System.Windows.Forms.MenuStrip # создать объект меню
$Menu.BackColor = "white" # цвет фона
$main_form.MainMenuStrip = $Menu # определить меню для формы
$main_form.Controls.Add($Menu) # добавить управление меню на форму

$menuItem_file = New-Object System.Windows.Forms.ToolStripMenuItem # создать вкладку
$menuItem_file.Text = "Файл" 
$Menu.Items.Add($menuItem_file) # добавить в меню вкладку

$menuItem_file_pad = New-Object System.Windows.Forms.ToolStripMenuItem # создать кнопку на владку файл
$menuItem_file_pad.Text = "Аутентификация"
$menuItem_file_pad.Image = $ico_cred
$menuItem_file_pad.ShortcutKeys = "Control, A"
$menuItem_file_pad.Add_Click({
$user = $env:USERDNSDOMAIN + "\" + $env:username # получить логин
$cred = Get-Credential $user # подставить переменную логина
$global:username = $Cred.UserName # заменить логин, если использовался другой
$global:password = $Cred.GetNetworkCredential().password # раскрыть пароль и присвоить глобальной переменной
if ($password -ne $null) {$Status.Text = "Авторизация выполнена пользователем: $username"}
if ($password -eq $null) {$Status.Text = "Авторизация не выполнена"}
})
$menuItem_file.DropDownItems.Add($menuItem_file_pad)

$menuItem_file_pad = New-Object System.Windows.Forms.ToolStripMenuItem # создать кнопку на владку файл
$menuItem_file_pad.Text = "Список серверов"
$menuItem_file_pad.Image = $ico_pad
$menuItem_file_pad.ShortcutKeys = "Control, S"
$menuItem_file_pad.Add_Click({ii $conf})
$menuItem_file.DropDownItems.Add($menuItem_file_pad)

$menuItem_file_exit = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_file_exit.Text = "Выход"
$menuItem_file_exit.ShortcutKeys = "Control, W"
$menuItem_file_exit.Add_Click({$main_form.Close()})
$menuItem_file.DropDownItems.Add($menuItem_file_exit)

$menuItem_find = New-Object System.Windows.Forms.ToolStripMenuItem # создать вкладку
$menuItem_find.Text = "Поиск" 
$Menu.Items.Add($menuItem_find)

# Список пользователей на брокере
$menuItem_find_broker = New-Object System.Windows.Forms.ToolStripMenuItem # создать кнопку на владку файл
$menuItem_find_broker.Text = "Connection Broker"
$menuItem_find_broker.Add_Click({
$broker = Read-Host "Введите полный доменное имя сервера с ролью Connection Broker:"
Import-Module RemoteDesktop # требуется установить модуль для подключения
$con = Get-RDUserSession -ConnectionBroker $broker | select hostserver, UserName, SessionState, CreateTime, DisconnectTime, unifiedsessionid | `
Out-GridView -title "Connect to server $broker" -PassThru | select hostserver, unifiedsessionid
if ($con -ne $null) {$id = $con | select -ExpandProperty unifiedsessionid}
if ($con -ne $null) {$srv = $con | select -ExpandProperty hostserver}
if ($con -ne $null) {mstsc /v:"$srv" /shadow:"$id" /control /noconsentprompt}
})
$menuItem_find.DropDownItems.Add($menuItem_find_broker)

# Сканер по текущей подсети активных серверов на наличие активных пользователей
$menuItem_find_scan = New-Object System.Windows.Forms.ToolStripMenuItem # создать кнопку на владку файл
$menuItem_find_scan.Text = "Сканер сети"
$menuItem_find_scan.Add_Click({
$ipconf = ipconfig # получить текущий ip-адрес
$ipconf = $ipconf -match "IPv4"
$ipconf = $ipconf -replace "   IPv4 Address. . . . . . . . . . . : "
$ip = $ipconf[0] # зрабрать только 1-й адрес
$network = $ip -replace "\.\d{1,3}$",".0" # заменить в конце строки 4-й актет на 0
$ip = $ip -replace "\.\d{1,3}$"
$outputBox_1.text = "Сканирование подсети: $network" | out-string

$start_time = Get-Date # зафиксировать время до начала сканирования
$list = 1..254 # диапазон сканирования 4-го актета
$iplist = foreach ($for in $list) {"$ip"+"."+"$for"} # сформировать список адресов
$ping = foreach ($for in $iplist) {ping -n 1 -l 1 -w 50 -v 4 $for} # пропинговать всю подсеть
$ping = $ping -match "TTL" # забрать строки с содержимым TTL (сервера которые ответили)
$ping = $ping -replace "Reply from " # удалить начало
$ping = $ping -replace ": bytes=1 .+" # удалить конец
$fqdn = foreach ($for in $ping) {nslookup $for} # проверка на регистрацию адреса в dns
$fqdn = $fqdn -match "Name:" # забрать строки с именем
$fqdn = $fqdn -replace "Name:\s+" # получить список FQDN
$user_list = foreach ($for in $fqdn) {" ";"Сервер: $for" ; query user /server:$for} # создаь массив из имени сервера и текущих пользователей

$user_list = $user_list -replace "\s{1,50}"," "
$user_list = $user_list -replace "USERNAME.+","Пользователи:"
$user_list = $user_list -replace "rdp-tcp#(\d{1,4})\s"
$user_list = $user_list -replace "console "
$user_list = $user_list -replace "Active([\s\d\.]{1,20})","подключен"
$user_list = $user_list -replace "Disc","отключен"
$user_list = $user_list -replace "подключен.+","- Подключен"
$user_list = $user_list -replace "отключен.+","- Отключен"
$user_list = $user_list -replace "^\s"
$outputBox_1.text += $user_list | out-string
$end_time = Get-Date # зафиксировать время по окончанию сканирования

$time = $end_time - $start_time # высчитать время работы скрипта
$min = $time.minutes
$sec = $time.seconds
$time = "$min"+" минут "+"$sec"+" секунд"
$outputBox_1.text += " ","Время сканирования: $time" | out-string
})
$menuItem_find.DropDownItems.Add($menuItem_find_scan)
#endregion

#region Статус
$StatusStrip = New-Object System.Windows.Forms.StatusStrip
$StatusStrip.BackColor = "white" # цвет фона
$StatusStrip.Font = "$Font,9"
$main_form.Controls.Add($statusStrip) # добавить полосу статуса

$Status = New-Object System.Windows.Forms.ToolStripMenuItem
$StatusStrip.Items.Add($Status) # добавить событие
$Status.Text = "©Telegram @kup57"
#endregion

$main_form.ShowDialog()