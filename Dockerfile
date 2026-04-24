# ใช้ Nginx web server ขนาดเล็ก (Alpine) เป็น Base Image
FROM nginx:alpine

# ก๊อปปี้ไฟล์โค้ดของเรา ไปวางทับหน้าเว็บเริ่มต้นของ Nginx
COPY index.html /usr/share/nginx/html/

# บอกว่า Container นี้จะให้บริการผ่าน Port 80
EXPOSE 80