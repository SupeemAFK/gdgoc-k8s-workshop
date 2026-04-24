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

## 🚢 Part 3: Deploy & Access the App (25 นาที)

เราจะย้ายแอปพลิเคชันจาก Docker ธรรมดา ขึ้นมาอยู่บน Kubernetes และเปิดช่องทางให้เครื่องเราเข้าถึงได้

### 3.1 โหลด Image เข้าสู่ K8s Cluster
เนื่องจาก KIND รันอยู่ในพื้นที่ปิด มันจึงไม่เห็น `my-app:v1` ที่เราเพิ่งสร้าง เราต้องโหลดเข้าไปใน Cluster ก่อน:

```bash
kind load docker-image my-app:v1 --name gdgoc-local
```

### 3.2 สร้าง Deployment (สั่งให้ K8s ดูแลแอป)
สร้างไฟล์ชื่อ `deployment.yaml` เพื่ออธิบายว่าเราต้องการรันแอปหน้าตาแบบไหนและจำนวนเท่าไหร่:
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
ดู pods
```bash
kubectl get pods
```

### 3.3 เปิดช่องทางเข้าถึง (Port Forward)
แอปพลิเคชันเรารันอยู่บน K8s แล้ว 2 ตัว แต่ยังอยู่ภายในเครือข่ายจำลอง เราจะเปิดอุโมงค์เชื่อมต่อ (เหมาะสำหรับ Dev/Test local):
```bash
kubectl port-forward deployment/web-deployment 8000:80
```
👉 **ทดสอบ:** เปิด Web Browser ไปที่ `http://localhost:8000` (ปล่อย Terminal นี้รันค้างไว้)

## 🚀 Part 4: Day 2 Operations - Scaling & Zero-Downtime Update (40 นาที)

*(⚠️ คำแนะนำ: ให้เปิด Terminal หน้าต่างใหม่ สำหรับรันคำสั่งในส่วนนี้ เพื่อไม่ให้กระทบกับ Port-forward ที่รันค้างไว้)*

นี่คือเวทมนตร์ของ Kubernetes! เราจะมาจัดการแอปพลิเคชันของเราเมื่อมีคนใช้งานเยอะขึ้น และเมื่อเราต้องการอัปเดตเวอร์ชันใหม่

### 4.1 Horizontal Scaling (การสเกลแนวนอน)
สมมติว่ามี Traffic เข้าเว็บเรามหาศาล เราต้องการเพิ่มเครื่องด่วน! เราสามารถสั่ง Scale ได้ทันที:
```bash
kubectl scale deployment web-deployment --replicas=5
```
ดูผลลัพธ์การสร้าง Pods ใหม่แบบสดๆ (กด Ctrl+C เพื่อออกจากการ watch)
```bash
kubectl get pods -w
```
Traffic ของคุณตอนนี้กำลังวิ่งกระจายเข้าสู่ 1 ใน 5 Pods ที่เราสร้างไว้อัตโนมัติ!

### 4.2 เตรียมแอปพลิเคชันเวอร์ชัน 2 (v2)
สมมติว่าทีม Dev ต้องการเปลี่ยนข้อความบนหน้าเว็บ เราจะเริ่มจากกลับไปแก้ Code และสร้าง Image ตัวใหม่:

1. แก้ไขไฟล์ index.html
```bash
echo "<h1>Hello GDGOC! Welcome to Version 2 🚀🔥</h1>" > index.html
```
2. Build Docker Image เวอร์ชันใหม่ (สังเกต Tag เป็น :v2)
```bash
docker build -t my-app:v2 .
```
3. โหลด Image v2 เข้าสู่ KIND Cluster
```bash
kind load docker-image my-app:v2 --name gdgoc-local
```

### 4.3 Rolling Update (อัปเดตแบบไร้รอยต่อ)
เราจะสั่งให้ K8s อัปเดตแอปจาก v1 เป็น v2 K8s จะใช้เทคนิค **Rolling Update** คือค่อยๆ ปิด v1 ทีละตัว และสร้าง v2 ขึ้นมาแทนที่ ทำให้เว็บไม่ล่มเลย (Zero Downtime)

สั่งเปลี่ยน Image ใน Deployment เป็น v2
```bash
kubectl set image deployment/web-deployment my-web-app=my-app:v2
```

ดูสถานะการอัปเดต
```bash
kubectl rollout status deployment/web-deployment
```

👉 **ทดสอบ:** กลับไปที่ Browser (`http://localhost:8000`) แล้วกด Refresh คุณจะเห็นข้อความเปลี่ยนเป็น Version 2!

### 4.4 Rollback (ถอยร่นเมื่อเกิดข้อผิดพลาด)
ถ้าแอปเวอร์ชัน 2 มีบั๊ก เราสามารถย้อนกลับ (Rollback) ไปเวอร์ชันก่อนหน้าได้อย่างรวดเร็วในคำสั่งเดียว:

สั่ง Rollback กลับไปเวอร์ชันก่อนหน้า
```bash
kubectl rollout undo deployment/web-deployment
```
ดูสถานะการย้อนกลับ
```bash
kubectl rollout status deployment/web-deployment
```
👉 **ทดสอบ:** กลับไป Refresh หน้าเว็บอีกครั้ง ทุกอย่างจะกลับมาเป็นเวอร์ชันแรกสุดอย่างปลอดภัย!

## 🧹 Part 5: Cleanup & Wrap-up (10 นาที)

อย่าลืมทำความสะอาด Resource เพื่อไม่ให้เปลือง Memory เครื่องครับ:

1. กลับไปที่ Terminal ที่รัน Port-forward ค้างไว้ แล้วกด Ctrl+C
2. ลบ K8s Cluster
```bash
kind delete cluster --name gdgoc-local
```
3. ลบ Docker Container 
```bash
docker rm -f my-first-container
```
🎉 **ยินดีด้วย!** คุณได้เห็นเส้นทางตั้งแต่ Day 0 (การเขียน Code) -> สวมแพ็กเกจด้วย Docker -> และสเกลมันรวมถึงการทำ Day 2 Operations บน Kubernetes แล้ว!