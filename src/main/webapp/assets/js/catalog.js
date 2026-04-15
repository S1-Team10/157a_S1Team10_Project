(function () {
  var page = document.querySelector("[data-catalog-page]");
  var form = document.querySelector("[data-catalog-form]");
  var input = document.querySelector("[data-search-input]");
  var status = document.querySelector("[data-results-status]");
  var error = document.querySelector("[data-results-error]");
  var table = document.querySelector("[data-results-table]");
  var tableBody = document.querySelector("[data-results-body]");
  var detailEmpty = document.querySelector("[data-item-detail-empty]");
  var detailCard = document.querySelector("[data-item-detail-card]");
  var detailId = document.querySelector("[data-detail-id]");
  var detailName = document.querySelector("[data-detail-name]");
  var detailPrice = document.querySelector("[data-detail-price]");
  var detailDescription = document.querySelector("[data-detail-description]");
  var detailSizes = document.querySelector("[data-detail-sizes]");
  var detailColors = document.querySelector("[data-detail-colors]");
  var detailStock = document.querySelector("[data-detail-stock]");

  if (!page || !form || !input || !status || !error || !table || !tableBody) {
    return;
  }

  var apiUrl = form.getAttribute("data-api-url");
  var initialSelectedItemId = Number(page.getAttribute("data-selected-item-id"));
  var state = {
    items: [],
    selectedItemId: Number.isNaN(initialSelectedItemId) ? null : initialSelectedItemId
  };

  form.addEventListener("submit", function (event) {
    event.preventDefault();
    state.selectedItemId = null;
    fetchResults(input.value.trim());
  });

  tableBody.addEventListener("click", function (event) {
    var itemButton = event.target.closest("[data-item-select]");
    if (!itemButton) {
      return;
    }

    var itemId = Number(itemButton.getAttribute("data-item-select"));
    selectItem(itemId, true);
  });

  fetchResults(input.value.trim(), false);

  function fetchResults(query, pushHistory) {
    setLoadingState(true);
    clearMessages();

    var shouldPushHistory = pushHistory !== false;
    var requestUrl = apiUrl + "?q=" + encodeURIComponent(query);

    fetch(requestUrl, {
      headers: {
        Accept: "application/json"
      }
    })
      .then(function (response) {
        return response.json().then(function (data) {
          return {
            ok: response.ok,
            data: data
          };
        });
      })
      .then(function (result) {
        if (!result.ok) {
          throw new Error(result.data.error || "Unable to load products right now.");
        }

        state.items = Array.isArray(result.data.items) ? result.data.items : [];

        if (state.selectedItemId !== null && !findItemById(state.selectedItemId)) {
          state.selectedItemId = null;
        }

        renderResults();
        renderDetail();

        if (shouldPushHistory) {
          updateQueryString(query, state.selectedItemId);
        }
      })
      .catch(function (fetchError) {
        table.hidden = true;
        clearDetail();
        status.textContent = "";
        error.textContent = fetchError.message;
      })
      .finally(function () {
        setLoadingState(false);
      });
  }

  function renderResults() {
    tableBody.innerHTML = "";

    if (!state.items.length) {
      table.hidden = true;
      status.textContent = 'No items matched "' + input.value.trim() + '".';
      return;
    }

    table.hidden = false;
    status.textContent = "Found " + state.items.length + " item(s). Click a product name to view stock details.";

    state.items.forEach(function (item) {
      var row = document.createElement("tr");
      if (item.itemId === state.selectedItemId) {
        row.className = "is-selected";
      }

      row.innerHTML =
        "<td>" + escapeHtml(String(item.itemId)) + "</td>" +
        "<td><button class=\"product-link\" type=\"button\" data-item-select=\"" + escapeHtml(String(item.itemId)) + "\"><strong>" +
        escapeHtml(item.itemName) +
        "</strong></button></td>" +
        "<td>" + escapeHtml(item.description) + "</td>" +
        "<td class=\"price\">$" + escapeHtml(String(item.price)) + "</td>";

      tableBody.appendChild(row);
    });
  }

  function selectItem(itemId, pushHistory) {
    state.selectedItemId = itemId;
    renderResults();
    renderDetail();

    if (pushHistory !== false) {
      updateQueryString(input.value.trim(), itemId);
    }
  }

  function renderDetail() {
    var selectedItem = findItemById(state.selectedItemId);

    if (!selectedItem) {
      clearDetail();
      return;
    }

    if (detailEmpty) {
      detailEmpty.hidden = true;
    }

    if (detailCard) {
      detailCard.hidden = false;
    }

    if (detailId) {
      detailId.textContent = "Item #" + selectedItem.itemId;
    }

    if (detailName) {
      detailName.textContent = selectedItem.itemName;
    }

    if (detailPrice) {
      detailPrice.textContent = "$" + selectedItem.price;
    }

    if (detailDescription) {
      detailDescription.textContent = selectedItem.description;
    }

    if (detailSizes) {
      detailSizes.textContent = "Not available";
    }

    if (detailColors) {
      detailColors.textContent = "Not available";
    }

    if (detailStock) {
      detailStock.textContent = "Min: " + selectedItem.minStock + " | Max: " + selectedItem.maxStock;
    }
  }

  function clearDetail() {
    if (detailEmpty) {
      detailEmpty.hidden = false;
    }

    if (detailCard) {
      detailCard.hidden = true;
    }

    updateQueryString(input.value.trim(), null);
  }

  function findItemById(itemId) {
    if (itemId === null) {
      return null;
    }

    for (var index = 0; index < state.items.length; index += 1) {
      if (Number(state.items[index].itemId) === Number(itemId)) {
        return state.items[index];
      }
    }

    return null;
  }

  function clearMessages() {
    error.textContent = "";
    status.textContent = "";
  }

  function setLoadingState(isLoading) {
    form.classList.toggle("is-loading", isLoading);
    input.disabled = isLoading;
  }

  function updateQueryString(query, itemId) {
    var url = new URL(window.location.href);

    if (query) {
      url.searchParams.set("q", query);
    } else {
      url.searchParams.delete("q");
    }

    if (itemId) {
      url.searchParams.set("itemId", String(itemId));
    } else {
      url.searchParams.delete("itemId");
    }

    window.history.replaceState({}, "", url.toString());
  }

  function escapeHtml(text) {
    return String(text)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }
})();
