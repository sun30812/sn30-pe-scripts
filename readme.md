# sn30-pe-scripts
Windows PE환경에서 사용하기 위해 직접 만든 Powershell 스크립트 입니다.
> ⚠️ 주의: 이 저장소의 모든 스크립트들은  사용으로 인해 발생한 문제점에 대해 책임지지 않습니다.

## 브랜치 안내
해당 브랜치는 `main`입니다. 기능 추가가 가장 빨리 이루어집니다. 코드의 안정성이 **매우 낮지만** 신기능을 제일 먼저 확인할 수 있습니다.

## 파일 설명

* sn30-pe-diskpart.txt: sn30pe-init에서 쓰이는 파일입니다.
* sn30-pe-backup.ps1: 드라이버를 데이터 파티션으로 넣어줍니다.
* sn30pe-init.ps1: Windows이미지를 설치하기 위한 스크립트 입니다.
* sn30pe-launcher.ps1: GUI로 여러 작업을 실행할 수 있도록 해주는 스크립트 입니다. 추후 안정성이 확보되면 `sn30pe-init.ps1`으로 통합됩니다.

## 목차
- [sn30-pe-scripts](#sn30-pe-scripts)
  - [목차](#목차)
- [sn30pe-init](#sn30pe-init)
  - [주의사항](#주의사항)
  - [알려진 문제](#알려진-문제)
  - [준비사항](#준비사항)
    - [데이터 파티션 내에 폴더](#데이터-파티션-내에-폴더)
      - [drivers](#drivers)
      - [images](#images)
    - [PE의 시작 스크립트에 추가하기](#pe의-시작-스크립트에-추가하기)
  - [실행해보기](#실행해보기)
- [sn30pe-backup](#sn30pe-backup)
- [sn30pe-launcher](#sn30pe-launcher)

---

# sn30pe-init
PE가 부팅하고 기본으로 실행되는 스크립트 파일입니다. 이 스크립트 파일을 실행하면 몇번의 숫자 입력과 yes를 입력하여 지정한 디스크에 Windows를 설치할 수 있습니다.(드라이버 설치 가능)
## 주의사항
* 이 설치 스크립트는 UEFI(GPT)방식의 설치만 지원됩니다.
* 드라이버와 Windows 이미지 파일은 별도의 파티션에 구성해야합니다.
    * 이미지 파일이 4기가를 넘을 수 있어서 FAT32 파일 시스템인 부팅용 파티션과 분리할 필요가 있음
    * 별도의 파티션 이름은 `sn30-pe-data`여야 하나(대소문자 구분 안함) 스크립트 최상단에 `$data_drive` 를 변경함으로써 변경 가능
* PE의 시작 스크립트에 등록하려면 PE에 `powershell` 구성요소가 추가 되어야 합니다.
    * 추가 방법: [MS 설명서링크](https://docs.microsoft.com/ko-kr/windows-hardware/manufacture/desktop/winpe-adding-powershell-support-to-windows-pe)
## 알려진 문제
현재 발견된 문제가 없습니다.

## 준비사항
### 데이터 파티션 내에 폴더
> 이 작업을 수행하면 sn30pe-init 스크립트를 실행할 수 있습니다.(PE환경이 아니라도)

여기서 데이터 파티션은 **PE의 부팅용 파티션 말고** ntfs로 포맷된 다른 파티션을 의미합니다. 이를 통해 4기가 이상의 Windows이미지 파일도 사용이 가능합니다.
참고로 USB디스크도## 주의사항
* 이 설치 스크립트는 UEFI(GPT)방식의 설치만 지원됩니다.
* 드라이버와 Windows 이미지 파일은 별도의 파티션에 구성해야합니다.
    * 이미지 파일이 4기가를 넘을 수 있어서 FAT32 파일 시스템인 부팅용 파티션과 분리할 필요가 있음
    * 별도의 파티션 이름은 `sn30-pe-data`여야 하나(대소문자 구분 안함) 스크립트 최상단에 `$data_drive` 를 변경함으로써 변경 가능
* PE의 시작 스크립트에 등록하려면 PE에 `powershell` 구성요소가 추가 되어야 합니다.
    * 추가 방법: [MS 설명서링크](https://docs.microsoft.com/ko-kr/windows-hardware/manufacture/desktop/winpe-adding-powershell-support-to-windows-pe)
## 알려진 문제
현재 발견된 문제가 없습니다.

## 준비사항
### 데이터 파티션 내에 폴더
> 이 작업을 수행하면 sn30pe-init 스크립트를 실행할 수 있습니다.(PE환경이 아니라도)

여기서 데이터 파티션은 **PE의 부팅용 파티션 말고** ntfs로 포맷된 다른 파티션을 의미합니다. 이를 통해 4기가 이상의 Windows이미지 파일도 사용이 가능합니다.
참고로 USB디스크도 두개로 파티션을 나눌 수 있습니다.(추후 문서에 추가 예정)


Windows 설치 작업에 쓰일 이미지와 드라이버를 데이터 드라이브에 넣어야 합니다. 데이터 드라이브에 다음 두 폴더를 추가합니다.
* `drivers`
* `images`

두 폴더는 이름이 다르면 안됩니다. 이제 폴더별로 들어가야 하는 파일을 설명하겠습니다.
#### drivers
이 안에는 원하는 이름의 폴더를 생성하신 후 거기에 inf형식의 드라이버를 백업한 것을 넣으시면 됩니다. `sn30pe_backup` 스크립트를 사용하면 이 폴더에 현재 부팅하고 계신 기기의 드라이버를 추철해서 넣어줍니다.
#### images
현재는 `.wim`이나 `.esd`파일만 지원합니다. 이곳에 파일을 넣어주시면 됩니다.
### PE의 시작 스크립트에 추가하기
> ⚠️ 주의사항에 써놓았듯 PE에 `powershell` 구성요소가 추가되어야 시작 스크립트에 추가가 가능합니다.

1. PE의 `boot.wim`을 마운트 해야합니다. `dism`으로 해도 좋고 `Mount-WindowsImage`명령을 사용해도 좋습니다.
2. 마운트한 폴더에서 `windows` 폴더에 `sn30pe-init.ps1`파일을 넣습니다.
3. 마운트한 폴더에서 `windows/system32`폴더에 `sn30-pe-diskpart.txt`를 넣습니다.
3. 마운트한 폴더에서 `windows/system32/startnet.cmd` 파일의 맨 끝에 `powershell -executionpolicy bypass -command %systemroot%\sn30pe-init.ps1`를 추가합니다.
4. dism명령어에서는 `/commit`옵션을 `Mount-WindowsImage`명령어에서는 `-Save` 옵션을 주고 마운트 해제하면 됩니다.
## 실행해보기
> 실제 설치 작업은 수행하지 않고 실행만 할 때 필요한 작업입니다.

sn30pe-init.ps1의 `# Perform Action` 아래 부분을 전부 주석 처리 하시면 됩니다. 그러면 마지막 설치 옵션 검토 후에 `yes`를 입력해도 무방합니다.(설치 진행 안함)

---
# sn30pe-backup
현재 사용중인 Windows의 드라이버를 PE의 데이터 파티션에 복사해주는 스크립트 입니다.

데이터 파티션의 이름은 `sn30-pe-data`여야 하나(대소문자 구분 안함) 스크립트 최상단에 있는`$data_drive`을 변경하면 됩니다.

관리자 권한으로 실행을 하신 후(`powershell -executionpolicy bypass -command sn30pe-init.ps1`) 원하는 이름을 입력하면 데이터 파티션의 드라이버 폴더에 지정한 폴더 이름으로 복사해줍니다.

---
# sn30pe-launcher
## 주의 사항
이 파일은 인코딩이 EUC-KR입니다.(한글 파워쉘은 인코딩 기본이 EUC-KR)
GUI로 여러 작업을 실행할 수 있도록 해주는 스크립트 입니다. 메모장, 이미지 를 이용한 설치작업 등을 지원하는 방향으로 개발 중입니다.  
추후 안정성이 확보되면 `sn30pe-init.ps1`으로 통합됩니다. 현재는 기능 구현이 **매우 미흡합니다.** 참고하시기 바랍니다.