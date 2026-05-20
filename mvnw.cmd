<# : batch portion
@REM ----------------------------------------------------------------------------
@REM Licensed to the Apache Software Foundation (ASF) under one
@REM or more contributor license agreements.  See the NOTICE file
@REM distributed with this work for additional information
@REM regarding copyright ownership.  The ASF licenses this file
@REM to you under the Apache License, Version 2.0 (the
@REM "License"); you may not use this file except in compliance
@REM with the License.  You may obtain a copy of the License at
@REM
@REM    http://www.apache.org/licenses/LICENSE-2.0
@REM
@REM Unless required by applicable law or agreed to in writing,
@REM software distributed under the License is distributed on an
@REM "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
@REM KIND, either express or implied.  See the License for the
@REM specific language governing permissions and limitations
@REM under the License.
@REM ----------------------------------------------------------------------------

@REM ----------------------------------------------------------------------------
@REM Apache Maven Wrapper startup batch script, version 3.3.4
@REM
@REM Optional ENV vars
@REM   MVNW_REPOURL - repo url base for downloading maven distribution
@REM   MVNW_USERNAME/MVNW_PASSWORD - user and password for downloading maven
@REM   MVNW_VERBOSE - true: enable verbose log; others: silence the output
@REM ----------------------------------------------------------------------------

@IF "%__MVNW_ARG0_NAME__%"=="" (SET __MVNW_ARG0_NAME__=%~nx0)
@SET __MVNW_CMD__=
@SET __MVNW_ERROR__=
@SET __MVNW_PSMODULEP_SAVE=%PSModulePath%
@SET PSModulePath=
@FOR /F "usebackq tokens=1* delims==" %%A IN (`powershell -noprofile "& {$scriptDir='%~dp0'; $script='%__MVNW_ARG0_NAME__%'; icm -ScriptBlock ([Scriptblock]::Create((Get-Content -Raw '%~f0'))) -NoNewScope}"`) DO @(
  IF "%%A"=="MVN_CMD" (set __MVNW_CMD__=%%B) ELSE IF "%%B"=="" (echo %%A) ELSE (echo %%A=%%B)
)
@SET PSModulePath=%__MVNW_PSMODULEP_SAVE%
@SET __MVNW_PSMODULEP_SAVE=
@SET __MVNW_ARG0_NAME__=
@SET MVNW_USERNAME=
@SET MVNW_PASSWORD=
@IF NOT "%__MVNW_CMD__%"=="" ("%__MVNW_CMD__%" %*)
@echo Cannot start maven from wrapper >&2 && exit /b 1
@GOTO :EOF
: end batch / begin powershell #>

$ErrorActionPreference = "Stop"
if ($env:MVNW_VERBOSE -eq "true") {
  $ErrorActionPreference = "Continue"
}

# calculate distributionUrl, requires .mvn/wrapper/maven-wrapper.properties
$MavenWrapperPropertyFile = "$scriptDir/.mvn/wrapper/maven-wrapper.properties"
if (Test-Path -Path $MavenWrapperPropertyFile) {
  $content = Get-Content $MavenWrapperPropertyFile | Where-Object { -not $_.StartsWith('#') }
  $content | ForEach-Object {
    if ($_ -match '^\s*([^=]+?)\s*=\s*(.*?)\s*$') {
      Set-Variable -Name $Matches[1] -Value $Matches[2]
    }
  }
}

if ($env:MVNW_REPOURL) {
  $MVNW_REPO_PATTERN = if ($distributionUrl.contains('/maven2')) { '/maven2' } else { '/plugins' }
  $distributionUrl = "$env:MVNW_REPOURL$MVNW_REPO_PATTERN$($distributionUrl -replace '^.*$MVNW_REPO_PATTERN', '')"
}

if ($distributionUrl -eq $null) {
  Write-Error "cannot read distributionUrl property in $MavenWrapperPropertyFile"
}

switch -wildcard -casesensitive ( $($distributionUrl -replace '^.*/','') ) {
  "*.zip" {
    $unzipMethod = "ZipFile"
    $tempDownloadFile = [System.IO.Path]::GetTempFileName() + ".zip"
    break
  }
  "*.tar.gz" {
    $unzipMethod = "tar"
    $tempDownloadFile = [System.IO.Path]::GetTempFileName() + ".tar.gz"
    break
  }
  default {
    Write-Error "distributionUrl '$distributionUrl' is not supported, only zip and tar.gz"
    break
  }
}

# Find the home directory. Prefer $env:MAVEN_USER_HOME over $env:USERPROFILE then $env:HOMEPATH.
if ($env:MAVEN_USER_HOME) {
  $userHome = $env:MAVEN_USER_HOME
} elseif ($env:USERPROFILE) {
  $userHome = $env:USERPROFILE
} else {
  $userHome = $env:HOMEPATH
}

$distributionUrlName = $distributionUrl -replace '^.*/([^/]*$)', '$1'
$distributionUrlNameMain = $distributionUrlName -replace '\.[^.]*$', '' -replace '-bin$',''
$MAVEN_HOME_PARENT = "$userHome/.m2/wrapper/dists/$distributionUrlNameMain"
$MAVEN_HOME = "$MAVEN_HOME_PARENT/$distributionUrlName"

if (Test-Path -Path "$MAVEN_HOME" -PathType Container) {
  $MVN_CMD = "$MAVEN_HOME/bin/mvn"
  if ($env:MVNW_VERBOSE -eq "true") {
    Write-Output "Found existing installation at $MAVEN_HOME"
  }
} else {
  Write-Output "Downloading from: $distributionUrl"
  $webclient = New-Object System.Net.WebClient
  if ($env:MVNW_USERNAME -and $env:MVNW_PASSWORD) {
    $webclient.Credentials = New-Object System.Net.NetworkCredential($env:MVNW_USERNAME, $env:MVNW_PASSWORD)
  }
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  $webclient.DownloadFile($distributionUrl, $tempDownloadFile) | Out-Null
  Write-Output "Unzipping to: $MAVEN_HOME_PARENT"
  if ($unzipMethod -eq "ZipFile") {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($tempDownloadFile, $MAVEN_HOME_PARENT)
  } else {
    tar -xzf $tempDownloadFile -C $MAVEN_HOME_PARENT
  }
  $MVN_FOUND_DIRS = Get-ChildItem -Path $MAVEN_HOME_PARENT | Where-Object { $_.Name -like "apache-maven-*" } | Select-Object -Last 1
  $MAVEN_HOME = $MVN_FOUND_DIRS.FullName
  Write-Output "Maven installation complete."
  Remove-Item $tempDownloadFile
}

$MVN_CMD = "$MAVEN_HOME/bin/mvn"
Write-Output "MVN_CMD=$MVN_CMD"
