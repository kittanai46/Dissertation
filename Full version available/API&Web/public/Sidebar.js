document.addEventListener("DOMContentLoaded", function() {
  console.log("Sidebar.js loaded");

  // ปุ่ม toggle สำหรับขยาย/ย่อ sidebar
  const hamBurger = document.querySelector(".toggle-btn");
  const sidebar = document.querySelector("#sidebar");

  hamBurger.addEventListener("click", function () {
      console.log("Toggle button clicked");
      sidebar.classList.toggle("expand");
  });

  // ตรวจสอบการทำงานของลิงก์ใน sidebar ที่มี href="#"
  document.querySelectorAll('a[href="javascript:void(0);"]').forEach(anchor => {
      anchor.addEventListener('click', function(e) {
          e.preventDefault(); // ป้องกันการ reload หน้า
      });
  });

  // จัดการ collapse ของเมนู "เอกสารการลา"
  var myCollapse = document.getElementById('auth');
  var bsCollapse = new bootstrap.Collapse(myCollapse, {
      toggle: false
  });

  document.querySelector('.sidebar-link[data-bs-target="#auth"]').addEventListener('click', function () {
      bsCollapse.toggle();  // สลับการเปิด/ปิดของเมนู
  });
});
