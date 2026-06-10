import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "overlay"]

  open() {
    this.element.classList.add("drawer--open")
  }

  close() {
    this.element.classList.remove("drawer--open")
    this.panelTarget.querySelector("turbo-frame").innerHTML = ""
  }
}
