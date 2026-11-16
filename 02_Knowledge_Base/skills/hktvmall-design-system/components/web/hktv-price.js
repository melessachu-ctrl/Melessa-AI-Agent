/**
 * HKTVmall listing price (Figma 7083:2002). Matches references/components/price.md.
 * Sync to GCP with hktv-price.css. Requires hktv-tokens.css.
 * PDP is a separate component and is not implemented here.
 *
 * Usage:
 *   <hktv-price kind="sp" size="l" amount="289" original="399"></hktv-price>
 *   <hktv-price kind="sp" amount="289" promotion="日本北海道空運到港"></hktv-price>
 * Optional: ka-label, unit-amount, unit-name, unit-average, unit-zh, not-for-sale-text
 * Badge slot: child with data-slot="badge"
 */
(function () {
  const KINDS = new Set([
    "rp",
    "sp",
    "vip",
    "gvip",
    "dvip",
    "ppp",
    "cashback",
    "greenlab",
    "publichousing",
    "notforsale",
  ]);
  const SIZES = new Set(["l", "s"]);

  function formatAmount(raw) {
    const n = Number(raw);
    if (!Number.isFinite(n)) return "";
    const negative = n < 0;
    const tenths = Math.round(Math.abs(n) * 10);
    const whole = Math.floor(tenths / 10);
    const fraction = tenths % 10;
    const grouped = String(whole).replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    return (negative ? "-" : "") + "$" + grouped + "." + fraction;
  }

  function formatUnit(amount, unit, average, chinese) {
    const money = formatAmount(amount);
    if (!money || !unit) return "";
    if (average) {
      return chinese ? "平均 " + money + "/" + unit : "Avg. " + money + "/" + unit;
    }
    return money + "/" + unit;
  }

  function normalizeKind(value) {
    const v = (value || "rp").toLowerCase().replace(/[_-]/g, "");
    if (v === "greenlab") return "greenlab";
    if (v === "publichousing") return "publichousing";
    if (v === "notforsale") return "notforsale";
    return KINDS.has(v) ? v : "rp";
  }

  class HKTVPrice extends HTMLElement {
    static get observedAttributes() {
      return [
        "kind",
        "size",
        "amount",
        "original",
        "promotion",
        "ka-label",
        "unit-amount",
        "unit-name",
        "unit-average",
        "unit-zh",
        "not-for-sale-text",
      ];
    }

    connectedCallback() {
      if (!this._root) {
        const badge = this.querySelector('[data-slot="badge"], [slot="badge"]');
        this._badge = badge;
        this.textContent = "";
        this._root = document.createElement("div");
        this._root.className = "hktv-price";
        this.appendChild(this._root);
      }
      this._render();
    }

    attributeChangedCallback() {
      if (this._root) this._render();
    }

    _render() {
      const kind = normalizeKind(this.getAttribute("kind"));
      const size = SIZES.has((this.getAttribute("size") || "l").toLowerCase())
        ? (this.getAttribute("size") || "l").toLowerCase()
        : "l";
      this.setAttribute("kind", kind);
      this.setAttribute("size", size);

      const root = this._root;
      root.textContent = "";

      const ka = (this.getAttribute("ka-label") || "").trim();
      if (ka) {
        const el = document.createElement("span");
        el.className = "hktv-price__ka hktv-body-3-semibold";
        el.textContent = ka;
        root.appendChild(el);
      }

      if (kind === "notforsale") {
        const el = document.createElement("span");
        el.className =
          "hktv-price__main hktv-price__main--notforsale " +
          (size === "l" ? "hktv-price-listing-main" : "hktv-price-listing-multi-col");
        el.textContent = (this.getAttribute("not-for-sale-text") || "").trim() || "Not for sale";
        root.appendChild(el);
        return;
      }

      const promotion = (this.getAttribute("promotion") || "").trim();
      const original = this.getAttribute("original");
      if (promotion) {
        const el = document.createElement("span");
        el.className = "hktv-price__promo hktv-body-3-regular";
        el.textContent = promotion;
        root.appendChild(el);
      } else if (original != null && original !== "") {
        const el = document.createElement("span");
        el.className = "hktv-price__original hktv-price-listing-rp";
        el.textContent = formatAmount(original);
        root.appendChild(el);
      }

      const row = document.createElement("div");
      row.className = "hktv-price__main-row";
      const main = document.createElement("span");
      main.className =
        "hktv-price__main hktv-price__main--" +
        kind +
        " " +
        (size === "l" ? "hktv-price-listing-main" : "hktv-price-listing-multi-col");
      main.textContent = formatAmount(this.getAttribute("amount"));
      row.appendChild(main);

      if (this._badge) {
        const badgeWrap = document.createElement("span");
        badgeWrap.className = "hktv-price__badge";
        badgeWrap.appendChild(this._badge);
        row.appendChild(badgeWrap);
      }
      root.appendChild(row);

      const unitAmount = this.getAttribute("unit-amount");
      const unitName = (this.getAttribute("unit-name") || "").trim();
      if (unitAmount != null && unitAmount !== "" && unitName) {
        const chinese = this.getAttribute("unit-zh") !== "false";
        const average =
          this.hasAttribute("unit-average") &&
          this.getAttribute("unit-average") !== "false";
        const el = document.createElement("span");
        el.className = "hktv-price__unit hktv-body-3-regular";
        el.textContent = formatUnit(unitAmount, unitName, average, chinese);
        root.appendChild(el);
      }
    }
  }

  if (!customElements.get("hktv-price")) {
    customElements.define("hktv-price", HKTVPrice);
  }
})();
