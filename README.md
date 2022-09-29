# 42Region Practice - OpenStack

## 1. Docker 실행 방법
- 저장소를 클론합니다.
- `docker compose up --build` 또는 `docker-compose up --build` 로 서비스를 실행합니다.
```bash
$ git clone https://github.com/42seoul-region/practice-openstack.git
$ docker compose up --build
```

### 도커 서비스 삭제
- `docker compose down` 또는 `docker-compose down` 명령으로 컨테이너와 임시 볼륨을 제거할 수 있습니다.

## 2. 기본 설치 위치
- 기본 `.env` 파일에 설정된 값은 다음과 같습니다.
  - 관리자 ID는 `keystone`, 관리자 패스워드는 `keystone_admin_password`이 초기값입니다.
  - keystone API는 http://localhost:5000/v3 위치에 설치됩니다.

-----------------------------------------------------------------------------------------------

## nova_create branch
- nova dockerfile 추가
- [key_manager] session 항목들을 [keystone_authtoken] session으로 변경
  - glance image 생성 안되던 문제 해결
- docker-compose file, network subnet 설정
  - nova external ip를 설정하기 위함 (차후 수정 될수도 있음)
- openstackclient config script 변경
  - role, endpoint에 대한 check 부분을 주로 변경
- neutron dockerfile 추가
- horizon dockerfile 추가
- docker-compose에 memcached image 추가

### issue
- docker compose down 후 data를 삭제하지 않고 docker compose up --build를 진행할 시,
  서비스들의 데이터베이스를 다시 만드는 문제
  - DB에서 외래키가 설정되어 있는데, keystone의 bootstrap을 적용하면서 기존 동일한 이름의 region을 삭제하는 것 같고,
    이 연계 효과로 인해 연결된 모든 엔드포인트가 사라진다.
  - 키스톤은 왜 다시 초기화를 하는가?
    ⇒ 컨테이너를 삭제했다가 다시 만들었기 때문에 컨테이너 내부에 만든 설정 완료를 표식하기 위해 만든 파일이 사라졌기 때문이다