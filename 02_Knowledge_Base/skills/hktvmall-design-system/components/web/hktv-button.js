/**
 * HKTVmall Button (Figma 3135:812). Matches references/components/button.md.
 * Sync to GCP with hktv-button.css. Requires hktv-tokens.css typography classes.
 *
 * Usage:
 *   <hktv-button appearance="filled" shape="rounded" size="l" state="enable">加入購物車</hktv-button>
 * Optional slots: <span slot="start-icon">…</span> <span slot="end-icon">…</span>
 * (Light DOM: place icons as children with data-slot="start-icon"|"end-icon".)
 */
(function () {
  const APPEARANCES = new Set(["filled", "secondary", "outline", "text"]);
  const SHAPES = new Set(["rounded", "capsule"]);
  const SIZES = new Set(["l", "m", "s", "xs"]);
  const STATES = new Set(["enable", "disabled", "loading"]);

  function labelClass(appearance, size) {
    const large = size === "l" || size === "m";
    if (appearance === "text") {
      return large ? "hktv-body-1-regular" : "hktv-body-2-regular";
    }
    return large ? "hktv-title-semibold" : "hktv-body-2-semibold";
  }

  function normalize(value, allowed, fallback) {
    const v = (value || "").toLowerCase();
    return allowed.has(v) ? v : fallback;
  }

  class HKTVButton extends HTMLElement {
    static get observedAttributes() {
      return ["appearance", "shape", "size", "state", "disabled"];
    }

    connectedCallback() {
      if (this._built) {
        this._sync();
        return;
      }
      this._built = true;

      const startIcon = this.querySelector('[data-slot="start-icon"], [slot="start-icon"]');
      const endIcon = this.querySelector('[data-slot="end-icon"], [slot="end-icon"]');
      const labelNodes = Array.from(this.childNodes).filter(
        (n) =>
          n !== startIcon &&
          n !== endIcon &&
          !(n.nodeType === 1 && (n.getAttribute("data-slot") || n.getAttribute("slot")))
      );

      const button = document.createElement("button");
      button.type = "button";
      button.className = "hktv-btn";
      button.setAttribute("part", "button");

      if (startIcon) {
        const wrap = document.createElement("span");
        wrap.className = "hktv-btn__icon hktv-btn__icon--start";
        wrap.appendChild(startIcon);
        button.appendChild(wrap);
      }

      const label = document.createElement("span");
      label.className = "hktv-btn__label";
      labelNodes.forEach((n) => label.appendChild(n));
      if (!label.textContent.trim()) {
        label.textContent = "Button";
      }
      this._label = label;
      this._labelDefault = label.textContent;
      button.appendChild(label);

      if (endIcon) {
        const wrap = document.createElement("span");
        wrap.className = "hktv-btn__icon hktv-btn__icon--end";
        wrap.appendChild(endIcon);
        button.appendChild(wrap);
      }

      const spinner = document.createElement("span");
      spinner.className = "hktv-btn__spinner";
      spinner.hidden = true;
      spinner.setAttribute("aria-hidden", "true");
      this._spinner = spinner;
      button.appendChild(spinner);

      this.textContent = "";
      this.appendChild(button);
      this._button = button;
      this._sync();
    }

    attributeChangedCallback() {
      if (this._built) this._sync();
    }

    _sync() {
      const appearance = normalize(this.getAttribute("appearance"), APPEARANCES, "filled");
      const shape = normalize(this.getAttribute("shape"), SHAPES, "rounded");
      const size = normalize(this.getAttribute("size"), SIZES, "l");
      let state = normalize(this.getAttribute("state"), STATES, "enable");
      if (this.hasAttribute("disabled")) state = "disabled";

      this.setAttribute("appearance", appearance);
      this.setAttribute("shape", shape);
      this.setAttribute("size", size);
      this.setAttribute("state", state);

      if (!this._button || !this._label) return;

      this._label.className = "hktv-btn__label " + labelClass(appearance, size);
      const loading = state === "loading";
      const disabled = state === "disabled" || loading;
      this._button.disabled = disabled;
      this._spinner.hidden = !loading;
      this._label.hidden = loading;
      this._button.setAttribute("aria-busy", loading ? "true" : "false");
      if (loading) {
        this._button.setAttribute("aria-label", this._labelDefault || "Loading");
      } else {
        this._button.removeAttribute("aria-label");
      }
    }
  }

  if (!customElements.get("hktv-button")) {
    customElements.define("hktv-button", HKTVButton);
  }
})();
