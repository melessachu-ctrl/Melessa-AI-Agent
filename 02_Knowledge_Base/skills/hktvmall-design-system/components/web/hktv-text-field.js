/**
 * <hktv-text-field title="Title" placeholder="Default Hint" value="" size="m" state="placeholder">
 * Optional: prefix="$" secure message="錯誤"
 * Icon slot: <span data-slot="clear"> or data-slot="secure"
 * state: placeholder | focus | typing | filled | error | error-typing | disabled
 */
(function () {
  const STATES = new Set(["placeholder", "focus", "typing", "filled", "error", "error-typing", "disabled"]);
  const SIZES = new Set(["m", "s"]);

  class HKTVTextField extends HTMLElement {
    static get observedAttributes() {
      return ["title", "value", "placeholder", "size", "state", "message", "prefix", "secure"];
    }

    connectedCallback() {
      if (!this._built) {
        this._built = true;
        this._label = document.createElement("span");
        this._label.className = "hktv-field__label hktv-body-1-regular";
        this._box = document.createElement("div");
        this._box.className = "hktv-field__box";
        this._prefix = document.createElement("span");
        this._prefix.className = "hktv-body-1-regular";
        this._value = document.createElement("span");
        this._value.className = "hktv-field__value hktv-body-1-regular";
        this._caret = document.createElement("span");
        this._caret.className = "hktv-field__caret";
        this._secure = document.createElement("span");
        this._secure.className = "hktv-field__icon";
        this._clear = document.createElement("span");
        this._clear.className = "hktv-field__icon";
        this._message = document.createElement("span");
        this._message.className = "hktv-field__message hktv-body-2-regular";
        this._box.append(this._prefix, this._value, this._caret, this._secure, this._clear);
        const stack = document.createElement("div");
        stack.style.display = "flex";
        stack.style.flexDirection = "column";
        stack.style.gap = "var(--hktv-spacing-4)";
        stack.append(this._box, this._message);
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
      const placeholder = this.getAttribute("placeholder") || "Default Hint";
      this._label.textContent = this.getAttribute("title") || "Title";
      const empty = value.length === 0;
      this._value.textContent = empty ? placeholder : value;
      this._value.classList.toggle("hktv-field__placeholder", empty);
      const prefix = this.getAttribute("prefix");
      this._prefix.hidden = !prefix;
      this._prefix.textContent = prefix || "";
      this._caret.hidden = !(state === "focus" || state === "typing" || state === "error-typing");
      this._secure.hidden = this.getAttribute("secure") == null;
      const slottedClear = this.querySelector('[data-slot="clear"]');
      this._clear.replaceChildren(slottedClear || document.createTextNode(""));
      this._clear.hidden = !(state === "error" || state === "error-typing");
      const slottedSecure = this.querySelector('[data-slot="secure"]');
      if (slottedSecure) this._secure.replaceChildren(slottedSecure);
      const message = this.getAttribute("message") || "";
      this._message.hidden = !((state === "error" || state === "error-typing") && message);
      this._message.textContent = message;
    }
  }

  if (!customElements.get("hktv-text-field")) customElements.define("hktv-text-field", HKTVTextField);
})();
