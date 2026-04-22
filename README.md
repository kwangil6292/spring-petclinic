# 🌿 Spring PetClinic - AWS 하이브리드 클라우드 인프라 자동화 프로젝트

> 작성자: 김광일  
> 기간: 2026.03.25 ~ 2026.04.27

---

## 📌 프로젝트 소개

Ansible을 활용한 IaC(Infrastructure as Code)로 AWS 클라우드 인프라를 자동화하고,  
Jenkins + Docker + AWS CodeDeploy를 이용한 CI/CD 파이프라인을 구축한 프로젝트입니다.

---

## 🏗️ 아키텍처 구조

```
[개발자]
    │
    │ git push (aws 브랜치)
    ▼
[GitHub] ──Webhook──▶ [Jenkins EC2 - Private Subnet]
                              │
                    ┌─────────┴─────────┐
                    │                   │
              Gradle Build         Docker Build
                    │                   │
                    └─────────┬─────────┘
                              │
                         Docker Push
                              │
                         [Docker Hub]
                              │
                        Upload to S3
                              │
                   [S3 - scripts.zip]
                              │
                    ┌─ 배포 승인 대기 ─┐
                    │   (사람이 승인)   │
                    └─────────┬─────────┘
                              │
                       AWS CodeDeploy
                              │
                    ┌─────────▼─────────┐
                    │   ALB (80 포트)    │
                    └─────────┬─────────┘
                              │
               ┌──────────────┴──────────────┐
               │                             │
    [WAS EC2 - ap-northeast-2a]   [WAS EC2 - ap-northeast-2c]
         (Private Subnet)              (Private Subnet)
         Docker: PetClinic             Docker: PetClinic
```

---

## 🛠️ 기술 스택

| 분류 | 기술 |
|------|------|
| IaC | Ansible |
| CI/CD | Jenkins, AWS CodeDeploy |
| 컨테이너 | Docker, Docker Compose |
| 클라우드 | AWS (VPC, EC2, ALB, ASG, S3, Route53, IAM, CodeDeploy) |
| 소스 관리 | GitHub |
| 이미지 저장소 | Docker Hub |
| 언어/프레임워크 | Java 17, Spring Boot, Gradle |

---

## 📁 프로젝트 구조

```
spring-petclinic/
├── scripts/
│   ├── docker-compose.yml      # 앱 실행 설정
│   ├── run_process.sh          # 배포 후 실행 스크립트
│   └── kill_process.sh         # 기존 프로세스 종료 스크립트
├── appspec.yml                 # CodeDeploy 배포 설정
├── Dockerfile                  # Docker 이미지 빌드 설정
└── Jenkinsfile                 # CI/CD 파이프라인 정의
```

---

## 🔄 CI/CD 파이프라인 흐름

```
1. Git Clone       - aws 브랜치에서 소스 코드 가져오기
2. Install JDK 17  - JDK 17 설치 (없을 경우)
3. Gradle Build    - Spring Boot 앱 빌드 (bootJar)
4. Docker Build    - Docker 이미지 생성
5. Docker Push     - Docker Hub에 이미지 업로드
6. Docker Clean    - 로컬 이미지 정리
7. Upload to S3    - 배포 스크립트 S3 업로드
8. 배포 승인       - 담당자 승인 대기 (30분)
9. CodeDeploy      - AWS EC2에 자동 배포
```

---

## ☁️ AWS 인프라 구성 (Ansible 자동화)

### Ansible 실행 순서

```bash
# 0. MFA 토큰 발급 (필수!)
source ./scripts/token.sh

# 1. Network 생성
ansible-playbook pb-network.yml -e "task_action=deploy"

# 2. IAM 생성
ansible-playbook pb-iam.yml -e "task_action=deploy"

# 3. Golden AMI 생성
ansible-playbook pb-app-origin.yml -e "task_action=deploy"

# 4. Jenkins EC2 생성
ansible-playbook pb-jenkins.yml -e "task_action=deploy"

# 5. Load Balancer 생성
ansible-playbook pb-loadbalancer.yml -e "task_action=deploy"

# 6. ASG 생성
ansible-playbook pb-asg.yml -e "task_action=deploy"

# 7. CodeDeploy 생성
ansible-playbook pb-codedeploy.yml -e "task_action=deploy"
```

### 삭제 순서 (역순)

```bash
ansible-playbook pb-codedeploy.yml -e "task_action=terminate"
ansible-playbook pb-asg.yml -e "task_action=terminate"
ansible-playbook pb-loadbalancer.yml -e "task_action=terminate"
ansible-playbook pb-jenkins.yml -e "task_action=terminate"
ansible-playbook pb-iam.yml -e "task_action=terminate"
ansible-playbook pb-network.yml -e "task_action=terminate"
```

---

## 🌐 서비스 접속

| 서비스 | URL |
|--------|-----|
| PetClinic 앱 | http://user01-app.busanit.com |
| Jenkins | http://user01-jenkins.busanit.com |

---

## ⚠️ 트러블슈팅

### 1. CodeDeploy DownloadBundle 실패
- **원인**: ASG 인스턴스에 IAM Instance Profile 미적용
- **해결**: ASG terminate → deploy 재실행

### 2. AllowTraffic 무한 대기
- **원인**: docker-compose 포트 매핑 불일치 (`80:8080` → ALB는 `8080`으로 전송)
- **해결**: docker-compose.yml 포트를 `8080:8080`으로 수정, Deregistration Delay 300초 → 30초로 변경

### 3. ASG 인스턴스 3개 생성
- **원인**: 서브넷 조회 시 유령 AZ(`apne2-az3`) 포함
- **해결**: `selectattr` 필터로 `ap-northeast-2a`, `ap-northeast-2c`만 지정
