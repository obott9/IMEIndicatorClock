# IMEIndicatorClock

[English](README.md) | [日本語](README_ja.md) | [繁體中文](README_zh-Hant.md) | [简体中文](README_zh-Hans.md)

IME(입력기) 상태를 시각적으로 표시하고 사용자 정의 가능한 데스크톱 시계를 제공하는 macOS 유틸리티 앱입니다.

## 스크린샷

### IME 상태 연동 데스크톱 시계
| IME OFF (영어) | IME ON (일본어) |
|:-------------:|:--------------:|
| ![IME OFF](docs/images/clock_ime_off.png) | ![IME ON](docs/images/clock_ime_on.png) |

### 설정 화면
| IME 표시기 | 시계 | 마우스 커서 표시기 |
|:---------:|:----:|:----------------:|
| ![IME 설정](docs/images/settings_ime_indicator.png) | ![시계 설정](docs/images/settings_clock.png) | ![커서 설정](docs/images/settings_cursor_indicator.png) |

### 다국어 UI
| 일본어 | 번체 중국어 |
|:------:|:---------:|
| ![About 일본어](docs/images/about_ja.png) | ![About 중국어](docs/images/about_zh-Hant.png) |

## 비전

**우리의 목표는 전 세계의 IME를 지원하는 것입니다.**

여러 언어를 전환하며 사용하는 사용자가 현재 입력 모드를 한눈에 확인할 수 있도록 돕는 것을 목표로 합니다.

## 기능

### IME 표시기
- 화면에 현재 입력기 상태를 시각적으로 표시
- 일본어 입력: 빨간 원에 "あ"
- 영어 입력: 파란 원에 "A"
- 위치, 크기, 투명도 사용자 정의 가능

### 데스크톱 시계
- 아날로그 및 디지털 모드를 지원하는 플로팅 시계
- 날짜 표시 지원
- IME 상태에 따른 배경색 전환 기능
- 창 크기, 글꼴 크기, 색상을 자유롭게 사용자 정의

### 마우스 커서 표시기
- 마우스 커서 근처에 IME 상태를 표시
- 텍스트 입력 시 편리

## 언어 지원

### 완전 지원 (IME 감지 + UI)
| 언어 | IME 감지 | UI 번역 |
|------|:--------:|:-------:|
| 일본어 | ✅ | ✅ |
| 영어 | ✅ | ✅ |
| 중국어(간체) | ✅ | ✅ |
| 중국어(번체) | ✅ | ✅ |
| 한국어 | ✅ | ✅ |

### IME 감지 + 기본 UI
| 언어 | IME 감지 | UI 번역 |
|------|:--------:|:-------:|
| 태국어 | ✅ | ✅ |
| 베트남어 | ✅ | ✅ |
| 아랍어 | ✅ | ✅ |
| 히브리어 | ✅ | ✅ |
| 힌디어 | ✅ | ✅ |
| 러시아어 | ✅ | ✅ |
| 그리스어 | ✅ | ✅ |

*이러한 언어의 UI 번역은 기계 번역으로, 개선이 필요할 수 있습니다. 기여를 환영합니다!*

## 시스템 요구 사항

- macOS 14.0 (Sonoma) 이상
- Apple Silicon / Intel Mac 지원

## 설치

1. 이 저장소를 복제
2. Xcode에서 프로젝트 열기
3. 빌드 및 실행

```bash
git clone https://github.com/obott9/IMEIndicatorClock.git
cd IMEIndicatorClock
open IMEIndicatorClock.xcodeproj
```

## 사용 방법

1. 앱을 실행하면 메뉴 바에 아이콘이 나타납니다
2. 메뉴 바 아이콘에서 각종 설정에 접근
3. 시계나 표시기를 원하는 위치로 드래그

## 필요한 권한

- **손쉬운 사용**: IME 상태 모니터링에 필요합니다. 첫 실행 시 권한을 요청합니다.

## 개발

이 프로젝트는 Anthropic의 [Claude AI](https://claude.ai/)와 공동 개발되었습니다.

Claude가 지원한 부분:
- 아키텍처 설계 및 코드 구현
- 다국어 현지화
- 문서 및 README 작성

## 지원

이 앱이 유용하다면 커피 한 잔 사주세요!

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/obott9)

## 기여

기여를 환영합니다! 특히:
- 추가 언어의 UI 번역
- 더 많은 IME 유형 지원
- 버그 보고 및 기능 요청

## 라이선스

MIT License - 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.
