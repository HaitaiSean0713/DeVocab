--- web/check_webview.js
+++ web/check_webview.js
@@ -60,11 +60,13 @@
     copyBtn.style.boxShadow = '0 4px 6px rgba(0,0,0,0.3)';

     copyBtn.onclick = function() {
-      navigator.clipboard.writeText(window.location.href).then(function() {
+      var copyUrl = window.location.origin + '/DeVocab/';
+      navigator.clipboard.writeText(copyUrl).then(function() {
         copyBtn.innerText = '已複製！請貼上至 Chrome 或 Safari';
         copyBtn.style.backgroundColor = '#34A853';
       }).catch(function(err) {
         // Fallback for clipboard
         var dummy = document.createElement('input');
         document.body.appendChild(dummy);
-        dummy.value = window.location.href;
+        dummy.value = copyUrl;
         dummy.select();
