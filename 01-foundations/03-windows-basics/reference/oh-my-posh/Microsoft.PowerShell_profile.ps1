# ===================================================================
#  🔒 SECURE DEVOPS POWERSHELL PROFILE — Windows 11
#  Version: 1.0.0-OPTIMIZED
#  ✅ Oh-My-Posh • Terminal-Icons • DevOps Aliases • Native PS Cmdlets
# ===================================================================

# --- 00. Existing Config ---
Import-Module -Name Terminal-Icons
oh-my-posh init pwsh --config "$env:USERPROFILE\.themes\kali.omp.json" | Invoke-Expression

# --- 01. Environment Variables ---
$env:JAVA_HOME = "C:\Program Files\Microsoft\jdk-17.0.19.10-hotspot"
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$env:PATH += ";$env:ANDROID_HOME\cmdline-tools\latest\bin;$env:ANDROID_HOME\platform-tools;$env:JAVA_HOME\bin"

# --- 02. Core Helpers ---
function lazyg { git add .; git commit -m $args; git push }
function which($name) { Get-Command $name | Select-Object -ExpandProperty Definition }
function whichdir($name) { Split-Path -Parent (Get-Command $name | Select-Object -ExpandProperty Definition) }
function reload { & $PROFILE; Write-Host "✅ Profile reloaded" -ForegroundColor Green }
function path { $env:PATH -split ';' }
function activate {
    param([string]$Path = ".venv")
    $venvDir = Resolve-Path $Path -ErrorAction SilentlyContinue
    if (-not $venvDir) { Write-Warning "⚠ Not found: $Path"; return }
    $script = Join-Path $venvDir "Scripts\Activate.ps1"
    if (Test-Path $script) {
        . $script
        oh-my-posh init pwsh --config "$env:USERPROFILE\.themes\kali.omp.json" | Invoke-Expression
        Write-Host "✅ Activated: $(Split-Path $venvDir -Leaf)" -ForegroundColor Green
    } else {
        Write-Warning "⚠ Activate.ps1 not found"
    }
}
# --- 03. Navigation & System ---
function l { Get-ChildItem -Force | Format-Table Mode, LastWriteTime, Length, Name -AutoSize }
function ll { Get-ChildItem -Force | Format-List Mode, LastWriteTime, Length, Name }
function la { Get-ChildItem -Force -Name }
function lt { Get-ChildItem | Sort-Object LastWriteTime -Descending | Format-Table LastWriteTime, Length, Name -AutoSize }
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .3 { Set-Location ../../.. }
function .4 { Set-Location ../../../.. }
function h { Get-History | Select-String -Pattern $args -CaseSensitive:$false }
function ports { netstat -ano | Select-String "LISTENING" }
function myip { Invoke-RestMethod -Uri "https://ifconfig.me" -ErrorAction SilentlyContinue }
function now { Get-Date -Format "yyyy-MM-dd HH:mm:ss" }
function timestamp { Get-Date -Format "yyyyMMdd_HHmmss" }
function df { Get-Volume | Format-Table DriveLetter, FileSystemLabel, @{L="Size(GB)";E={[math]::Round($_.Size/1GB,2)}}, @{L="Free(GB)";E={[math]::Round($_.SizeRemaining/1GB,2)}} -AutoSize }
function free { Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 10 Name, @{L="Mem(MB)";E={[math]::Round($_.WorkingSet64/1MB,2)}} | Format-Table }
function top { Get-Process | Sort-Object CPU -Descending | Select-Object -First 15 Id, CPU, Name, Handles | Format-Table }
function mkcd { param($path); New-Item -ItemType Directory -Path $path -Force | Out-Null; Set-Location $path }
function sysinfo { 
    $os = Get-CimInstance Win32_OperatingSystem
    Write-Host "🖥  $($os.Caption) $($os.Version) | 👤 $env:USERNAME@$env:COMPUTERNAME" 
}
function disk { df }
function mem { free }
function cpu { Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors | Format-Table }

# --- 04. Git ---
function gs { git status -sb $args }
function ga { git add $args }
function gaa { git add -A $args }
function gap { git add -p $args }
function gc { git commit -m $args }
function gca { git commit -am $args }
function gp { git push $args }
function gpf { git push --force-with-lease $args }
function gl { git pull --rebase $args }
function gb { git branch -vv $args }
function gba { git branch -a $args }
function gco { git checkout $args }
function gcb { git checkout -b $args }
function gcm { 
    git checkout main $args 2>$null
    if ($LASTEXITCODE -ne 0) { git checkout master $args }
}
function gd { git diff --staged $args }
function gds { git diff --staged --stat $args }
function glog { git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit $args }
function gloga { git log --all --graph --oneline --decorate $args }
function gundo { git reset --soft HEAD~1 $args }
function gclean { 
    git branch --merged $args 2>$null | Where-Object { $_ -notmatch '^\*|main|master|develop' } | ForEach-Object { git branch -d $_.Trim() } 
}
function gprune { git remote prune origin $args }
function gamend { git commit --amend --no-edit $args }
function gwho { git log -1 --pretty=format:"%an <%ae>" $args }
function gtime { git log -1 --pretty=format:"%ai" $args }
function gclone { param($url, $dir=$(Split-Path $url -LeafBase)); git clone --quiet $url $dir; Set-Location $dir; Write-Host "✅ Cloned: $dir" -ForegroundColor Green }
function gswitch { 
    $branches = git branch -a 2>$null | Where-Object { $_ -notmatch 'HEAD' -and $_ -notmatch '^remotes' } | ForEach-Object { $_.Trim().TrimStart('* ') } | Sort-Object -Unique
    if (-not $branches) { Write-Warning "⚠ No branches found"; return }
    $sel = $branches | Out-GridView -PassThru -Title "Select Branch"
    if ($sel) { git checkout $sel }
}
function gclean-merged { 
    $protected = 'main','master','develop'
    git branch --merged $args 2>$null | Where-Object { $_ -notmatch '^\*' } | ForEach-Object { 
        $b = $_.Trim()
        if ($protected -notcontains $b) { git branch -d $b 2>$null; Write-Host "✅ Deleted: $b" -ForegroundColor Green }
    }
}

# --- 05. Docker ---
function dps { docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" $args 2>$null }
function dpa { docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}" $args 2>$null }
function dstats { docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" $args 2>$null }
function dstop { docker stop (docker ps -q $args 2>$null) $args 2>$null }
function dkill { docker rm -f (docker ps -aq $args 2>$null) $args 2>$null }
function dex { docker exec -it $args }
function dimg { docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}" $args 2>$null }
function dprune { docker system prune -af --volumes $args }
function dclean { docker rmi (docker images -q -f dangling=true $args 2>$null) $args 2>$null }
function dlogs { docker logs -f --tail=100 $args }
function dbuild { docker build --progress=plain -t $args }
function dexec { docker exec -it $args }
function dinspect { docker inspect --format="{{json .Config}}" $args 2>$null | ConvertFrom-Json | ConvertTo-Json -Depth 5 }
function dco { if (docker compose version 2>$null) { docker compose $args } elseif (Get-Command docker-compose -ErrorAction SilentlyContinue) { docker-compose $args } else { Write-Warning "⚠ Docker Compose not installed" } }
function dcup { dco up -d $args }
function dcdn { dco down $args }
function dcl { dco logs -f $args }
function dcps { dco ps $args }

# --- 06. Kubernetes ---
function kgp { kubectl get pods $args 2>$null }
function kgpw { kubectl get pods -o wide $args 2>$null }
function kgs { kubectl get svc $args 2>$null }
function kgd { kubectl get deployments $args 2>$null }
function kga { kubectl get all $args 2>$null }
function kd { kubectl describe $args 2>$null }
function kl { kubectl logs -f --tail=100 $args 2>$null }
function kexec { kubectl exec -it $args 2>$null }
function kdelp { kubectl delete pod $args 2>$null }
function kw { kubectl get pods $args --watch 2>$null }
function kaf { kubectl apply -f $args 2>$null }
function kdf { kubectl delete -f $args 2>$null }
function ksh { param($pod, $ns="default"); kubectl exec -it $pod -n $ns -- pwsh 2>$null; if ($LASTEXITCODE -ne 0) { kubectl exec -it $pod -n $ns -- cmd 2>$null; if ($LASTEXITCODE -ne 0) { Write-Error "❌ Could not exec into $pod" } } }
function klogs { param($pod, $ns="default"); kubectl logs -f --tail=200 $pod -n $ns $args 2>$null }
function kportf { param($pod, $port, $ns="default"); kubectl port-forward $pod $port -n $ns $args 2>$null }
function kctx { kubectl config current-context $args 2>$null }
function kns { kubectl config view --minify --output 'jsonpath={..namespace}' $args 2>$null }

# --- 07. Terraform ---
function tf { terraform $args 2>$null }
function tfi { terraform init $args }
function tfp { terraform plan $args }
function tfa { terraform apply $args }
function tfaa { terraform apply -auto-approve $args }
function tfd { terraform destroy $args }
function tfv { terraform validate $args }
function tfo { terraform output $args }
function tfw { terraform workspace $args }
function tff { terraform fmt -recursive $args }
function tfs { terraform state list $args }
function tfinit { terraform init -upgrade -reconfigure $args }
function tfplan { terraform plan -out=tfplan $args; Write-Host "✅ Plan saved to tfplan. Apply with: terraform apply tfplan" -ForegroundColor Green }
function tfapply { if (Test-Path tfplan) { terraform apply tfplan $args } else { Write-Warning "⚠ No tfplan file. Run 'tfplan' first." } }

# --- 08. Cloud (AWS/GCP/Azure) ---
function aws-who { aws sts get-caller-identity $args 2>$null }
function aws-ls { aws s3 ls $args 2>$null }
function aws-ec2 { aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].{ID:InstanceId,Name:Tags[?Key==\`Name\`].Value|[0],Type:InstanceType,IP:PrivateIpAddress}" --output table $args 2>$null }
function asp { param($profile); $env:AWS_PROFILE=$profile; Write-Host "✅ AWS Profile: $env:AWS_PROFILE" -ForegroundColor Green }
function ec2-connect { param($id); Write-Host "🔐 Starting SSM Session for $id..."; aws ssm start-session --target $id $args 2>$null }
function g-who { gcloud auth list $args 2>$null }
function g-list { gcloud projects list $args 2>$null }
function g-compute { gcloud compute instances list $args 2>$null }
function g-proj { param($id); gcloud config set project $id $args 2>$null; Write-Host "✅ GCP Project: $id" -ForegroundColor Green }
function g-zone { param($zone); gcloud config set compute/zone $zone $args 2>$null; Write-Host "✅ GCP Zone: $zone" -ForegroundColor Green }
function az-who { az account show $args 2>$null }
function az-login { az login --use-device-code $args 2>$null }
function az-list { az account list --output table $args 2>$null }
function az-vm { az vm list --output table $args 2>$null }
function az-sub { param($sub); az account set --subscription $sub $args 2>$null; Write-Host "✅ Azure Subscription: $sub" -ForegroundColor Green }

# --- 09. Utilities & Network ---
function extract {
    param($file)
    if (-not (Test-Path $file)) { Write-Error "❌ '$file' is not a valid file"; return }
    switch -Regex ($file) {
        '\.zip$' { Expand-Archive -Path $file -DestinationPath . -Force; Write-Host "✅ Extracted: $file" -ForegroundColor Green }
        '\.tar\.gz$|\.tgz$' { tar xzf $file; Write-Host "✅ Extracted: $file" -ForegroundColor Green }
        '\.tar$' { tar xf $file; Write-Host "✅ Extracted: $file" -ForegroundColor Green }
        default { Write-Warning "⚠ Use Expand-Archive or tar.exe for unsupported formats" }
    }
}
function findf { param($pattern); Get-ChildItem -Recurse -Name | Where-Object { $_ -like "*$pattern*" } | Select-Object -First 20 }
function grepf { param($pattern); Select-String -Pattern $pattern -Path .\* -Recurse -CaseSensitive:$false | Select-Object -First 50 }
function serve { param($port=8080); Write-Host "🌐 Serving $(Get-Location) on http://localhost:$port"; python -m http.server $port }
function jp { param($file); if ($file) { Get-Content $file | ConvertFrom-Json | ConvertTo-Json -Depth 10 } else { $input | ConvertFrom-Json | ConvertTo-Json -Depth 10 } }
function y2j { Write-Warning "⚠ Install module: Install-Module powershell-yaml -Scope CurrentUser"; $input | ConvertFrom-Yaml | ConvertTo-Json -Depth 10 }
function ping8 { Test-Connection 8.8.8.8 -Count 8 }
function ping1 { Test-Connection 1.1.1.1 -Count 1 }
function dns-test { Resolve-DnsName google.com -Type A | Select-Object Name, IPAddress }
function http-test { Invoke-WebRequest -Uri "https://httpbin.org/ip" -Method Head -UseBasicParsing 2>$null }
function ssh-keys { Get-ChildItem "$env:USERPROFILE\.ssh\*.pub" -ErrorAction SilentlyContinue | Format-Table Length, LastWriteTime, Name }
function env-check { Get-ChildItem env: | Where-Object { $_.Name -match 'AWS|AZURE|GCLOUD|KUBE|TF_|DOCKER' } | Sort-Object Name }
function open-ports { netstat -ano | Select-String "LISTENING" }
function web-check { try { $r = Invoke-WebRequest -Uri "https://httpbin.org/status/200" -UseBasicParsing -TimeoutSec 5; if ($r.StatusCode -eq 200) { Write-Host "✅ Web connectivity OK (HTTP $($r.StatusCode))" -ForegroundColor Green } } catch { Write-Host "❌ Web check failed" -ForegroundColor Red } }
function if-info { Get-NetIPConfiguration | Select-Object InterfaceAlias, IPv4Address, IPv4DefaultGateway | Format-Table }
function route-table { Get-NetRoute | Where-Object DestinationPrefix -ne '0.0.0.0/0' | Select-Object DestinationPrefix, NextHop, InterfaceAlias, RouteMetric | Sort-Object DestinationPrefix | Format-Table }
function default-gw { Get-NetRoute | Where-Object DestinationPrefix -eq '0.0.0.0/0' | Select-Object -First 1 NextHop, InterfaceAlias }
function wifi-info { (Get-NetAdapter -Physical | Where-Object Status -eq 'Up').Name; netsh wlan show interfaces | Select-String "SSID|Signal|Channel" }
function tcp-test {
    param([string]$Target, [int]$Port)
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $tcp.Connect($Target, $Port)
        Write-Host "[OK] " -NoNewline -ForegroundColor Green
        Write-Host "$Target`:$Port is OPEN"
        $tcp.Close()
    }
    catch {
        Write-Host "[FAIL] " -NoNewline -ForegroundColor Red
        Write-Host "$Target`:$Port is CLOSED/FILTERED"
    }
}
function net-diag { 
    Write-Host "🌐 Network Diagnostics Summary"
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-Host "📍 Public IP: $(Invoke-RestMethod -Uri https://ifconfig.me -ErrorAction SilentlyContinue)"
    Write-Host "🏠 Local IP: $((if-info | Select-Object -ExpandProperty IPv4Address) -join ', ')"
    Write-Host "🚪 Default GW: $(default-gw | Select-Object -ExpandProperty NextHop)"
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# --- 10. Profile End ---
Write-Host "✅ DevOps PowerShell Profile Loaded" -ForegroundColor Green