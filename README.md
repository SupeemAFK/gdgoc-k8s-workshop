# 🚀 Workshop: The Evolution of Code to Scale (Hands-on Guide)

**Session 2:** From Day 0 to Docker & Kubernetes (Local Environment)
**Time:** 2 Hours

ยินดีต้อนรับเข้าสู่ช่วง Hands-on ครับ! หลังจากที่เราได้เห็นภาพรวมวิวัฒนาการของ Infrastructure กันไปแล้ว ใน 2 ชั่วโมงนี้ เราจะมาลงมือทำจริง โดยสวมบทบาทเป็น Developer ที่จะนำ Source Code ธรรมดาๆ แพ็คใส่ Container (Docker) และนำไปรันบน Kubernetes Cluster จำลอง (KIND) เพื่อให้พร้อมสำหรับการ Scale

---

## 🛠 สิ่งที่ต้องเตรียมพร้อม (Prerequisites)
ก่อนเริ่ม กรุณาเปิด Terminal / Command Prompt และตรวจสอบว่ามีเครื่องมือเหล่านี้พร้อมใช้งาน:
1. `docker --version` (เช็คว่า Docker Desktop หรือ Engine ทำงานอยู่)
2. `kubectl version --client` (เช็คว่าติดตั้ง K8s CLI แล้ว)
3. `kind version` (เช็คว่าติดตั้ง KIND แล้ว)

---

## 📦 Part 1: Docker Basics - ทำให้โค้ดกลายเป็นกล่อง (40 นาที)

เป้าหมายในส่วนนี้คือการจำลองแอปพลิเคชันหน้าเว็บง่ายๆ และนำมันไปใส่ใน Docker Container เพื่อแก้ปัญหา "It works on my machine!"

### 1.1 สร้างแอปพลิเคชัน (Day 0: Code)
สร้างโฟลเดอร์สำหรับ Workshop และสร้างไฟล์ HTML ธรรมดาขึ้นมา:

```bash
mkdir gdgoc-workshop && cd gdgoc-workshop
echo "<h1>Hello GDGOC! My App is running in a Container 🐳</h1>" > index.html
```

### 1.2 สร้าง Dockerfile (The Recipe)
สร้างไฟล์ชื่อ Dockerfile (ไม่ต้องมีนามสกุล) เพื่อเขียนคำสั่งบอก Docker ว่าจะสร้าง Image นี้อย่างไร:

```bash
# ใช้ Nginx web server ขนาดเล็ก (Alpine) เป็น Base Image
FROM nginx:alpine

# ก๊อปปี้ไฟล์โค้ดของเรา ไปวางทับหน้าเว็บเริ่มต้นของ Nginx
COPY index.html /usr/share/nginx/html/

# บอกว่า Container นี้จะให้บริการผ่าน Port 80
EXPOSE 80
```

### 1.3 Build & Run (Day 1: Deploy to Docker)
ตอนนี้เราจะสร้าง (Build) โค้ดให้เป็น Image และสั่งให้มันทำงาน:
```bash
# 1. สั่ง Build โค้ดให้กลายเป็น Image ชื่อ my-app เวอร์ชั่น v1
docker build -t my-app:v1 .

# 2. ตรวจสอบว่า Image ถูกสร้างขึ้นมาแล้วจริงๆ
docker images | grep my-app

# 3. สั่งรัน Container โดยผูก Port 8080 ของเครื่องเรา เข้ากับ Port 80 ของ Container
docker run -d -p 8080:80 --name my-first-container my-app:v1
```

## 🎡 Part 2: Kubernetes Setup - สร้าง Cluster จำลองด้วย KIND (20 นาที)

เมื่อเรามี Container แล้ว การรัน Docker เครื่องเดียวจะไม่ตอบโจทย์เมื่อเราต้องการ Scale ระบบมารับคนหลักล้าน เราจึงต้องใช้ Kubernetes (K8s) เข้ามาเป็นผู้จัดการ

### 2.1 สร้าง Kubernetes Cluster
เราจะใช้ KIND (Kubernetes in Docker) สร้าง Cluster 1 Node ภายในเครื่องของเราเองแบบง่ายๆ:
```bash
kind create cluster --name gdgoc-local
```

### 2.2 ตรวจสอบสถานะ Cluster
```bash
# เช็คว่าเราชี้ kubectl มาที่ Cluster นี้แล้ว
kubectl cluster-info --context kind-gdgoc-local

# ดูจำนวนเครื่องใน Cluster (ควรจะเห็น 1 Node สถานะ Ready)
kubectl get nodes
```

## 🚢 Part 3: Deploy & Scale in Kubernetes (40 นาที)
### 3.1 โหลด Image เข้าสู่ K8s Cluster
เนื่องจาก KIND รันอยู่ในพื้นที่ปิด มันจึงไม่เห็น my-app:v1 ที่เราเพิ่งสร้าง เราต้องโหลดเข้าไปใน Cluster ก่อน:
```bash
kind load docker-image my-app:v1 --name gdgoc-local
```

### 3.2 สร้าง Deployment (สั่งให้ K8s ดูแลแอป)
สร้างไฟล์ชื่อ deployment.yaml เพื่ออธิบายว่าเราต้องการรันแอปหน้าตาแบบไหนและจำนวนเท่าไหร่:
```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
spec:
  replicas: 2 # เริ่มต้นที่ 2 Pods ก่อน
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: my-web-app
        image: my-app:v1
        imagePullPolicy: IfNotPresent # ให้ใช้ Image ในเครื่อง ไม่ต้องไปโหลดจากเน็ต
        ports:
        - containerPort: 80
```
สั่ง Apply เพื่อให้ K8s จัดการสร้างตามที่เราต้องการ:
```bash
kubectl apply -f deployment.yaml
```

### 3.3 ตรวจสอบ Pods
```bash
kubectl get pods
```

### 3.4 ทดลอง Scaling!
สมมติว่าตอนนี้มี Traffic เข้าเว็บเรามหาศาล เราต้องการเพิ่มเครื่องด่วน! เราสามารถสั่ง Scale ได้ทันที:
```bash
kubectl scale deployment web-deployment --replicas=5
```

## 🌐 Part 4: Accessing the App & Wrap-up (20 นาที)

แอปพลิเคชันเรารันอยู่บน K8s แล้ว 5 ตัว แต่ตอนนี้มันอยู่ภายในเครือข่ายของ K8s เราจะเปิดช่องทางให้เครื่องเราเข้าไปใช้งานได้ผ่าน Port Forwarding (เหมาะสำหรับ Dev/Test local)

### 4.1 เปิดช่องทางเข้าถึง (Port Forward)
```bash
kubectl port-forward deployment/web-deployment 8000:80
```
👉 ทดสอบ: เปิด Web Browser ไปที่ http://localhost:8000
Traffic ของคุณจะวิ่งเข้าสู่ 1 ใน 5 Pods ที่เราสร้างไว้อัตโนมัติ!

### 4.2 Cleanup (ทำความสะอาดเครื่อง)
อย่าลืมทำความสะอาด Resource เพื่อไม่ให้เปลือง Memory เครื่องครับ:
```bash
# กด Ctrl+C เพื่อหยุด Port-forward
# ลบ K8s Cluster
kind delete cluster --name gdgoc-local

# ลบ Docker Container 
docker rm -f my-first-container
```
🎉 ยินดีด้วย! คุณได้เห็นเส้นทางตั้งแต่การเขียน Code -> สวมแพ็กเกจด้วย Docker -> และสเกลมันบน Kubernetes แล้ว!