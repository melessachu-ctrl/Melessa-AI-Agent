/**
 * HKTVmall Cart Button (Figma 7088:1450). Matches references/components/cart-button.md.
 *
 * <hktv-cart-button type="cart" size="l" style="rounded">
 *   <span data-slot="icon">…svg…</span>
 * </hktv-cart-button>
 *
 * type: cart | discount | cashback | notify | favourite
 * Outlined Cart Primary / Secondary are not supported.
 * type="cart" always renders rounded.
 */
(function () {
  const TYPES = new Set(["cart", "discount", "cashback", "notify", "favourite"]);
  const SIZES = new Set(["l", "s"]);
  const STYLES = new Set(["oval", "rounded"]);

  function normalize(value, allowed, fallback) {
    const v = (value || "").toLowerCase();
    return allowed.has(v) ? v : fallback;
  }

  class HKTVCartButton extends HTMLElement {
    static get observedAttributes() {
      return ["type", "size", "style"];
    }

    connectedCallback() {
      if (!this._built) {
        this._built = true;
        const icon = this.querySelector('[data-slot="icon"], [slot="icon"]');
        const button = document.createElement("button");
        button.type = "button";
        button.className = "hktv-cart-btn";
        button.setAttribute("part", "button");
        this._button = button;

        const iconWrap = document.createElement("span");
        iconWrap.className = "hktv-cart-btn__icon";
        if (icon) iconWrap.appendChild(icon);
        this._iconWrap = iconWrap;

        const label = document.createElement("span");
        label.className = "hktv-cart-btn__label hktv-caption-2-semibold";
        label.innerHTML = "<span>大手</span><span>折扣</span>";
        this._label = label;

        button.appendChild(iconWrap);
        button.appendChild(label);
        this.appendChild(button);
      }
      this._sync();
    }

    attributeChangedCallback() {
      if (this._built) this._sync();
    }

    _sync() {
      const type = normalize(this.getAttribute("type"), TYPES, "cart");
      const size = normalize(this.getAttribute("size"), SIZES, "l");
      const style = type === "cart" ? "rounded" : normalize(this.getAttribute("style"), STYLES, "rounded");
      this.dataset.type = type;
      this.dataset.size = size;
      this.dataset.style = style;
      const names = {
        cart: "加入購物車",
        discount: "大手折扣",
        cashback: "Cashback",
        notify: "到貨通知",
        favourite: "收藏",
      };
      this._button.setAttribute("aria-label", names[type]);
      const showLabel = type === "discount" && !this._iconWrap.firstChild;
      this._label.hidden = !showLabel;
      this._iconWrap.hidden = showLabel || !this._iconWrap.firstChild;
    }
  }

  if (!customElements.get("hktv-cart-button")) {
    customElements.define("hktv-cart-button", HKTVCartButton);
  }
})();
