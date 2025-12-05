# Math Insight (AI Math Tutor Platform)

**Math Insight**는 Flutter와 Dart Frog로 개발된 **AI 기반 지능형 수학 학원 관리 플랫폼**입니다.
Google Gemini API를 활용한 오답 자동 생성 기능과 디스코드 알림 등 **Server-to-Server** 아키텍처가 적용되었습니다.

## 주요 기능 (Key Features)

* ** AI 문제 출제:** 선생님이 정답만 입력하면 AI(Gemini)가 매력적인 오답 4개를 자동 생성
* ** 스마트 오답노트:** 시험 종료 즉시 오답 데이터 적재 및 취약점 분석 차트 제공
* ** 실시간 소통:** 학생-선생님 간 1:1 Q&A 채팅 및 읽음 확인 기능
* ** Neural UI:** 독창적인 글래스모피즘(Glassmorphism) 및 네온 디자인 테마 적용

##  기술 스택 (Tech Stack)

* **Client:** Flutter (Provider, http)
* **Server:** Dart Frog (Middleware, Dependency Injection)
* **Database:** SQLite
* **AI & External:** Google Generative AI (Gemini)
* 
##  실행 방법 (Getting Started)

### 1. Server Setup
```bash
cd server
dart pub get
# .env 파일을 생성하고 API KEY를 입력하세요
dart_frog dev

cd client
flutter pub get
flutter run
