Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# =========================
# FORM
# =========================
$form = New-Object System.Windows.Forms.Form
$form.Text = "yt-dlp GUI PRO"
$form.Size = New-Object System.Drawing.Size(850, 650)
$form.StartPosition = "CenterScreen"
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

# =========================
# LOG
# =========================
$log = New-Object System.Windows.Forms.RichTextBox
$log.Size = New-Object System.Drawing.Size(810, 240)
$log.Location = New-Object System.Drawing.Point(10, 300)
$log.ReadOnly = $true
$log.BackColor = "Black"
$log.ForeColor = "White"
$log.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 9)
$form.Controls.Add($log)

function Write-Log {
    param($text, $color="White")

    $log.SelectionStart = $log.Text.Length
    $log.SelectionColor = $color
    $log.AppendText("$text`r`n")
    $log.ScrollToCaret()
}

# =========================
# URL
# =========================
$form.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text="URL:"
    Location=New-Object System.Drawing.Point(10, 20)
    AutoSize=$true
}))

$textUrl = New-Object System.Windows.Forms.TextBox
$textUrl.Location = New-Object System.Drawing.Point(70, 18)
$textUrl.Size = New-Object System.Drawing.Size(470, 22)
$form.Controls.Add($textUrl)

# =========================
# PASTE URL
# =========================
$btnPaste = New-Object System.Windows.Forms.Button
$btnPaste.Text = "Pegar URL"
$btnPaste.Location = New-Object System.Drawing.Point(550, 15)
$btnPaste.Size = New-Object System.Drawing.Size(90, 28)
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
# COOKIES
# =========================
$cookiePath = ""

$btnCookies = New-Object System.Windows.Forms.Button
$btnCookies.Text = "Cookies"
$btnCookies.Location = New-Object System.Drawing.Point(650, 15)
$btnCookies.Size = New-Object System.Drawing.Size(90, 28)
$form.Controls.Add($btnCookies)

$btnCookies.Add_Click({
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Filter = "TXT (*.txt)|*.txt|All (*.*)|*.*"
    if ($dlg.ShowDialog() -eq "OK") {
        $script:cookiePath = $dlg.FileName
        Write-Log "🍪 Cookies cargadas" Yellow
        Write-Log "📁 $cookiePath" Gray
        Refresh-Cmd
    }
})

# =========================
# INPUTS
# =========================
$form.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text="Formato:"
    Location=New-Object System.Drawing.Point(10, 55)
    AutoSize=$true
}))

$textFormat = New-Object System.Windows.Forms.TextBox
$textFormat.Location = New-Object System.Drawing.Point(80, 52)
$textFormat.Size = New-Object System.Drawing.Size(200, 22)
$textFormat.Text = "bestvideo+bestaudio"
$form.Controls.Add($textFormat)

$form.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text="Subs:"
    Location=New-Object System.Drawing.Point(300, 55)
    AutoSize=$true
}))

$textSub = New-Object System.Windows.Forms.TextBox
$textSub.Location = New-Object System.Drawing.Point(350, 52)
$textSub.Size = New-Object System.Drawing.Size(80, 22)
$form.Controls.Add($textSub)

# =========================
# VERSION INFO (2 LINEAS ORDENADAS)
# =========================

$lblYtDlp = New-Object System.Windows.Forms.Label
$lblYtDlp.Location = New-Object System.Drawing.Point(10, 85)
$lblYtDlp.Size = New-Object System.Drawing.Size(820, 18)
$lblYtDlp.ForeColor = "DarkGreen"
$form.Controls.Add($lblYtDlp)

$lblFfmpeg = New-Object System.Windows.Forms.Label
$lblFfmpeg.Location = New-Object System.Drawing.Point(10, 105)
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
$lblCmd.Location = New-Object System.Drawing.Point(10, 125)
$lblCmd.Size = New-Object System.Drawing.Size(810, 30)
$lblCmd.TextAlign = "MiddleCenter"   # 🔥 CENTRADO
$lblCmd.ForeColor = "DarkBlue"
$lblCmd.BorderStyle = "FixedSingle"
$form.Controls.Add($lblCmd)

$lblCmd.Add_Click({
    [System.Windows.Forms.Clipboard]::SetText($lblCmd.Text)
    Write-Log "📋 CMD principal copiado" Cyan
})

function Refresh-Cmd {
    $cmd = "yt-dlp"
    if ($cookiePath) {
        $cmd += " --cookies `"$cookiePath`""
    }
    if ($textFormat.Text) { $cmd += " -f $($textFormat.Text)" }
    if ($textSub.Text) { $cmd += " --write-subs --embed-subs --sub-lang $($textSub.Text)" }
    if ($textUrl.Text) { $cmd += " `"$($textUrl.Text)`""
    }
    if ($cookieEnabled) {
        $lblCmd.Text = "🍪 cookies activadas | " + $cmd
    } else {
        $lblCmd.Text = $cmd
    }
}

# =========================
# COMANDOS COPIABLES
# =========================
$lblFormatsCmd = New-Object System.Windows.Forms.Label
$lblFormatsCmd.Location = New-Object System.Drawing.Point(10, 160)
$lblFormatsCmd.Size = New-Object System.Drawing.Size(810, 20)
$lblFormatsCmd.ForeColor = "Black"
$lblFormatsCmd.BorderStyle = "FixedSingle"
$form.Controls.Add($lblFormatsCmd)

$lblSubsCmd = New-Object System.Windows.Forms.Label
$lblSubsCmd.Location = New-Object System.Drawing.Point(10, 185)
$lblSubsCmd.Size = New-Object System.Drawing.Size(810, 20)
$lblSubsCmd.ForeColor = "Black"
$lblSubsCmd.BorderStyle = "FixedSingle"
$form.Controls.Add($lblSubsCmd)

$lblAudioCmd = New-Object System.Windows.Forms.Label
$lblAudioCmd.Location = New-Object System.Drawing.Point(10, 210)
$lblAudioCmd.Size = New-Object System.Drawing.Size(810, 20)
$lblAudioCmd.ForeColor = "Black"
$lblAudioCmd.BorderStyle = "FixedSingle"
$form.Controls.Add($lblAudioCmd)

$lblDownloadSubCmd = New-Object System.Windows.Forms.Label
$lblDownloadSubCmd.Location = New-Object System.Drawing.Point(10, 235)
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
        $cmd = "yt-dlp -F `"$($textUrl.Text)`""
        [System.Windows.Forms.Clipboard]::SetText($cmd)
        Write-Log "📋 comando formatos copiado" Cyan
    } else {
        Write-Log "❌ URL vacía" Red
    }
})

$lblSubsCmd.Add_Click({
    if ($textUrl.Text) {
        $cmd = "yt-dlp --list-subs `"$($textUrl.Text)`""
        [System.Windows.Forms.Clipboard]::SetText($cmd)
        Write-Log "📋 comando subs copiado" Cyan
    } else {
        Write-Log "❌ URL vacía" Red
    }
})

$lblAudioCmd.Add_Click({
    if ($textUrl.Text) {
        $cmd = "yt-dlp -x --audio-format mp3 `"$($textUrl.Text)`""
        [System.Windows.Forms.Clipboard]::SetText($cmd)
        Write-Log "📋 audio copiado" Cyan
    } else {
        Write-Log "❌ URL vacía" Red
    }
})

$lblDownloadSubCmd.Add_Click({
    if ($textUrl.Text) {
        $cmd = "yt-dlp --write-subs --sub-lang <Formato del subtitulo> `"$($textUrl.Text)`""
        [System.Windows.Forms.Clipboard]::SetText($cmd)
        Write-Log "📋 subtítulo copiado" Cyan
    } else {
        Write-Log "❌ URL vacía" Red
    }
})

# =========================
# BOTONES
# =========================
$btnFormats = New-Object System.Windows.Forms.Button
$btnFormats.Text = "Formatos"
$btnFormats.Location = New-Object System.Drawing.Point(120, 257)
$btnFormats.Size = New-Object System.Drawing.Size(120, 30)
$form.Controls.Add($btnFormats)

$btnSubs = New-Object System.Windows.Forms.Button
$btnSubs.Text = "Subs"
$btnSubs.Location = New-Object System.Drawing.Point(250, 257)
$btnSubs.Size = New-Object System.Drawing.Size(120, 30)
$form.Controls.Add($btnSubs)

$btnDownload = New-Object System.Windows.Forms.Button
$btnDownload.Text = "Descargar"
$btnDownload.Location = New-Object System.Drawing.Point(380, 257)
$btnDownload.Size = New-Object System.Drawing.Size(120, 30)
$form.Controls.Add($btnDownload)

$btnClear = New-Object System.Windows.Forms.Button
$btnClear.Text = "Limpiar log"
$btnClear.Location = New-Object System.Drawing.Point(510, 257)
$btnClear.Size = New-Object System.Drawing.Size(120, 30)
$form.Controls.Add($btnClear)

$btnClear.Add_Click({ $log.Clear() })

# =========================
# ACTIONS
# =========================
$btnFormats.Add_Click({
    if (-not $textUrl.Text) { Write-Log "❌ URL vacía" Red; return }

    Write-Log "🎬 Listando formatos..." Cyan
    $args = @()
    if ($cookiePath) { $args += "--cookies"; $args += $cookiePath }
    $args += "-F"
    $args += $textUrl.Text

    $out = & yt-dlp.exe @args 2>&1
    $out | ForEach-Object { Write-Log $_ White }

    Write-Log "✔ listo" Green
})

$btnSubs.Add_Click({
    if (-not $textUrl.Text) { Write-Log "❌ URL vacía" Red; return }

    Write-Log "📝 Listando subs..." Cyan
    $args = @()
    if ($cookiePath) { $args += "--cookies"; $args += $cookiePath }
    $args += "--list-subs"
    $args += $textUrl.Text

    $out = & yt-dlp.exe @args 2>&1
    $out | ForEach-Object { Write-Log $_ Gray }

    Write-Log "✔ listo" Green
})

$btnDownload.Add_Click({
    try {
        Write-Log "⬇ descargando..." Cyan

        $args = @()
        if ($cookiePath) { $args += "--cookies"; $args += $cookiePath }
        if ($textFormat.Text) { $args += "-f"; $args += $textFormat.Text }
        if ($textSub.Text) { $args += "--write-subs"; $args += "--embed-subs"; $args += "--sub-lang"; $args += $textSub.Text }

        $args += $textUrl.Text

        Start-Process yt-dlp -ArgumentList $args -NoNewWindow -Wait

        Write-Log "✔ terminado" Green
    } catch {
        Write-Log $_.Exception.Message Red
    }
})

# =========================
# TIMER
# =========================
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 300
$timer.Add_Tick({
    Refresh-Cmd
    Refresh-ExtraCmds
})
$timer.Start()

Refresh-Cmd
Refresh-ExtraCmds

[void]$form.ShowDialog()
