# 3-Tier Infrastructure Architecture

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                    Internet                                          │
└────────────────────────────────────┬────────────────────────────────────────────────┘
                                     │
                                     │ HTTPS/HTTP
                                     │
┌────────────────────────────────────┼────────────────────────────────────────────────┐
│                                AWS VPC (10.0.0.0/16)                                 │
│                                                                                      │
│  ┌───────────────────────────────────────────────────────────────────────────────┐ │
│  │                        Internet Gateway                                        │ │
│  └───────────────────────────────┬───────────────────────────────────────────────┘ │
│                                  │                                                  │
│  ┌───────────────────────────────┼───────────────────────────────────────────────┐ │
│  │              PUBLIC TIER (Availability Zone 1 & 2)                             │ │
│  │  ┌────────────────────────────┴──────────────────────────────┐                │ │
│  │  │         Subnet 10.0.1.0/24 (AZ1) │ 10.0.2.0/24 (AZ2)      │                │ │
│  │  │                                                             │                │ │
│  │  │  ┌─────────────────────────────────────────────────────┐  │                │ │
│  │  │  │   Application Load Balancer (ALB)                   │  │                │ │
│  │  │  │   - Port 80 → Target Group (Port 3000)              │  │                │ │
│  │  │  │   - Health Check: /api/health                       │  │                │ │
│  │  │  │   - Security Group: alb-sg                          │  │                │ │
│  │  │  │     • Inbound: 80 (0.0.0.0/0), 443 (0.0.0.0/0)      │  │                │ │
│  │  │  │     • Outbound: 3000 → app-sg                       │  │                │ │
│  │  │  └─────────────────────────────────────────────────────┘  │                │ │
│  │  │                                                             │                │ │
│  │  │  ┌──────────────────┐         ┌──────────────────┐        │                │ │
│  │  │  │  NAT Gateway 1   │         │  NAT Gateway 2   │        │                │ │
│  │  │  │  (Elastic IP)    │         │  (Elastic IP)    │        │                │ │
│  │  │  └──────────────────┘         └──────────────────┘        │                │ │
│  │  │                                                             │                │ │
│  │  │  ┌──────────────────────────────────────────────┐         │                │ │
│  │  │  │       Bastion Host (EC2)                     │         │                │ │
│  │  │  │       - Elastic IP: 18.202.84.57             │         │                │ │
│  │  │  │       - Instance Type: t3.micro               │         │                │ │
│  │  │  │       - Security Group: bastion-sg            │         │                │ │
│  │  │  │         • Inbound: SSH (22) from allowed CIDRs│         │                │ │
│  │  │  │       - Docker, AWS CLI, MySQL client         │         │                │ │
│  │  │  └──────────────────────────────────────────────┘         │                │ │
│  │  └─────────────────────────────────────────────────────────────┘                │ │
│  └───────────────────────────────────────────────────────────────────────────────┘ │
│                                      │                                               │
│                                      │ Routes via NAT Gateway                        │
│                                      │                                               │
│  ┌───────────────────────────────────┼───────────────────────────────────────────┐ │
│  │           PRIVATE APP TIER (Availability Zone 1 & 2)                           │ │
│  │  ┌────────────────────────────────┴──────────────────────────────┐            │ │
│  │  │      Subnet 10.0.11.0/24 (AZ1) │ 10.0.12.0/24 (AZ2)            │            │ │
│  │  │                                                                 │            │ │
│  │  │  ┌────────────────────────────────────────────────────────┐   │            │ │
│  │  │  │         Auto Scaling Group                             │   │            │ │
│  │  │  │         - Min: 2, Max: 4, Desired: 2                   │   │            │ │
│  │  │  │         - Launch Template: Amazon Linux 2               │   │            │ │
│  │  │  │                                                          │   │            │ │
│  │  │  │  ┌──────────────────┐      ┌──────────────────┐        │   │            │ │
│  │  │  │  │   EC2 Instance 1 │      │   EC2 Instance 2 │        │   │            │ │
│  │  │  │  │   (AZ1)          │      │   (AZ2)          │        │   │            │ │
│  │  │  │  │   10.0.11.x      │      │   10.0.12.x      │        │   │            │ │
│  │  │  │  │                  │      │                  │        │   │            │ │
│  │  │  │  │  ┌────────────┐  │      │  ┌────────────┐  │        │   │            │ │
│  │  │  │  │  │   Docker   │  │      │  │   Docker   │  │        │   │            │ │
│  │  │  │  │  │ NoteService│  │      │  │ NoteService│  │        │   │            │ │
│  │  │  │  │  │  (Port     │  │      │  │  (Port     │  │        │   │            │ │
│  │  │  │  │  │   3000)    │  │      │  │   3000)    │  │        │   │            │ │
│  │  │  │  │  └────────────┘  │      │  └────────────┘  │        │   │            │ │
│  │  │  │  │                  │      │                  │        │   │            │ │
│  │  │  │  │  IAM Role:       │      │  IAM Role:       │        │   │            │ │
│  │  │  │  │  - ECR Pull      │      │  - ECR Pull      │        │   │            │ │
│  │  │  │  │  - Secrets Read  │      │  - Secrets Read  │        │   │            │ │
│  │  │  │  │  - CloudWatch    │      │  - CloudWatch    │        │   │            │ │
│  │  │  │  │                  │      │                  │        │   │            │ │
│  │  │  │  │  Security Group: │      │  Security Group: │        │   │            │ │
│  │  │  │  │  app-sg          │      │  app-sg          │        │   │            │ │
│  │  │  │  │  • In: 3000      │      │  • In: 3000      │        │   │            │ │
│  │  │  │  │    from ALB      │      │    from ALB      │        │   │            │ │
│  │  │  │  │  • In: 22 from   │      │  • In: 22 from   │        │   │            │ │
│  │  │  │  │    Bastion       │      │    Bastion       │        │   │            │ │
│  │  │  │  └──────────────────┘      └──────────────────┘        │   │            │ │
│  │  │  └────────────────────────────────────────────────────────┘   │            │ │
│  │  └─────────────────────────────────────────────────────────────────┘            │ │
│  └───────────────────────────────────────────────────────────────────────────────┘ │
│                                      │                                               │
│                                      │ Port 3306 (MySQL)                             │
│                                      │                                               │
│  ┌───────────────────────────────────┼───────────────────────────────────────────┐ │
│  │            PRIVATE DB TIER (Availability Zone 1 & 2)                           │ │
│  │  ┌────────────────────────────────┴──────────────────────────────┐            │ │
│  │  │      Subnet 10.0.21.0/24 (AZ1) │ 10.0.22.0/24 (AZ2)            │            │ │
│  │  │                                                                 │            │ │
│  │  │  ┌────────────────────────────────────────────────────────┐   │            │ │
│  │  │  │         RDS MySQL (Multi-AZ)                           │   │            │ │
│  │  │  │         - Engine: MySQL 8.0                            │   │            │ │
│  │  │  │         - Instance Class: db.t3.micro                  │   │            │ │
│  │  │  │         - Storage: 20GB (Encrypted)                    │   │            │ │
│  │  │  │         - Database Name: appdb                         │   │            │ │
│  │  │  │         - Security Group: db-sg                        │   │            │ │
│  │  │  │           • Inbound: 3306 from app-sg                  │   │            │ │
│  │  │  │         - Credentials: AWS Secrets Manager             │   │            │ │
│  │  │  │         - Automated Backups: 7 days                    │   │            │ │
│  │  │  │                                                          │   │            │ │
│  │  │  │         Primary (AZ1)  ────Sync────▶  Standby (AZ2)    │   │            │ │
│  │  │  └────────────────────────────────────────────────────────┘   │            │ │
│  │  └─────────────────────────────────────────────────────────────────┘            │ │
│  └───────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                      │
└──────────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────────────┐
│                            AWS MANAGED SERVICES                                       │
│                                                                                       │
│  ┌────────────────────────┐  ┌────────────────────────┐  ┌─────────────────────┐   │
│  │   ECR Repository       │  │   Secrets Manager      │  │   CloudWatch        │   │
│  │   (eu-west-1)          │  │                        │  │   - Logs            │   │
│  │                        │  │   Secret:              │  │   - Metrics         │   │
│  │   Repository:          │  │   3tier-iac-db-        │  │   - Alarms          │   │
│  │   3tier-iac-noteservice│  │   credentials          │  │                     │   │
│  │                        │  │   {                    │  │   Log Groups:       │   │
│  │   Images:              │  │     "username": "...", │  │   - /aws/ec2/       │   │
│  │   - latest             │  │     "password": "...", │  │     noteservice     │   │
│  │   - <git-sha>          │  │     "host": "...",     │  │                     │   │
│  │                        │  │     "port": 3306,      │  │                     │   │
│  │   Lifecycle Policy:    │  │     "dbname": "appdb"  │  │                     │   │
│  │   - Keep 10 images     │  │   }                    │  │                     │   │
│  │   - Delete untagged    │  │                        │  │                     │   │
│  │     after 7 days       │  │   Auto-Rotation: 30d   │  │                     │   │
│  │                        │  │   Encryption: KMS      │  │                     │   │
│  └────────────────────────┘  └────────────────────────┘  └─────────────────────┘   │
│                                                                                       │
│  ┌────────────────────────┐  ┌────────────────────────┐                             │
│  │   IAM Roles            │  │   Route 53 (Optional)  │                             │
│  │                        │  │                        │                             │
│  │   ec2-role:            │  │   DNS Records for ALB  │                             │
│  │   - ECR:PullImage      │  │   noteservice.         │                             │
│  │   - Secrets:GetValue   │  │   example.com          │                             │
│  │   - CloudWatch:Logs    │  │   ↓                    │                             │
│  │   - SSM:GetParameter   │  │   ALB DNS              │                             │
│  └────────────────────────┘  └────────────────────────┘                             │
└──────────────────────────────────────────────────────────────────────────────────────┘
```

## Architecture Components

### 1. **VPC (Virtual Private Cloud)**
- **CIDR Block**: 10.0.0.0/16
- **Availability Zones**: 2 (eu-west-1a, eu-west-1b)
- **DNS Support**: Enabled
- **DNS Hostnames**: Enabled

### 2. **Public Tier** (Internet-Facing)
**Subnets**:
- AZ1: 10.0.1.0/24
- AZ2: 10.0.2.0/24

**Components**:
- **Application Load Balancer (ALB)**
  - Listens on port 80 (HTTP)
  - Forwards to Target Group (port 3000)
  - Health checks: `/api/health`
  - Cross-zone load balancing enabled
  
- **NAT Gateways** (High Availability)
  - One per AZ for redundancy
  - Elastic IPs attached
  - Routes traffic from private subnets to internet
  
- **Bastion Host**
  - Jump server for SSH access to private instances
  - Elastic IP: 18.202.84.57
  - Hardened security (SSH only from specific IPs)

### 3. **Private Application Tier**
**Subnets**:
- AZ1: 10.0.11.0/24
- AZ2: 10.0.12.0/24

**Components**:
- **Auto Scaling Group**
  - Min: 2, Max: 4, Desired: 2
  - Launch Template: Amazon Linux 2
  - Health checks: ELB + EC2
  - Scale on CPU/Memory metrics
  
- **EC2 Instances**
  - Instance Type: t3.micro
  - Docker installed with NoteService container
  - Port 3000 exposed for application traffic
  - IAM instance profile attached
  - User data installs: Docker, AWS CLI
  
- **NoteService Application**
  - Next.js 14 App (containerized)
  - Prisma ORM for database access
  - REST API endpoints: /api/notes, /api/health
  - Retrieves DB credentials from Secrets Manager

### 4. **Private Database Tier**
**Subnets**:
- AZ1: 10.0.21.0/24
- AZ2: 10.0.22.0/24

**Components**:
- **RDS MySQL**
  - Engine: MySQL 8.0
  - Multi-AZ deployment for HA
  - Instance Class: db.t3.micro
  - Storage: 20GB (encrypted at rest)
  - Automated backups: 7 days retention
  - Credentials stored in AWS Secrets Manager
  - Database Name: appdb

### 5. **Security Groups**

| Security Group | Inbound Rules | Outbound Rules |
|----------------|---------------|----------------|
| **alb-sg** | Port 80 (HTTP) from 0.0.0.0/0<br>Port 443 (HTTPS) from 0.0.0.0/0 | Port 3000 to app-sg<br>All traffic to 0.0.0.0/0 |
| **app-sg** | Port 3000 from alb-sg<br>Port 22 from bastion-sg | Port 3306 to db-sg<br>Port 443 to 0.0.0.0/0 (for ECR/Secrets) |
| **db-sg** | Port 3306 from app-sg | All traffic to app-sg |
| **bastion-sg** | Port 22 from allowed CIDRs | Port 22 to app-sg<br>All traffic to 0.0.0.0/0 |

### 6. **Managed Services**

**ECR (Elastic Container Registry)**:
- Repository: `3tier-iac-noteservice`
- Image scanning enabled
- Lifecycle policy: Keep 10 tagged images, delete untagged after 7 days
- Encryption: AES256

**AWS Secrets Manager**:
- Secret Name: `3tier-iac-db-credentials`
- Auto-generated password (32 characters)
- Rotation: 30 days (optional)
- Encrypted with KMS

**IAM Roles**:
- **ec2-role**: Attached to EC2 instances
  - ECR: Pull images
  - Secrets Manager: Read database credentials
  - CloudWatch: Write logs
  - SSM: Parameter Store access

**CloudWatch**:
- Log Groups: `/aws/ec2/noteservice`
- Metrics: CPU, Memory, Network, Disk
- Alarms: High CPU, Low healthy hosts

### 7. **Network Flow**

1. **User Request**:
   ```
   User → ALB (Port 80) → Target Group (Port 3000) → EC2 Instance → Docker Container
   ```

2. **Database Connection**:
   ```
   Docker Container → RDS MySQL (Port 3306) [credentials from Secrets Manager]
   ```

3. **Container Deployment**:
   ```
   Developer → ECR (Push Image) → EC2 (Pull Image) → Docker Run
   ```

4. **SSH Access**:
   ```
   Developer → Bastion (SSH) → Private EC2 Instance (SSH)
   ```

5. **Outbound (Internet Access)**:
   ```
   Private EC2 → NAT Gateway → Internet Gateway → Internet
   ```

## High Availability & Resilience

1. **Multi-AZ Deployment**: All tiers span 2 availability zones
2. **Load Balancing**: ALB distributes traffic across healthy instances
3. **Auto Scaling**: ASG maintains desired capacity, scales on demand
4. **Database Replication**: RDS Multi-AZ with automatic failover
5. **NAT Gateway Redundancy**: One per AZ for continued internet access
6. **Health Checks**: ALB continuously monitors instance health
7. **Backup Strategy**: RDS automated backups (7 days), snapshots

## Security Best Practices

1. **Network Segmentation**: Public/Private subnet isolation
2. **Least Privilege**: Security groups with minimal required access
3. **Encryption**: 
   - EBS volumes encrypted at rest
   - RDS storage encrypted
   - Secrets Manager uses KMS
4. **Bastion Host**: Single entry point for SSH access
5. **IMDSv2**: Required for metadata service (SSRF protection)
6. **No Public IPs**: App instances only have private IPs
7. **Secret Rotation**: Database credentials rotated regularly

## Deployment Workflow

1. **Build & Push**:
   ```bash
   cd noteservice
   ./build-and-push.sh  # Builds Docker image, pushes to ECR
   ```

2. **Deploy to EC2**:
   ```bash
   ./deploy-to-ec2.sh   # SSH via bastion, pulls image, runs container
   ```

3. **Access Application**:
   ```
   http://3tier-iac-alb-1018353806.eu-west-1.elb.amazonaws.com
   ```

## Monitoring & Logging

- **ALB Access Logs**: S3 bucket (optional)
- **CloudWatch Logs**: Application logs from Docker containers
- **CloudWatch Metrics**: CPU, Memory, Network, Custom app metrics
- **RDS Metrics**: Connections, CPU, Storage, Read/Write IOPS
- **Auto Scaling Events**: Scale-up/down notifications

## Cost Optimization

1. **Right-sized Instances**: t3.micro for dev/staging
2. **Auto Scaling**: Scale down during low traffic
3. **Reserved Instances**: For predictable workloads (production)
4. **NAT Gateway**: Consider NAT instances for cost savings
5. **RDS Multi-AZ**: Disable for non-production environments
6. **ECR Lifecycle Policy**: Automatically clean up old images

## Future Enhancements

1. **HTTPS/SSL**: Add ACM certificate to ALB
2. **Route 53**: Custom domain with hosted zone
3. **CloudFront**: CDN for static assets
4. **WAF**: Web Application Firewall on ALB
5. **Lambda**: Serverless functions for background jobs
6. **ElastiCache**: Redis/Memcached for session storage
7. **S3**: Object storage for file uploads
8. **CI/CD**: GitHub Actions → ECR → ECS/EC2 deployment
