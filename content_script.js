var Convert = require('ansi-to-html');
var convert = new Convert();

(function() {
    // Ensure we're modifying a plain text file view
    if (document.contentType !== "text/plain") {
        return;
    }

    // Capture the raw text content
    let preElement = document.body.firstChild;

    // Ensure it's a <pre> tag (how Firefox renders .txt files)
    if (!preElement || preElement.tagName !== "PRE") {
        return;
    }

    let textContent = preElement.textContent;
    let ansi_html = convert.toHtml(textContent);
    ansi_html = ansi_html.replace(/\n/g, '<br>'); // Preserve newlines

    document.body.innerHTML = ansi_html;

    document.body.style.fontFamily = "monospace";
    document.body.style.whiteSpace = "pre-wrap";
    document.body.style.wordBreak = "break-word";
    document.body.style.overflowWrap = "break-word";
})();
