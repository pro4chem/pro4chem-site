(function() {
  function escapeHtml(value) {
    return String(value || "").replace(/[&<>"']/g, function(char) {
      return {
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': "&quot;",
        "'": "&#39;"
      }[char];
    });
  }

  function initSearch(root) {
    var input = document.getElementById("siteSearchInput");
    var results = document.getElementById("siteSearchResults");
    var buttons = Array.prototype.slice.call(document.querySelectorAll("[data-search-category]"));
    var entries = [];
    var category = "All";

    if (!input || !results) return;

    function render() {
      var q = (input.value || "").trim().toLowerCase();
      var matched = entries.filter(function(entry) {
        var inCategory = category === "All" || entry.category === category;
        var haystack = [
          entry.title,
          entry.navLabel,
          entry.category,
          (entry.tags || []).join(" "),
          entry.searchText && entry.searchText.en,
          entry.searchText && entry.searchText.es
        ].join(" ").toLowerCase();
        return inCategory && (!q || haystack.indexOf(q) !== -1);
      }).slice(0, 24);

      results.innerHTML = matched.map(function(entry) {
        return '<article class="search-result-card"><small>' + escapeHtml(entry.category) + '</small><h3><a href="' + escapeHtml(entry.url) + '">' + escapeHtml(entry.title) + '</a></h3><p>' + escapeHtml(entry.excerpt && entry.excerpt.en) + '</p></article>';
      }).join("") || '<p class="empty-note">No matching Pro4Chem pages found.</p>';
    }

    buttons.forEach(function(button) {
      button.addEventListener("click", function() {
        category = button.dataset.searchCategory || "All";
        buttons.forEach(function(item) {
          item.classList.toggle("active", item === button);
        });
        render();
      });
    });

    input.addEventListener("input", render);
    fetch(root.dataset.searchIndex).then(function(response) {
      return response.json();
    }).then(function(data) {
      entries = data.entries || [];
      render();
    }).catch(function() {
      results.innerHTML = '<p class="empty-note">Search index is not available yet.</p>';
    });
  }

  document.addEventListener("DOMContentLoaded", function() {
    var root = document.querySelector(".search-app");
    if (root) initSearch(root);
  });
})();
