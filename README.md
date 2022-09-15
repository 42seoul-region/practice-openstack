# 42Region Practice - OpenStack

## 1. Docker 실행 방법
- 저장소를 submodule과 함께 클론합니다.
- `docker compose up --build` 또는 `docker-compose up --build` 로 서비스를 실행합니다.
```bash
$ git clone --recursive https://github.com/42seoul-region/practice-openstack.git
$ docker compose up --build
```

### 도커 서비스 삭제
- `docker compose down` 또는 `docker-compose down` 명령으로 컨테이너와 임시 볼륨을 제거할 수 있습니다.

## 2. 기본 설치 위치
- 기본 `.env` 파일에 설정된 값은 다음과 같습니다.
  - 관리자 ID는 `admin`, 관리자 패스워드는 `keystone_admin_password`이 초기값입니다.
  - keystone API는 http://localhost:5000/v3 위치에 설치됩니다.
