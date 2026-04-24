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