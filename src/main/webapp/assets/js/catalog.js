(() => {
  const form = document.querySelector("[data-catalog-form]");
  const searchInput = document.querySelector("[data-search-input]");
  const page = document.querySelector("[data-catalog-page]");
  const statusEl = document.querySelector("[data-results-status]");
  const errorEl = document.querySelector("[data-results-error]");
  const table = document.querySelector("[data-results-table]");
  const tbody = document.querySelector("[data-results-body]");

  const detailEmpty = document.querySelector("[data-item-detail-empty]");
  const detailCard = document.querySelector("[data-item-detail-card]");
  const detailId = document.querySelector("[data-detail-id]");
  const detailName = document.querySelector("[data-detail-name]");
  const detailPrice = document.querySelector("[data-detail-price]");
  const detailDesc = document.querySelector("[data-detail-description]");
  const detailSizes = document.querySelector("[data-detail-sizes]");
  const detailColors = document.querySelector("[data-detail-colors]");
  const detailStock = document.querySelector("[data-detail-stock]");
  const addToCartButton = document.querySelector("[data-add-to-cart]");

  const cartEmpty = document.querySelector("[data-cart-empty]");
  const cartList = document.querySelector("[data-cart-list]");
  const cartTotalRow = document.querySelector("[data-cart-total-row]");
  const cartTotal = document.querySelector("[data-cart-total]");
  const clearCartButton = document.querySelector("[data-cart-clear]");
  const placeOrderButton = document.querySelector("[data-place-order]");
  const orderStatus = document.querySelector("[data-order-status]");
  const orderError = document.querySelector("[data-order-error]");

  const apiUrl = form.dataset.apiUrl;
  const orderUrl = page.dataset.orderUrl;
  const loginUrl = page.dataset.loginUrl;
  const cartStorageKey = "threadlink.cart";

  let allItems = [];
  let cartItems = loadCart();
  let sortCol = null;
  let sortDir = "asc";
  let selectedId = parseInt(page.dataset.selectedItemId, 10) || null;

  function setStatus(msg) {
    statusEl.textContent = msg;
    statusEl.hidden = !msg;
  }

  function setError(msg) {
    errorEl.textContent = msg;
    errorEl.hidden = !msg;
  }

  function setOrderStatus(msg) {
    orderStatus.textContent = msg;
    orderStatus.hidden = !msg;
  }

  function setOrderError(msg) {
    orderError.textContent = msg;
    orderError.hidden = !msg;
  }

  function formatPrice(raw) {
    const n = parseFloat(raw);
    return isNaN(n) ? raw : "$" + n.toFixed(2);
  }

  function priceNumber(raw) {
    const n = parseFloat(raw);
    return isNaN(n) ? 0 : n;
  }

  function escapeHtml(str) {
    if (str == null) return "";
    return String(str)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function loadCart() {
    try {
      const saved = JSON.parse(localStorage.getItem(cartStorageKey) || "[]");
      return Array.isArray(saved) ? saved : [];
    } catch (err) {
      return [];
    }
  }

  function saveCart() {
    localStorage.setItem(cartStorageKey, JSON.stringify(cartItems));
  }

  function sortedItems() {
    if (!sortCol) return allItems;
    return [...allItems].sort((a, b) => {
      let av = a[sortCol];
      let bv = b[sortCol];

      if (sortCol === "itemId" || sortCol === "price") {
        av = parseFloat(av);
        bv = parseFloat(bv);
      } else {
        av = (av || "").toLowerCase();
        bv = (bv || "").toLowerCase();
      }

      if (av < bv) return sortDir === "asc" ? -1 : 1;
      if (av > bv) return sortDir === "asc" ? 1 : -1;
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

  function selectItem(id) {
    selectedId = id;

    document.querySelectorAll("[data-results-body] tr").forEach(tr => {
      tr.classList.toggle(
        "is-selected",
        tr.querySelector("[data-item-id]")?.dataset.itemId == id
      );
    });

    const url = new URL(window.location);
    url.searchParams.set("itemId", id);
    history.replaceState(null, "", url);

    const item = allItems.find(i => i.itemId === id);
    if (!item) return;

    detailId.textContent = `Item #${item.itemId}`;
    detailName.textContent = item.itemName || "-";
    detailPrice.textContent = formatPrice(item.price);
    detailDesc.textContent = item.description || "No description available.";
    detailSizes.textContent = "See in-store for available sizes";
    detailColors.textContent = "See in-store for available colors";
    detailStock.textContent = `Min ${item.minStock} - Max ${item.maxStock}`;

    detailEmpty.hidden = true;
    detailCard.hidden = false;
    updateAddToCartButton();
  }

  function clearDetail() {
    selectedId = null;
    detailEmpty.hidden = false;
    detailCard.hidden = true;
    const url = new URL(window.location);
    url.searchParams.delete("itemId");
    history.replaceState(null, "", url);
  }

  function addSelectedItemToCart() {
    const item = allItems.find(i => i.itemId === selectedId);
    if (!item || cartItems.some(cartItem => cartItem.itemId === item.itemId)) {
      return;
    }

    cartItems.push({
      itemId: item.itemId,
      itemName: item.itemName,
      price: item.price
    });
    saveCart();
    renderCart();
    updateAddToCartButton();
    setOrderStatus(`${item.itemName} added to your cart.`);
    setOrderError("");
  }

  function removeCartItem(itemId) {
    cartItems = cartItems.filter(item => item.itemId !== itemId);
    saveCart();
    renderCart();
    updateAddToCartButton();
  }

  function clearCart() {
    cartItems = [];
    saveCart();
    renderCart();
    updateAddToCartButton();
  }

  function updateAddToCartButton() {
    if (!selectedId || !addToCartButton) return;
    const inCart = cartItems.some(item => item.itemId === selectedId);
    addToCartButton.disabled = inCart;
    addToCartButton.textContent = inCart ? "In Cart" : "Add to Cart";
  }

  function renderCart() {
    cartList.innerHTML = "";
    cartEmpty.hidden = cartItems.length > 0;
    cartTotalRow.hidden = cartItems.length === 0;
    clearCartButton.disabled = cartItems.length === 0;
    placeOrderButton.disabled = cartItems.length === 0;

    let total = 0;
    cartItems.forEach(item => {
      total += priceNumber(item.price);
      const li = document.createElement("li");
      li.innerHTML = `
        <span>
          <span class="cart-item-name">${escapeHtml(item.itemName)}</span>
          <span class="cart-item-price">${formatPrice(item.price)}</span>
        </span>
        <button class="cart-remove-button" type="button" data-remove-item="${item.itemId}">Remove</button>
      `;

      li.querySelector("[data-remove-item]").addEventListener("click", () => {
        removeCartItem(item.itemId);
      });
      cartList.appendChild(li);
    });

    cartTotal.textContent = formatPrice(total);
  }

  async function placeOrder() {
    if (!cartItems.length) return;

    setOrderStatus("Placing your order...");
    setOrderError("");
    placeOrderButton.disabled = true;

    const body = new URLSearchParams();
    cartItems.forEach(item => body.append("itemId", item.itemId));

    try {
      const res = await fetch(orderUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"
        },
        body
      });

      if (res.redirected) {
        throw new Error(`Please log in before placing an order: ${loginUrl}`);
      }

      const data = await res.json();
      if (!res.ok || data.error) {
        throw new Error(data.error || `Server error ${res.status}`);
      }

      clearCart();
      setOrderStatus(`Order #${data.orderId} placed. Total: ${formatPrice(data.totalAmount)}.`);
    } catch (err) {
      setOrderStatus("");
      setOrderError(err.message);
    } finally {
      renderCart();
    }
  }

  async function fetchItems(query) {
    setError("");
    setStatus("Loading products...");
    table.hidden = true;
    form.classList.add("is-loading");

    const params = new URLSearchParams({ q: query });

    try {
      const res = await fetch(`${apiUrl}?${params}`);
      const data = await res.json();

      if (!res.ok || data.error) {
        throw new Error(data.error || `Server error ${res.status}`);
      }

      allItems = data.items || [];
      renderTable();

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

  function buildSortableHeaders() {
    const cols = [
      { label: "Item ID", col: "itemId" },
      { label: "Product", col: "itemName" },
      { label: "Description", col: "description" },
      { label: "Price", col: "price" }
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

  form.addEventListener("submit", e => {
    e.preventDefault();
    const q = searchInput.value.trim();

    const url = new URL(window.location);
    url.searchParams.set("q", q);
    if (selectedId) url.searchParams.set("itemId", selectedId);
    history.pushState(null, "", url);

    fetchItems(q);
  });

  addToCartButton.addEventListener("click", addSelectedItemToCart);
  clearCartButton.addEventListener("click", () => {
    clearCart();
    setOrderStatus("");
    setOrderError("");
  });
  placeOrderButton.addEventListener("click", placeOrder);

  errorEl.hidden = true;
  orderStatus.hidden = true;
  orderError.hidden = true;

  buildSortableHeaders();
  renderCart();
  fetchItems(searchInput.value.trim());
})();
