document.addEventListener("DOMContentLoaded", function() {
  console.log("Sidebar.js loaded");

  const hamBurger = document.querySelector(".toggle-btn");
  const sidebar = document.querySelector("#sidebar");

  hamBurger.addEventListener("click", function () {
      console.log("Toggle button clicked");
      sidebar.classList.toggle("expand");
  });
});

