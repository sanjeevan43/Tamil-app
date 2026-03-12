import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { getAuth } from "firebase/auth";
import { getStorage } from "firebase/storage";

const firebaseConfig = {
    apiKey: "AIzaSyDw-pCDEHyBs2lPnpVsLZXD1i6hh65L95k",
    appId: "1:356453132420:web:256c9c8127289bcc96bad1",
    messagingSenderId: "356453132420",
    projectId: "h3-tamil-app",
    authDomain: "h3-tamil-app.firebaseapp.com",
    storageBucket: "h3-tamil-app.firebasestorage.app",
    measurementId: "G-XFC0SQ0ZTJ"
};

const app = initializeApp(firebaseConfig);
export const db = getFirestore(app);
export const auth = getAuth(app);
export const storage = getStorage(app);
