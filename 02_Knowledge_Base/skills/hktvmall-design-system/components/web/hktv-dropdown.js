/**
 * <hktv-dropdown title="Title" placeholder="Default Hint" value="" size="m" state="placeholder">
 * state: placeholder | focus | filled | disabled
 * Closed field only. Put icon-chevrondown-small-outlined in data-slot="chevron".
 */
(function () {
  const STATES = new Set(["placeholder", "focus", "filled", "disabled"]);
  const SIZES = new Set(["m", "s"]);

  class HKTVDropdown extends HTMLElement {
    static get observedAttributes() {
      return ["title", "value", "placeholder", "size", "state"];
    }

    connectedCallback() {
      if (!this._built) {
        this._built = true;
        this._label = document.createElement("span");
        this._label.className = "hktv-field__label hktv-body-1-regular";
        this._box = document.createElement("button");
        this._box.type = "button";
        this._box.className = "hktv-field__box";
        this._value = document.createElement("span");
        this._value.className = "hktv-field__value hktv-body-1-regular";
        this._chevron = document.createElement("span");
        this._chevron.className = "hktv-field__chevron";
        this._box.append(this._value, this._chevron);
        this.append(this._label, this._box);
      }
      this._sync();
    }

    attributeChangedCallback() {
      if (this._built) this._sync();
    }

    _sync() {
      const state = STATES.has(this.getAttribute("state")) ? this.getAttribute("state") : "placeholder";
      const size = SIZES.has(this.getAttribute("size")) ? this.getAttribute("size") : "m";
      this.dataset.state = state;
      this.dataset.size = size;
      const value = this.getAttribute("value") || "";
      const empty = value.length === 0 || state === "placeholder";
      this._label.textContent = this.getAttribute("title") || "Title";
      this._value.textContent = empty ? (this.getAttribute("placeholder") || "Default Hint") : value;
      this._value.classList.toggle("hktv-field__placeholder", empty);
      this._box.disabled = state === "disabled";
      const icon = this.querySelector('[data-slot="chevron"]');
      this._chevron.replaceChildren(icon || document.createTextNode("▾"));
    }
  }

  if (!customElements.get("hktv-dropdown")) customElements.define("hktv-dropdown", HKTVDropdown);
})();
