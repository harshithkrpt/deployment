# Method 1 : deploying directly to ec2 the java service 

## Deploy Spring Boot JAR to EC2 (Amazon Linux) — Step Notes

#### Prerequisites

* AWS account
* EC2 instance running (Amazon Linux)
* Security group allows ports:

  * 22 (SSH)
  * 8080 (App access)
* `.pem` key downloaded
* Java Spring Boot project ready

---

#### 1. Build JAR Locally

Navigate to project root and run:

```
mvn clean package -DskipTests
```

Output file generated:

```
target/<app-name>.jar
```

---

#### 2. Connect to EC2

```
ssh -i key.pem ec2-user@<EC2_PUBLIC_IP>
```

---

#### 3. Install Java on EC2

For Amazon Linux:

```
sudo yum install java-17-amazon-corretto -y
```

Verify:

```
java -version
```

---

#### 4. Copy JAR to EC2

Run from local machine:

```
scp -i key.pem target/app.jar ec2-user@<EC2_IP>:/home/ec2-user
```

---

#### 5. Run Application

Inside EC2:

```
java -jar app.jar
```

Open browser:

```
http://<EC2_IP>:8080
```

---

#### 6. Run in Background

```
nohup java -Xms128m -Xmx512m -jar app.jar > app.log 2>&1 &
```

Check process:

```
ps -ef | grep java
```

---

#### 7. Fix Port Access (If App Not Reachable)

AWS Console → Security Groups → Inbound Rules → Add:

* Type: Custom TCP
* Port: 8080
* Source: 0.0.0.0/0

---

#### 8. (Optional) Use External Database Instead of H2

Set environment variables before running:

```
export DB_URL=jdbc:postgresql://host:5432/db
export DB_USER=postgres
export DB_PASS=password
export DB_DRIVER=org.postgresql.Driver
export DB_DIALECT=org.hibernate.dialect.PostgreSQLDialect
```

---

#### 9. Stop Application

```
ps -ef | grep java
kill <PID>
```

---

#### Summary Workflow

```
Build → Copy → SSH → Run → Verify → Background
```

---

#### Notes

* H2 database is in-memory → data resets on restart
* t2.micro recommended JVM memory:

```
-Xms128m -Xmx512m
```

* Same JAR can run locally, on EC2, Docker, or Kubernetes

---
