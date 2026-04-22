(() => {
  // ── DOM refs ──────────────────────────────────────────────────────────────
  const form        = document.querySelector("[data-catalog-form]");
  const searchInput = document.querySelector("[data-search-input]");
  const page        = document.querySelector("[data-catalog-page]");
  const statusEl    = document.querySelector("[data-results-status]");
  const errorEl     = document.querySelector("[data-results-error]");
  const table       = document.querySelector("[data-results-table]");
  const tbody       = document.querySelector("[data-results-body]");

  const detailPanel     = document.querySelector("[data-item-detail]");
  const detailEmpty     = document.querySelector("[data-item-detail-empty]");
  const detailCard      = document.querySelector("[data-item-detail-card]");
  const detailId        = document.querySelector("[data-detail-id]");
  const detailName      = document.querySelector("[data-detail-name]");
  const detailPrice     = document.querySelector("[data-detail-price]");
  const detailDesc      = document.querySelector("[data-detail-description]");
  const detailSizes     = document.querySelector("[data-detail-sizes]");
  const detailColors    = document.querySelector("[data-detail-colors]");
  const detailStock     = document.querySelector("[data-detail-stock]");

  // ── State ─────────────────────────────────────────────────────────────────
  const apiUrl = form.dataset.apiUrl;
  let allItems = [];
  let sortCol  = null;   // "itemId" | "itemName" | "description" | "price"
  let sortDir  = "asc";  // "asc" | "desc"
  let selectedId = parseInt(page.dataset.selectedItemId, 10) || null;

  // ── Helpers ───────────────────────────────────────────────────────────────
  function setStatus(msg) {
    statusEl.textContent = msg;
    statusEl.hidden = !msg;
  }

  function setError(msg) {
    errorEl.textContent = msg;
    errorEl.hidden = !msg;
  }

  function formatPrice(raw) {
    const n = parseFloat(raw);
    return isNaN(n) ? raw : "$" + n.toFixed(2);
  }

  // ── Sorting ───────────────────────────────────────────────────────────────
  function sortedItems() {
    if (!sortCol) return allItems;
    return [...allItems].sort((a, b) => {
      let av = a[sortCol];
      let bv = b[sortCol];
      // numeric sort for itemId / price
      if (sortCol === "itemId" || sortCol === "price") {
        av = parseFloat(av);
        bv = parseFloat(bv);
      } else {
        av = (av || "").toLowerCase();
        bv = (bv || "").toLowerCase();
      }
      if (av < bv) return sortDir === "asc" ? -1 : 1;
      if (av > bv) return sortDir === "asc" ?  1 : -1;
      return 0;
    });
  }

  function setSortButtons() {
    document.querySelectorAll(".sort-button").forEach(btn => {
      if (btn.dataset.col === sortCol) {
        btn.dataset.sortDirection = sortDir;
      } else {
        delete btn.dataset.sortDirection;
      }
    });
  }

  // ── Render table ──────────────────────────────────────────────────────────
  function renderTable() {
    const items = sortedItems();
    tbody.innerHTML = "";

    if (!items.length) {
      table.hidden = true;
      setStatus("No items matched your search.");
      return;
    }

    items.forEach(item => {
      const tr = document.createElement("tr");
      if (item.itemId === selectedId) tr.classList.add("is-selected");

      tr.innerHTML = `
        <td>${item.itemId}</td>
        <td>
          <button class="product-link" type="button" data-item-id="${item.itemId}">
            ${escapeHtml(item.itemName)}
          </button>
        </td>
        <td>${escapeHtml(item.description)}</td>
        <td class="price">${formatPrice(item.price)}</td>
      `;

      tr.querySelector(".product-link").addEventListener("click", () => {
        selectItem(item.itemId);
      });

      tbody.appendChild(tr);
    });

    table.hidden = false;
    setStatus("");
  }

  // Basic HTML escaping on the client side for safety
  function escapeHtml(str) {
    if (str == null) return "";
    return str
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  // ── Detail panel ──────────────────────────────────────────────────────────
  function selectItem(id) {
    selectedId = id;

    // Highlight row
    document.querySelectorAll("[data-results-body] tr").forEach(tr => {
      tr.classList.toggle(
        "is-selected",
        tr.querySelector("[data-item-id]")?.dataset.itemId == id
      );
    });

    // Update URL param without reloading
    const url = new URL(window.location);
    url.searchParams.set("itemId", id);
    history.replaceState(null, "", url);

    const item = allItems.find(i => i.itemId === id);
    if (!item) return;

    detailId.textContent   = `Item #${item.itemId}`;
    detailName.textContent = item.itemName || "—";
    detailPrice.textContent = formatPrice(item.price);
    detailDesc.textContent  = item.description || "No description available.";

    // sizes/colors are not in the Item model — show a friendly placeholder
    detailSizes.textContent  = "See in-store for available sizes";
    detailColors.textContent = "See in-store for available colors";
    detailStock.textContent  =
      `Min ${item.minStock} — Max ${item.maxStock}`;

    detailEmpty.hidden = true;
    detailCard.hidden  = false;
  }

  function clearDetail() {
    selectedId = null;
    detailEmpty.hidden = false;
    detailCard.hidden  = true;
    const url = new URL(window.location);
    url.searchParams.delete("itemId");
    history.replaceState(null, "", url);
  }

  // ── Fetch ─────────────────────────────────────────────────────────────────
  async function fetchItems(query) {
    setError("");
    setStatus("Loading products…");
    table.hidden = true;
    form.classList.add("is-loading");

    const params = new URLSearchParams({ q: query });

    try {
      const res  = await fetch(`${apiUrl}?${params}`);
      const data = await res.json();

      if (!res.ok || data.error) {
        throw new Error(data.error || `Server error ${res.status}`);
      }

      allItems = data.items || [];
      renderTable();

      // Restore selected item from URL param if still in results
      if (selectedId && allItems.find(i => i.itemId === selectedId)) {
        selectItem(selectedId);
      } else {
        clearDetail();
      }

    } catch (err) {
      allItems = [];
      table.hidden = true;
      setStatus("");
      setError(`Could not load results: ${err.message}`);
    } finally {
      form.classList.remove("is-loading");
    }
  }

  // ── Sort button wiring ────────────────────────────────────────────────────
  function buildSortableHeaders() {
    const cols = [
      { label: "Item ID",     col: "itemId"      },
      { label: "Product",     col: "itemName"     },
      { label: "Description", col: "description"  },
      { label: "Price",       col: "price"        },
    ];

    const ths = table.querySelectorAll("thead th");
    ths.forEach((th, i) => {
      if (!cols[i]) return;
      const { label, col } = cols[i];
      th.innerHTML = `
        <button class="sort-button" type="button" data-col="${col}">
          ${label}
        </button>
      `;
      th.querySelector(".sort-button").addEventListener("click", () => {
        if (sortCol === col) {
          sortDir = sortDir === "asc" ? "desc" : "asc";
        } else {
          sortCol = col;
          sortDir = "asc";
        }
        setSortButtons();
        renderTable();
      });
    });
  }

  // ── Form submit ───────────────────────────────────────────────────────────
  form.addEventListener("submit", e => {
    e.preventDefault();
    const q = searchInput.value.trim();

    // Sync URL so the page is bookmarkable
    const url = new URL(window.location);
    url.searchParams.set("q", q);
    if (selectedId) url.searchParams.set("itemId", selectedId);
    history.pushState(null, "", url);

    fetchItems(q);
  });

  // ── Init ──────────────────────────────────────────────────────────────────
  // Hide error element on load (it has no hidden attr in the JSP)
  errorEl.hidden = true;

  buildSortableHeaders();

  // Run an initial search using whatever q= is already in the URL
  fetchItems(searchInput.value.trim());
})();