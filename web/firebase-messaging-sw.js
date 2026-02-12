importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyBR-iVzjUqDtg3BUSMqQfIwn0qReaRrKBY",
    appId: "1:285253284489:web:458ec93ef1f70bbeb28c58",
    messagingSenderId: "285253284489",
    projectId: "hompimpapos",
    authDomain: "hompimpapos.firebaseapp.com",
    storageBucket: "hompimpapos.firebasestorage.app",
    measurementId: "G-CQBXSZ278H"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);
    // Customize notification here
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: '/icons/Icon-192.png'
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});
