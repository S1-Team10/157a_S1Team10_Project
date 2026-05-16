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
  const detailPhoto = document.querySelector("[data-detail-photo]");
  const detailName = document.querySelector("[data-detail-name]");
  const detailPrice = document.querySelector("[data-detail-price]");
  const detailDesc = document.querySelector("[data-detail-description]");
  const detailCurrentStock = document.querySelector("[data-detail-current-stock]");
  const detailSizes = document.querySelector("[data-detail-sizes]");
  const detailColors = document.querySelector("[data-detail-colors]");
  const detailStock = document.querySelector("[data-detail-stock]");
  const stockRangeGroup = document.querySelector("[data-stock-range-group]");
  const selectedSize = document.querySelector("[data-selected-size]");
  const selectedColor = document.querySelector("[data-selected-color]");
  const addToCartButton = document.querySelector("[data-add-to-cart]");

  const cartEmpty = document.querySelector("[data-cart-empty]");
  const cartList = document.querySelector("[data-cart-list]");
  const cartTotalRow = document.querySelector("[data-cart-total-row]");
  const cartTotal = document.querySelector("[data-cart-total]");
  const clearCartButton = document.querySelector("[data-cart-clear]");
  const placeOrderButton = document.querySelector("[data-place-order]");
  const discountCodeInput = document.querySelector("[data-discount-code]");
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
      return Array.isArray(saved)
        ? saved.map(item => ({
            ...item,
            quantity: Math.max(1, parseInt(item.quantity, 10) || 1),
            selectedSize: item.selectedSize || "",
            selectedColor: item.selectedColor || ""
          })).filter(item => item.selectedSize && item.selectedColor)
        : [];
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

  function optionList(value) {
    return String(value || "")
      .split(",")
      .map(part => part.trim())
      .filter(Boolean);
  }

  function renderChoice(select, values, placeholder) {
    select.innerHTML = "";

    const placeholderOption = document.createElement("option");
    placeholderOption.value = "";
    placeholderOption.textContent = placeholder;
    select.appendChild(placeholderOption);

    values.forEach(value => {
      const option = document.createElement("option");
      option.value = value;
      option.textContent = value;
      select.appendChild(option);
    });

    select.disabled = values.length === 0;
  }

  async function readJsonResponse(res) {
    const text = await res.text();
    try {
      return text ? JSON.parse(text) : {};
    } catch (err) {
      throw new Error(`Server returned a non-JSON response (${res.status}).`);
    }
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
    detailCurrentStock.textContent = `${item.currentStock ?? 0} available`;
    detailSizes.textContent = item.sizes || "See in-store for available sizes";
    detailColors.textContent = item.colors || "See in-store for available colors";
    renderChoice(selectedSize, optionList(item.sizes || item.size), "Choose a size");
    renderChoice(selectedColor, optionList(item.colors || item.color), "Choose a color");

    const canShowStockRange = item.minStock != null && item.maxStock != null;
    stockRangeGroup.hidden = !canShowStockRange;
    detailStock.textContent = canShowStockRange ? `Min ${item.minStock} - Max ${item.maxStock}` : "";

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
    const size = selectedSize.value;
    const color = selectedColor.value;
    if (!item || item.currentStock <= 0) {
      return;
    }

    if (!size || !color) {
      setOrderStatus("");
      setOrderError("Choose a size and color before adding this item.");
      return;
    }

    if (cartItems.some(cartItem => cartItem.itemId === item.itemId)) {
      setOrderStatus("");
      setOrderError("This item is already in your cart. Remove it first to choose a different size or color.");
      return;
    }

    cartItems.push({
      itemId: item.itemId,
      itemName: item.itemName,
      price: item.price,
      selectedSize: size,
      selectedColor: color,
      quantity: 1
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

  function updateCartQuantity(itemId, quantity) {
    const cartItem = cartItems.find(item => item.itemId === itemId);
    const catalogItem = allItems.find(item => item.itemId === itemId);
    if (!cartItem) return;

    const maxQuantity = catalogItem ? catalogItem.currentStock : 99;
    cartItem.quantity = Math.min(Math.max(1, quantity), Math.max(1, maxQuantity));
    saveCart();
    renderCart();
  }

  function clearCart() {
    cartItems = [];
    saveCart();
    renderCart();
    updateAddToCartButton();
  }

  function updateAddToCartButton() {
    if (!selectedId || !addToCartButton) return;
    const item = allItems.find(item => item.itemId === selectedId);
    const inCart = cartItems.some(cartItem => cartItem.itemId === selectedId);
    const outOfStock = item && item.currentStock <= 0;
    addToCartButton.disabled = inCart || outOfStock;
    addToCartButton.textContent = outOfStock ? "Out of Stock" : inCart ? "In Cart" : "Add to Cart";
  }

  function renderCart() {
    cartList.innerHTML = "";
    cartEmpty.hidden = cartItems.length > 0;
    cartTotalRow.hidden = cartItems.length === 0;
    clearCartButton.disabled = cartItems.length === 0;
    placeOrderButton.disabled = cartItems.length === 0;

    let total = 0;
    cartItems.forEach(item => {
      const catalogItem = allItems.find(catalogItem => catalogItem.itemId === item.itemId);
      const maxQuantity = catalogItem ? catalogItem.currentStock : Math.max(1, item.quantity);
      item.quantity = Math.min(Math.max(1, parseInt(item.quantity, 10) || 1), Math.max(1, maxQuantity));
      total += priceNumber(item.price) * item.quantity;
      const li = document.createElement("li");
      li.innerHTML = `
        <span>
          <span class="cart-item-name">${escapeHtml(item.itemName)}</span>
          <span class="cart-item-price">${formatPrice(item.price)} each</span>
          <span class="cart-item-options">${escapeHtml(item.selectedSize)} / ${escapeHtml(item.selectedColor)}</span>
        </span>
        <label class="cart-quantity">
          Qty
          <input type="number" min="1" max="${maxQuantity}" value="${item.quantity}" data-quantity-item="${item.itemId}">
        </label>
        <button class="cart-remove-button" type="button" data-remove-item="${item.itemId}">Remove</button>
      `;

      li.querySelector("[data-quantity-item]").addEventListener("change", e => {
        updateCartQuantity(item.itemId, parseInt(e.target.value, 10) || 1);
      });
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
    if (discountCodeInput.value.trim()) {
      body.append("discountCode", discountCodeInput.value.trim());
    }
    cartItems.forEach(item => {
      body.append("itemId", item.itemId);
      body.append("quantity", item.quantity);
      body.append("selectedSize", item.selectedSize);
      body.append("selectedColor", item.selectedColor);
    });

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

      const data = await readJsonResponse(res);
      if (!res.ok || data.error) {
        throw new Error(data.error || `Server error ${res.status}`);
      }

      clearCart();
      setOrderStatus(`Order #${data.orderId} placed. Total: ${formatPrice(data.totalAmount)}.`);
      await fetchItems(searchInput.value.trim());
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
      const data = await readJsonResponse(res);

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
  selectedSize.addEventListener("change", updateAddToCartButton);
  selectedColor.addEventListener("change", updateAddToCartButton);
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
