/**
 * <hktv-phone-field title="手機號碼" country="+852" value="" placeholder="手機號碼" size="m" state="placeholder">
 * state: placeholder | focus | typing | filled | error
 * Slots: data-slot="chevron", data-slot="clear"
 */
(function () {
  const STATES = new Set(["placeholder", "focus", "typing", "filled", "error"]);
  const SIZES = new Set(["m", "s"]);

  class HKTVPhoneField extends HTMLElement {
    static get observedAttributes() {
      return ["title", "country", "value", "placeholder", "size", "state", "message"];
    }

    connectedCallback() {
      if (!this._built) {
        this._built = true;
        this._label = document.createElement("span");
        this._label.className = "hktv-field__label hktv-body-1-regular";
        this._row = document.createElement("div");
        this._row.className = "hktv-phone__row";
        this._code = document.createElement("button");
        this._code.type = "button";
        this._code.className = "hktv-field__box hktv-phone__code";
        this._codeText = document.createElement("span");
        this._codeText.className = "hktv-field__value hktv-body-1-regular";
        this._chevron = document.createElement("span");
        this._chevron.className = "hktv-field__chevron";
        this._code.append(this._codeText, this._chevron);
        this._number = document.createElement("div");
        this._number.className = "hktv-field__box";
        this._value = document.createElement("span");
        this._value.className = "hktv-field__value hktv-body-1-regular";
        this._caret = document.createElement("span");
        this._caret.className = "hktv-field__caret";
        this._clear = document.createElement("span");
        this._clear.className = "hktv-field__icon";
        this._number.append(this._value, this._caret, this._clear);
        this._row.append(this._code, this._number);
        this._message = document.createElement("span");
        this._message.className = "hktv-field__message hktv-body-2-regular";
        const stack = document.createElement("div");
        stack.style.display = "flex";
        stack.style.flexDirection = "column";
        stack.style.gap = "var(--hktv-spacing-4)";
        stack.append(this._row, this._message);
        this.append(this._label, stack);
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
      const empty = value.length === 0;
      this._label.textContent = this.getAttribute("title") || "手機號碼";
      this._codeText.textContent = this.getAttribute("country") || "+852";
      this._value.textContent = empty ? (this.getAttribute("placeholder") || "手機號碼") : value;
      this._value.classList.toggle("hktv-field__placeholder", empty);
      this._caret.hidden = !(state === "focus" || state === "typing");
      const clear = this.querySelector('[data-slot="clear"]');
      this._clear.replaceChildren(clear || document.createTextNode(""));
      this._clear.hidden = state !== "error";
      const chevron = this.querySelector('[data-slot="chevron"]');
      this._chevron.replaceChildren(chevron || document.createTextNode("▾"));
      const message = this.getAttribute("message") || "";
      this._message.hidden = !(state === "error" && message);
      this._message.textContent = message;
    }
  }

  if (!customElements.get("hktv-phone-field")) customElements.define("hktv-phone-field", HKTVPhoneField);
})();
