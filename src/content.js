var Convert = require('ansi-to-html');
var convert = new Convert();

(function() {
    // Ensure we're modifying a plain text file view.
    if (document.contentType !== "text/plain") {
        return;
    }

    // Capture the raw text content
    let preElement = document.body.firstChild;

    // Ensure it's a <pre> tag (how Firefox renders .txt files).
    if (!preElement || preElement.tagName !== "PRE") {
        return;
    }

    // Create a flex container for line numbers + content.
    let container = document.createElement("div");
    container.style.fontFamily = "monospace";
    container.style.display = "flex";
    container.style.alignItems = "flex-start";
    container.style.whiteSpace = "pre"; // Prevents breaking of numbers and text.
    container.style.width = "fit-content"; // Ensures content fits properly.

    // Create the line numbers column and prevent selection.
    let line_numbers = document.createElement("div");
    line_numbers.style.textAlign = "right";
    line_numbers.style.paddingRight = "10px";
    line_numbers.style.userSelect = "none"; // Prevent selection of line numbers.

    // Create the content column.
    let content = document.createElement("div");
    content.style.textAlign = "left";

    // Add line numbers and text line by line.
    let rendered_lines = convert.toHtml(preElement.textContent).split(/\n/,);
    rendered_lines.forEach((line, index) => {
        let lineNumber = document.createElement("div");
        lineNumber.textContent = index + 1;
        line_numbers.appendChild(lineNumber);

        let line_content = document.createElement("div");
        line_content.innerHTML = line || " "; // Preserve empty lines.
        content.appendChild(line_content);
    });

    // Replace the original content.
    document.body.innerHTML = "";
    container.appendChild(line_numbers);
    container.appendChild(content);
    document.body.appendChild(container);

    // Handle extension settings.
    const storage = typeof browser !== "undefined" ? browser.storage.sync : chrome.storage.sync;

    storage.get("toggleLineNumbers", function (data) {
        line_numbers.style.display = data.showDiv ? "block" : "none";
    });

    storage.onChanged.addListener(function (changes, namespace) {
        if (changes.toggleLineNumbers) {
            line_numbers.style.display = changes.toggleLineNumbers.newValue ? "block" : "none";
        }
    });
})();
