<script type="module">
  // Import the functions you need from the SDKs you need
  import { initializeApp } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-app.js";
  import { getAnalytics } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-analytics.js";
  // TODO: Add SDKs for Firebase products that you want to use
  // https://firebase.google.com/docs/web/setup#available-libraries

  // Your web app's Firebase configuration
  // For Firebase JS SDK v7.20.0 and later, measurementId is optional
  const firebaseConfig = {
    apiKey: "AIzaSyDjPzm5mrZDtgBXATpt22GEeR4fZQBhDCc",
    authDomain: "bollingerblast-f59a6.firebaseapp.com",
    projectId: "bollingerblast-f59a6",
    storageBucket: "bollingerblast-f59a6.appspot.com",
    messagingSenderId: "1095191925119",
    appId: "1:1095191925119:web:66f98e59e25b3b75e28a4a",
    measurementId: "G-87YH5V55EL"
  };

  // Initialize Firebase
  const app = initializeApp(firebaseConfig);
  const analytics = getAnalytics(app);
</script>