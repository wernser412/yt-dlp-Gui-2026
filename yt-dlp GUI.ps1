Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# =========================
# FORM
# =========================
$form = New-Object System.Windows.Forms.Form
$form.Text = "yt-dlp GUI PRO"
$form.Size = New-Object System.Drawing.Size(850, 710)
$form.StartPosition = "CenterScreen"
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

# =========================
# LOG
# =========================
$log = New-Object System.Windows.Forms.RichTextBox
$log.Size = New-Object System.Drawing.Size(810, 240)
$log.Location = New-Object System.Drawing.Point(10, 395)
$log.ReadOnly = $true
$log.BackColor = "Black"
$log.ForeColor = "White"
$log.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 9)
$form.Controls.Add($log)

function Write-Log {
    param($text, $color = "White")

    if ($log.InvokeRequired) {
        # Llamado desde el hilo del proceso yt-dlp -> hay que pasar al hilo de UI
        $log.Invoke([Action]{ Write-Log $text $color })
        return
    }

    $log.SelectionStart = $log.Text.Length
    $log.SelectionColor = $color
    $log.AppendText("$text`r`n")
    $log.ScrollToCaret()
}

# =========================
# URL + COOKIES (misma fila)
# =========================
$form.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = "URL:"
    Location = New-Object System.Drawing.Point(10, 20)
    AutoSize = $true
}))

$textUrl = New-Object System.Windows.Forms.TextBox
$textUrl.Location = New-Object System.Drawing.Point(70, 18)
$textUrl.Size = New-Object System.Drawing.Size(430, 22)
$textUrl.Text = "https://www.youtube.com/watch?v=j_gnvrfaQGc"
$form.Controls.Add($textUrl)

$btnPaste = New-Object System.Windows.Forms.Button
$btnPaste.Text = "Pegar URL"
$btnPaste.Location = New-Object System.Drawing.Point(510, 15)
$btnPaste.Size = New-Object System.Drawing.Size(70, 28)
$form.Controls.Add($btnPaste)

$btnPaste.Add_Click({
    try {
        $textUrl.Text = [System.Windows.Forms.Clipboard]::GetText()
        Write-Log "📋 URL pegada" Cyan
    } catch {
        Write-Log "❌ Clipboard vacío" Red
    }
})

# =========================
# COOKIES (los dos botones, misma fila)
# =========================
$script:cookiePath = ""
$script:cookieEnabled = $false

$btnCookies = New-Object System.Windows.Forms.Button
$btnCookies.Text = "Cookies"
$btnCookies.Location = New-Object System.Drawing.Point(590, 15)
$btnCookies.Size = New-Object System.Drawing.Size(80, 28)
$form.Controls.Add($btnCookies)

$btnForgetCookies = New-Object System.Windows.Forms.Button
$btnForgetCookies.Text = "Olvidar cookies"
$btnForgetCookies.Location = New-Object System.Drawing.Point(680, 15)
$btnForgetCookies.Size = New-Object System.Drawing.Size(110, 28)
$form.Controls.Add($btnForgetCookies)

$btnCookies.Add_Click({
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Filter = "TXT (*.txt)|*.txt|All (*.*)|*.*"
    if ($dlg.ShowDialog() -eq "OK") {
        $script:cookiePath = $dlg.FileName
        $script:cookieEnabled = $true
        Write-Log "🍪 Cookies cargadas" Yellow
        Write-Log "📁 $cookiePath" Gray
        Refresh-Cmd
    }
})

$btnForgetCookies.Add_Click({
    $script:cookiePath = ""
    $script:cookieEnabled = $false
    Write-Log "🗑 Cookies olvidadas" Yellow
    Refresh-Cmd
})

# =========================
# TOOLTIPS
# =========================
$toolTip = New-Object System.Windows.Forms.ToolTip
$toolTip.AutoPopDelay = 15000
$toolTip.InitialDelay = 300
$toolTip.ReshowDelay = 100

# =========================
# MODO DE DESCARGA
# Normal / Solo video / Solo audio / Solo subtítulos.
# Al elegir uno, se bloquean (grisan) los controles que no aplican
# para que quede claro qué se va a descargar.
# =========================
$grpMode = New-Object System.Windows.Forms.GroupBox
$grpMode.Text = "Modo de descarga"
$grpMode.Location = New-Object System.Drawing.Point(10, 48)
$grpMode.Size = New-Object System.Drawing.Size(820, 50)
$form.Controls.Add($grpMode)

$rbNormal = New-Object System.Windows.Forms.RadioButton
$rbNormal.Text = "Normal (video+audio)"
$rbNormal.Location = New-Object System.Drawing.Point(10, 20)
$rbNormal.Size = New-Object System.Drawing.Size(160, 20)
$rbNormal.Checked = $true
$grpMode.Controls.Add($rbNormal)

$rbVideoOnly = New-Object System.Windows.Forms.RadioButton
$rbVideoOnly.Text = "Solo video"
$rbVideoOnly.Location = New-Object System.Drawing.Point(180, 20)
$rbVideoOnly.Size = New-Object System.Drawing.Size(100, 20)
$grpMode.Controls.Add($rbVideoOnly)

$rbAudioOnly = New-Object System.Windows.Forms.RadioButton
$rbAudioOnly.Text = "Solo audio"
$rbAudioOnly.Location = New-Object System.Drawing.Point(290, 20)
$rbAudioOnly.Size = New-Object System.Drawing.Size(100, 20)
$grpMode.Controls.Add($rbAudioOnly)

$rbSubsOnly = New-Object System.Windows.Forms.RadioButton
$rbSubsOnly.Text = "Solo subtítulos"
$rbSubsOnly.Location = New-Object System.Drawing.Point(400, 20)
$rbSubsOnly.Size = New-Object System.Drawing.Size(120, 20)
$grpMode.Controls.Add($rbSubsOnly)

$lblAudioFmt = New-Object System.Windows.Forms.Label
$lblAudioFmt.Text = "Formato audio:"
$lblAudioFmt.Location = New-Object System.Drawing.Point(540, 22)
$lblAudioFmt.AutoSize = $true
$grpMode.Controls.Add($lblAudioFmt)

$comboAudioFmt = New-Object System.Windows.Forms.ComboBox
$comboAudioFmt.Location = New-Object System.Drawing.Point(635, 19)
$comboAudioFmt.Size = New-Object System.Drawing.Size(70, 22)
$comboAudioFmt.DropDownStyle = "DropDownList"
[void]$comboAudioFmt.Items.AddRange(@("mp3", "m4a", "wav", "opus", "best"))
$comboAudioFmt.SelectedItem = "mp3"
$comboAudioFmt.Enabled = $false
$grpMode.Controls.Add($comboAudioFmt)

$toolTip.SetToolTip($grpMode, @"
Normal:
  descarga video + audio juntos (con subs si completaste "Subs").

Solo video:
  descarga solo la pista de video, sin audio ni subtitulos
  (usa el formato "bestvideo" automaticamente).

Solo audio:
  descarga y extrae solo el audio, en el formato elegido
  a la derecha (mp3, m4a, wav, opus).

Solo subtítulos:
  no descarga el video, solo el/los subtitulos elegidos en "Subs"
  (--skip-download).

Al elegir un modo, los controles que no aplican quedan bloqueados.
"@)

$toolTip.SetToolTip($comboAudioFmt, @"
mp3 (predeterminado):
  formato de audio mas comun y compatible con casi todo.

m4a:
  audio AAC, buena calidad, es el formato nativo de YouTube.

wav:
  audio sin compresion, maxima calidad, archivos mucho mas pesados.

opus:
  codec moderno muy eficiente, buena calidad con poco peso.

best:
  no re-codifica nada, extrae el mejor audio tal cual viene
  en su formato original (mas rapido, sin perdida por conversion).
"@)

# =========================
# INPUTS
# =========================
$form.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = "Formato:"
    Location = New-Object System.Drawing.Point(10, 108)
    AutoSize = $true
}))

# ComboBox editable: podés elegir un preset o escribir cualquier selector de yt-dlp a mano
$comboFormat = New-Object System.Windows.Forms.ComboBox
$comboFormat.Location = New-Object System.Drawing.Point(80, 105)
$comboFormat.Size = New-Object System.Drawing.Size(210, 22)
$comboFormat.DropDownStyle = "DropDown"
[void]$comboFormat.Items.AddRange(@(
    "bestvideo+bestaudio",
    "best",
    "worst",
    "bestvideo*+bestaudio/best",
    "bestvideo"
))
$comboFormat.Text = "bestvideo+bestaudio"
$form.Controls.Add($comboFormat)

$toolTip.SetToolTip($comboFormat, @"
bestvideo+bestaudio (predeterminado):
  mejor video y mejor audio por separado, unidos con ffmpeg.

best:
  el mejor formato ya combinado en un solo archivo (mas rapido, no necesita ffmpeg).

worst:
  la peor calidad disponible (util para pruebas rapidas).

bestvideo*+bestaudio/best:
  igual que bestvideo+bestaudio, pero si el video no tiene pistas
  separadas, cae automaticamente a 'best' en vez de fallar.

bestvideo:
  solo la pista de video, sin audio (se usa automaticamente en modo "Solo video").

Tambien podes escribir cualquier otro selector de yt-dlp a mano,
por ejemplo: bestvideo[height<=1080]+bestaudio
"@)

$form.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = "Subs:"
    Location = New-Object System.Drawing.Point(290, 108)
    AutoSize = $true
}))

# ComboBox editable: código de idioma (o combinación) para los subtítulos
$comboSub = New-Object System.Windows.Forms.ComboBox
$comboSub.Location = New-Object System.Drawing.Point(330, 105)
$comboSub.Size = New-Object System.Drawing.Size(85, 22)
$comboSub.DropDownStyle = "DropDown"
[void]$comboSub.Items.AddRange(@("es", "en", "es,en", "all"))
$form.Controls.Add($comboSub)

$toolTip.SetToolTip($comboSub, @"
es / en:
  baja solo subtitulos en español / ingles.

es,en:
  baja varios idiomas a la vez (separados por coma).

all:
  baja todos los idiomas de subtitulos disponibles.

Dejalo vacio si no queres subtitulos. Tambien podes escribir
cualquier codigo de idioma a mano (fr, pt, de, etc.).
"@)

$chkAutoSubs = New-Object System.Windows.Forms.CheckBox
$chkAutoSubs.Text = "Subs automáticos"
$chkAutoSubs.Location = New-Object System.Drawing.Point(425, 107)
$chkAutoSubs.AutoSize = $true
$form.Controls.Add($chkAutoSubs)

$toolTip.SetToolTip($chkAutoSubs, @"
Muchos videos no tienen subtitulos "reales", solo los que
YouTube genera automaticamente (con --write-auto-subs).
Tildá esto si el video que bajás no trae subtítulos con la
opción normal.
"@)

# =========================
# CONVERTIR A (contenedor final de salida)
# =========================
$form.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = "Convertir a:"
    Location = New-Object System.Drawing.Point(10, 138)
    AutoSize = $true
}))

$comboConvert = New-Object System.Windows.Forms.ComboBox
$comboConvert.Location = New-Object System.Drawing.Point(90, 135)
$comboConvert.Size = New-Object System.Drawing.Size(100, 22)
$comboConvert.DropDownStyle = "DropDownList"
[void]$comboConvert.Items.AddRange(@("Original", "mp4", "mkv", "webm", "avi"))
$comboConvert.SelectedItem = "Original"
$form.Controls.Add($comboConvert)

$toolTip.SetToolTip($comboConvert, @"
Original (predeterminado):
  no convierte nada, deja el contenedor que trae el video (lo que
  ya veniamos haciendo hasta ahora).

mp4 / mkv / webm / avi:
  fuerza ese contenedor final. yt-dlp usa --merge-output-format,
  asi que si es compatible NO reconvierte el video/audio (rapido),
  solo lo reempaqueta en el contenedor elegido.
"@)

# =========================
# CARPETA DE DESTINO
# Automático = misma carpeta donde está el script (o la carpeta
# actual si lo corrés pegado en una consola). Manual = elegís vos
# con el botón "...".
# =========================
$script:scriptFolder = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$script:customFolder = [Environment]::GetFolderPath("Desktop")
$script:outputFolder = $script:scriptFolder

$form.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = "Destino:"
    Location = New-Object System.Drawing.Point(210, 138)
    AutoSize = $true
}))

$chkAutoFolder = New-Object System.Windows.Forms.CheckBox
$chkAutoFolder.Text = "Automático"
$chkAutoFolder.Location = New-Object System.Drawing.Point(270, 137)
$chkAutoFolder.AutoSize = $true
$chkAutoFolder.Checked = $true
$form.Controls.Add($chkAutoFolder)

$textOutput = New-Object System.Windows.Forms.TextBox
$textOutput.Location = New-Object System.Drawing.Point(365, 135)
$textOutput.Size = New-Object System.Drawing.Size(340, 22)
$textOutput.Text = $script:outputFolder
$textOutput.ReadOnly = $true
$form.Controls.Add($textOutput)

$btnOutput = New-Object System.Windows.Forms.Button
$btnOutput.Text = "..."
$btnOutput.Location = New-Object System.Drawing.Point(710, 134)
$btnOutput.Size = New-Object System.Drawing.Size(75, 24)
$btnOutput.Enabled = $false
$form.Controls.Add($btnOutput)

$toolTip.SetToolTip($chkAutoFolder, @"
Automático (predeterminado):
  guarda en la misma carpeta donde está este script (`$PSScriptRoot).

Destildalo para elegir vos la carpeta con el botón "...".
"@)

$chkAutoFolder.Add_CheckedChanged({
    if ($chkAutoFolder.Checked) {
        $script:outputFolder = $script:scriptFolder
        $textOutput.Text = $script:outputFolder
        $btnOutput.Enabled = $false
    } else {
        $script:outputFolder = $script:customFolder
        $textOutput.Text = $script:outputFolder
        $btnOutput.Enabled = $true
    }
    Refresh-Cmd
})

$btnOutput.Add_Click({
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($dlg.ShowDialog() -eq "OK") {
        $script:customFolder = $dlg.SelectedPath
        $script:outputFolder = $script:customFolder
        $textOutput.Text = $script:outputFolder
        Write-Log "📁 Carpeta de destino: $outputFolder" Cyan
        Refresh-Cmd
    }
})

# =========================
# VERSION INFO
# =========================
$lblYtDlp = New-Object System.Windows.Forms.Label
$lblYtDlp.Location = New-Object System.Drawing.Point(10, 168)
$lblYtDlp.Size = New-Object System.Drawing.Size(820, 18)
$lblYtDlp.ForeColor = "DarkGreen"
$form.Controls.Add($lblYtDlp)

$lblFfmpeg = New-Object System.Windows.Forms.Label
$lblFfmpeg.Location = New-Object System.Drawing.Point(10, 188)
$lblFfmpeg.Size = New-Object System.Drawing.Size(820, 18)
$lblFfmpeg.ForeColor = "DarkGreen"
$form.Controls.Add($lblFfmpeg)

try {
    $lblYtDlp.Text = "yt-dlp: " + (& yt-dlp --version)
} catch {
    $lblYtDlp.Text = "yt-dlp: no detectado"
}

try {
    $lblFfmpeg.Text = "ffmpeg: " + (& ffmpeg -version 2>$null | Select-Object -First 1)
} catch {
    $lblFfmpeg.Text = "ffmpeg: no detectado"
}

# =========================
# CMD CENTRAL (CLICK COPY)
# =========================
$lblCmd = New-Object System.Windows.Forms.Label
$lblCmd.Location = New-Object System.Drawing.Point(10, 208)
$lblCmd.Size = New-Object System.Drawing.Size(810, 30)
$lblCmd.TextAlign = "MiddleCenter"
$lblCmd.ForeColor = "DarkBlue"
$lblCmd.BorderStyle = "FixedSingle"
$form.Controls.Add($lblCmd)

$lblCmd.Add_Click({
    [System.Windows.Forms.Clipboard]::SetText($lblCmd.Text)
    Write-Log "📋 CMD principal copiado" Cyan
})

function Refresh-Cmd {
    $cmd = "yt-dlp"
    if ($script:cookiePath) {
        $cmd += " --cookies `"$($script:cookiePath)`""
    }

    if ($rbAudioOnly.Checked) {
        $cmd += " -x --audio-format $($comboAudioFmt.Text)"
    }
    elseif ($rbSubsOnly.Checked) {
        $cmd += " --skip-download --write-subs"
        if ($chkAutoSubs.Checked) { $cmd += " --write-auto-subs" }
        if ($comboSub.Text) { $cmd += " --sub-lang $($comboSub.Text)" }
    }
    else {
        # Normal o Solo video
        if ($comboFormat.Text) { $cmd += " -f `"$($comboFormat.Text)`"" }
        if ($comboConvert.SelectedItem -and $comboConvert.SelectedItem -ne "Original") {
            $cmd += " --merge-output-format $($comboConvert.SelectedItem)"
        }
        if ($rbNormal.Checked -and $comboSub.Text) {
            $cmd += " --write-subs --embed-subs --sub-lang $($comboSub.Text)"
            if ($chkAutoSubs.Checked) { $cmd += " --write-auto-subs" }
        }
    }

    if ($script:outputFolder) { $cmd += " -o `"$($script:outputFolder)\%(title)s.%(ext)s`"" }
    if ($textUrl.Text) { $cmd += " `"$($textUrl.Text)`"" }

    if ($script:cookieEnabled) {
        $lblCmd.Text = "🍪 cookies activadas | " + $cmd
    } else {
        $lblCmd.Text = $cmd
    }
}

# =========================
# COMANDOS COPIABLES
# =========================
$lblFormatsCmd = New-Object System.Windows.Forms.Label
$lblFormatsCmd.Location = New-Object System.Drawing.Point(10, 243)
$lblFormatsCmd.Size = New-Object System.Drawing.Size(810, 20)
$lblFormatsCmd.ForeColor = "Black"
$lblFormatsCmd.BorderStyle = "FixedSingle"
$form.Controls.Add($lblFormatsCmd)

$lblSubsCmd = New-Object System.Windows.Forms.Label
$lblSubsCmd.Location = New-Object System.Drawing.Point(10, 268)
$lblSubsCmd.Size = New-Object System.Drawing.Size(810, 20)
$lblSubsCmd.ForeColor = "Black"
$lblSubsCmd.BorderStyle = "FixedSingle"
$form.Controls.Add($lblSubsCmd)

$lblAudioCmd = New-Object System.Windows.Forms.Label
$lblAudioCmd.Location = New-Object System.Drawing.Point(10, 293)
$lblAudioCmd.Size = New-Object System.Drawing.Size(810, 20)
$lblAudioCmd.ForeColor = "Black"
$lblAudioCmd.BorderStyle = "FixedSingle"
$form.Controls.Add($lblAudioCmd)

$lblDownloadSubCmd = New-Object System.Windows.Forms.Label
$lblDownloadSubCmd.Location = New-Object System.Drawing.Point(10, 318)
$lblDownloadSubCmd.Size = New-Object System.Drawing.Size(810, 20)
$lblDownloadSubCmd.ForeColor = "Black"
$lblDownloadSubCmd.BorderStyle = "FixedSingle"
$form.Controls.Add($lblDownloadSubCmd)

function Refresh-ExtraCmds {
    if ($textUrl.Text) {
        $lblFormatsCmd.Text = "Listar Formato de video: yt-dlp -F `"$($textUrl.Text)`""
        $lblSubsCmd.Text = "Listar Formato de Subtitulos: yt-dlp --list-subs `"$($textUrl.Text)`""
        $lblAudioCmd.Text = "Descargar solo audio (mp3): yt-dlp -x --audio-format mp3 `"$($textUrl.Text)`""
        $lblDownloadSubCmd.Text = "Descargar solo subtítulo: yt-dlp --write-subs --sub-lang <Formato del subtitulo> `"$($textUrl.Text)`""
    } else {
        $lblFormatsCmd.Text = "Listar Formato de video: yt-dlp -F <url>"
        $lblSubsCmd.Text = "Listar Formato de Subtitulos: yt-dlp --list-subs <url>"
        $lblAudioCmd.Text = "Descargar solo audio (mp3): yt-dlp -x --audio-format mp3 <url>"
        $lblDownloadSubCmd.Text = "Descargar solo subtítulo: yt-dlp --write-subs --sub-lang <Formato del subtitulo> <url>"
    }
}

$lblFormatsCmd.Add_Click({
    if ($textUrl.Text) {
        [System.Windows.Forms.Clipboard]::SetText("yt-dlp -F `"$($textUrl.Text)`"")
        Write-Log "📋 comando formatos copiado" Cyan
    } else {
        Write-Log "❌ URL vacía" Red
    }
})

$lblSubsCmd.Add_Click({
    if ($textUrl.Text) {
        [System.Windows.Forms.Clipboard]::SetText("yt-dlp --list-subs `"$($textUrl.Text)`"")
        Write-Log "📋 comando subs copiado" Cyan
    } else {
        Write-Log "❌ URL vacía" Red
    }
})

$lblAudioCmd.Add_Click({
    if ($textUrl.Text) {
        [System.Windows.Forms.Clipboard]::SetText("yt-dlp -x --audio-format mp3 `"$($textUrl.Text)`"")
        Write-Log "📋 audio copiado" Cyan
    } else {
        Write-Log "❌ URL vacía" Red
    }
})

$lblDownloadSubCmd.Add_Click({
    if ($textUrl.Text) {
        [System.Windows.Forms.Clipboard]::SetText("yt-dlp --write-subs --sub-lang <Formato del subtitulo> `"$($textUrl.Text)`"")
        Write-Log "📋 subtítulo copiado" Cyan
    } else {
        Write-Log "❌ URL vacía" Red
    }
})

# Guarda el formato anterior para restaurarlo al salir de "Solo video"
$script:formatBeforeVideoOnly = $comboFormat.Text

function Update-DownloadMode {
    if ($rbAudioOnly.Checked) {
        $comboFormat.Enabled  = $false
        $comboConvert.Enabled = $false
        $comboSub.Enabled     = $false
        $chkAutoSubs.Enabled  = $false
        $comboAudioFmt.Enabled = $true
    }
    elseif ($rbSubsOnly.Checked) {
        $comboFormat.Enabled  = $false
        $comboConvert.Enabled = $false
        $comboSub.Enabled     = $true
        $chkAutoSubs.Enabled  = $true
        $comboAudioFmt.Enabled = $false
    }
    elseif ($rbVideoOnly.Checked) {
        if ($comboFormat.Text -ne "bestvideo") {
            $script:formatBeforeVideoOnly = $comboFormat.Text
            $comboFormat.Text = "bestvideo"
        }
        $comboFormat.Enabled  = $true
        $comboConvert.Enabled = $true
        $comboSub.Enabled     = $false
        $chkAutoSubs.Enabled  = $false
        $comboAudioFmt.Enabled = $false
    }
    else {
        # Normal
        if ($comboFormat.Text -eq "bestvideo") {
            $comboFormat.Text = $script:formatBeforeVideoOnly
        }
        $comboFormat.Enabled  = $true
        $comboConvert.Enabled = $true
        $comboSub.Enabled     = $true
        $chkAutoSubs.Enabled  = $true
        $comboAudioFmt.Enabled = $false
    }
    Refresh-Cmd
}

$rbNormal.Add_CheckedChanged({ if ($rbNormal.Checked) { Update-DownloadMode } })
$rbVideoOnly.Add_CheckedChanged({ if ($rbVideoOnly.Checked) { Update-DownloadMode } })
$rbAudioOnly.Add_CheckedChanged({ if ($rbAudioOnly.Checked) { Update-DownloadMode } })
$rbSubsOnly.Add_CheckedChanged({ if ($rbSubsOnly.Checked) { Update-DownloadMode } })

# =========================
# BOTONES
# =========================
$btnFormats = New-Object System.Windows.Forms.Button
$btnFormats.Text = "Formatos"
$btnFormats.Location = New-Object System.Drawing.Point(120, 348)
$btnFormats.Size = New-Object System.Drawing.Size(110, 30)
$form.Controls.Add($btnFormats)

$btnSubs = New-Object System.Windows.Forms.Button
$btnSubs.Text = "Subs"
$btnSubs.Location = New-Object System.Drawing.Point(240, 348)
$btnSubs.Size = New-Object System.Drawing.Size(110, 30)
$form.Controls.Add($btnSubs)

$btnDownload = New-Object System.Windows.Forms.Button
$btnDownload.Text = "Descargar"
$btnDownload.Location = New-Object System.Drawing.Point(360, 348)
$btnDownload.Size = New-Object System.Drawing.Size(110, 30)
$form.Controls.Add($btnDownload)

$btnClear = New-Object System.Windows.Forms.Button
$btnClear.Text = "Limpiar log"
$btnClear.Location = New-Object System.Drawing.Point(480, 348)
$btnClear.Size = New-Object System.Drawing.Size(110, 30)
$form.Controls.Add($btnClear)

$btnClear.Add_Click({ $log.Clear() })

# =========================
# ALWAYS ON TOP
# =========================
$chkAlwaysOnTop = New-Object System.Windows.Forms.CheckBox
$chkAlwaysOnTop.Text = "Siempre visible"
$chkAlwaysOnTop.Location = New-Object System.Drawing.Point(610, 355)
$chkAlwaysOnTop.AutoSize = $true
$form.Controls.Add($chkAlwaysOnTop)

$toolTip.SetToolTip($chkAlwaysOnTop, "Mantiene la ventana siempre por encima de las demás (Always on top).")

$chkAlwaysOnTop.Add_CheckedChanged({
    $form.TopMost = $chkAlwaysOnTop.Checked
})

# Lista de botones que se deshabilitan mientras corre una operación
$actionButtons = @($btnFormats, $btnSubs, $btnDownload)

function Set-ButtonsEnabled {
    param([bool]$enabled)

    if ($btnFormats.InvokeRequired) {
        # Llamado desde el hilo del proceso yt-dlp -> hay que pasar al hilo de UI
        $btnFormats.Invoke([Action]{ Set-ButtonsEnabled $enabled })
        return
    }

    foreach ($b in $actionButtons) { $b.Enabled = $enabled }
}

# =========================
# EJECUCIÓN DE yt-dlp SIN BLOQUEAR LA UI
# En vez de eventos (que dieron problemas dentro de ShowDialog), leemos
# la salida del proceso por "polling" desde el mismo Timer que ya corre
# cada 300ms. Todo se ejecuta en el hilo de la interfaz -> cero problemas
# de cross-thread, cero dependencia de la cola de eventos de PowerShell.
# =========================
$script:activeProc  = $null
$script:outReader   = $null
$script:errReader   = $null
$script:outTask     = $null
$script:errTask     = $null
$script:doneMessage = ""

function Start-YtDlpAsync {
    param(
        [string[]]$YtArgs,
        [string]$DoneMessage = "✔ listo"
    )

    if ($script:activeProc) {
        Write-Log "⚠ Ya hay una operación en curso, esperá a que termine" Yellow
        return
    }

    Set-ButtonsEnabled $false

    # En Windows PowerShell 5.1, ProcessStartInfo.ArgumentList puede venir en $null
    # (problema de compatibilidad con .NET Framework), así que armamos el string
    # de argumentos a mano, citando cada valor que tenga espacios o comillas.
    $quotedArgs = foreach ($a in $YtArgs) {
        $escaped = $a -replace '"', '\"'
        if ($escaped -match '\s') { '"' + $escaped + '"' } else { $escaped }
    }
    $argString = $quotedArgs -join ' '

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "yt-dlp"
    $psi.Arguments = $argString
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true

    try {
        $proc = [System.Diagnostics.Process]::Start($psi)
    } catch {
        Write-Log "❌ $($_.Exception.Message)" Red
        Set-ButtonsEnabled $true
        return
    }

    $script:activeProc  = $proc
    $script:outReader   = $proc.StandardOutput
    $script:errReader   = $proc.StandardError
    $script:outTask     = $script:outReader.ReadLineAsync()
    $script:errTask     = $script:errReader.ReadLineAsync()
    $script:doneMessage = $DoneMessage
}

# Se llama en cada tick del Timer. No bloquea: solo mira si las tareas de
# lectura asíncrona ya tienen una línea lista y, si es así, la muestra.
function Poll-YtDlpOutput {
    if (-not $script:activeProc) { return }

    if ($script:outTask -and $script:outTask.IsCompleted) {
        $line = $script:outTask.Result
        if ($null -ne $line) {
            Write-Log $line White
            $script:outTask = $script:outReader.ReadLineAsync()
        } else {
            $script:outTask = $null
        }
    }

    if ($script:errTask -and $script:errTask.IsCompleted) {
        $line = $script:errTask.Result
        if ($null -ne $line) {
            Write-Log $line Yellow
            $script:errTask = $script:errReader.ReadLineAsync()
        } else {
            $script:errTask = $null
        }
    }

    if (-not $script:outTask -and -not $script:errTask -and $script:activeProc.HasExited) {
        Write-Log $script:doneMessage Green
        Set-ButtonsEnabled $true
        $script:activeProc.Dispose()
        $script:activeProc = $null
    }
}

# =========================
# ACTIONS
# =========================
$btnFormats.Add_Click({
    if (-not $textUrl.Text) { Write-Log "❌ URL vacía" Red; return }

    Write-Log "🎬 Listando formatos..." Cyan
    $ytArgs = @()
    if ($script:cookiePath) { $ytArgs += "--cookies"; $ytArgs += $script:cookiePath }
    $ytArgs += "-F"
    $ytArgs += $textUrl.Text

    Start-YtDlpAsync -YtArgs $ytArgs -DoneMessage "✔ listo"
})

$btnSubs.Add_Click({
    if (-not $textUrl.Text) { Write-Log "❌ URL vacía" Red; return }

    Write-Log "📝 Listando subs..." Cyan
    $ytArgs = @()
    if ($script:cookiePath) { $ytArgs += "--cookies"; $ytArgs += $script:cookiePath }
    $ytArgs += "--list-subs"
    $ytArgs += $textUrl.Text

    Start-YtDlpAsync -YtArgs $ytArgs -DoneMessage "✔ listo"
})

$btnDownload.Add_Click({
    if (-not $textUrl.Text) { Write-Log "❌ URL vacía" Red; return }

    $ytArgs = @()
    if ($script:cookiePath) { $ytArgs += "--cookies"; $ytArgs += $script:cookiePath }

    if ($rbAudioOnly.Checked) {
        Write-Log "🎧 descargando solo audio..." Cyan
        $ytArgs += "-x"; $ytArgs += "--audio-format"; $ytArgs += $comboAudioFmt.Text
    }
    elseif ($rbSubsOnly.Checked) {
        Write-Log "📝 descargando solo subtítulos..." Cyan
        $ytArgs += "--skip-download"; $ytArgs += "--write-subs"
        if ($chkAutoSubs.Checked) { $ytArgs += "--write-auto-subs" }
        if ($comboSub.Text) { $ytArgs += "--sub-lang"; $ytArgs += $comboSub.Text }
    }
    else {
        if ($rbVideoOnly.Checked) {
            Write-Log "🎬 descargando solo video..." Cyan
        } else {
            Write-Log "⬇ descargando..." Cyan
        }
        if ($comboFormat.Text) { $ytArgs += "-f"; $ytArgs += $comboFormat.Text }
        if ($comboConvert.SelectedItem -and $comboConvert.SelectedItem -ne "Original") {
            $ytArgs += "--merge-output-format"; $ytArgs += $comboConvert.SelectedItem
        }
        if ($rbNormal.Checked -and $comboSub.Text) {
            $ytArgs += "--write-subs"; $ytArgs += "--embed-subs"; $ytArgs += "--sub-lang"; $ytArgs += $comboSub.Text
            if ($chkAutoSubs.Checked) { $ytArgs += "--write-auto-subs" }
        }
    }

    if ($script:outputFolder) {
        $ytArgs += "-o"; $ytArgs += "$($script:outputFolder)\%(title)s.%(ext)s"
    }
    $ytArgs += $textUrl.Text

    Start-YtDlpAsync -YtArgs $ytArgs -DoneMessage "✔ descarga terminada"
})

# =========================
# TIMER
# =========================
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 300
$timer.Add_Tick({
    Refresh-Cmd
    Refresh-ExtraCmds
    Poll-YtDlpOutput
})
$timer.Start()

Update-DownloadMode
Refresh-Cmd
Refresh-ExtraCmds

[void]$form.ShowDialog()
