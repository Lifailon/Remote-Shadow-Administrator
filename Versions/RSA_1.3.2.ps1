#region config
$conf = "$env:USERPROFILE\Documents\RSA.conf.txt"
$domain = "$env:userdnsdomain"
$Font = "Arial"
$Size = "10"
Add-Type -assembly System.Drawing
$ico_rdp       = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command mstsc).Path)
$ico_usr       = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command lusrmgr.msc).Path)
$ico_cred      = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command netplwiz).Path)
$ico_pad       = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command notepad).Path)
$ico_info      = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command msinfo32).Path)
$ico_comp      = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command compmgmt).Path)
$ico_services  = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command services.msc).Path)
$ico_proc      = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command taskmgr.exe).Path)
$ico_net       = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command ncpa.cpl).Path)
$ico_gp        = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command gpedit.msc).Path)
$ico_gpr       = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command rsop.msc).Path)
$ico_disk      = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command diskmgmt.msc).Path)
$ico_iscsi     = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command iscsicpl.exe).Path)
$ico_system    = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command sysdm.cpl).Path)
$ico_netfolder = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command fsmgmt.msc).Path)
$ico_report    = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command devmgmt.msc).Path)
$ico_event     = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command eventvwr.exe).Path)
$ico_soft      = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command control.exe).Path)
$ico_upd       = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command wusa.exe).Path)
$ico_dism      = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command cleanmgr).Path)
$ico_dev       = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command devmgmt.msc).Path)
$ico_file      = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command FileHistory.exe).Path)
$ico_time      = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command timedate.cpl).Path)
$ico_kms       = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command msconfig).Path)
$ico_sync      = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command mobsync.exe).Path)
$ico_desk      = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command desk.cpl).Path)
$ico_regedit   = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command regedit).Path)
$ico_perf      = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command perfmon.msc).Path)
#endregion

#region main_form
Add-Type -assembly System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text = "Remote Shadow Administrator"
$main_form.ShowIcon = $false
$main_form.StartPosition = "CenterScreen"
$main_form.Font = "$Font,$Size"
$main_form.ForeColor = "Black"
$main_form.Size = New-Object System.Drawing.Size(850,710)
$main_form.AutoSize = $true
#endregion

#region functions_main
function list-update {
$ListBox.Items.Clear()
$srv_list = Get-Content $conf
foreach ($tmp in $srv_list) {$ListBox.Items.Add($tmp)}
}

function list-domain {
$Status.Text = "Подключение к домену: $domain"
$ListBox.Items.Clear()
$domain_comp = Get-ADComputer -Filter * -Properties *
$domain_comp_name = $domain_comp.Name
foreach ($tmp in $domain_comp_name) {$ListBox.Items.Add($tmp)}
}

function get-ping {
$ping = ping -n 1 -v 4 $srv
if ($ping -match "ttl") {$ping = @("Сервер: $srv - доступен")} else {$ping = @("Сервер: $srv - не доступен")}
$global:ping_out = $ping
}

function Get-Query {
$usrv = query user /server:$srv

$usrv = $usrv -replace "\s{1,50}"," "
$usrv = $usrv -replace "USERNAME.+"
$usrv = $usrv -replace "rdp-tcp#(\d{1,4})\s"
$usrv = $usrv -replace "console "
$usrv = $usrv -replace "Active([\s\d\.]{1,20})","подключен"
$usrv = $usrv -replace "Disc","отключен"
$usrv = $usrv -replace "подключен.+","Подключен"
$usrv = $usrv -replace "отключен.+","Отключен"
$usrv = $usrv -replace "^\s"
$usrv = $usrv -split "\s"

$obj = @()
if ($usrv[1] -gt 0) {$obj += [PSCustomObject]@{"Имя" = $usrv[1]; "ID" = $usrv[2]; "Статус" = $usrv[3]}}
if ($usrv[4] -gt 0) {$obj += [PSCustomObject]@{"Имя" = $usrv[4]; "ID" = $usrv[5]; "Статус" = $usrv[6]}}
if ($usrv[7] -gt 0) {$obj += [PSCustomObject]@{"Имя" = $usrv[7]; "ID" = $usrv[8]; "Статус" = $usrv[9]}}
if ($usrv[10] -gt 0) {$obj += [PSCustomObject]@{"Имя" = $usrv[10]; "ID" = $usrv[11]; "Статус" = $usrv[12]}}
if ($usrv[13] -gt 0) {$obj += [PSCustomObject]@{"Имя" = $usrv[13]; "ID" = $usrv[14]; "Статус" = $usrv[15]}}
if ($usrv[16] -gt 0) {$obj += [PSCustomObject]@{"Имя" = $usrv[16]; "ID" = $usrv[17]; "Статус" = $usrv[18]}}
if ($usrv[19] -gt 0) {$obj += [PSCustomObject]@{"Имя" = $usrv[19]; "ID" = $usrv[20]; "Статус" = $usrv[21]}}
if ($usrv[22] -gt 0) {$obj += [PSCustomObject]@{"Имя" = $usrv[22]; "ID" = $usrv[23]; "Статус" = $usrv[24]}}
if ($usrv[25] -gt 0) {$obj += [PSCustomObject]@{"Имя" = $usrv[25]; "ID" = $usrv[26]; "Статус" = $usrv[27]}}
if ($usrv[28] -gt 0) {$obj += [PSCustomObject]@{"Имя" = $usrv[28]; "ID" = $usrv[29]; "Статус" = $usrv[30]}}
if ($usrv[31] -gt 0) {$obj += [PSCustomObject]@{"Имя" = $usrv[31]; "ID" = $usrv[32]; "Статус" = $usrv[33]}}
if ($usrv[34] -gt 0) {$obj += [PSCustomObject]@{"Имя" = $usrv[34]; "ID" = $usrv[35]; "Статус" = $usrv[36]}}
if ($usrv[37] -gt 0) {$obj += [PSCustomObject]@{"Имя" = $usrv[37]; "ID" = $usrv[38]; "Статус" = $usrv[39]}}
if ($usrv[40] -gt 0) {$obj += [PSCustomObject]@{"Имя" = $usrv[40]; "ID" = $usrv[41]; "Статус" = $usrv[42]}}
if ($usrv[43] -gt 0) {$obj += [PSCustomObject]@{"Имя" = $usrv[43]; "ID" = $usrv[44]; "Статус" = $usrv[45]}}
if ($usrv[46] -gt 0) {$obj += [PSCustomObject]@{"Имя" = $usrv[46]; "ID" = $usrv[47]; "Статус" = $usrv[48]}}
if ($usrv[49] -gt 0) {$obj += [PSCustomObject]@{"Имя" = $usrv[49]; "ID" = $usrv[50]; "Статус" = $usrv[51]}}
if ($usrv[52] -gt 0) {$obj += [PSCustomObject]@{"Имя" = $usrv[52]; "ID" = $usrv[53]; "Статус" = $usrv[54]}}
if ($usrv[55] -gt 0) {$obj += [PSCustomObject]@{"Имя" = $usrv[55]; "ID" = $usrv[56]; "Статус" = $usrv[57]}}
if ($usrv[58] -gt 0) {$obj += [PSCustomObject]@{"Имя" = $usrv[58]; "ID" = $usrv[59]; "Статус" = $usrv[60]}}
$global:obj = $obj
}

function get-obj {
$list = New-Object System.collections.ArrayList
$list.AddRange($obj)
$dataGridView.DataSource = $list
}

function up-time {
$boottime = Get-CimInstance -ComputerName $srv Win32_OperatingSystem | select LastBootUpTime
$datetime = (Get-Date) - $boottime.LastBootUpTime | SELECT Days,Hours,Minutes
$string = [convert]::ToString($datetime)
$string = $string -replace "@{"
$string = $string -replace "}"
$string = $string -replace ";"
$string = $string -replace "Days=","Дней: "
$string = $string -replace "Hours=","Часов: "
$string = $string -replace "Minutes=","Минут: "
$global:uptime = $string
}

function fun-main {
get-ping
$Status.Text = "$ping_out"
$ping_out_false = "Сервер: $srv - не доступен"
if ("$ping_out" -ne $ping_out_false) {
Get-Query
get-obj
up-time
} else {
$uptime = $null
}
if ($uptime.Length -gt 1) {$Status.Text += ". Время работы - $uptime"} else {$Status.Text += ". WinRM не доступен"}
}

function broker-user {
$broker = Read-Host "Введите полное доменное имя сервера с ролью RDCB:"
Import-Module RemoteDesktop
$con = Get-RDUserSession -ConnectionBroker $broker | select hostserver, UserName, SessionState, CreateTime, DisconnectTime, unifiedsessionid | `
Out-GridView -title "Сервер: $broker" -PassThru
if ($con -ne $null) {$id = $con | select -ExpandProperty unifiedsessionid}
if ($con -ne $null) {$srv = $con | select -ExpandProperty hostserver}
if ($con -ne $null) {mstsc /v:"$srv" /shadow:"$id" /control /noconsentprompt}
}

function domain-comp {
$comp = Get-ADComputer -Filter * -Properties * | select @{Label="Статус"; Expression={
if ($_.Enabled -eq "True") {$_.Enabled -replace "True","Активный"} else {$_.Enabled -replace "False","Заблокирован"}
}}, @{Label="Имя"; Expression={$_.Name}}, @{Label="IP-адрес"; Expression={$_.IPv4Address}}, `
@{Label="Операционная система"; Expression={$_.OperatingSystem}}, @{Label="Пользователь"; `
Expression={$_.ManagedBy -replace "(CN=|,.+)"}}, @{Label="Дата создания"; Expression={$_.Created}} | sort -Descending "Дата создания" | `
Out-GridView -Title "domain: $domain" –PassThru
$global:srv = $comp.Имя
fun-main
}
#endregion

#region functions_admin
function comp-manager {
compmgmt.msc /computer=\\$srv
}

function services-view {
$Service = Get-Service -computername "$srv" | Out-GridView -Title "Службы на сервере $srv" –PassThru
$global:Service_out = $Service.Name
if ($Service_out -ne $null) {services-restart}
}

function services-restart {
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("Остановить или перезапустить службу: $Service_out",0,"Выберите действие",2)
if ($output -eq "4") {Get-Service -computername $srv | Where {$_.Name -Like $Service_out} | Restart-Service}
if ($output -eq "3") {Get-Service -computername $srv | Where {$_.Name -Like $Service_out} | Stop-Service}
$status_services = Get-Service -computername $srv | Where {$_.Name -Like $Service_out}
$status_services = $status_services.Status
$output = $wshell.Popup("Статус: $status_services",0,"Информация",64)
$Service_out = $null
}

function process-users {
Invoke-Command -ComputerName "$srv" -ScriptBlock {Get-Process -IncludeUserName} | sort -Descending CPU | `
select CPU, WS, UserName, ProcessName, Company, ProductVersion, Path | `
Out-GridView -Title "Процессы на сервере $srv" –PassThru | `
Invoke-Command -ComputerName $srv -ScriptBlock {Stop-Process -Force}
}

function view-soft {
$software = icm $srv {Get-Package -ProviderName msi} | select name,version,Source,ProviderName `
| Out-GridView -Title "Программы на сервере $srv" –PassThru
if ($software.Name -ne $null) {$global:soft = $software.Name} else {$soft = $null}
$wshell = New-Object -ComObject Wscript.Shell
if ($soft -ne $null) {
$output = $wshell.Popup("Удалить $soft ?",0,"Выберите действие",4)
}
if ($output -eq "6") {remove-soft}
}

function remove-soft {
$Status.Text = "10%...удаление"; sleep 1
$session = New-PSSession $srv
$Status.Text = "20%...удаление"; sleep 1
icm -Session $session {$soft = $using:soft}
$Status.Text = "30%...удаление"; sleep 1
icm -Session $session {if ($soft -ne $null) {
Get-Package -Name "$soft" | Uninstall-Package}
}
$Status.Text = "50%...удаление"; sleep 1
icm -Session $session {$soft = $null}
$Status.Text = "70%...удаление"; sleep 1
Disconnect-PSSession $session
$Status.Text = "80%...удаление"; sleep 1
Remove-PSSession $session
$Status.Text = "90%...удаление"; sleep 1
$soft = $null
$Status.Text = "100%...Завершено"; sleep 1
}

function upd-dism {
$session = New-PSSession $srv
$dismName = icm -Session $session {dism /Online /Get-Packages /format:table} | Out-Gridview `
-Title "Пакеты на сервере $srv" –PassThru
if ($dismName -ne $null) {
$dismNamePars = $dismName -replace "\|.+"
$dismNamePars = $dismNamePars -replace "\s"
} else {$dismNamePars = $null}
$wshell = New-Object -ComObject Wscript.Shell
if ($dismNamePars -ne $null) {
$output = $wshell.Popup("Удалить обновление $dismNamePars на сервере $srv ?",0,"Выберите действие",4)
}
if ($output -eq "6") {icm -Session $session {$dismNamePars = $using:dismNamePars}}
if ($output -eq "6") {$Status.Text = "10%...удаление"; sleep 1}
if ($output -eq "6") {icm -Session $session {dism /Online /Remove-Package /PackageName:$dismNamePars /quiet /norestart}}
if ($output -eq "6") {$Status.Text = "100%...готово"; sleep 1}
if ($output -eq "6") {icm -Session $session {$dismNamePars = $null}}
Disconnect-PSSession $session
Remove-PSSession $session
if ($output -eq "6") {$dismNamePars = $null}
}

function SMB-files {
$session = New-CIMSession –Computername $srv
Get-SmbOpenFile -CIMSession $session | select ClientUserName,ClientComputerName,Path,SessionID | `
Out-GridView -PassThru –title "Открытые файлы на сервере $srv" | Close-SmbOpenFile -CIMSession $session -Confirm:$false –Force
}

function TCP-Viewer {
Invoke-Command -ComputerName $srv -ScriptBlock {Get-NetTCPConnection -State Established,Listen | Select-Object -Property LocalAddress, LocalPort, `
@{name='RemoteHostName';expression={(Resolve-DnsName $_.RemoteAddress).NameHost}},RemoteAddress, RemotePort, State, `
@{name='ProcessName';expression={(Get-Process -Id $_.OwningProcess). Path}},OffloadState,CreationTime} | `
Out-Gridview -Title "Сетевые TCP-подключения на сервере $srv"
}

function gp-upd {
Invoke-Command -ComputerName $srv -ScriptBlock {gpupdate /force}
if ($lastexitcode -eq 0) {$Status.Text = "Групповые политики на сервере $srv применены"} else {$Status.Text = "Ошибка применения политик"}
}

function gp-res {
$usr = Read-Host "Введите имя пользователя:"
$path = "C:\Users\$env:UserName\desktop\GPResult-$srv-$usr.html"
GPRESULT /S $srv /user $usr /H $path
ii $path
}
#endregion

#region functions_power
function power-reboot {
shutdown /r /f /t 60 /m \\$srv /c "Плановая перезагрузка сервера через 30 секунд"
if ($lastexitcode -eq 0) {$Status.Text = "Перезагрузка запланирована"}
if (($lastexitcode -ne 0) -and ($lastexitcode -eq 1190)) {$Status.Text = "Перезагрузка уже запланирована"}
if (($lastexitcode -ne 0) -and ($lastexitcode -ne 1190)) {$Status.Text = "Ошибка перезапуска"}
}

function power-off {
shutdown /s /f /t 30 /m \\$srv
if ($lastexitcode -eq 0) {$Status.Text = "Выключение запланировано"} else {$Status.Text = "Ошибка выключения"}
}

function power-cancel {
shutdown /a /m \\$srv
if ($lastexitcode -eq 0) {$Status.Text = "Перезагрузка отменена"}
if (($lastexitcode -ne 0) -and ($lastexitcode -eq 1116)) {$Status.Text = "Перезагрузка уже отменена"}
if (($lastexitcode -ne 0) -and ($lastexitcode -ne 1116)) {$Status.Text = "Ошибка отмены перезапуска"}
}

function power-monitor {
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("Что бы отключить блокировку экрана нажмите да
Что бы указать время до блокировки, нажмите нет",0,"Выберите действие",3)
if ($output -eq "6") {$timeout = "0"}
if ($output -eq "7") {$timeout = Read-Host "Введите время в минутах"}
$session = New-PSSession $srv
icm -Session $session {$timeout = $using:timeout}
icm -Session $session {powercfg -change -monitor-timeout-ac $timeout}
icm -Session $session {powercfg -change -monitor-timeout-dc $timeout}
Remove-PSSession $session
if ($output -eq "6") {$Status.Text = "Блокировка экрана отключена"}
if ($output -eq "7") {$Status.Text = "Блокировка экрана включена ($timeout минут)"}
}

function power-standby {
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("Что бы отключить спящий режим нажмите да
Что бы указать время до перехода в спящий режим, нажмите нет",0,"Выберите действие",3)
if ($output -eq "6") {$timeout = "0"}
if ($output -eq "7") {$timeout = Read-Host "Введите время в минутах"}
$session = New-PSSession $srv
icm -Session $session {$timeout = $using:timeout}
icm -Session $session {powercfg -x -standby-timeout-ac $timeout}
icm -Session $session {powercfg -x -standby-timeout-dc $timeout}
Remove-PSSession $session
if ($output -eq "6") {$Status.Text = "Спящий режим отключен"}
if ($output -eq "7") {$Status.Text = "Спящий режим включен ($timeout минут)"}
}

function power-wol {
[string]$mac_out = $outputBox_message.text
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("Разбудить сервер с MAC-адресом: $mac_out ?",0,"Адрес из поля ввода сообщения",4)
if ($output -eq "6") {
$global:mac = $mac_out;
wol-pack
}}

function wol-pack {
$BroadcastProxy=[System.Net.IPAddress]::Broadcast
$Ports = 0,7,9

$synchronization = [byte[]](,0xFF * 6)
$bmac = $mac -Split '-' | ForEach-Object { [byte]('0x' + $_) }
$packet = $synchronization + $bmac * 16

$UdpClient = New-Object System.Net.Sockets.UdpClient
ForEach ($port in $Ports) {$UdpClient.Connect($BroadcastProxy, $port)
$UdpClient.Send($packet, $packet.Length) | Out-Null}
$UdpClient.Close()
$Status.Text = "Пакет отправлен"
}

function resolve {
#$ns = nslookup $srv
#$ns = $ns[-2]
#$global:ns = $ns -replace "Address:\s{1,10}"
$rdns = Resolve-DnsName $srv
$global:ns = $rdns.IPAddress
}

function get-mac-proxy {
if ($srv -NotMatch "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}") {resolve} else {$ns = $srv}
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("Использовать proxy-сервер?",0,"Выберите действие",3)
if ($output -eq "6") {$proxy = Read-Host "Введите адрес прокси сервера:"}
if ($output -eq "7") {$arp = arp -a}
if ($proxy -ne $null) {$arp = Invoke-Command -ComputerName $proxy -ScriptBlock {arp -a}}
$arp = $arp -match "\b$ns\b"
$arp = $arp -replace "\s{1,10}"," "
$arp = $arp -replace "\s","+"
$arp = $arp -split "\+"
$mac = $arp -match "\w\w-\w\w-"
$outputBox_message.text = $mac
}

function get-dhcp {
$mac = Invoke-Command -ComputerName $srv -ScriptBlock {Get-DhcpServerv4Scope | Get-DhcpServerv4Lease} | out-gridview -Title "HDCP Server: $srv" –PassThru
$mac = $mac.ClientId
$outputBox_message.text = $mac
}
#endregion

#region functions_event
function event-vwr {eventvwr $srv}

function event-sys {
Get-EventLog -ComputerName $srv -LogName System -Newest 100 -EntryType Error,Warning | `
select TimeWritten, EventID, EntryType, Source, Message | `
Out-Gridview -Title "Логи системы на сервере $srv"
}

function event-app {
Get-EventLog -ComputerName $srv -LogName Application -Newest 100 -EntryType Error,Warning | `
select TimeWritten, EventID, EntryType, Source, Message | `
Out-Gridview -Title "Логи приложений на сервере $srv"
}

function rdp-con {
$RDPAuths = Get-WinEvent -ComputerName $srv -LogName "Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational" `
-FilterXPath '<QueryList><Query Id="0"><Select>*[System[EventID=1149]]</Select></Query></QueryList>'
[xml[]]$xml = $RDPAuths | Foreach {$_.ToXml()}
$EventData = Foreach ($event in $xml.Event)
{ New-Object PSObject -Property @{
"Время подключения" = (Get-Date ($event.System.TimeCreated.SystemTime) -Format 'yyyy-MM-dd hh:mm K')
"Имя пользователя" = $event.UserData.EventXML.Param1
"Адрес клиента" = $event.UserData.EventXML.Param3
}} $EventData | Out-Gridview -Title "История RDP подключений на сервере $srv"
}
#endregion

#region functions_Time
function net-time {
$net_time = net time \\$srv
$regtime = $net_time -match "$srv"
$regtime = $regtime -replace "$srv"
$regtime = $regtime -replace "Current time at \\\\ is "
$global:nettime = $regtime
$Status.Text = "Текущее время на сервере $srv - $nettime. "

$span = new-timespan -Start (get-date) -end (icm $srv {get-date})
[string]$diff = $span.TotalSeconds
$Status.Text += "Разница во времени: $diff секунд"
}

function check-time {
[string]$in_time = icm $srv {w32tm /query /status}
if ($in_time -match "Last") {
[string]$in_time = $in_time -replace ".+(?<= Last)"
[string]$in_time = $in_time -replace "^","Last"
} else {
[string]$in_time = icm $srv {w32tm /query /source}
}
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("$in_time",0,"Статус $srv",64)
}

function time-test {
$in_time = w32tm /stripchart /computer:$srv /dataonly /samples:1
if ($in_time -match "0x800705B4") {
$Status.Text = "Ошибка источника времени $srv"
} else {$Status.Text = "Нет ошибок источника времени $srv"}
}

function sync-domain {
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("
Что бы сделать источником времени домен, нажмите да
Указать внешний источник, нажмите нет",0,"Выберите действие для сервера $srv",3)
if ($output -eq "6") {sync-PDC}
if ($output -eq "7") {sync-external}
}

function sync-external {
$session = New-PSSession $srv
$servertime = Read-Host "Введите имя сервера"
icm -Session $session {$servertime = $using:servertime}
if ($servertime -ne $null) {icm -Session $session {w32tm.exe /config /manualpeerlist:"$servertime,0x8" /syncfromflags:manual /reliable:yes /update}}
icm -Session $session {Get-Service | Where {$_.Name -match "w32time"} | restart-service}
Remove-PSSession $session
$Status.Text = "$servertime выбран внешним источником времени"
}

function sync-PDC {
$session = New-PSSession $srv
icm -Session $session {Get-Service | Where {$_.Name -match "w32time"} | stop-service}
$Status.Text = "10%...Остановка службы"; sleep 5
icm -Session $session {w32tm.exe /unregister}
$Status.Text = "20%...Сброс настроек"; sleep 10
$Status.Text = "30%...Сброс настроек"; sleep 10
$Status.Text = "40%...Сброс настроек"; sleep 5
$Status.Text = "50%...Настройка"; sleep 5
icm -Session $session {w32tm.exe /register}
$Status.Text = "60%...Настройка"; sleep 5
$Status.Text = "70%...Настройка"; sleep 5
icm -Session $session {Get-Service | Where {$_.Name -match "w32time"} | start-service}
$Status.Text = "80%...Настройка"; sleep 5
icm -Session $session {w32tm /config /syncfromflags:domhier /update}
$Status.Text = "90%...Запуск службы"; sleep 5
icm -Session $session {Get-Service | Where {$_.Name -match "w32time"} | restart-service}
Remove-PSSession $session
$Status.Text = "100%...Готово"
}

function sync-time {
icm $srv {w32tm /resync /rediscover}
$Status.Text = "Синхронизирован"
}
#endregion

#region functions_KMS
function kms-status {
$wmios = gwmi Win32_OperatingSystem -computername $srv
$os = $wmios.Caption

$check = icm $srv {Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | where {$_.PartialProductKey}}
$kms_ver = $check.LicenseFamily
$kms_channel = $check.Description
$kms_key = $check.ProductKeyChannel
$kms_check = $check.LicenseStatus
if ($kms_check -eq 0) {$kms_status = "Сервер не активирован"}
if ($kms_check -eq 1) {$kms_status = "Сервер активирован"}
if ($kms_check -eq 2) {$kms_status = "OOBGrace"}
if ($kms_check -eq 3) {$kms_status = "OOTGrace (не может активироваться автоматически или прошло более 180 дней)"}
if ($kms_check -eq 4) {$kms_status = "NonGenuineGrace"}
if ($kms_check -eq 5) {$kms_status = "Срок ознакомительного использования Windows окончен"}
if ($kms_check -eq 6) {$kms_status = "ExtendedGrace (срок использования ознакомительной версии Windows можно продлить несколько раз с помощью команды slmgr /rearm)"}

$kms_ip = $check.DiscoveredKeyManagementServiceMachineIpAddress
if ($check.DiscoveredKeyManagementServiceMachineName -gt 0) {$kms_name = $check.DiscoveredKeyManagementServiceMachineName}
if ($check.KeyManagementServiceMachine -gt 0) 				{$kms_name = $check.KeyManagementServiceMachine}
if ($check.DiscoveredKeyManagementServiceMachinePort -gt 0) {$kms_port = $check.DiscoveredKeyManagementServiceMachinePort}
if ($check.KeyManagementServicePort -gt 0) 					{$kms_port = $check.KeyManagementServicePort}
$ip_port = "$kms_ip"+":"+"$kms_port"

$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup(
"Операционная системая: $os
Редакция: $kms_ver
Канал: $kms_channel
Ключ: $kms_key
Статус: $kms_status ($kms_check)
Сервер лицензий: $kms_name ($ip_port)",
64,"$srv")
}

function kms-domain {
$kms_domain = nslookup -type=srv _vlmcs._tcp.$domain
#$kms_domain = $kms_domain -Match "(hostname|port)"
$kms_domain = $kms_domain -Match "(hostname)"
[string]$kms_domain = $kms_domain -replace ".+(?<== )"
$Status.Text = "Адрес KMS-сервера $kms_domain в домене $domain"
}

function gvlk-managment {
$main_form_gvlk = New-Object System.Windows.Forms.Form
$main_form_gvlk.Text = "GVLK активатор"
$main_form_gvlk.ShowIcon = $false
$main_form_gvlk.StartPosition = "CenterScreen"
$main_form_gvlk.Font = "$Font,$Size"
$main_form_gvlk.ForeColor = "Black"
$main_form_gvlk.Size = New-Object System.Drawing.Size(290,390)
$main_form_gvlk.AutoSize = $true

$ListBox_gvlk = New-Object System.Windows.Forms.ListBox
$ListBox_gvlk.Location  = New-Object System.Drawing.Point(10,10)
$ListBox_gvlk.Size = New-Object System.Drawing.Size(250,300)
$ListBox_gvlk.Items.Add("Windows Server 2016 Datacenter")
$ListBox_gvlk.Items.Add("Windows Server 2016 Standart")
$ListBox_gvlk.Items.Add("Windows Server 2019 Datacenter")
$ListBox_gvlk.Items.Add("Windows Server 2019 Standart")
$ListBox_gvlk.Items.Add("Windows Server 2022 Datacenter")
$ListBox_gvlk.Items.Add("Windows Server 2022 Standart")
$ListBox_gvlk.Items.Add("Windows 10 Professional")
$main_form_gvlk.Controls.add($ListBox_gvlk)

$button_gvlk = New-Object System.Windows.Forms.Button
$button_gvlk.Text = "Выбрать"
$button_gvlk.Location = New-Object System.Drawing.Point(10,310)
$button_gvlk.Size = New-Object System.Drawing.Size(100,30)
$main_form_gvlk.Controls.Add($button_gvlk)

$button_gvlk.Add_Click({
$global:gvlk_key = $ListBox_gvlk.selectedItem
$main_form_gvlk.close()
})

$main_form_gvlk.ShowDialog()

if ($gvlk_key -eq "Windows Server 2016 Datacenter") {icm $srv {cscript $env:windir\system32\slmgr.vbs /ipk CB7KF-BWN84-R7R2Y-793K2-8XDDG}}
if ($gvlk_key -eq "Windows Server 2016 Standart")   {icm $srv {cscript $env:windir\system32\slmgr.vbs /ipk WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY}}
if ($gvlk_key -eq "Windows Server 2019 Datacenter") {icm $srv {cscript $env:windir\system32\slmgr.vbs /ipk WMDGN-G9PQG-XVVXX-R3X43-63DFG}}
if ($gvlk_key -eq "Windows Server 2019 Standart")   {icm $srv {cscript $env:windir\system32\slmgr.vbs /ipk N69G4-B89J2-4G8F4-WWYCC-J464C}}
if ($gvlk_key -eq "Windows Server 2022 Datacenter") {icm $srv {cscript $env:windir\system32\slmgr.vbs /ipk WX4NM-KYWYW-QJJR4-XV3QB-6VM33}}
if ($gvlk_key -eq "Windows Server 2022 Standart")   {icm $srv {cscript $env:windir\system32\slmgr.vbs /ipk VDYBN-27WPP-V4HQT-9VMD4-VMK7H}}
if ($gvlk_key -eq "Windows 10 Professional")        {icm $srv {cscript $env:windir\system32\slmgr.vbs /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX}}
if ($gvlk_key -eq $null) {

$Status.Text = "Редакция не выбрана"} else {
$Status.Text = "Активация публичного ключа Generic Volume License Key для редакции $gvlk_key выполнена"}
$gvlk_key = $null
}

function kms-server {
$kms_srv_enter = Read-Host "Введите адрес KMS-сервера"
$Status.Text = "Выбран KMS-сервер: $kms_srv_enter"
$port_default = "1688"
$kms_srv_port = "$kms_srv_enter"+":"+"$port_default"
$session = New-PSSession $srv
icm -Session $session {$kms_srv_port = $using:kms_srv_port}
icm -Session $session {cscript $env:windir\system32\slmgr.vbs /skms $kms_srv_port}
Remove-PSSession $session
}

function kms-lic {
icm $srv {cscript $env:windir\system32\slmgr.vbs /ato}
$Status.Text = "Активация выполнена"
}
#endregion

#region functions_WMI
function wim-disk {
$disk = gwmi Win32_logicalDisk -ComputerName $srv | select @{Label="Раздел"; Expression={$_.DeviceID}}, @{Label="Всего"; Expression={[string]([int]($_.Size/1Gb))+" ГБ"}},`
@{Label="Доступно"; Expression={[string]([int]($_.FreeSpace/1Gb))+" ГБ"}}, @{Label="Доступно %"; Expression={[string]([int]($_.FreeSpace/$_.Size*100))+" %"}}
$list = New-Object System.collections.ArrayList
$list.AddRange($disk)
$dataGridView.DataSource = $list
}

function wim-mem {
$memory = Invoke-Command -ComputerName $srv -ScriptBlock {Get-ComputerInfo | select @{Label="ALL"; `
Expression={[string]($_.CsPhyicallyInstalledMemory/1mb)+" ГБайт"}}, `
@{Label="FREE"; Expression={[string]([int]($_.OsFreePhysicalMemory/1kb))+" Мбайт"}}}
$mem_all = $memory.all
$mem_free = $memory.free
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("Всего: $mem_all`
Доступно: $mem_free",0,"Оперативная память",64,"$srv")
}

function wmi-soft {
$soft_wmi = gwmi Win32_Product -ComputerName $srv | select Name,Version,Vendor,InstallDate,InstallLocation,InstallSource | `
sort -Descending InstallDate | Out-Gridview -Title "Программы на сервере $srv" –PassThru
$soft_wmi_uninstall = $soft_wmi.Name
$wshell = New-Object -ComObject Wscript.Shell
if ($soft_wmi_uninstall -ne $null) {
$output = $wshell.Popup("Удалить $soft_wmi_uninstall на сервер $srv ?",0,"Выберите действие",4)
}
if ($output -eq "6") {
$uninstall = (gwmi Win32_Product -ComputerName $srv -Filter "Name = '$soft_wmi_uninstall'").Uninstall()
}
if ($uninstall.ReturnValue -eq 0) {$Status.text = "Удаление $soft_wmi_uninstall на сервер $srv выполнено"} else {
$Status.text = "Ошибка удаления ($uninstall.ReturnValue)"
}}

function openfile {
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.Filter = "msi (*.msi)|*.msi"
$OpenFileDialog.InitialDirectory = ".\"
$OpenFileDialog.Title = "Выберите файл"
$getKey = $OpenFileDialog.ShowDialog()
[string]$global:path_msi = $OpenFileDialog.FileNames
[string]$global:name_msi = $OpenFileDialog.SafeFileName
$status.Text = "Выбран файл: $path_msi"
}

function wmi-install {
openfile
$wshell = New-Object -ComObject Wscript.Shell
if ($path_msi -ne $null) {
$output = $wshell.Popup("Установить $name_msi на сервер $srv ?",0,"Выберите действие",4)
}
if ($output -eq "6") {wmi-installer}
}

function wmi-installer {
#$Status.Text = "Запущен процесс установка $name_msi на сервер $srv"
#$install = Invoke-CimMethod -ComputerName $srv -ClassName Win32_Product -MethodName Install -Arguments @{PackageLocation=$path_msi}
#$install_out = $install.ReturnValue
#if ($install_out -eq "0") {$status.Text = "Установка $name_msi на сервере $srv выполнена успешно"} else {
#$status.Text = "Ошибка установки ($install_out)"}
############################################################
#$Status.Text = "Запущен процесс установка $name_msi на сервер $srv"
#$install = (Get-WMIObject -Authentication PacketPrivacy -ComputerName $srv -List | Where-Object -FilterScript {$_.Name -eq "Win32_Product"}).Install($path_msi)
#$install_out = $install.ReturnValue # забрать вывод
#if ($install_out -eq "0") {$status.Text = "Установка $name_msi на сервере $srv выполнена успешно"} else {
#$status.Text = "Ошибка установки ($install_out)"}
############################################################
$session = New-PSSession $srv
icm -Session $session {$path_msi = $using:path_msi}
$Status.Text = "Запущен процесс установка $name_msi на сервер $srv"
$install = icm -Session $session {Install-Package -Name $path_msi -Force -Verbose}
icm -Session $session {$path_msi = $null}
Disconnect-PSSession $session
Remove-PSSession $session
$path_msi = $null
[string]$inst_out = $install.Status
if ($install -ne $null) {$Status.Text = "Установка завершена ($inst_out)"} else {$Status.Text = "Ошибка установки"}
}

function wmi-upd {
$HotFixID = Get-WmiObject -Class Win32_QuickFixEngineering -ComputerName "$srv" | `
sort -Descending InstalledOn | Out-Gridview -Title "Обновления на сервере $srv" –PassThru
Set-Clipboard $HotFixID.HotFixID
$Clipboard = Get-Clipboard
if ($HotFixID -ne $null) {$status.Text = "Обновление $Clipboard скопировано в буфер обмена для поиска в DISM"}
}

function wmi-drivers {
gwmi -ComputerName $srv Win32_SystemDriver | Out-Gridview -Title "Драйвера на сервере $srv"
}

function wmi-report {
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
$space | Out-File $path
Invoke-Item $path
}

function wmi-share {
$share = Get-WmiObject -ComputerName $srv -Class Win32_Share | Out-Gridview -Title "Share на сервере $srv" –PassThru
$name = $share.name
$path = "\\$srv\"+"$name"
ii $path
}

function wmi-rdp {
$rdp = Get-WmiObject -Class Win32_TerminalServiceSetting -Namespace root\CIMV2\TerminalServices -Computer $srv -Authentication 6
$rdp_status = $rdp.AllowTSConnections
if ($rdp_status -eq 1) {$rdp_var = "включено"} elseif ($rdp_status -eq 0) {$rdp_var = "отключено"}
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("Удаленное подключение - $rdp_var, на сервере $srv`
нажмите да, что бы включить или нет - отключить",0,"Выберите действие",3)
if ($output -eq "6") {
(Get-WmiObject -Class Win32_TerminalServiceSetting -Namespace root\CIMV2\TerminalServices -Computer $srv `
-Authentication 6).SetAllowTSConnections(1,1)
}
if ($output -eq "7") {
(Get-WmiObject -Class Win32_TerminalServiceSetting -Namespace root\CIMV2\TerminalServices -Computer $srv `
-Authentication 6).SetAllowTSConnections(0,0)
}
}

function wmi-nla {
$nla = (Get-WmiObject -class "Win32_TSGeneralSetting" -Namespace root\cimv2\Terminalservices -ComputerName $srv `
-Filter "TerminalName='RDP-tcp'")
if ($nla.UserAuthenticationRequired -eq 1) {$nla_out = "включена"}
if ($nla.UserAuthenticationRequired -eq 0) {$nla_out = "выключена"}
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("Network Level Authentication - $nla_out, на сервере $srv`
нажмите да, что бы включить или нет - отключить",0,"Выберите действие",3)
if ($output -eq "6") {
(Get-WmiObject -class "Win32_TSGeneralSetting" -Namespace root\cimv2\Terminalservices -ComputerName $srv `
-Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(1)
}
if ($output -eq "7") {
(Get-WmiObject -class "Win32_TSGeneralSetting" -Namespace root\cimv2\Terminalservices -ComputerName $srv `
-Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0)
}
}
#endregion

#region cred
function srv-cred {
$user = $env:USERDNSDOMAIN + "\" + $env:username
$cred = Get-Credential $user
$global:username = $Cred.UserName
$global:password = $Cred.GetNetworkCredential().password
if ($password -ne $null) {$Status.Text = "Авторизация выполнена пользователем: $username"}
if ($password -eq $null) {$Status.Text = "Авторизация не выполнена"}
}
#endregion

#region srv_list
$GroupBox_srv = New-Object System.Windows.Forms.GroupBox
$GroupBox_srv.Text = "Список серверов"
$GroupBox_srv.AutoSize = $true
$GroupBox_srv.Location  = New-Object System.Drawing.Point(10,55)
$GroupBox_srv.Size = New-Object System.Drawing.Size(300,580)
$main_form.Controls.Add($GroupBox_srv)

$ListBox = New-Object System.Windows.Forms.ListBox
$ListBox.Location  = New-Object System.Drawing.Point(10,25)
$ListBox.Size = New-Object System.Drawing.Size(280,440)
$ListBox.Font = "$Font,12"
list-update
$GroupBox_srv.Controls.add($ListBox)

$ContextMenu = New-Object System.Windows.Forms.ContextMenu
$ContextMenu.MenuItems.Add("Обновить",{list-update})
$ContextMenu.MenuItems.Add("Список серверов",{ii $conf})
$ContextMenu.MenuItems.Add("Список серверов домена",{list-domain})
$ListBox.ContextMenu = $ContextMenu

$button_1 = New-Object System.Windows.Forms.Button
$button_1.Text = " Проверить"
$button_1.Image = $ico_usr
$button_1.ImageAlign = "MiddleLeft"
$button_1.Location = New-Object System.Drawing.Point(8,470)
$button_1.Size = New-Object System.Drawing.Size(145,40)
$GroupBox_srv.Controls.Add($button_1)

$button_1.Add_Click({
$global:srv = $ListBox.selectedItem
fun-main
})

$button_mstsc = New-Object System.Windows.Forms.Button
$button_mstsc.Text = "        Подключиться"
$button_mstsc.Image = $ico_rdp
$button_mstsc.ImageAlign = "MiddleLeft"
$button_mstsc.Location = New-Object System.Drawing.Point(8,515)
$button_mstsc.Size = New-Object System.Drawing.Size(145,40)
$GroupBox_srv.Controls.Add($button_mstsc)

$button_mstsc.Add_Click({
$Status.Text = "Подключение к серверу $srv"
if ($password -ne $Null) {
cmdkey /generic:"TERMSRV/$srv" /user:"$username" /pass:"$password"
}
mstsc /admin /v:$srv
Start-Sleep -Seconds 1
cmdkey /delete:"TERMSRV/$srv"
})
#endregion

#region user_table
$GroupBox_usr = New-Object System.Windows.Forms.GroupBox
$GroupBox_usr.Text = "Список пользователей"
$GroupBox_usr.AutoSize = $true
$GroupBox_usr.Location  = New-Object System.Drawing.Point(320,55)
$GroupBox_usr.Size = New-Object System.Drawing.Size(500,580)
$main_form.Controls.Add($GroupBox_usr)

$dataGridView = New-Object System.Windows.Forms.DataGridView
$dataGridView.Location = New-Object System.Drawing.Point(10,25)
$dataGridView.Size = New-Object System.Drawing.Size(480,435)
$dataGridView.AutoSizeColumnsMode = "Fill" 
$dataGridView.Font = "$Font,10"
$dataGridView.AutoSize = $false
$dataGridView.MultiSelect = $false
$dataGridView.ReadOnly = $true
$GroupBox_usr.Controls.Add($dataGridView)

$button_2 = New-Object System.Windows.Forms.Button
$button_2.Text = "Подключиться"
$button_2.Location = New-Object System.Drawing.Point(8,470)
$button_2.Size = New-Object System.Drawing.Size(145,40)
$GroupBox_usr.Controls.Add($button_2)

$button_2.Add_Click({
$id = $dataGridView.SelectedCells.Value
$obj_usr = $obj | Where {$_.ID -match $id}
$obj_usr = $obj_usr.Имя
$wshell = New-Object -ComObject Wscript.Shell
if ($obj_usr -gt 1) {
$output = $wshell.Popup("Запрашивать разрешение на подключение к пользователю $obj_usr ?",0,"Выберите действие",3)
} else {
$output = $wshell.Popup("Не выбран ID в списке",0,"Внимание",64)
}
if ($output -eq "6") {mstsc /shadow:$id /v:$srv /control}
if ($output -eq "7") {mstsc /shadow:$id /v:$srv /control /noconsentprompt}
})

$button_3 = New-Object System.Windows.Forms.Button
$button_3.Text = "Отключить"
$button_3.Location = New-Object System.Drawing.Point(8,515)
$button_3.Size = New-Object System.Drawing.Size(145,40)
$GroupBox_usr.Controls.Add($button_3)

$button_3.Add_Click({
$id = $dataGridView.SelectedCells.Value
$obj_usr = $obj | Where {$_.ID -match $id}
$obj_usr = $obj_usr.Имя
$wshell = New-Object -ComObject Wscript.Shell
if ($obj_usr -gt 1) {
$Output = $wshell.Popup("Отключить пользователя $obj_usr ?",0,"Выберите действие",4)
} else {
$output = $wshell.Popup("Не выбран ID в списке",0,"Внимание",64)
}
if ($output -eq "6") {logoff $id /server:$srv /v}
Get-Query
get-obj
})
#endregion

#region message
$outputBox_message = New-Object System.Windows.Forms.TextBox
$outputBox_message.Text = "Введите сообщение для отправки пользователям"
$outputBox_message.Location = New-Object System.Drawing.Point(165,470)
$outputBox_message.Size = New-Object System.Drawing.Size(225,85)
$outputBox_message.MultiLine = $True
$GroupBox_usr.Controls.Add($outputBox_message)

$VScrollBar = New-Object System.Windows.Forms.VScrollBar
$outputBox_message.Scrollbars = "Vertical"

$button_6 = New-Object System.Windows.Forms.Button
$button_6.Text = "Отправить"
$button_6.Location = New-Object System.Drawing.Point(400,495)
$button_6.Size = New-Object System.Drawing.Size(90,60)
$GroupBox_usr.Controls.Add($button_6)

$button_6.Add_Click({
$id = $dataGridView.SelectedCells.Value
$obj_usr = $obj | Where {$_.ID -match $id}
$obj_usr = $obj_usr.Имя
$text = $outputBox_message.Text
$wshell = New-Object -ComObject Wscript.Shell
if ($obj_usr -gt 1) {
$output = $wshell.Popup("Для отправки сообщение всем пользователем, нажмите да`
Пользователю $obj_usr, нажмите нет`
На сервер: $srv",0,"Выберите действие",3)
} else {
$output = $wshell.Popup("Не выбран ID в списке",0,"Внимание",64)
}
if ($output -eq "6") {msg * /server:$srv $text}
if ($output -eq "7") {msg $id /server:$srv $text}
if ($lastexitcode -eq 0) {$Status.Text = "Сообщение отправлено"} else {$Status.Text = "Сообщение не отправлено"}
})
#endregion

#region menu-file
$Menu = New-Object System.Windows.Forms.MenuStrip
$Menu.BackColor = "white"
$main_form.MainMenuStrip = $Menu
$main_form.Controls.Add($Menu)

$menuItem_file = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_file.Text = "Файл" 
$Menu.Items.Add($menuItem_file)

$menuItem_file_cred = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_file_cred.Text = "Аутентификация"
$menuItem_file_cred.Image = $ico_cred
$menuItem_file_cred.ShortcutKeys = "Control, A"
$menuItem_file_cred.Add_Click({srv-cred})
$menuItem_file.DropDownItems.Add($menuItem_file_cred)

$menuItem_file_update = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_file_update.Text = "Обновить"
$menuItem_file_update.Image = $ico_sync
$menuItem_file_update.ShortcutKeys = "Control, R"
$menuItem_file_update.Add_Click({list-update})
$menuItem_file.DropDownItems.Add($menuItem_file_update)

$menuItem_file_pad = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_file_pad.Text = "Список серверов"
$menuItem_file_pad.Image = $ico_pad
$menuItem_file_pad.ShortcutKeys = "Control, S"
$menuItem_file_pad.Add_Click({ii $conf})
$menuItem_file.DropDownItems.Add($menuItem_file_pad)

$menuItem_file_domain = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_file_domain.Text = "Список серверов домена"
$menuItem_file_domain.ShortcutKeys = "Control, D"
$menuItem_file_domain.Add_Click({list-domain})
$menuItem_file.DropDownItems.Add($menuItem_file_domain)

$menuItem_file_domain_table = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_file_domain_table.Text = "Таблица серверов домена"
$menuItem_file_domain_table.ShortcutKeys = "Control, T"
$menuItem_file_domain_table.Add_Click({domain-comp})
$menuItem_file.DropDownItems.Add($menuItem_file_domain_table)

$menuItem_file_broker = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_file_broker.Text = "Connection Broker"
$menuItem_file_broker.ShortcutKeys = "Control, B"
$menuItem_file_broker.Add_Click({broker-user})
$menuItem_file.DropDownItems.Add($menuItem_file_broker)

$menuItem_file_exit = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_file_exit.Text = "Выход"
$menuItem_file_exit.ShortcutKeys = "Control, W"
$menuItem_file_exit.Add_Click({$main_form.Close()})
$menuItem_file.DropDownItems.Add($menuItem_file_exit)
#endregion

#region menu-admin
$menuItem_admin = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_admin.Text = "Администрирование" 
$Menu.Items.Add($menuItem_admin)

$menuItem_admin_comp = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_admin_comp.Text = "Управление"
$menuItem_admin_comp.Image = $ico_comp
$menuItem_admin_comp.Add_Click({comp-manager})
$menuItem_admin.DropDownItems.Add($menuItem_admin_comp)

$menuItem_admin_services = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_admin_services.Text = "Службы"
$menuItem_admin_services.Image = $ico_services
$menuItem_admin_services.Add_Click({services-view})
$menuItem_admin.DropDownItems.Add($menuItem_admin_services)

$menuItem_admin_process = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_admin_process.Text = "Процессы"
$menuItem_admin_process.Image = $ico_proc
$menuItem_admin_process.Add_Click({process-users})
$menuItem_admin.DropDownItems.Add($menuItem_admin_process)

$menuItem_admin_software_remove = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_admin_software_remove.Text = "Программы"
$menuItem_admin_software_remove.Image = $ico_soft
$menuItem_admin_software_remove.Add_Click({view-soft})
$menuItem_admin.DropDownItems.Add($menuItem_admin_software_remove)

$menuItem_admin_dism = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_admin_dism.Image = $ico_dism
$menuItem_admin_dism.Text = "DISM Packages"
$menuItem_admin_dism.Add_Click({upd-dism})
$menuItem_admin.DropDownItems.Add($menuItem_admin_dism)

$menuItem_admin_SMB = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_admin_SMB.Text = "SMB Open Files"
$menuItem_admin_SMB.Image = $ico_iscsi
$menuItem_admin_SMB.Add_Click({SMB-files})
$menuItem_admin.DropDownItems.Add($menuItem_admin_SMB)

$menuItem_admin_TCP = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_admin_TCP.Text = "TCP Viewer"
$menuItem_admin_TCP.Image = $ico_net
$menuItem_admin_TCP.Add_Click({tcp-viewer})
$menuItem_admin.DropDownItems.Add($menuItem_admin_TCP)

$menuItem_admin_gpu = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_admin_gpu.Text = "GP Update"
$menuItem_admin_gpu.Image = $ico_gp
$menuItem_admin_gpu.Add_Click({gp-upd})
$menuItem_admin.DropDownItems.Add($menuItem_admin_gpu)

$menuItem_admin_gpr = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_admin_gpr.Text = "GP Result"
$menuItem_admin_gpr.Image = $ico_gpr
$menuItem_admin_gpr.Add_Click({gp-res})
$menuItem_admin.DropDownItems.Add($menuItem_admin_gpr)
#endregion

#region menu-power
$menuItem_power = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_power.Text = "Питание" 
$Menu.Items.Add($menuItem_power)

$menuItem_power_reboot = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_power_reboot.Text = "Перезагрузить"
$menuItem_power_reboot.Add_Click({power-reboot})
$menuItem_power.DropDownItems.Add($menuItem_power_reboot)

$menuItem_power_off = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_power_off.Text = "Выключить"
$menuItem_power_off.Add_Click({power-off})
$menuItem_power.DropDownItems.Add($menuItem_power_off)

$menuItem_power_cancel = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_power_cancel.Text = "Отменить"
$menuItem_power_cancel.Add_Click({power-cancel})
$menuItem_power.DropDownItems.Add($menuItem_power_cancel)

$menuItem_power_monitor = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_power_monitor.Text = "Блокировка экрана"
$menuItem_power_monitor.Add_Click({power-monitor})
$menuItem_power.DropDownItems.Add($menuItem_power_monitor)

$menuItem_power_standby = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_power_standby.Text = "Спящий режим"
$menuItem_power_standby.Add_Click({power-standby})
$menuItem_power.DropDownItems.Add($menuItem_power_standby)

$menuItem_power_mac = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_power_mac.Text = "Get-MAC-Proxy"
$menuItem_power_mac.Add_Click({get-mac-proxy})
$menuItem_power.DropDownItems.Add($menuItem_power_mac)

$menuItem_power_dhcp = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_power_dhcp.Text = "Get-DHCP"
$menuItem_power_dhcp.Add_Click({get-dhcp})
$menuItem_power.DropDownItems.Add($menuItem_power_dhcp)

$menuItem_power_wol = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_power_wol.Text = "Wake-on-Lan"
$menuItem_power_wol.Add_Click({power-wol})
$menuItem_power.DropDownItems.Add($menuItem_power_wol)
#endregion

#region menu-event
$menuItem_event = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_event.Text = "Логи" 
$Menu.Items.Add($menuItem_event)

$menuItem_event_sys = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_event_sys.Text = "Система"
$menuItem_event_sys.Add_Click({event-sys})
$menuItem_event.DropDownItems.Add($menuItem_event_sys)

$menuItem_event_app = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_event_app.Text = "Приложения"
$menuItem_event_app.Add_Click({event-app})
$menuItem_event.DropDownItems.Add($menuItem_event_app)

$menuItem_event_conn = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_event_conn.Text = "RDP-подключения"
$menuItem_event_conn.Add_Click({rdp-con})
$menuItem_event.DropDownItems.Add($menuItem_event_conn)
#endregion

#region menu-time
$menuItem_Time = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_Time.Text = "Время" 
$Menu.Items.Add($menuItem_Time)

$menuItem_Time_Time = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_Time_Time.Text = "Время"
$menuItem_Time_Time.Image = $ico_time
$menuItem_Time_Time.Add_Click({net-time})
$menuItem_Time.DropDownItems.Add($menuItem_Time_Time)

$menuItem_Time_Check_Time = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_Time_Check_Time.Text = "Источник времени"
$menuItem_Time_Check_Time.Add_Click({check-time})
$menuItem_Time.DropDownItems.Add($menuItem_Time_Check_Time)

$menuItem_Time_Test_Time = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_Time_Test_Time.Text = "Проверить источник"
$menuItem_Time_Test_Time.Add_Click({time-test})
$menuItem_Time.DropDownItems.Add($menuItem_Time_Test_Time)

$menuItem_Time_Sync_Domain = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_Time_Sync_Domain.Text = "Изменить источник"
$menuItem_Time_Sync_Domain.Add_Click({sync-domain})
$menuItem_Time.DropDownItems.Add($menuItem_Time_Sync_Domain)

$menuItem_Time_Sync_Time = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_Time_Sync_Time.Text = "Сихронизировать время"
$menuItem_Time_Sync_Time.Add_Click({sync-time})
$menuItem_Time.DropDownItems.Add($menuItem_Time_Sync_Time)
#endregion

#region menu-kms
$menuItem_kms = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_kms.Text = "KMS" 
$Menu.Items.Add($menuItem_kms)

$menuItem_kms_status = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_kms_status.Text = "Лицензия"
$menuItem_kms_status.Image = $ico_kms
$menuItem_kms_status.Add_Click({kms-status})
$menuItem_kms.DropDownItems.Add($menuItem_kms_status)

$menuItem_kms_domain = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_kms_domain.Text = "Сервер домена"
$menuItem_kms_domain.Add_Click({kms-domain})
$menuItem_kms.DropDownItems.Add($menuItem_kms_domain)

$menuItem_kms_gvlk = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_kms_gvlk.Text = "GVLK активатор"
$menuItem_kms_gvlk.Add_Click({gvlk-managment})
$menuItem_kms.DropDownItems.Add($menuItem_kms_gvlk)

$menuItem_kms_srv = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_kms_srv.Text = "Указать KMS-сервер"
$menuItem_kms_srv.Add_Click({kms-server})
$menuItem_kms.DropDownItems.Add($menuItem_kms_srv)

$menuItem_kms_lic = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_kms_lic.Text = "Получить лицензию"
$menuItem_kms_lic.Add_Click({kms-lic})
$menuItem_kms.DropDownItems.Add($menuItem_kms_lic)
#endregion

#region menu-wmi
$menuItem_wmi = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_wmi.Text = "WMI" 
$Menu.Items.Add($menuItem_wmi)

$menuItem_wmi_disk = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_wmi_disk.Text = "Диски"
$menuItem_wmi_disk.Add_Click({wim-disk})
$menuItem_wmi.DropDownItems.Add($menuItem_wmi_disk)

$menuItem_wmi_memory = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_wmi_memory.Text = "Память"
$menuItem_wmi_memory.Add_Click({wim-mem})
$menuItem_wmi.DropDownItems.Add($menuItem_wmi_memory)

$menuItem_wmi_software = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_wmi_software.Text = "Программы"
$menuItem_wmi_software.Add_Click({wmi-soft})
$menuItem_wmi.DropDownItems.Add($menuItem_wmi_software)

$menuItem_wmi_install = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_wmi_install.Text = "Установка"
$menuItem_wmi_install.Add_Click({wmi-install})
$menuItem_wmi.DropDownItems.Add($menuItem_wmi_install)

$menuItem_wmi_update = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_wmi_update.Text = "Обновления"
$menuItem_wmi_update.Add_Click({wmi-upd})
$menuItem_wmi.DropDownItems.Add($menuItem_wmi_update)

$menuItem_wmi_drivers = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_wmi_drivers.Text = "Драйвера"
$menuItem_wmi_drivers.Add_Click({wmi-drivers})
$menuItem_wmi.DropDownItems.Add($menuItem_wmi_drivers)

$menuItem_wmi_report = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_wmi_report.Text = "Инвентаризация"
$menuItem_wmi_report.Add_Click({wmi-report})
$menuItem_wmi.DropDownItems.Add($menuItem_wmi_report)

$menuItem_wmi_share = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_wmi_share.Text = "Share"
$menuItem_wmi_share.Add_Click({wmi-share})
$menuItem_wmi.DropDownItems.Add($menuItem_wmi_share)

$menuItem_wmi_rdp = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_wmi_rdp.Text = "RDP"
$menuItem_wmi_rdp.Add_Click({wmi-rdp})
$menuItem_wmi.DropDownItems.Add($menuItem_wmi_rdp)

$menuItem_wmi_nla = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_wmi_nla.Text = "NLA"
$menuItem_wmi_nla.Add_Click({wmi-nla})
$menuItem_wmi.DropDownItems.Add($menuItem_wmi_nla)
#endregion

#region menu-2
$mainToolStrip = New-Object System.Windows.Forms.ToolStrip
$mainToolStrip.Location = New-Object System.Drawing.Point(0,25)
$mainToolStrip.Anchor = "Top"
$main_form.Controls.Add($mainToolStrip)

$toolStripCred = New-Object System.Windows.Forms.ToolStripButton
$toolStripCred.ToolTipText = "Аутентификация"
$toolStripCred.Image = $ico_cred
$toolStripCred.Add_Click({srv-cred})
$mainToolStrip.Items.Add($toolStripCred)

$toolStripDisk = New-Object System.Windows.Forms.ToolStripButton
$toolStripDisk.ToolTipText = "Диски"
$toolStripDisk.Image = $ico_disk
$toolStripDisk.Add_Click({wim-disk})
$mainToolStrip.Items.Add($toolStripDisk)

$toolStripShare = New-Object System.Windows.Forms.ToolStripButton
$toolStripShare.ToolTipText = "Share"
$toolStripShare.Image = $ico_netfolder
$toolStripShare.Add_Click({wmi-share})
$mainToolStrip.Items.Add($toolStripShare)

$toolStripSMB = New-Object System.Windows.Forms.ToolStripButton
$toolStripSMB.ToolTipText = "SMB Open Files"
$toolStripSMB.Image = $ico_iscsi
$toolStripSMB.Add_Click({SMB-files})
$mainToolStrip.Items.Add($toolStripSMB)

$toolStripComp = New-Object System.Windows.Forms.ToolStripButton
$toolStripComp.ToolTipText = "Управление"
$toolStripComp.Image = $ico_comp
$toolStripComp.Add_Click({comp-manager})
$mainToolStrip.Items.Add($toolStripComp)

$toolStripServices = New-Object System.Windows.Forms.ToolStripButton
$toolStripServices.ToolTipText = "Службы"
$toolStripServices.Image = $ico_services
$toolStripServices.Add_Click({services-view})
$mainToolStrip.Items.Add($toolStripServices)

$toolStripProcess = New-Object System.Windows.Forms.ToolStripButton
$toolStripProcess.ToolTipText = "Процессы"
$toolStripProcess.Image = $ico_proc
$toolStripProcess.Add_Click({process-users})
$mainToolStrip.Items.Add($toolStripProcess)

$toolStripSoft = New-Object System.Windows.Forms.ToolStripButton
$toolStripSoft.ToolTipText = "Программы (Get-Package)"
$toolStripSoft.Image = $ico_soft
$toolStripSoft.Add_Click({view-soft})
$mainToolStrip.Items.Add($toolStripSoft)

$toolStripUpdate = New-Object System.Windows.Forms.ToolStripButton
$toolStripUpdate.ToolTipText = "Обновления"
$toolStripUpdate.Image = $ico_upd
$toolStripUpdate.Add_Click({wmi-upd})
$mainToolStrip.Items.Add($toolStripUpdate)

$toolStripDISM = New-Object System.Windows.Forms.ToolStripButton
$toolStripDISM.ToolTipText = "DISM Packages"
$toolStripDISM.Image = $ico_dism
$toolStripDISM.Add_Click({upd-dism})
$mainToolStrip.Items.Add($toolStripDISM)

$toolStripDrivers = New-Object System.Windows.Forms.ToolStripButton
$toolStripDrivers.ToolTipText = "Драйвера"
$toolStripDrivers.Image = $ico_dev
$toolStripDrivers.Add_Click({wmi-drivers})
$mainToolStrip.Items.Add($toolStripDrivers)

$toolStripReport = New-Object System.Windows.Forms.ToolStripButton
$toolStripReport.ToolTipText = "Инвентаризация"
$toolStripReport.Image = $ico_system
$toolStripReport.Add_Click({wmi-report})
$mainToolStrip.Items.Add($toolStripReport)

$toolStripTCP = New-Object System.Windows.Forms.ToolStripButton
$toolStripTCP.ToolTipText = "TCP Viewer"
$toolStripTCP.Image = $ico_net
$toolStripTCP.Add_Click({TCP-Viewer})
$mainToolStrip.Items.Add($toolStripTCP)

$toolStripLog = New-Object System.Windows.Forms.ToolStripButton
$toolStripLog.ToolTipText = "Логи"
$toolStripLog.Image = $ico_event
$toolStripLog.Add_Click({event-vwr})
$mainToolStrip.Items.Add($toolStripLog)

$toolStripTime = New-Object System.Windows.Forms.ToolStripButton
$toolStripTime.ToolTipText = "Время"
$toolStripTime.Image = $ico_time
$toolStripTime.Add_Click({net-time})
$mainToolStrip.Items.Add($toolStripTime)

$toolStripWDS = New-Object System.Windows.Forms.ToolStripButton
$toolStripWDS.ToolTipText = "Лицензия"
$toolStripWDS.Image = $ico_kms
$toolStripWDS.Add_Click({kms-status})
$mainToolStrip.Items.Add($toolStripWDS)
#endregion

#region status
$StatusStrip = New-Object System.Windows.Forms.StatusStrip
$StatusStrip.BackColor = "white"
$StatusStrip.Font = "$Font,9"
$main_form.Controls.Add($statusStrip)

$Status = New-Object System.Windows.Forms.ToolStripMenuItem
$StatusStrip.Items.Add($Status)
$Status.Text = "©Telegram @kup57"

$main_form.ShowDialog()
#endregion