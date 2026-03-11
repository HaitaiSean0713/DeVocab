// Function to check if the user is in a webview (in-app browser)
function isInAppBrowser() {
  var ua = navigator.userAgent || navigator.vendor || window.opera;

  // Rules for popular in-app browsers
  var rules = [
    'WebView',
    'FBAV', // Facebook
    'FBAN', // Facebook
    'Instagram', // Instagram
    'Line', // LINE
    'MicroMessenger', // WeChat
    'Threads', // Threads
    '; wv', // Android WebView
    'GSA', // Google App
    'Twitter',
    'com.google.android.googlequicksearchbox'
  ];

  for (var i = 0; i < rules.length; i++) {
    if (ua.indexOf(rules[i]) > -1) {
      return true;
    }
  }

  // iOS WebView detection
  if (/(iPhone|iPod|iPad).*AppleWebKit(?!.*Safari)/i.test(ua)) {
    return true;
  }

  return false;
}

// Prompt the user to open in an external browser if inside an in-app browser
if (isInAppBrowser()) {
  document.addEventListener('DOMContentLoaded', function() {
    var overlay = document.createElement('div');
    overlay.style.position = 'fixed';
    overlay.style.top = '0';
    overlay.style.left = '0';
    overlay.style.width = '100%';
    overlay.style.height = '100%';
    overlay.style.backgroundColor = 'rgba(0,0,0,0.95)';
    overlay.style.color = 'white';
    overlay.style.display = 'flex';
    overlay.style.flexDirection = 'column';
    overlay.style.alignItems = 'center';
    overlay.style.justifyContent = 'center';
    overlay.style.zIndex = '999999';
    overlay.style.fontFamily = 'sans-serif';
    overlay.style.textAlign = 'center';
    overlay.style.padding = '20px';
    overlay.style.boxSizing = 'border-box';

    var icon = document.createElement('div');
    icon.innerHTML = '⚠️';
    icon.style.fontSize = '48px';
    icon.style.marginBottom = '20px';

    var title = document.createElement('h2');
    title.innerText = '請使用系統瀏覽器開啟';
    title.style.marginBottom = '16px';
    title.style.lineHeight = '1.4';

    var text = document.createElement('p');
    text.innerText = '您目前的瀏覽器 (如 LINE, IG, FB, Threads 內建) 不支援 Google 登入。\n請點選右上角或右下角的選單：\n選擇「在預設瀏覽器中開啟」或「在 Chrome / Safari 中開啟」';
    text.style.lineHeight = '1.6';
    text.style.fontSize = '16px';
    text.style.color = '#e0e0e0';
    text.style.marginBottom = '40px';
    text.style.maxWidth = '400px';

    var btnContainer = document.createElement('div');
    var copyBtn = document.createElement('button');
    copyBtn.innerText = '複製網址';
    copyBtn.style.padding = '14px 28px';
    copyBtn.style.fontSize = '16px';
    copyBtn.style.fontWeight = 'bold';
    copyBtn.style.backgroundColor = '#4285F4';
    copyBtn.style.color = 'white';
    copyBtn.style.border = 'none';
    copyBtn.style.borderRadius = '28px';
    copyBtn.style.cursor = 'pointer';
    copyBtn.style.boxShadow = '0 4px 6px rgba(0,0,0,0.3)';

    copyBtn.onclick = function() {
      navigator.clipboard.writeText(window.location.origin + '/DeVocab/').then(function() {
        copyBtn.innerText = '已複製！請貼上至 Chrome 或 Safari';
        copyBtn.style.backgroundColor = '#34A853';
      }).catch(function(err) {
        // Fallback for clipboard
        var dummy = document.createElement('input');
        document.body.appendChild(dummy);
        dummy.value = window.location.origin + '/DeVocab/';
        dummy.select();
        document.execCommand('copy');
        document.body.removeChild(dummy);
        copyBtn.innerText = '已複製！請貼上至 Chrome 或 Safari';
        copyBtn.style.backgroundColor = '#34A853';
      });
    };

    btnContainer.appendChild(copyBtn);

    overlay.appendChild(icon);
    overlay.appendChild(title);
    overlay.appendChild(text);
    overlay.appendChild(btnContainer);

    document.body.appendChild(overlay);
  });
}
