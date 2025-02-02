document.addEventListener("DOMContentLoaded", function () {
  const storage = typeof browser !== "undefined" ? browser.storage.sync : chrome.storage.sync;

  // Default values.
  const toggleLineNumbersSetting = document.getElementById("toggleLineNumbers");

  storage.get("toggleLineNumbers", function (data) {
    toggleLineNumbersSetting.checked = data.toggleLineNumbers ?? false;
  });

  // Update storage when the toggle is changed.
  toggleLineNumbersSetting.addEventListener("change", function () {
    storage.set({ toggleLineNumbers: toggleLineNumbersSetting.checked }, function () {
      console.log("Setting saved:", toggleLineNumbersSetting.checked);
    });
  });
});
